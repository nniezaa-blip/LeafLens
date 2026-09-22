#!/usr/bin/env bash
# =============================================================================
# LeafLens — Project Setup Script (Linux / macOS / Windows Git Bash)
# =============================================================================
# Installs mise, project toolchain, Android SDK extras, creates an emulator,
# and adds adb/emulator to PATH in the appropriate shell RC file.
# Idempotent — safe to run multiple times.
# =============================================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
AVD_NAME="pixel_8"
# Emulator guest image. x64 hosts run x86_64 with hardware acceleration;
# IS_ARM64 detection below overrides this to arm64-v8a on ARM64 hosts.
AVD_TARGET="system-images;android-36;google_apis;x86_64"
SDK_PACKAGES() {
  echo "platform-tools"
  if [[ "$IS_WINDOWS" == "true" && "$IS_ARM64" != "true" ]]; then
    # x86_64 emulation needs an acceleration backend on Windows; WHPX often
    # isn't enabled, so also fetch Google's AEHD driver package.
    echo "extras;google;Android_Emulator_Hypervisor_Driver"
  fi
  echo "emulator"
  echo "${AVD_TARGET}"
  echo "build-tools;36.1.0"
  echo "platforms;android-36"
}

# ── Colors ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
log_info()  { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# ── Platform detection ──────────────────────────────────────────────────────
OS="$(uname -s)"
IS_WINDOWS=false
IS_ARM64=false
case "$OS" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=true ;;
esac
if [[ "$(uname -m)" == "aarch64" || "$(uname -m)" == "arm64" ]]; then
  IS_ARM64=true
  # ARM64 hosts can't accelerate x86_64 guest images — use the native arm64-v8a image.
  AVD_TARGET="system-images;android-36;google_apis;arm64-v8a"
fi

if [[ "$OS" != "Linux" && "$OS" != "Darwin" && "$IS_WINDOWS" != "true" ]]; then
  log_error "Unsupported OS: $OS."
  exit 1
fi

# ── Mise data directory ────────────────────────────────────────────────────
if [[ "$IS_WINDOWS" == "true" ]]; then
  DEFAULT_MISE_DATA="${LOCALAPPDATA}/mise"
  DEFAULT_MISE_DATA="${DEFAULT_MISE_DATA//\\/\/}"
else
  DEFAULT_MISE_DATA="$HOME/.local/share/mise"
fi
MISE_DATA="${MISE_DATA:-$DEFAULT_MISE_DATA}"

# ── Read pinned android-sdk version from .mise.toml ────────────────────────
# mise's global install cache ($MISE_DATA) is shared across every project on
# the machine, so a dev who's touched another Flutter/Android project can end
# up with multiple android-sdk versions cached. Always read the version this
# project actually pins rather than guessing from whatever is on disk.
android_sdk_version() {
  local v
  v="$(grep -E '^[[:space:]]*android-sdk[[:space:]]*=' "$PROJECT_ROOT/.mise.toml" | sed -E 's/.*"([^"]+)".*/\1/')"
  if [[ -z "$v" ]]; then
    log_error "Could not find android-sdk version in $PROJECT_ROOT/.mise.toml"
    exit 1
  fi
  echo "$v"
}

# ── Resolve ANDROID_HOME from mise install ──────────────────────────────────
resolve_android_home() {
  local version="$1" dir
  # vfox's android-sdk plugin expands a major-only pin like "20" to a
  # concrete "20.0" install dir (with a "20" symlink alongside it). The
  # windows-arm64 manual-install path below only ever creates the expanded
  # "20.0" form, so check both.
  for dir in "$MISE_DATA/installs/android-sdk/$version" "$MISE_DATA/installs/android-sdk/$version.0"; do
    if [[ -d "$dir" ]]; then
      echo "$dir"
      return 0
    fi
  done
  log_error "Android SDK version $version (from .mise.toml) not found under $MISE_DATA/installs/android-sdk/"
  log_error "Run 'mise install' first."
  return 1
}

# ── Symlink adb/emulator/fastboot into ~/.local/bin ─────────────────────────
# mise's `activate` hook rebuilds PATH from scratch on every prompt, pruning
# anything under its own install dir that it doesn't itself manage (only
# cmdline-tools is a recognized "tool" bin dir — platform-tools and emulator,
# installed separately via sdkmanager, are not). Adding those paths directly
# to a shell rc file gets silently stripped moments later by that hook.
# Symlinking into ~/.local/bin (outside mise's install tree, so immune to the
# pruning) survives it.
link_sdk_binaries() {
  local android_home="$1" target_dir="$HOME/.local/bin"
  mkdir -p "$target_dir"
  local bin
  for bin in "$android_home/platform-tools/adb" "$android_home/platform-tools/fastboot" "$android_home/emulator/emulator"; do
    if [[ -x "$bin" ]]; then
      ln -sf "$bin" "$target_dir/$(basename "$bin")"
      log_ok "Linked ${target_dir}/$(basename "$bin") -> ${bin}"
    fi
  done
}

# ── Detect shell RC file ────────────────────────────────────────────────────
detect_rc() {
  if [[ "$IS_WINDOWS" == "true" ]]; then
    echo "$HOME/.bashrc"
    return
  fi
  case "${SHELL##*/}" in
    zsh)  echo "$HOME/.zshrc" ;;
    bash)
      if [[ "$OS" == "Darwin" ]]; then echo "$HOME/.bash_profile"
      else echo "$HOME/.bashrc"; fi ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *)    echo "$HOME/.profile" ;;
  esac
}

