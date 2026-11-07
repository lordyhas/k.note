# Security

## Threat model

The app is open source and runs on devices we do not control. Anyone can read
the code, rebuild a modified APK, or call the Firestore REST API directly with
their own Firebase Auth token. **Nothing in the Flutter code is a security
boundary.** Data is protected only by what Google's servers enforce:

- **Firebase Auth** issues a signed ID token whose `uid` cannot be forged.
- **Firestore Security Rules** (`firestore.rules`) run server-side on every
  request and decide what that `uid` may read or write.

The Firebase API keys in `lib/firebase_options.dart` are public identifiers,
not secrets. They are shipped inside every build anyway.

## Data isolation

Each user owns one subtree:

```
users/{uid}          profile (optional)
users/{uid}/notes/*  notes
users/{uid}/tasks/*  tasks
users/{uid}/settings/preferences   the user's preferences
feedback/{id}        messages sent from the Feedback page
```

`feedback` is the only collection outside a user's subtree, so that the team
can read it in the Firebase console. A verified user can only create feedback
under their own `uid` and email, with a non-empty message of at most 5000
characters and known fields; they can read and delete only their own (account
deletion removes it) and never edit it.

The rules allow a request only when the `{uid}` in the path equals
`request.auth.uid`. A modified app that asks for another user's path gets
`PERMISSION_DENIED`. Listing `users`, and any path not matched in the rules,
is denied.

## Email verification

Firebase lets anyone create an email/password account with an address they
do not own. Such an account cannot reach anyone else's data (it has its own
`uid`), but it squats the address, shows an email nobody checked, and Firebase
may later hand the account to whoever signs in with Google for that address.

So the rules also require `request.auth.token.email_verified == true`:

- Google accounts are verified by Google, so nothing changes for them.
- Email/password accounts get a verification link at sign-up
  (`AuthRepository.signUp`). Until they open it, the router keeps them on
  `VerifyEmailPage`, which can resend the link, checks every 5 seconds whether
  it was opened, and lets them log out. Once verified, the app refreshes the
  ID token (`AuthRepository.reloadUser`): the old token still says `false`.
- Anonymous accounts have no verified email and are denied. The app does not
  offer anonymous sign-in.

Existing unverified email accounts are blocked from their notes until they
verify. They see `VerifyEmailPage` after updating the app; an older app
version only gets permission errors, so deploy the rules once the new version
is out.

The rules also validate writes. Only known fields are accepted, with the
expected types, and the stored `id` must match the document id and cannot
change. Legacy documents with extra fields can still be updated or
overwritten, but no new unknown field can be added.

When a field is added to `NoteModel`, `CheckList` or `User.asMap()`, add it to
`noteKeys()`, `taskKeys()` or `profileKeys()` in `firestore.rules` as well, or
the write will be rejected.

## Blocking a user

Account status is **not** stored in Firestore. A flag in a document the user
can write, like the former `isBlocked` field, can be flipped back by the user.
Only an admin can block someone:

1. **Disable the account** in Firebase console → Authentication → Users →
   *Disable account*. The user can no longer sign in, and their token stops
   refreshing within an hour.
2. **Cut access immediately (optional).** Set the `blocked` custom claim with
   the Admin SDK, from a trusted machine and never from the app:

   ```js
   // node, with GOOGLE_APPLICATION_CREDENTIALS pointing to a service account
   const admin = require('firebase-admin');
   admin.initializeApp();
   await admin.auth().setCustomUserClaims(uid, { blocked: true });
   await admin.auth().revokeRefreshTokens(uid);
   ```

   `isOwner()` in the rules denies every request carrying `blocked: true`.

Never commit a service account key. `.gitignore` excludes the usual file
names.

Email verification, which `verifiedAccount` used to mimic, is required by the
rules through `request.auth.token.email_verified` (see above).

## Deploying the rules

Rules in this repository are the source of truth. Do not edit them in the
console.

```bash
npx firebase-tools login
npx firebase-tools deploy --only firestore:rules   # project from .firebaserc
```

## Testing the rules

`test/firestore_rules/` runs the real rules in the Firestore emulator with
`@firebase/rules-unit-testing`. It needs Node.js 20+ and Java 11+.

```bash
cd test/firestore_rules
npm ci
npm test
```

CI runs the same job on every push and pull request.

On Windows the emulator's Java process can outlive the run and keep port 8080
busy. If the next run reports "port taken", stop that `java` process.

## Hardening checklist (Firebase console)

- [ ] Deploy `firestore.rules` and check that no "test mode" rule remains.
- [ ] Restrict the API keys (Google Cloud console → Credentials): Android
      package + SHA-1, iOS bundle id, web HTTP referrers.
- [ ] Enable App Check (Play Integrity / App Attest / reCAPTCHA) and enforce it
      for Firestore. This is defence in depth and does not replace the rules.

## App Check

`main.dart` activates Firebase App Check before anything else: Play Integrity
on Android release builds, reCAPTCHA Enterprise on the web, and the debug
provider in debug builds. Requests are only rejected once enforcement is on,
so set it up in this order:

1. Firebase console > App Check > Apps:
   - Android: register with **Play Integrity**, and add the release SHA-256
     fingerprint (from Google Play > App integrity > App signing key once the
     app is on Play, plus the upload key).
   - Web: create a reCAPTCHA Enterprise key for the app's domains, register it,
     and build with `flutter build web --dart-define=RECAPTCHA_SITE_KEY=<key>`.
     Without the define, App Check stays off on the web.
   - Debug builds log a debug token (`Enter this debug secret into the allow
     list...`); add it under *Manage debug tokens*.
2. Watch the App Check metrics for Firestore and Authentication until almost
   all requests are verified (older app versions are not).
3. Enforce for Cloud Firestore, then Authentication.
