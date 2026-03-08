# Architecture

## High-level design

K.Note follows a pragmatic layered structure:

- **Presentation layer**: widgets and screens under `lib/src/`.
- **Application/state layer**: blocs/cubits in `lib/data/app_bloc/`.
- **Data layer**: authentication repository + Firestore/local managers under `lib/data/`.

## Application bootstrap

`main.dart` performs:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp(...)`
3. Auth repository creation
4. `AuthenticationBloc` wiring at app root
5. Router bootstrapping via `AppRouter.routes(...)`

## Routing and navigation

- Routing is centralized in `lib/routes.dart` via `go_router`.
- Entry route (`/`) redirects based on `AuthenticationBloc` status.
- A `ShellRoute` hosts authenticated app sections under `NavigationHomeScreen`.
- Important areas include home, settings, note editor(s), task screen/editor, archived/offline/trash pages.

## State management

Key state objects:

- `AuthenticationBloc`: user session state and logout flow.
- `LoginCubit` / `SignUpCubit`: auth form state + submission status.
- `LanguageBloc` and `StyleCubit`: app UI preferences.

`AuthRepository.user` is a stream backed by Firebase auth state changes and cached current user.

## Data flow (notes)

Typical note flow:

1. UI action from screen/widget.
2. Data operation executed through `FirebaseManager`.
3. Firestore update/read in user-scoped subcollections.
4. Note model mapping (`NoteModel.fromMap` / `asMap`).
5. Optional encryption/decryption on note title/text values.

## Persistence model

- Cloud: Cloud Firestore (`K_NOTE/general_data/USERS/...`).
- Local: additional local persistence dependencies exist (`hive`, `hydrated_bloc`); verify active paths per feature when changing persistence behavior.

## Security/encryption

- Encryption support is implemented via `EncryptionService` and key storage under Firestore user keys.
- Home screen triggers setup/unlock dialogs depending on local key status and remote key presence.

## Notable technical debt / to confirm

- Some files contain legacy/commented sections (ObjectBox remnants, alternate editor page, etc.).
- `.env` exists but active runtime use is not evident in startup code.
