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
  which derives the selected navigation entry from the current path.
- `AppShell` picks its navigation from the window width, on every platform
  (`AppShell.navigationFor`, breakpoints in `lib/ui/core/widgets/responsive.dart`):
  a bottom bar (Notes, Tasks, You) under 600 dp, a rail of icons from 600 dp, and a pane
  with labels from 840 dp. The rail and the pane (`SideNavigationPane`) list Notes, Tasks,
  Calendar, Archived notes, Bin, Profile & settings (`AppShell.sideIndexFor` picks the
  selected entry). Pages read `SideNavigationScope.of(context)`
  (`lib/ui/shell/side_navigation_scope.dart`, kept out of `app_shell.dart` because an import
  cycle with the pages crashes the incremental web compiler); the settings page uses it to
  hide the Bin, Archived notes and Calendar entries the side navigation already has.
- Pages are responsive: content stops growing at a readable width and stays centered
  (`CenteredContent`, `centeredPadding`, `ContentWidths`), the notes grid adds columns as
  the window widens, and forms scroll when the window is too short for them.
- Calendar (`/user/calendar`, `CalendarPage`) shows a month of tasks placed on their due
  date (or reminder date), with the selected day's tasks beside it on wide screens and
  below it on phones.
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

- Cloud: Cloud Firestore (`users/...`).
- Local: Firestore's offline cache only; there is no separate local database.

## Security/encryption

- Each user can only access `users/{uid}`; this is enforced server-side by `firestore.rules`, not by the app. See [security.md](security.md).
- Custom E2EE was removed; data relies on Firestore encryption at rest.
- Account status (blocking) lives in Firebase Auth (disabled account or `blocked` custom claim), never in a client-writable document.

## Notable technical debt / to confirm

- `.env` exists but active runtime use is not evident in startup code.
- `StyleCubit` is not persisted between launches.

## Reminders and repeating tasks

- `ReminderService` (`lib/data/services/reminder_service.dart`) schedules a local
  notification (`flutter_local_notifications`) at the reminder time of each open task.
  `main.dart` starts it with the signed-in user (`ReminderService.follow`): it rebuilds the
  whole schedule from `FirestoreService.watchTasks` whenever the tasks change, and cancels
  everything on sign-out. Reminders set on another device are scheduled the next time the
  app runs. Android and iOS only; the web has no scheduled local notifications. Exact alarms
  are used when the user allows them (Android 12+), otherwise Android may deliver the
  reminder a few minutes late.
- Completing a repeating task (from the list, or by checking its last step in the editor)
  creates its next occurrence: `CheckList.nextOccurrence` copies it unchecked, with the due
  date moved to `TaskRepeat.nextAfter` and the reminder moved by the same number of days,
  and `FirestoreService.updateTaskWithNext` writes both in one batch.

## Account deletion

`DeleteAccountCubit` asks the user to sign in again (password, or Google), deletes their
Firestore data (`FirestoreService.deleteAllUserData`: notes, tasks, feedback, profile; it
waits for the server), then the Firebase Auth account, which signs them out.

## Profile and preferences

- The display name lives in Firebase Auth (`AuthRepository.updateDisplayName`) and is
  copied to the profile document `users/{uid}` (`FirestoreService.saveUserProfile`).
  `ProfilePage` (`/user/profile`) edits it through `ProfileCubit`; accounts without a name
  show their initials (`UserAvatar`).
- `UserPreferences` (`lib/domain/models/user_preferences.dart`) is stored in
  `users/{uid}/settings/preferences` so it follows the account to every device.
  `PreferencesCubit`, created in `main.dart`, follows the signed-in user and their
  preferences live (defaults when signed out). `main.dart` puts them in a
  `PreferencesScope` above `MaterialApp`: pages read `PreferencesScope.of(context)` and
  change them with `PreferencesScope.update(context, ...)`, which saves in the background.
  Without a scope (widget tests) pages get the defaults.
- What each preference drives: `language` → `MaterialApp.locale`; `notesLayout` →
  `NotesPage`; `remindersEnabled` → `ReminderService.setEnabled`; `reminderHour` → the
  "Tomorrow"/"Next week" reminder shortcuts; `firstDayOfWeek` →
  `PreferencesScope.firstDayOfWeekIndex` (calendar, "Next week" shortcuts).
- Adding a preference: a field with a default in `UserPreferences`, read defensively in
  `fromMap`, its key and allowed values in `preferenceKeys()`/`isValidPreferences()` in
  `firestore.rules`, and a tile in `PreferencesPage`.
- There is only a dark theme for now, so there is no theme preference yet.

