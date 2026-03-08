# Testing

## Current test setup

- Test framework: `flutter_test`
- Bloc testing: `bloc_test`
- Mocking: `mocktail`

Current tests are mostly unit-oriented (`test/unit/...`) and include:
- login cubit state transitions
- note model mapping

## Commands

```bash
flutter test
flutter test test/unit/data/app_bloc/login_bloc/login_cubit_test.dart
flutter test test/unit/data/model/note_model_test.dart
```

## CI checks

GitHub Actions workflow (`.github/workflows/flutter_ci.yml`) runs:

1. `flutter pub get`
2. `flutter analyze --no-fatal-warnings --no-fatal-infos`
3. `flutter test`

## Testing conventions (recommended for this repo)

- Keep unit tests close to BLoC/cubit and model behavior.
- Prefer deterministic bloc tests with explicit `seed` + `expect` states.
- Add regression tests for route/auth redirects when modifying router/auth blocs.
