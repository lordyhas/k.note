# Style Guide

## Baseline

- Lints: `flutter_lints` via `analysis_options.yaml`.
- Formatting: standard Dart formatter.

## Commands

```bash
dart format .
flutter analyze --no-fatal-warnings --no-fatal-infos
```

## Conventions inferred from codebase

- Route names are exposed as static `routeName` fields on screens.
- State management uses BLoC/Cubit with immutable states (where implemented).
- Shared exports are grouped in barrel files (`lib/data/app_bloc.dart`, `lib/src/pages/screens.dart`, etc.).

## Architecture guardrails for contributors

- Keep navigation declarations centralized in `lib/routes.dart`.
- Keep auth/session logic in `AuthenticationBloc`/`AuthRepository`, not in UI widgets.
- Keep Firestore access concentrated in manager/repository classes.
- Add DartDoc for public service/repository/routing APIs when their behavior changes.
