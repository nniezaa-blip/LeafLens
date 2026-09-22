<#

.SYNOPSIS

    LeafLens — Project Setup Script (Windows)

.DESCRIPTION

    Installs Scoop, mise, project toolchain, Android SDK extras, creates an

    emulator, and adds adb/emulator to PATH in the PowerShell profile.

    Idempotent — safe to run multiple times.

.NOTES

    Requires PowerShell 5.1+ (pwsh preferred). Run in a non-admin terminal.

#>



$ErrorActionPreference = 'Stop'

$ProgressPreference = 'SilentlyContinue'

# mise (and other tools it shells out to) write UTF-8 output, including a ✓
# checkmark on success. Without this, Windows PowerShell decodes/renders that
# through the legacy console codepage and shows mojibake ("Γ£ô") instead.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null



# ── Config ──────────────────────────────────────────────────────────────────

$AvdName = 'pixel_8'

# Emulator guest image. x64 hosts run the x86_64 image with hardware
# acceleration; ARM64 hosts get arm64-v8a (Assert-ArchCompatible overrides
# this). Read via Get-SdkPackages so install sees the post-detection value.
$script:AvdTarget = 'system-images;android-36;google_apis;x86_64'

function Get-SdkPackages {

    @(

        'platform-tools'

        'emulator'

        $script:AvdTarget

        'build-tools;36.1.0'

        'platforms;android-36'

    )

}

$MiseData = if ($env:MISE_DATA) { $env:MISE_DATA } else { "$env:LOCALAPPDATA\mise" }



function Write-Info  { Write-Host "[INFO]  $args" -ForegroundColor Cyan }

function Write-Ok    { Write-Host "[OK]    $args" -ForegroundColor Green }

function Write-Warn  { Write-Host "[WARN]  $args" -ForegroundColor Yellow }

function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }

# Render redirected native stderr (2>&1) as plain text. On both PowerShell 5.1
# and 7.x, 2>&1 wraps each stderr line in an ErrorRecord; stringifying a bare
# line can surface "System.Management.Automation.RemoteException" placeholders,
# so pull Exception.Message instead and keep stdout lines as strings.
function Get-NativeText {

    process {

        if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { [string]$_ }

    }

}

function Write-LogLine { process { Write-Host "  $_" } }



# ── Admin guard ─────────────────────────────────────────────────────────────

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($IsAdmin) {

    Write-Warn "Running as Administrator — Scoop works better without elevation."

    Write-Warn "Run as a standard user, then re-run."

    exit 1

}



# ── Check Unix tools (mv/rm) needed by mise ─────────────────────────────────

function Assert-UnixTools {

    # Try to find mv anywhere

    $mvFound = Get-Command mv.exe -ErrorAction SilentlyContinue -CommandType Application

    if ($mvFound) { return }



    # Not found — try Git's usr/bin at common locations

    $gitPaths = @(

        'C:\Program Files\Git\usr\bin',

        'C:\Program Files (x86)\Git\usr\bin',

        "$env:LOCALAPPDATA\Programs\Git\usr\bin",

        "$env:USERPROFILE\scoop\apps\git\current\usr\bin"

    )



    foreach ($gp in $gitPaths) {

        if (Test-Path "$gp\mv.exe") {

            $env:Path = "$gp;$env:Path"

            Write-Ok "Unix tools found at: $gp"

            return

        }

    }



    # Nothing found — install busybox via Scoop (most reliable)

    Write-Warn "Unix tools (mv/rm) not found — installing busybox via Scoop..."



    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {

        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

        Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

    }



    # busybox in main bucket provides all Unix commands

    scoop install busybox *>&1 | Out-Null



    # Activate busybox shims

    $busyboxShim = "$env:USERPROFILE\scoop\shims"

    if (Test-Path "$busyboxShim\mv.exe") {

        $env:Path = "$busyboxShim;$env:Path"

        Write-Ok "busybox installed — mv/rm now available"

        return

    }



    Write-Error "Unix tools still not found after trying Git paths and busybox."

    Write-Error "Install Git for Windows (with 'Unix tools' option) or run: scoop install busybox"

    Write-Error "Then re-run this script."

    exit 1

}



