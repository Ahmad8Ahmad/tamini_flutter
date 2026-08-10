# Tamini Distribution

In Syria the App Store and Google Play are not accessible, so the app is
distributed two ways:

1. **Android APK** – the main product, sideloaded (install from a browser).
2. **PWA (web)** – for iPhone users and quick preview; installable to the home
   screen from the browser.

## How updates work

The app checks `version.json` once per launch. If `version` is newer than the
installed app version, a dialog opens with a download button pointing at
`apkUrl`. The check URL is configured in `lib/core/config/app_config.dart`
(`releaseBaseUrl`).

`version.json` format:

```json
{
  "version": "1.0.0",
  "apkUrl": "https://your-host/tamini-v1.0.0.apk",
  "notes": "What's new in this version"
}
```

Every APK release must bump both `version:` in `pubspec.yaml` and
`AppConfig.appVersion` in `lib/core/config/app_config.dart`.

## Option A – GitHub Releases (zero hosting)

Both workflows are already in `.github/workflows/`:

- `release.yml` – builds universal + per-ABI APKs, uploads them and a generated
  `version.json` to a new GitHub Release. Run it from the **Actions** tab
  ("Run workflow"), or just push a `v*` tag.
- `deploy-pages.yml` – builds the PWA and deploys it to GitHub Pages. Enable
  Pages in the repo: **Settings → Pages → Source: GitHub Actions**.

APK URLs use GitHub's `releases/latest/download/...` endpoints, which resolve
to the newest release, so the app's update URL never changes between releases.

To sign releases in CI (recommended), add these repo **Actions secrets**:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | base64 of `android/app/tamini-release.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `ANDROID_KEYSTORE_ALIAS` | `tamini` |

`base64` on Windows: `certutil -encode android\app\tamini-release.jks tmp.txt` then paste the body.

Without these secrets the workflow still runs, but falls back to debug signing.

## Option B – Your own host

Upload `version.json` and the APKs to any HTTPS host (Cloudflare Pages, your
server), then set `AppConfig.releaseBaseUrl` to that host's folder and rebuild.
Keep the same keystore so existing installs can be updated in place.

## Signing key

`android/app/tamini-release.jks` + the password in `android/key.properties`
(gitignored) are **not recoverable** if lost. Back them up. Anyone with the
keystore can sign apps for your package name.
