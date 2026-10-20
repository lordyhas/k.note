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
K_NOTE/general_data/USERS/{uid}          profile (optional)
K_NOTE/general_data/USERS/{uid}/notes/*  notes
K_NOTE/general_data/USERS/{uid}/tasks/*  tasks
```

The rules allow a request only when the `{uid}` in the path equals
`request.auth.uid`. A modified app that asks for another user's path gets
`PERMISSION_DENIED`. Listing `USERS`, and any path not matched in the rules,
is denied.

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

Email verification, which `verifiedAccount` used to mimic, is available in the
rules as `request.auth.token.email_verified` if it ever needs to be required.

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
- [ ] Remove data from the removed E2EE feature
      (`USERS/{uid}/keys/master_key`). Clients can no longer access it.