# ── Read pinned android-sdk version from .mise.toml ──────────────────────────

# mise's global install cache ($MiseData) is shared across every project on

# the machine, so a dev who's touched another Flutter/Android project can end

# up with multiple android-sdk versions cached. Always read the version this

# project actually pins rather than guessing from whatever is on disk (a plain

# string sort of directory names, e.g., puts "9.0" ahead of "20.0").

function Get-AndroidSdkVersion {

    $version = @(Get-Content '.mise.toml' | Select-String 'android-sdk' | ForEach-Object { $_ -replace '.*"([^"]+)".*', '$1' })[0]

    if (-not $version) {

        Write-Error "Could not find android-sdk version in .mise.toml"

        exit 1

    }

    return $version

}

function Get-JavaVersion {

    $version = @(Get-Content '.mise.toml' | Select-String '^\s*java\s*=' | ForEach-Object { $_ -replace '.*"([^"]+)".*', '$1' })[0]

    if (-not $version) {

        Write-Error "Could not find java version in .mise.toml"

        exit 1

    }

    return $version

}



# ── Resolve ANDROID_HOME from mise install ───────────────────────────────────

function Resolve-AndroidHome {

    param([string]$Version)

    # vfox's android-sdk plugin expands a major-only pin like "20" to a

    # concrete "20.0" install dir. Check both forms.

    foreach ($candidate in @($Version, "$Version.0")) {

        $dir = Join-Path "$MiseData\installs\android-sdk" $candidate

        if (Test-Path $dir -PathType Container) {

            return $dir

        }

    }

    Write-Error "Android SDK version $Version (from .mise.toml) not found under $MiseData\installs\android-sdk\"

    Write-Error "This means mise install failed for android-sdk. Check the errors above."

    exit 1

}



# ── Shim adb/fastboot/emulator into %USERPROFILE%\.local\bin ────────────────

# If the user has `mise activate pwsh` in their profile (mise's standard

# recommended setup, same as this project's own .zshrc), mise rebuilds PATH

# from scratch on every prompt and prunes anything under its own install dir

# that it doesn't itself manage — platform-tools/emulator, installed

# separately via sdkmanager, aren't recognized "tool" bin dirs. Adding those

# paths directly to the profile gets silently stripped moments later.

# Windows symlinks need Developer Mode/admin, so use thin .cmd wrapper shims

# in a directory outside mise's install tree instead — immune to the pruning.

