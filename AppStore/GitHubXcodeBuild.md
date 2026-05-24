# GitHub Xcode Build

This repo has two GitHub Actions workflows:

- `Xcode Build`: fast simulator compile, metadata validation, and secret scan on every push.
- `Xcode App Store Archive`: manual signed archive that exports an App Store IPA and can optionally upload it to App Store Connect.

## Required GitHub Secrets

Add these in GitHub: `Settings > Secrets and variables > Actions > New repository secret`.

Required for signed archive:

- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `IOS_DISTRIBUTION_CERTIFICATE_BASE64`: base64 text for the Apple Distribution `.p12`.
- `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`: password used when exporting the `.p12`.
- `IOS_PROVISIONING_PROFILE_BASE64`: base64 text for the App Store `.mobileprovision` profile for `com.posturepilotai.app`.

Required only when `upload_to_app_store_connect` is enabled:

- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID.
- `APP_STORE_CONNECT_API_KEY_BASE64`: base64 text for the `.p8` private key.

Never commit the raw `.p12`, `.mobileprovision`, `.p8`, passwords, or API keys.

## Base64 Commands

PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AppleDistribution.p12")) | Set-Content ios_dist_cert_base64.txt
[Convert]::ToBase64String([IO.File]::ReadAllBytes("PosturePilotAI_AppStore.mobileprovision")) | Set-Content ios_profile_base64.txt
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8")) | Set-Content asc_api_key_base64.txt
```

macOS:

```bash
base64 -i AppleDistribution.p12 | pbcopy
base64 -i PosturePilotAI_AppStore.mobileprovision | pbcopy
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

## Run The Build

1. Open GitHub Actions for `lanray07/PosturePilot-AI`.
2. Select `Xcode App Store Archive`.
3. Click `Run workflow`.
4. Leave `upload_to_app_store_connect` off if you only want an IPA artifact.
5. Turn `upload_to_app_store_connect` on to send the IPA to App Store Connect after export.

The workflow sets `MARKETING_VERSION=1.0` and uses the GitHub Actions run number as the App Store build number, so reruns produce unique uploadable builds.
