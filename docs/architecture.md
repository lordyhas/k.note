# Architecture

## High-level design

K.Note follows the layered structure of the official Flutter architecture guide
(see [PROJECT_STRUCTURE.md](../PROJECT_STRUCTURE.md) and
[ADR 0002](decisions/0002-project-structure.md)):

- **UI layer** (`lib/ui/`): screens and widgets per feature (`auth`, `notes`,
  `tasks`, `settings`), with their blocs/cubits in `ui/<feature>/bloc/`, and shared
  theme, localization and widgets in `ui/core/`.
- **Data layer** (`lib/data/`): `AuthRepository` (Firebase Auth, Google Sign-In)
  and `FirestoreService` (notes, tasks, profile).
- **Domain models** (`lib/domain/models/`): plain data classes mapped to and from
  Firestore documents.

## Application bootstrap

`main.dart` performs:

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Firebase.initializeApp(...)`
3. Auth repository creation
4. `AuthenticationBloc` wiring at app root
5. Router bootstrapping via `AppRouter.routes(...)`

## Routing and navigation

- Routing is centralized in `lib/routing/router.dart` via `go_router`.
- Entry route (`/`) redirects based on `AuthenticationBloc` status.
- A `ShellRoute` hosts the authenticated tabs (notes, tasks, settings) in `AppShell`,
  which derives the selected bottom bar tab from the current path.
- Full-screen editors (`NoteEditorPage`, `TaskEditorPage`) open above the shell.

## State management

Key state objects:

- `AuthenticationBloc`: user session state and logout flow.
- `LoginCubit` / `SignUpCubit`: auth form state + submission status.
- `StyleCubit`: app UI preferences. The language follows the device (English or French) through `AppLocalizations`.

`AuthRepository.user` is a stream backed by Firebase auth state changes and cached current user.

## Data flow (notes)

Typical note flow:

1. UI action from screen/widget.
2. Data operation executed through `FirestoreService`, usually wrapped in
   `saveInBackground` so the UI does not wait for the server (offline support).
3. Firestore update/read in user-scoped subcollections; lists listen live with
   `snapshots()`.
4. Model mapping (`NoteModel` / `CheckList` `fromMap` / `asMap`).

## Persistence model

- Cloud: Cloud Firestore (`K_NOTE/general_data/USERS/...`).
- Local: Firestore's offline cache only; there is no separate local database.

## Security/encryption

- Each user can only access `K_NOTE/general_data/USERS/{uid}`; this is enforced server-side by `firestore.rules`, not by the app. See [security.md](security.md).
- Custom E2EE was removed; data relies on Firestore encryption at rest.
- Account status (blocking) lives in Firebase Auth (disabled account or `blocked` custom claim), never in a client-writable document.

## Notable technical debt / to confirm

- `.env` exists but active runtime use is not evident in startup code.
- `StyleCubit` is not persisted between launches.
