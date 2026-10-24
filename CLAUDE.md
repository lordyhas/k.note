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

CI (`.github/workflows/`) runs `pub get` → `analyze` (non-fatal warnings/infos) → `test`, plus a `firestore-rules` job, on pushes/PRs to `main`, `master`, `dev`, `production`.

## Architecture

Layered structure from the official Flutter architecture guide, with BLoC/Cubit as view models. `PROJECT_STRUCTURE.md` is the reference for the layout, the dependency rules (`ui` → `data` → `domain`) and where new code goes; ADR 0002 records why.

- `lib/config/assets.dart`: `AppAssets` asset paths.
- `lib/routing/router.dart`: `AppRouter`, every route.
- `lib/domain/models/`: `NoteModel` (`note.dart`), `CheckList`/`TodoItem` (`task.dart`), `TaskRepeat`, `User`, `DataToMap`/`DocumentModel`.
- `lib/data/repositories/auth_repository.dart` and `lib/data/services/firestore_service.dart`.
- `lib/ui/<feature>/{bloc,widgets}/` for `auth`, `notes`, `tasks`, `settings`; `lib/ui/core/` (theme, localization, shared widgets, `AppBlocObserver`); `lib/ui/shell/app_shell.dart` (bottom navigation).
- `lib/utils/save_in_background.dart`.

There are no barrel files: import each file directly with `package:knote/...`. `part` is only used for bloc events/states.

### Bootstrap (`lib/main.dart`)

`Firebase.initializeApp` → create `AuthRepository` and await its first `user` emission → `Bloc.observer = AppBlocObserver()` → `RepositoryProvider<AuthRepository>` → `BlocProvider<AuthenticationBloc>` → `MultiBlocProvider(LanguageBloc, StyleCubit)` → `MaterialApp.router` (with `scaffoldMessengerKey: appMessengerKey`). Locales are `en` and `fr`. The theme is hard-coded dark. `FlutterQuillLocalizations.delegate` is required by the editor.

### Navigation (`lib/routing/router.dart`)

All routes live in `AppRouter.routes(...)`. They are GoRouter routes that refresh on `GoRouterRefreshStream(authBloc.stream)`, with `redirectLimit: 1`.
- `/` redirects to `/home` or `/login` based on `AuthenticationStatus`. `/login` redirects to `/home` when authenticated.
- A `ShellRoute` wraps the tabs in `AppShell`, which picks the bottom bar tab from the current path (`AppShell.tabIndexFor`) and switches tabs with `goNamed`. Notes is `/home`, Tasks is `/home/tasks`, settings (with trash, archive, about, help…) is `/user`.
- Full-screen editors (`NoteEditorPage`, `TaskEditorPage`) set `parentNavigatorKey: key` to escape the shell. They receive their model through `state.extra` (`NoteModel?` / `CheckList?`; `null` means create new).
- Route path segments and names come from each page's static `routeName`; route names must be unique.

### State

- `AuthenticationBloc` (`ui/auth/bloc/`) listens to `AuthRepository.user` and drives redirects; other features read the session from it.
- `LoginCubit` and `SignUpCubit` handle form state using `formz` inputs (`login_models.dart`).
- `LanguageBloc` is a plain `Cubit<Language>` in `ui/core/localization/strings.dart`; `StyleCubit` is in `ui/core/themes/style_cubit.dart`. Neither is persisted.

### Auth (`lib/data/repositories/auth_repository.dart`)

`AuthRepository` wraps `firebase_auth` and `google_sign_in` (email/password, Google). It exposes the app's own `User` model (`domain/models/user.dart`), which is not `firebase_auth.User`. It only holds Firebase Auth data (`isAnonymous`, `isCheckMail`, ...), and `User.empty` means signed out. Account status such as blocking is managed in Firebase Auth (disabled account or `blocked` custom claim), never stored in a client-writable document. `User.asMap()` is the Firestore profile and must match `profileKeys()` in `firestore.rules`.

### Data (`lib/data/services/firestore_service.dart`)

- `FirestoreService` is **not a singleton**. Pages construct it per user with `FirestoreService.user(user)`. Every constructor accepts an optional `FirebaseFirestore`, and tests inject `FakeFirebaseFirestore` through it. Paths: `K_NOTE/general_data/USERS/{userId}/notes` and `.../tasks`. Methods return the Firestore futures and don't swallow errors; lists use live `snapshots()` streams (`watchTasks`).
- UI writes go through `saveInBackground` (`lib/utils/`): not awaited (Firestore completes writes only on server ack, never offline), with failures reported via the app-wide `ScaffoldMessenger`.
- Models implement `DataToMap` (`fromMap`/`asMap`), and `fromMap` is deliberately defensive about malformed docs. `CheckList.repeat` is encoded/decoded by `TaskRepeat`.
- There is no local database; persistence offline relies on Firestore's cache.

### Tests (`test/`)

`test/` mirrors `lib/` (e.g. `test/ui/tasks/widgets/task_quick_add_test.dart`). Tests use `bloc_test`, `mocktail` (`MockAuthRepository extends Mock implements AuthRepository`) and `fake_cloud_firestore` for `FirestoreService`. `test/firestore_rules/` is a separate Node project for the security rules.

## Conventions

- Keep routes in `lib/routing/router.dart`. Keep auth logic in bloc/repository layers and Firestore access in `lib/data/`, never in widgets.
- Screens are `*Page` classes in `*_page.dart` files under `lib/ui/<feature>/widgets/`. Imports are `package:knote/...`, sorted (`dart:`, packages, `package:knote`).
- Branches use `feat/`, `fix/`, `docs/` or `refactor/`. Commits follow Conventional Commits. PRs usually target `dev`.
- `avoid_print` is enabled; use `debugPrint` (as `AppBlocObserver` does) instead of `print`.
- When behavior changes, update `README.md`, `docs/*` and `CHANGELOG.md`.

## Firebase / platform

- Security is enforced by `firestore.rules` (per-uid isolation + schema validation), never by app code; see `docs/security.md`. When adding a field to `NoteModel`, `CheckList` or `User.asMap()`, add it to the matching `*Keys()` list in the rules. Rules tests: `cd test/firestore_rules && npm ci && npm test` (Firestore emulator, needs Java).
- `android/app/google-services.json` is required and is not committed. The Firebase project is `parents-data-8c0ee`.
- `lib/firebase_options.dart` is generated by FlutterFire CLI; don't edit it by hand. It only configures Android/iOS/Web, so desktop targets throw `UnsupportedError`.
- `.env` exists but is not wired into the app.
