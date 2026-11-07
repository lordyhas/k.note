# Releases

Merging into `production` runs `.github/workflows/release.yml`, which:

1. writes `google-services.json` and the upload key from the repository secrets,
2. runs the tests,
3. builds a signed app bundle (for Google Play) and APK,
4. fails if they are signed with a debug key,
5. publishes a GitHub release `v<version>+<build>` with both files attached.

It can also be started by hand: Actions > Release > Run workflow.

## Version

- The version name comes from `version:` in `pubspec.yaml` (the part before `+`).
  Bump it before merging into `production`.
- The version code (build number) is the workflow run number + 100, so it always
  increases, as Google Play requires.

## Upload key

| | |
|---|---|
| File | `knote-upload-keystore.jks`, kept outside the repository (PKCS12, RSA 4096) |
| Alias | `lordyhas` |
| Owner | `CN=Hassan Kajila, OU=lordyhas, O=Kdynamics Lab` |
| SHA-1 | `E3:10:BB:C4:9A:BA:1E:9C:EC:05:D0:AE:D4:01:08:94:F4:59:A2:77` |
| SHA-256 | `20:6A:C3:34:6C:60:5C:0A:3C:89:C0:42:5E:1D:A2:A5:F9:A0:3B:C9:07:59:97:B6:D5:E6:F2:4D:DC:C4:CB:5E` |

The password is in `android/key.properties` (not committed). Back up the `.jks` and the
password somewhere safe (a password manager): if they are lost, Google Play must be asked
to reset the upload key. With Play App Signing, Google keeps the key that signs the app for
users; this one only proves uploads come from us.

Both fingerprints are registered in Firebase (Android app), which Google sign-in needs.
Once the app is on Play, also register the **app signing key** fingerprints shown in
Play Console > App integrity.

## Repository secrets

| Secret | Content |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | the `.jks`, base64 |
| `ANDROID_KEYSTORE_PASSWORD` | `storePassword` |
| `ANDROID_KEY_PASSWORD` | `keyPassword` |
| `ANDROID_KEY_ALIAS` | `keyAlias` |
| `GOOGLE_SERVICES_JSON_BASE64` | `android/app/google-services.json`, base64 |

To replace one: `gh secret set NAME --repo lordyhas/k.note < file`.