function New-SdkShims {

    param([string]$AndroidHome)



    $shimDir = "$env:USERPROFILE\.local\bin"

    if (-not (Test-Path $shimDir)) {

        New-Item -ItemType Directory -Path $shimDir -Force | Out-Null

    }



    $targets = @(

        "$AndroidHome\platform-tools\adb.exe"

        "$AndroidHome\platform-tools\fastboot.exe"

        "$AndroidHome\emulator\emulator.exe"

    )



    foreach ($target in $targets) {

        if (Test-Path $target -PathType Leaf) {

            $name = [System.IO.Path]::GetFileNameWithoutExtension($target)

            $shimPath = "$shimDir\$name.cmd"

            Set-Content -Path $shimPath -Value "@echo off`r`n`"$target`" %*" -Encoding ASCII

            Write-Ok "Shimmed $shimPath -> $target"

        }

    }

}



# ── Ensure %USERPROFILE%\.local\bin is on PATH ───────────────────────────────

# This one entry is safe to persist in the profile: it lives outside mise's

# install tree, so mise's activate hook never prunes it.

function Ensure-LocalBinOnPath {

    $shimDir = "$env:USERPROFILE\.local\bin"

    $line = "`$env:Path = `"$shimDir;`$env:Path`""



    $profilePath = $PROFILE.CurrentUserAllHosts

    $profileDir = Split-Path $profilePath -Parent



    if (-not (Test-Path $profileDir)) {

        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

    }

    if (-not (Test-Path $profilePath -PathType Leaf)) {

        New-Item -ItemType File -Path $profilePath -Force | Out-Null

    }



    $existing = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

    $header = "# Added by LeafLens setup script"



    if ($existing -match [Regex]::Escape($line)) {

        Write-Ok "Already in profile: $line"

    } else {

        Add-Content -Path $profilePath -Value "`n$header`n$line"

        Write-Info "Added to $profilePath`: $line"

    }

}



# ── Ensure mise is activated in the shell profile ────────────────────────────

# mise-managed tools (flutter, java, gradle, pnpm, ...) are only on PATH when
# mise's activate hook runs at shell startup. The hook emits pure PowerShell,
# parses on both 5.1 and 7.x (it just warns about chpwd on 5.1 — suppressed
# via MISE_PWSH_CHPWD_WARNING), and puts $MISE_DATA\shims on PATH so every
# tool resolves in new terminals.

function Ensure-MiseActivation {

    $activate = @(

        '# LeafLens: mise activation (flutter/java/gradle/pnpm on PATH)'

        'if (Get-Command mise -ErrorAction SilentlyContinue) {'

        "    `$env:MISE_PWSH_CHPWD_WARNING = '0'"

        '    Invoke-Expression ((& mise activate pwsh) -join [Environment]::NewLine)'

        '}'

    ) -join "`n"



    $profileBase = Split-Path (Split-Path $PROFILE.CurrentUserAllHosts -Parent) -Parent

    $profilePaths = @(

        "$profileBase\WindowsPowerShell\profile.ps1"

        "$profileBase\PowerShell\profile.ps1"

    ) | Select-Object -Unique

    $marker = 'LeafLens: mise activation'



    foreach ($profilePath in $profilePaths) {



        $profileDir = Split-Path $profilePath -Parent

        if (-not (Test-Path $profileDir)) {

            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null

        }

        if (-not (Test-Path $profilePath -PathType Leaf)) {

            New-Item -ItemType File -Path $profilePath -Force | Out-Null

        }

        $existing = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

        if ($existing -match [Regex]::Escape($marker)) {

            Write-Ok "mise activation already in $profilePath"

        } else {

            Add-Content -Path $profilePath -Value "`n$activate`n"

            Write-Info "Added mise activation to $profilePath"

        }

    }

}



# ── Check architecture compatibility ────────────────────────────────────────

$script:IsArm64 = $false

function Assert-ArchCompatible {

    $arch = (Get-CimInstance Win32_Processor | Select-Object -First 1).Architecture

    # 0 = x86, 5 = ARM, 9 = x64 (AMD64), 12 = ARM64

    if ($arch -ne 12) { return }  # Not ARM64, no issue

    $script:IsArm64 = $true

    $script:AvdTarget = 'system-images;android-36;google_apis;arm64-v8a'

    Write-Warn "Windows ARM64 detected — Flutter 3.44.0 has no windows-arm64 build. Skipping Flutter (install it manually)."

}

function Install-ScoopIfMissing {

    if (Get-Command scoop -ErrorAction SilentlyContinue) {

        Write-Ok "Scoop already installed"

        return

    }

    Write-Info "Scoop not found — installing..."

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {

        Write-Error "Scoop installation failed."

        exit 1

    }

    Write-Ok "Scoop installed"

}



# ── mise ────────────────────────────────────────────────────────────────────

function Install-Mise {

    if (Get-Command mise -ErrorAction SilentlyContinue) {

        Write-Ok "mise already installed ($(mise --version))"

        return

    }

    Write-Info "Installing mise via Scoop..."

    scoop install mise *>&1 | ForEach-Object { Write-Host "  $_" }

    if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {

        Write-Error "mise installation failed."

        exit 1

    }

    Write-Ok "mise installed ($(mise --version))"

}



# ── Find project root ───────────────────────────────────────────────────────

function Find-ProjectRoot {

    $dir = (Get-Location).Path

    while ($dir) {

        if (Test-Path (Join-Path $dir '.mise.toml') -PathType Leaf) {

            return $dir

        }

        $parent = Split-Path $dir -Parent

        if ($parent -eq $dir) {

            break

        }

        $dir = $parent

    }

    Write-Error "No .mise.toml found from $((Get-Location).Path) upward."

    exit 1

}



# ── mise trust + install with progress ──────────────────────────────────────

function Install-MiseTools {

    param([string]$ProjectRoot)

    Set-Location $ProjectRoot



    Write-Info "Trusting mise config..."

    $prevEap = $ErrorActionPreference

    $ErrorActionPreference = 'Continue'

    mise trust *>$null

    $ErrorActionPreference = $prevEap


    if ($script:IsArm64) {
        $env:MISE_DISABLE_TOOLS = "flutter"
        # openjdk.org (mise's default shorthand vendor) publishes no windows-arm64
        # build for any Java version. Microsoft's OpenJDK build does.
        $env:MISE_JAVA_SHORTHAND_VENDOR = "microsoft"
    }

    Write-Info "Installing project toolchain via mise..."
    Write-Info "(this downloads Flutter, Android SDK, Java, Gradle, pnpm — may take a while)..."

    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    mise install 2>&1 | ForEach-Object { Write-Host "  $_" }
    $ErrorActionPreference = $prevEap

    if ($LASTEXITCODE -ne 0) {
        Write-Error "mise install failed (exit code $LASTEXITCODE). Check the output above for errors."
        exit 1
    }



    # Verify key tools were installed

    $androidSdkDir = Get-ChildItem "$MiseData\installs\android-sdk" -Directory -ErrorAction SilentlyContinue



    if (-not $androidSdkDir) {

        Write-Error "android-sdk failed to install. Check the mise output above for errors."

        Write-Error "Common cause: missing Unix tools (mv/rm) on Windows."

        exit 1

    }

    if (-not $script:IsArm64) {

        $flutterDir = Get-ChildItem "$MiseData\installs\flutter" -Directory -ErrorAction SilentlyContinue

        if (-not $flutterDir) {

            Write-Error "flutter failed to install. Check the mise output above."

            exit 1

        }

    }



    Write-Ok "mise tools installed"

}



# ── SDK extras ──────────────────────────────────────────────────────────────

function Install-SdkExtras {

    if (-not (Get-Command sdkmanager -ErrorAction SilentlyContinue)) {

        Write-Error "sdkmanager not in PATH after mise install."

        exit 1

    }



    # sdkmanager is a batch-launched Java console app that always prints a
    # warning ("A restricted method in java.lang.System has been called") to
    # stderr. With $ErrorActionPreference='Stop', those stderr lines become
    # NativeCommandError records and kill the script, so every sdkmanager /
    # avdmanager call below runs under 'Continue' and stderr is flattened to
    # plain text instead of ErrorRecord objects.

    $prevEap = $ErrorActionPreference

    $ErrorActionPreference = 'Continue'

    Write-Info "Accepting SDK licenses..."

    # A plain PowerShell pipe into sdkmanager.bat (a batch-file-launched Java
    # console app) silently drops everything past the first line of stdin —
    # only the first license ever gets accepted. Routing through cmd's native
    # file-based `<` redirection delivers every line reliably.
    $licenseAnswers = Join-Path $env:TEMP 'leaflens_sdk_license_answers.txt'
    (1..20 | ForEach-Object { 'y' }) -join "`n" | Set-Content -Path $licenseAnswers -Encoding ascii -NoNewline

    cmd /c "sdkmanager --licenses < `"$licenseAnswers`"" *>$null

    Remove-Item -Path $licenseAnswers -ErrorAction SilentlyContinue



    $packagesToInstall = Get-SdkPackages

    if ($script:IsArm64) {
        # Google has never published a windows-arm64 emulator binary (verified
        # against the official repository2-3.xml: linux/x64, macosx/x64,
        # macosx/aarch64, windows/x64 only — no windows/aarch64). Installing
        # the emulator package or its arm64 system image is pointless here.
        $packagesToInstall = $packagesToInstall | Where-Object { $_ -ne 'emulator' -and $_ -ne $script:AvdTarget }
    }

    # The on-device x86_64 image (and the emulator itself) needs an
    # acceleration backend on Windows. No WHPX/Hyper-V → install Google's
    # AEHD (Android Emulator Hypervisor Driver) package via sdkmanager.
    if (-not $script:IsArm64) {

        $packagesToInstall += 'extras;google;Android_Emulator_Hypervisor_Driver'

    }

    foreach ($pkg in $packagesToInstall) {

        $installed = (sdkmanager --list 2>&1 | Get-NativeText) -join "`n"

        if ($installed -match "^\s*$pkg\s+.*Installed") {

            Write-Ok "SDK package already installed: $pkg"

            continue

        }

        Write-Info "Installing SDK package: $pkg..."

        sdkmanager $pkg 2>&1 | Get-NativeText | Write-LogLine

        Write-Ok "Installed: $pkg"

    }

    Install-EmulatorHypervisorDriver

    $ErrorActionPreference = $prevEap

}



