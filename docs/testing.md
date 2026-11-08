# Testing

## Current test setup

- Test framework: `flutter_test`
- Bloc testing: `bloc_test`
- Mocking: `mocktail`

`test/` mirrors `lib/`: blocs and cubits (`test/ui/auth/bloc/`), widgets
(`test/ui/...`), models (`test/domain/models/`), `FirestoreService` with
`fake_cloud_firestore` (`test/data/services/`) and the router (`test/routing/`).

## Commands

```bash
flutter test
flutter test test/ui/auth/bloc/login_cubit_test.dart
flutter test test/domain/models/note_test.dart
```

## CI checks

GitHub Actions workflow (`.github/workflows/flutter_ci.yml`) runs:

1. `flutter pub get`
2. `flutter analyze --no-fatal-warnings --no-fatal-infos`
3. `flutter test`

A second job, `firestore-rules`, runs the security rules tests in
`test/firestore_rules/` against the Firestore emulator:

```bash
cd test/firestore_rules && npm ci && npm test   # needs Node.js 20+ and Java 11+
```

## Testing conventions (recommended for this repo)

- Keep unit tests close to BLoC/cubit and model behavior.
- Prefer deterministic bloc tests with explicit `seed` + `expect` states.
- Add regression tests for route/auth redirects when modifying router/auth blocs.