# ── Ensure ~/.local/bin is on PATH ──────────────────────────────────────────
# This one entry is safe to persist in the rc file: it lives outside mise's
# install tree, so mise's activate hook never prunes it.
ensure_local_bin_on_path() {
  local rc_file="$1"
  local entry='export PATH="$HOME/.local/bin:$PATH"'
  touch "$rc_file"
  if ! grep -Fxq "$entry" "$rc_file" 2>/dev/null; then
    echo "" >> "$rc_file"
    echo "# Added by LeafLens setup script" >> "$rc_file"
    echo "$entry" >> "$rc_file"
    log_info "Added to ${rc_file}: ${entry}"
  else
    log_ok "Already in ${rc_file}: ${entry}"
  fi
}

# ── Install mise if missing ─────────────────────────────────────────────────
install_mise() {
  if command -v mise &>/dev/null; then
    log_ok "mise ready ($(mise --version))"
    return
  fi

  log_info "mise not found — installing..."

  if [[ "$IS_WINDOWS" == "true" ]] && command -v scoop &>/dev/null; then
    scoop install mise
  elif [[ "$OS" == "Darwin" ]] && command -v brew &>/dev/null; then
    brew install mise
  else
    curl -fsSL https://mise.run | sh
  fi

  for dir in "$MISE_DATA/bin" "$HOME/.local/bin"; do
    if [[ -x "$dir/mise" ]]; then export PATH="$dir:$PATH"; break; fi
  done

  if ! command -v mise &>/dev/null; then
    log_error "mise installation failed."
    exit 1
  fi

  eval "$(mise activate bash 2>/dev/null)" || true
  if [[ -d "$MISE_DATA/shims" ]]; then
    export PATH="$MISE_DATA/shims:$PATH"
  fi

  log_ok "mise installed ($(mise --version))"
}

# ── Find project root ───────────────────────────────────────────────────────
find_project_root() {
  local dir="$1"
  while [[ "$dir" != "" && "$dir" != "/" ]]; do
    if [[ -f "$dir/.mise.toml" ]]; then echo "$dir"; return 0; fi
    dir="$(dirname "$dir")"
  done
  log_error "No .mise.toml found from $(pwd) upward."
  exit 1
}

# ── mise trust + install ────────────────────────────────────────────────────
install_mise_tools() {
  cd "$1"
  mise trust 2>/dev/null || true
  log_info "Installing project toolchain via mise..."

  # Flutter has no windows-arm64 build. Skip it for this run only (env var,
  # not .mise.toml) so x64/Linux/macOS contributors are unaffected.
  if [[ "$IS_WINDOWS" == "true" && "$IS_ARM64" == "true" ]]; then
    export MISE_DISABLE_TOOLS=flutter
    log_warn "Windows ARM64 detected — skipping Flutter (no arm64 build). Install it manually."
  fi

  mise install || true  # android-sdk may fail on windows-arm64, handled separately below

  if [[ "$IS_WINDOWS" == "true" && "$IS_ARM64" == "true" ]]; then
    return
  fi

  # mise's flutter install is a tree of symlinks into its tarball cache, not
  # plain directories — follow symlinks (-L) when checking for it.
  if [[ -z "$(find -L "$MISE_DATA/installs/flutter" -maxdepth 3 -name flutter -type f 2>/dev/null)" ]]; then
    log_error "Flutter failed to install via mise. Check the output above."
    exit 1
  fi
  log_ok "Flutter installed"
}