# ── Emulator hypervisor driver ───────────────────────────────────────────────

function Install-EmulatorHypervisorDriver {

    # No emulator at all on Windows ARM64 — nothing to accelerate.
    if ($script:IsArm64) { return }

    try {

        # HypervisorPresent true → Hyper-V / WHPX is active; the emulator will
        # use it directly and installing AEHD would conflict with it.
        if ((Get-CimInstance Win32_ComputerSystem -ErrorAction Stop).HypervisorPresent) {

            Write-Ok "Hypervisor present (Hyper-V / WHPX) — no emulator hypervisor driver needed"

            return

        }

    } catch {

        Write-Warn "Could not detect hypervisor status: $_"

    }

    try {

        $svc = Get-Service -Name 'aEhSvc' -ErrorAction SilentlyContinue

        if ($svc -and $svc.Status -eq 'Running') {

            Write-Ok "Android Emulator Hypervisor Driver already running (aEhSvc)"

            return

        }

    } catch {

        Write-Warn "Could not query hypervisor driver service: $_"

    }

    $drvBat = Join-Path $env:ANDROID_HOME 'extras\google\Android_Emulator_Hypervisor_Driver\silent_install.bat'

    if (-not (Test-Path "$drvBat" -PathType Leaf)) {

        Write-Warn "Emulator hypervisor driver not found under ANDROID_HOME — the emulator will require manual acceleration setup"

        return

    }

    Write-Info "Installing Android Emulator Hypervisor Driver (a UAC prompt will appear)..."

    try {

        $p = Start-Process -FilePath $drvBat -Verb RunAs -Wait -PassThru

        $svc = Get-Service -Name 'aEhSvc' -ErrorAction SilentlyContinue

        if ($svc -and $svc.Status -eq 'Running') {

            Write-Ok "Android Emulator Hypervisor Driver installed and running"

        } else {

            Write-Warn "Driver install exited with code $($p.ExitCode) but the service is not running. Run as admin manually: $drvBat"

        }

    } catch {

        Write-Warn "Elevated driver install was cancelled or failed: $($_.Exception.Message)"

    }

}



