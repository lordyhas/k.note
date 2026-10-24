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

## Text, colors and accessibility

- No user-visible text in widgets: add a key to `lib/ui/core/localization/app_en.arb`
  and `app_fr.arb` and use `context.l10n.<key>`. Use ICU placeholders and plurals
  (`{count, plural, =1{...} other{...}}`) rather than building sentences in Dart.
- Format dates with `intl` and `l10n.localeName`, or `MaterialLocalizations`,
  never with a fixed English pattern.
- Colors come from `AppColors.of(context)`; add a role there rather than a
  `Colors.*` literal.
- Every icon-only button has a translated `tooltip`, and touch targets are at
  least 48 x 48 dp.

## Architecture guardrails for contributors

- Keep navigation declarations centralized in `lib/routing/router.dart`.
- Keep auth/session logic in `AuthenticationBloc`/`AuthRepository`, not in UI widgets.
- Keep Firestore access in `lib/data/` (`FirestoreService`, repositories).
- Add DartDoc for public service/repository/routing APIs when their behavior changes.