# ── Manual android-sdk install for Windows ARM64 ────────────────────────────
# Mise's vfox android-sdk plugin post-install hook uses mkdir -p via CMD,
# which doesn't understand the -p flag on Windows. The installation fails
# and mise deletes everything. We install it manually instead.
install_android_sdk_manually() {
  local sdk_version="${1}.0"
  local sdk_dir="$MISE_DATA/installs/android-sdk/$sdk_version"

  # Check if already installed correctly
  if [[ -x "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
    return 0
  fi

  if [[ "$IS_WINDOWS" != "true" || "$IS_ARM64" != "true" ]]; then
    # Not on windows-arm64 — check if mise installed it, if not, error
    if ! [[ -x "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
      log_error "android-sdk failed to install. Run 'mise install' and check errors."
      exit 1
    fi
    return 0
  fi

  log_info "Windows ARM64 detected — installing Android SDK manually (mise vfox bug workaround)..."
  log_info "Downloading commandlinetools..."

  local zip_url="https://dl.google.com/android/repository/commandlinetools-win-14742923_latest.zip"
  local zip_file
  zip_file="$(mktemp).zip"

  # Download
  if command -v curl &>/dev/null; then
    curl -fsSL -o "$zip_file" "$zip_url"
  elif command -v wget &>/dev/null; then
    wget -q -O "$zip_file" "$zip_url"
  else
    log_error "Neither curl nor wget found. Cannot download Android SDK."
    exit 1
  fi

  log_info "Extracting to $sdk_dir..."

  # Extract to a temp location
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if command -v unzip &>/dev/null; then
    unzip -q "$zip_file" -d "$tmp_dir"
  elif command -v busybox &>/dev/null && busybox unzip 2>&1 | head -1; then
    busybox unzip -q "$zip_file" -d "$tmp_dir"
  else
    log_error "No unzip command found. Install unzip via: scoop install unzip"
    exit 1
  fi

  # mise's expected structure: cmdline-tools/<version>/bin/, cmdline-tools/<version>/lib/
  mkdir -p "$sdk_dir/cmdline-tools/$sdk_version"
  mv "$tmp_dir/cmdline-tools/"* "$sdk_dir/cmdline-tools/$sdk_version/"

  # Cleanup
  rm -rf "$tmp_dir" "$zip_file"

  # Verify
  if [[ -x "$sdk_dir/cmdline-tools/$sdk_version/bin/sdkmanager" ]]; then
    log_ok "Android SDK manually installed at: $sdk_dir"
  else
    log_error "Manual android-sdk installation failed."
    ls -la "$sdk_dir/cmdline-tools/$sdk_version/bin/" 2>/dev/null || true
    exit 1
  fi
}

# ── Android SDK extras via sdkmanager ──────────────────────────────────────
install_sdk_extras() {
  if ! command -v sdkmanager &>/dev/null; then
    log_error "sdkmanager not in PATH."
    log_error "Expected at: $(resolve_android_home "$ANDROID_SDK_VERSION" 2>/dev/null || echo '?')/cmdline-tools/${ANDROID_SDK_VERSION}.0/bin/sdkmanager"
    exit 1
  fi

  yes | sdkmanager --licenses 2>/dev/null || true

  for pkg in $(SDK_PACKAGES); do
    if sdkmanager --list 2>/dev/null | grep -qE "^[[:space:]]*${pkg}[[:space:]]+.*Installed"; then
      log_ok "SDK package already installed: ${pkg}"
      continue
    fi
    log_info "Installing SDK package: ${pkg}..."
    sdkmanager "$pkg"
    log_ok "Installed: ${pkg}"
  done

  install_emulator_hypervisor_driver
}

# ── Install emulator hypervisor driver (Windows only) ────────────────────────
install_emulator_hypervisor_driver() {
  [[ "$IS_WINDOWS" == "true" ]] || return
  [[ "$IS_ARM64" == "true" ]] && return

  local drv_bat="${ANDROID_HOME}/extras/google/Android_Emulator_Hypervisor_Driver/silent_install.bat"
  if [[ ! -f "$drv_bat" ]]; then
    log_warn "Emulator hypervisor driver not found — emulator will need manual acceleration setup."
    return
  fi

  if sc query aEhSvc >/dev/null 2>&1 && [[ "$(sc query aEhSvc | grep -c RUNNING)" -ge 1 ]]; then
    log_ok "Android Emulator Hypervisor Driver already running (aEhSvc)"
    return
  fi

  log_info "Installing Android Emulator Hypervisor Driver (a UAC prompt will appear)..."
  if command -v powershell >/dev/null 2>&1; then
    local winpath
    winpath="$(echo "${drv_bat}" | sed 's|/|\\|g')"
    if powershell -NoProfile -Command "Start-Process -FilePath '${winpath}' -Verb RunAs -Wait"; then
      if sc query aEhSvc >/dev/null 2>&1 && [[ "$(sc query aEhSvc | grep -c RUNNING)" -ge 1 ]]; then
        log_ok "Android Emulator Hypervisor Driver installed and running"
      else
        log_warn "Driver install ran but aEhSvc is not running. Run as admin manually: ${drv_bat}"
      fi
    else
      log_warn "Elevated driver install was cancelled or failed. Run as admin manually: ${drv_bat}"
    fi
  else
    log_warn "powershell not found — install the driver manually as admin: ${drv_bat}"
  fi
}

# ── Create AVD ──────────────────────────────────────────────────────────────
create_avd() {
  if ! command -v avdmanager &>/dev/null; then
    log_error "avdmanager not found in PATH"
    exit 1
  fi
  if avdmanager list avd -c 2>/dev/null | grep -q "^${AVD_NAME}$"; then
    log_ok "AVD '${AVD_NAME}' already exists"
    return
  fi
  echo "no" | avdmanager create avd -n "$AVD_NAME" -k "$AVD_TARGET" -d "pixel_8" -f
  log_ok "AVD '${AVD_NAME}' created"
}

# ── Run ─────────────────────────────────────────────────────────────────────
main() {
  echo ""
  echo -e "${GREEN}╔══════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║        LeafLens — Environment Setup              ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════╝${NC}"
  echo ""

  if [[ "$IS_WINDOWS" == "true" ]]; then
    log_info "Detected Windows (Git Bash)"
  fi

  install_mise

  PROJECT_ROOT="$(find_project_root "$(pwd)")"
  log_info "Project root: ${PROJECT_ROOT}"

  install_mise_tools "$PROJECT_ROOT"

  ANDROID_SDK_VERSION="$(android_sdk_version)"

  # Manual android-sdk install for windows-arm64 (mise vfox bug)
  install_android_sdk_manually "$ANDROID_SDK_VERSION"

  ANDROID_HOME="$(resolve_android_home "$ANDROID_SDK_VERSION")"
  export ANDROID_HOME
  log_ok "ANDROID_HOME=${ANDROID_HOME}"

  # Add cmdline-tools to PATH so sdkmanager/avdmanager resolve
  export PATH="$ANDROID_HOME/cmdline-tools/${ANDROID_SDK_VERSION}.0/bin:$PATH"

  install_sdk_extras
  create_avd

  link_sdk_binaries "$ANDROID_HOME"

  RC_FILE="$(detect_rc)"
  log_info "Detected shell RC: ${RC_FILE}"
  ensure_local_bin_on_path "$RC_FILE"

  echo ""
  log_ok "All done."
  log_info "Restart your terminal or run: source ${RC_FILE}"
  log_info "Then:  emulator -avd ${AVD_NAME}"
  log_info "       adb devices"
  if [[ "$IS_WINDOWS" == "true" && "$IS_ARM64" == "true" ]]; then
    log_warn "Flutter was skipped (no windows-arm64 build) — install it manually."
  fi
  echo ""
}

main "$@"
