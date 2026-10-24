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
- Screens are `*Page` classes in `*_page.dart` files under `lib/ui/<feature>/widgets/`.
- Imports are `package:knote/...` imports, sorted (`dart:`, packages, `package:knote`);
  no relative imports, no barrel files. `part` is only used for bloc events/states.
- See [PROJECT_STRUCTURE.md](../PROJECT_STRUCTURE.md) for where new code goes.

## Architecture guardrails for contributors

- Keep navigation declarations centralized in `lib/routing/router.dart`.
- Keep auth/session logic in `AuthenticationBloc`/`AuthRepository`, not in UI widgets.
- Keep Firestore access in `lib/data/` (`FirestoreService`, repositories).
- Add DartDoc for public service/repository/routing APIs when their behavior changes.
