# GitHub Actions Setup - Quick Start

This guide will help you set up GitHub Actions for automatic APK building and releases.

## Quick Setup (3 steps)

### Step 1: Generate the keystore secret

Run the helper script:

```bash
./generate_keystore_secret.sh
```

This will create `keystore_base64.txt` with the base64-encoded keystore.

### Step 2: Add secrets to GitHub

Go to your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

Add these 4 secrets:

| Secret Name        | Value                                          |
|--------------------|------------------------------------------------|
| `KEYSTORE_BASE64`  | Content from `keystore_base64.txt` (very long)|
| `KEYSTORE_PASSWORD`| `bookreader2024`                               |
| `KEY_PASSWORD`     | `bookreader2024`                               |
| `KEY_ALIAS`        | `upload`                                       |

### Step 3: Trigger a build

**Option A - Create a release tag:**
```bash
git tag v1.2.0
git push origin v1.2.0
```

**Option B - Manual workflow trigger:**
1. Go to **Actions** tab on GitHub
2. Select **Build and Release APK**
3. Click **Run workflow**

## What happens next?

The workflow will:
1. ✅ Set up Java 21 and Flutter
2. ✅ Install dependencies
3. ✅ Decode your keystore from secrets
4. ✅ Build a signed release APK
5. ✅ Create a GitHub release
6. ✅ Upload the APK to the release

## Troubleshooting

### "base64: invalid input" error

**Solution:** The `KEYSTORE_BASE64` secret is incorrect or empty.

1. Delete the old secret on GitHub
2. Re-run `./generate_keystore_secret.sh`
3. Copy the ENTIRE content from `keystore_base64.txt`
4. Create a new `KEYSTORE_BASE64` secret
5. Make sure there are NO extra spaces or newlines

### Secrets validation fails

**Solution:** Make sure all 4 secrets are set:
- KEYSTORE_BASE64
- KEYSTORE_PASSWORD
- KEY_PASSWORD
- KEY_ALIAS

### Build fails

Check the workflow logs on GitHub:
**Actions → Build and Release APK → Latest run**

## Files

- **`generate_keystore_secret.sh`**: Helper script to generate base64 keystore
- **`.github/workflows/build-apk.yml`**: GitHub Actions workflow configuration
- **`android/app/upload-keystore.jks`**: Your keystore file (NOT in git)
- **`key.properties`**: Local keystore configuration (NOT in git)

## Security

⚠️ **NEVER commit these files to git:**
- `android/app/upload-keystore.jks`
- `key.properties`
- `keystore_base64.txt`

They are already in `.gitignore`.

## More Details

For detailed instructions and troubleshooting, see:
- [`GITHUB_SECRETS_SETUP.md`](../../GITHUB_SECRETS_SETUP.md) in the repository root

## Testing Locally

You can test the signing configuration locally:

```bash
flutter build apk --release
```

If this works, the CI/CD will work too (once secrets are configured).

---

**Need help?** Check the workflow logs or see the detailed troubleshooting guide in `GITHUB_SECRETS_SETUP.md`.
