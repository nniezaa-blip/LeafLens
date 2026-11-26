# Android release

Releases are built from the `release` branch. `main` stays the integration
branch; release commits are cherry-picked onto `release` so a hotfix does not
drag every later commit into the store build.

## One-time setup

Create the release branch from the commit you want to ship:

```bash
git switch -c release
git push -u origin release
```

Add these repository secrets under **Settings → Secrets and variables → Actions**:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64 of `android/keystore/upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password |
| `ANDROID_KEY_ALIAS` | Key alias, normally `upload` |
| `ANDROID_KEY_PASSWORD` | Key password |

Generate the base64 value without printing the keystore:

```bash
base64 -i android/keystore/upload-keystore.jks | pbcopy
```

`android/key.properties` and the keystore stay gitignored. The workflow writes
both on the runner.

## Publish a release

1. Merge the change into `main` and wait for it to pass.
2. Run **Actions → release-cherry-pick → Run workflow**.
3. Enter the commit SHA and keep the target branch as `release`.
4. The workflow cherry-picks the commit and pushes `release`.
5. **android-release** runs on that push, runs analyze and tests, builds the
   universal APK plus `arm64-v8a`, `armeabi-v7a` and `x86_64` APKs, and
   publishes all four to a GitHub Release. The tag replaces the pubspec build
   separator, so `1.0.0+1` becomes `v1.0.0-1`.

You can also push a commit to `release` directly, or run `android-release` from
the Actions tab.

## Local release build

Create `android/key.properties` and the keystore locally, then:

```bash
flutter build apk --release
flutter build apk --release --split-per-abi
```

Outputs live under `build/app/outputs/flutter-apk/`:

- `app-release.apk` for any device
- `app-arm64-v8a-release.apk`
- `app-armeabi-v7a-release.apk`
- `app-x86_64-release.apk`

Without `android/key.properties`, the Gradle script falls back to debug signing
for local builds. CI fails instead of publishing a debug-signed APK.