# ── AVD ────────────────────────────────────────────────────────────────────

function Create-Avd {

    if (-not (Get-Command avdmanager -ErrorAction SilentlyContinue)) {

        Write-Error "avdmanager not in PATH"

        exit 1

    }

    $prevEap = $ErrorActionPreference

    $ErrorActionPreference = 'Continue'

    $avdList = (avdmanager list avd -c 2>&1 | Get-NativeText) -join "`n"

    if ($avdList -match "^${AvdName}$") {

        Write-Ok "AVD '${AvdName}' already exists"

        $ErrorActionPreference = $prevEap

        return

    }

    Write-Info "Creating AVD '${AvdName}' (requires system-images;android-36)..."

    'no' | avdmanager create avd -n $AvdName -k $script:AvdTarget -d pixel_8 -f 2>&1 | Get-NativeText | Write-LogLine

    Write-Ok "AVD '${AvdName}' created"

    $ErrorActionPreference = $prevEap

}



# ── Verify final state ──────────────────────────────────────────────────────

function Verify-Setup {

    $ok = $true

    $prevEap = $ErrorActionPreference

    $ErrorActionPreference = 'Continue'



    if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {

        Write-Warn "adb not in PATH. Run the script again or restart your terminal."

        $ok = $false

    }



    if (-not $script:IsArm64) {

        $avdCheck = (avdmanager list avd -c 2>&1 | Get-NativeText) -join "`n"

        if ($avdCheck -notmatch "^${AvdName}$") {

            Write-Warn "AVD '${AvdName}' not found. It may not have been created."

            $ok = $false

        }

    }



    if ($ok) {

        Write-Ok "All checks passed."

    }

    $ErrorActionPreference = $prevEap

}



