# GitHub Xcode Build

This repo has two GitHub Actions workflows:

- `Xcode Build`: fast simulator compile, metadata validation, and secret scan on every push.
- `Xcode App Store Archive`: manual signed archive that uses Xcode automatic signing, exports an App Store IPA, and can optionally upload it to App Store Connect.

## Required GitHub Secrets

Add these in GitHub: `Settings > Secrets and variables > Actions > New repository secret`.

Required for signed archive and upload:

- `APPLE_TEAM_ID`: Apple Developer Team ID.
- `APP_STORE_CONNECT_API_KEY_ID`: App Store Connect API key ID.
- `APP_STORE_CONNECT_API_ISSUER_ID`: App Store Connect issuer ID.
- `APP_STORE_CONNECT_API_KEY_BASE64`: base64 text for the `.p8` private key.

The App Store Connect API key must have enough access for Xcode automatic signing and App Store upload. Use an Account Holder, Admin, or App Manager account when creating the key.

Never commit raw `.p8` files or API keys. This workflow no longer needs `.p12` certificates or `.mobileprovision` profiles because Xcode automatic signing creates or updates signing assets during the macOS GitHub Actions job.

## Base64 Commands

PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("AuthKey_XXXXXXXXXX.p8")) | Set-Content asc_api_key_base64.txt
```

macOS:

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

## Run The Build

1. Open GitHub Actions for `lanray07/PosturePilot-AI`.
2. Select `Xcode App Store Archive`.
3. Click `Run workflow`.
4. Leave `upload_to_app_store_connect` off if you only want an IPA artifact.
5. Turn `upload_to_app_store_connect` on to send the IPA to App Store Connect after export.

The workflow sets `MARKETING_VERSION=1.0`, uses the GitHub Actions run number as the App Store build number, and passes `-allowProvisioningUpdates` with the App Store Connect API key so Xcode can manage signing in CI.
