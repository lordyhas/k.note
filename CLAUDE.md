# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get                                         # install dependencies
flutter analyze --no-fatal-warnings --no-fatal-infos    # lint (same flags as CI)
flutter test                                            # all tests
flutter test test/unit/data/model/note_model_test.dart  # single test file
flutter test --plain-name "some test name"              # single test by name
dart format lib/ test/                                  # format
flutter run -d chrome | -d android                      # run
flutter build apk --release / appbundle --release / web # build
```

CI (`.github/workflows/`) runs `pub get` → `analyze` (non-fatal warnings/infos) → `test` on pushes/PRs to `main`, `master`, `dev`, `production`.

## Architecture

Layered BLoC + Repository: UI (`lib/src/`, plus `lib/navigation_home_screen.dart`) → blocs/cubits (`lib/data/app_bloc/`, `lib/data/*.dart`) → data (`lib/data/database/`, `lib/data/app_bloc/auth_repository/`).

Barrel files are the usual import points: `lib/data/app_bloc.dart` (blocs + `AppBlocObserver`), `lib/data/authentication_repository.dart` (auth repo + `User`), `lib/data/database.dart`, `lib/data/values.dart`, `lib/widgets.dart`, `lib/src/pages/screens.dart`.

### Bootstrap (`lib/main.dart`)

`Firebase.initializeApp` → create `AuthRepository` and await its first `user` emission → `Bloc.observer = AppBlocObserver()` → `RepositoryProvider<AuthRepository>` → `BlocProvider<AuthenticationBloc>` → `MultiBlocProvider(LanguageBloc, StyleCubit)` → `MaterialApp.router`. Locales are `en` and `fr`. The theme is hard-coded dark. `FlutterQuillLocalizations.delegate` is required by the editor.

### Navigation (`lib/routes.dart`)

All routes live in `AppRouter.routes(...)`. They are GoRouter routes that refresh on `GoRouterRefreshStream(authBloc.stream)`, with `redirectLimit: 1`.
- `/` redirects to `/home` or `/login` based on `AuthenticationStatus`. `/login` redirects to `/home` when authenticated.
- A `ShellRoute` wraps the authenticated screens in `NavigationHomeScreen` (drawer + bottom nav). Most feature pages are **sub-routes of `/home`**. Settings (with trash) is a sibling top-level shell route.
- Full-screen editors (`TextEditor`, `TaskEditor`) set `parentNavigatorKey: key` to escape the shell. They receive their model through `state.extra` (`NoteModel?` / `CheckList?`; `null` means create new).
- Route path segments come from each screen's static `routeName`.

### State

- `AuthenticationBloc` listens to `AuthRepository.user` and drives redirects.
- `LoginCubit` and `SignUpCubit` handle form state using `formz` inputs (`login_models.dart`).
- `LanguageBloc` is actually a plain `Cubit<Language>` defined in `lib/data/value/strings.dart`. `StyleCubit` is in `lib/data/theme_and_language_cubit.dart`. Neither is persisted: `hydrated_bloc` and `hive` are dependencies but are **not initialized or used**.
- `navigation_controller_cubit.dart` holds the drawer and bottom-nav screen state.

### Auth (`lib/data/app_bloc/auth_repository/`)

`AuthRepository` wraps `firebase_auth` and `google_sign_in` (email/password, Google). It exposes the app's own `User` model from `user.dart`, which is not `firebase_auth.User`. That model carries app fields such as `isAnonymous`, `isBlocked`, `isDataCloud` and `verifiedAccount`, and `User.empty` means signed out.

### Data (`lib/data/database/`)

- `FirebaseManager` is **not a singleton**. Screens construct it per user with `FirebaseManager.user(user)` (see `home_screen.dart`, `new_text_editor_page.dart`). Every constructor accepts an optional `FirebaseFirestore`, and tests inject `FakeFirebaseFirestore` through it. Paths: `K_NOTE/general_data/USERS/{userId}/notes` and `.../tasks`. Custom E2EE / `keys/master_key` handling was removed, so the app relies on Firestore's at-rest encryption.
- Models (`model/note_model.dart`): `NoteModel` has the fields `savingModeValue` (index into `SavingMode` cloud/local/cloudAndLocal), `isLocked`, `isDeleted` and `isArchived`. `CheckList`/`TodoItem` are the task models. All models implement `DataToMap` (`fromMap`/`asMap`), and `fromMap` is deliberately defensive about malformed docs.
- `database_manager.dart` is legacy ObjectBox code and is entirely commented out. There is currently no working local persistence layer.

### UI

- Screens live in `lib/src/pages/` and `lib/src/pages/pages/`, login screens in `lib/src/pages/login/`, and the drawer in `lib/src/pages/custom_drawer/`.
- `new_text_editor_page.dart` (`TextEditor`, flutter_quill) is the live editor. `old_text_editor_page.dart` is dead code.

### Tests (`test/unit/`)

Tests mirror `lib/data/` and also include `routing/app_router_test.dart`. They use `bloc_test`, `mocktail` (`MockAuthRepository extends Mock implements AuthRepository`) and `fake_cloud_firestore` for `FirebaseManager`.

## Conventions

- Keep routes in `lib/routes.dart`. Keep auth logic in bloc/repository layers and Firestore access in data managers, never in widgets.
- Branches use `feat/`, `fix/`, `docs/` or `refactor/`. Commits follow Conventional Commits. PRs usually target `dev`.
- `avoid_print` is enabled; use `debugPrint` (as `AppBlocObserver` does) instead of `print`.
- When behavior changes, update `README.md`, `docs/*` and `CHANGELOG.md`.

## Firebase / platform

- `android/app/google-services.json` is required and is not committed. The Firebase project is `parents-data-8c0ee`.
- `lib/firebase_options.dart` is generated by FlutterFire CLI; don't edit it by hand. It only configures Android/iOS/Web, so desktop targets throw `UnsupportedError`.
- `.env` exists but is not wired into the app.