# ── Run ─────────────────────────────────────────────────────────────────────

function Main {

    Clear-Host

    Write-Host "╔══════════════════════════════════════════════════╗" -ForegroundColor Green

    Write-Host "║        LeafLens — Environment Setup              ║" -ForegroundColor Green

    Write-Host "╚══════════════════════════════════════════════════╝" -ForegroundColor Green

    Write-Host ""



    Assert-UnixTools

    Assert-ArchCompatible

    Install-ScoopIfMissing

Install-Mise

    Ensure-MiseActivation



    $projectRoot = Find-ProjectRoot

    Write-Info "Project root: $projectRoot"



    Install-MiseTools -ProjectRoot $projectRoot



    $javaVersion = Get-JavaVersion

    $javaHome = "$MiseData\installs\java\$javaVersion"

    if (-not (Test-Path "$javaHome\bin\java.exe" -PathType Leaf)) {
        Write-Error "java.exe not found under $javaHome. Check the mise output above for errors."
        exit 1
    }

    $env:JAVA_HOME = $javaHome

    $env:Path = "$javaHome\bin;$env:Path"

    [Environment]::SetEnvironmentVariable('JAVA_HOME', $javaHome, 'User')

    Write-Ok "JAVA_HOME=$env:JAVA_HOME (persisted for new terminals)"



    $androidSdkVersion = Get-AndroidSdkVersion

    $env:ANDROID_HOME = Resolve-AndroidHome -Version $androidSdkVersion

    $env:ANDROID_SDK_ROOT = $env:ANDROID_HOME

    [Environment]::SetEnvironmentVariable('ANDROID_HOME', $env:ANDROID_HOME, 'User')

    [Environment]::SetEnvironmentVariable('ANDROID_SDK_ROOT', $env:ANDROID_HOME, 'User')

    Write-Ok "ANDROID_HOME=$env:ANDROID_HOME (persisted for new terminals)"

    $cmdlineToolsBin = Get-ChildItem "$env:ANDROID_HOME\cmdline-tools" -Directory -ErrorAction SilentlyContinue |
        ForEach-Object { Join-Path $_.FullName 'bin' } |
        Where-Object { Test-Path $_ -PathType Container } |
        Select-Object -First 1

    if (-not $cmdlineToolsBin) {
        Write-Error "cmdline-tools bin directory not found under $env:ANDROID_HOME\cmdline-tools"
        exit 1
    }

    $env:Path = "$cmdlineToolsBin;$env:Path"



    Install-SdkExtras

    if ($script:IsArm64) {
        Write-Warn "Emulator/AVD skipped (no windows-arm64 emulator build exists). Use a physical device over adb instead."
    } else {
        Create-Avd
    }



    New-SdkShims -AndroidHome $env:ANDROID_HOME

    Ensure-LocalBinOnPath

    Verify-Setup



    Write-Host ""

    Write-Ok "All done."

    Write-Host "Restart your terminal or run: . `$PROFILE"

    if ($script:IsArm64) {

        Write-Host "Then:  adb devices  (connect a physical device — no emulator on windows-arm64)"

    } else {

        Write-Host "Then:  emulator -avd $AvdName"

        Write-Host "       adb devices"

    }

    if ($script:IsArm64) {

        Write-Warn "Flutter was skipped (no windows-arm64 build) — install it manually."

    }

    Write-Host ""

}



Main

