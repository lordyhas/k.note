# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                         # install dependencies
flutter analyze --no-fatal-warnings --no-fatal-infos    # lint (same flags as CI)
flutter test                                            # all tests
flutter test test/domain/models/note_test.dart          # single test file
flutter test --plain-name "some test name"              # single test by name
dart format lib/ test/                                  # format
flutter run -d chrome | -d android                      # run
flutter build apk --release / appbundle --release / web # build
```

CI (`.github/workflows/`) runs `pub get` → `analyze` (non-fatal warnings/infos) → `test`, plus a `firestore-rules` job, on every PR and on pushes to `main`, `master`, `dev`, `dev-new-ui`, `production`. Dependabot (`.github/dependabot.yml`) opens weekly update PRs for pub, the rules tests' npm packages and the GitHub Actions.

## Architecture

Layered structure from the official Flutter architecture guide, with BLoC/Cubit as view models. `PROJECT_STRUCTURE.md` is the reference for the layout, the dependency rules (`ui` → `data` → `domain`) and where new code goes; ADR 0002 records why.

- `lib/config/assets.dart`: `AppAssets` asset paths.
- `lib/routing/router.dart`: `AppRouter`, every route.
- `lib/domain/models/`: `NoteModel` (`note.dart`), `CheckList`/`TodoItem` (`task.dart`), `TaskRepeat`, `User`, `DataToMap`/`DocumentModel`.
- `lib/data/repositories/auth_repository.dart` and `lib/data/services/firestore_service.dart`.
- `lib/ui/<feature>/{bloc,widgets}/` for `auth`, `notes`, `tasks`, `settings`; `lib/ui/core/` (theme, localization, shared widgets, `AppBlocObserver`); `lib/ui/shell/app_shell.dart` (bottom navigation).
- `lib/utils/save_in_background.dart` and `lib/utils/autosave.dart` (debounced editor saves).

There are no barrel files: import each file directly with `package:knote/...`. `part` is only used for bloc events/states.

### Bootstrap (`lib/main.dart`)

`Firebase.initializeApp` → create `AuthRepository` and await its first `user` emission → `Bloc.observer = AppBlocObserver()` → `RepositoryProvider<AuthRepository>` → `BlocProvider<AuthenticationBloc>` → `BlocProvider<StyleCubit>` → `MaterialApp.router` (with `scaffoldMessengerKey: appMessengerKey`, `theme: AppTheme.dark`). The app follows the device language (`en` or `fr`, English fallback). `FlutterQuillLocalizations.delegate` is required by the editor.

### Navigation (`lib/routing/router.dart`)

All routes live in `AppRouter.routes(...)`. They are GoRouter routes that refresh on `GoRouterRefreshStream(authBloc.stream)`, with `redirectLimit: 1`.
- `/` redirects to `/home` or `/login` based on `AuthenticationStatus`. `/login` redirects to `/home` when authenticated. A top-level redirect sends users with an unverified email to `/verify-email`, and away from it otherwise.
- A `ShellRoute` wraps the tabs in `AppShell`, which picks the selected entry from the current path (`AppShell.tabIndexFor`, `sideIndexFor`) and switches with `goNamed`. Notes is `/home`, Tasks is `/home/tasks`, settings (with trash, archive, calendar, about, help…) is `/user`.
- `AppShell` chooses its navigation from the window width on every platform (`AppShell.navigationFor`): a bottom `NavigationBar` under 600 dp, then `SideNavigationPane` (`ui/shell/side_navigation_pane.dart`) as a rail of icons from 600 dp and as a pane with labels from 840 dp (`sideRouteNames`). Pages check `SideNavigationScope.of(context)` (`ui/shell/side_navigation_scope.dart`; never import `app_shell.dart` from a page: the import cycle crashes `flutter run -d chrome`); `SettingsPage` hides Bin, Archived notes and Calendar then.
- Full-screen editors (`NoteEditorPage`, `TaskEditorPage`) set `parentNavigatorKey: key` to escape the shell. They receive their model through `state.extra` (`NoteModel?` / `CheckList?`; `null` means create new).
- Route path segments and names come from each page's static `routeName`; route names must be unique.

### State

- `AuthenticationBloc` (`ui/auth/bloc/`) listens to `AuthRepository.user` and drives redirects; other features read the session from it.
- `LoginCubit` and `SignUpCubit` handle form state using `formz` inputs (`login_models.dart`).
- `StyleCubit` is in `ui/core/themes/style_cubit.dart` and is not persisted.
- `PreferencesCubit` (`ui/settings/bloc/`) holds the signed-in user's `UserPreferences` (Firestore `users/{uid}/settings/preferences`); `main.dart` exposes them through `PreferencesScope` (`ui/core/preferences_scope.dart`). Pages read `PreferencesScope.of(context)` and save with `PreferencesScope.update`, never the cubit, so widget tests without a scope get the defaults. New preferences also go in `preferenceKeys()` in `firestore.rules`.

### Auth (`lib/data/repositories/auth_repository.dart`)

`AuthRepository` wraps `firebase_auth` and `google_sign_in` (email/password, Google). It exposes the app's own `User` model (`domain/models/user.dart`), which is not `firebase_auth.User`. It only holds Firebase Auth data (`isAnonymous`, `isCheckMail`, ...), and `User.empty` means signed out. Account status such as blocking is managed in Firebase Auth (disabled account or `blocked` custom claim), never stored in a client-writable document. Email accounts must verify their address: `signUp` sends the link, `User.needsEmailVerification` makes the router's top-level redirect (`redirectForEmailVerification`) keep them on `VerifyEmailPage`, `reloadUser()` refreshes the token once verified, and `firestore.rules` requires `email_verified`. `User.asMap()` is the Firestore profile and must match `profileKeys()` in `firestore.rules`.

### Data (`lib/data/services/firestore_service.dart`)

- `FirestoreService` is **not a singleton**. Pages construct it per user with `FirestoreService.user(user)`. Every constructor accepts an optional `FirebaseFirestore`, and tests inject `FakeFirebaseFirestore` through it. Paths: `users/{userId}/notes` and `.../tasks`. Methods return the Firestore futures and don't swallow errors; lists use live `snapshots()` streams (`watchNotes`, `watchArchivedNotes`, `watchDeletedNotes`, `watchTasks`). Pages take an optional `firebaseManager` so widget tests can pass one backed by `FakeFirebaseFirestore`.
- UI writes go through `saveInBackground` (`lib/utils/`): not awaited (Firestore completes writes only on server ack, never offline), with failures reported via the app-wide `ScaffoldMessenger`. Removals offer Undo with `showUndoSnackBar` (`ui/core/widgets/`).
- Models implement `DataToMap` (`fromMap`/`asMap`), and `fromMap` is deliberately defensive about malformed docs. `CheckList.repeat` is encoded/decoded by `TaskRepeat`.
- There is no local database; persistence offline relies on Firestore's cache.

### Tests (`test/`)

`test/` mirrors `lib/` (e.g. `test/ui/tasks/widgets/task_quick_add_test.dart`). Tests use `bloc_test`, `mocktail` (`MockAuthRepository extends Mock implements AuthRepository`) and `fake_cloud_firestore` for `FirestoreService`. `test/firestore_rules/` is a separate Node project for the security rules.

### Localization and theme

- Every user-visible string is in `lib/ui/core/localization/app_en.arb` (template) and `app_fr.arb`, read with `context.l10n.<key>` (`l10n.dart`). `app_localizations*.dart` are generated by `flutter gen-l10n` (also run by `pub get`/`run`/`build`; config in `l10n.yaml`): edit the `.arb` files, never the generated ones, and commit both. `test/ui/core/localization/arb_test.dart` fails if a language misses a key or a placeholder.
- Code that runs without a usable context (e.g. `dispose`) caches `context.l10n` in `didChangeDependencies`. The data and domain layers return codes, not text (`AuthError`, `TaskRepeat`); the UI translates them (`authErrorText`, `repeatText`). Dates use `intl` with `l10n.localeName` (`task_text.dart`).
- Colors come from `AppColors.of(context)` (`ui/core/themes/app_colors.dart`, a `ThemeExtension` registered in `AppTheme.dark`), not `Colors.*` literals; user-chosen note/task palettes are data and stay literal.
- The look is Fluent-style Material: `AppTheme` sets the shapes (4 dp controls, 8 dp surfaces), strokes, buttons, fields, dialogs, sheets and bars once. Pages don't restyle them (no local corner radius or field border); a field without a box uses `border: InputBorder.none, filled: false`.
- Pages are responsive (`ui/core/widgets/responsive.dart`): keep content at a readable width with `CenteredContent`, or `centeredPadding` for a scroll view, using `ContentWidths`; never size from a fraction of the screen width without a cap. Check a page at phone, landscape, tablet and desktop widths.
- Icon-only buttons have a translated `tooltip`; touch targets are at least 48 dp.
- Widget tests pump `localizedApp(...)` / `localizedRouterApp(...)` from `test/helpers/localized_app.dart` (English by default, `locale:` to test French).

## Conventions

- Keep routes in `lib/routing/router.dart`. Keep auth logic in bloc/repository layers and Firestore access in `lib/data/`, never in widgets.
- Screens are `*Page` classes in `*_page.dart` files under `lib/ui/<feature>/widgets/`. Imports are `package:knote/...`, sorted (`dart:`, packages, `package:knote`).
- Branches use `feat/`, `fix/`, `docs/` or `refactor/`. Commits follow Conventional Commits. PRs usually target `dev`.
- `avoid_print` is enabled; use `debugPrint` (as `AppBlocObserver` does) instead of `print`.
- When behavior changes, update `README.md`, `docs/*` and `CHANGELOG.md`.

## Firebase / platform

- Security is enforced by `firestore.rules` (per-uid isolation + schema validation), never by app code; see `docs/security.md`. When adding a field to `NoteModel`, `CheckList`, `UserPreferences` or `User.asMap()`, add it to the matching `*Keys()` list in the rules. Rules tests: `cd test/firestore_rules && npm ci && npm test` (Firestore emulator, needs Java).
- `android/app/google-services.json` is required and is not committed. The Firebase project is `k8note`.
- `lib/firebase_options.dart` is generated by FlutterFire CLI; don't edit it by hand. It only configures Android and Web, so iOS (`ios/` is the default Flutter project, not configured or tested yet) and desktop targets throw `UnsupportedError`.
- `.env` exists but is not wired into the app.
