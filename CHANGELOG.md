# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) where applicable.

## [Unreleased]

### Added
- Microsoft To Do style quick add on the tasks screen: the + button opens an "Add a task" bar above the keyboard with due date, reminder and repeat options; tasks are added without leaving the page.
- "Set due date" in the task quick add opens a Today / Tomorrow / Next week / Pick a date menu, as in Microsoft To Do, instead of going straight to the calendar.
- "Remind me" in the task quick add opens a Later today / Tomorrow / Next week / Pick a date & time menu, as in Microsoft To Do.
- "Repeat" offers Daily, Weekdays, Weekly, Monthly, Yearly and Custom (every N days, weeks, months or years, with weekdays for weeks). Custom rules are stored in `CheckList.repeat` as `custom:<n>:<unit>[:<days>]` (see `TaskRepeat`); existing values are unchanged.
- Professional documentation set under `docs/` (setup, architecture, configuration, testing, style guide).
- Initial architecture ADR at `docs/decisions/0001-architecture-overview.md`.
- Contributor workflow guide in `CONTRIBUTING.md`.

- `firestore.rules`: each user can only read and write `K_NOTE/general_data/USERS/{uid}`, writes are schema-validated, and everything else is denied.
- Emulator-based security rules tests (`test/firestore_rules/`) and a `firestore-rules` CI job.
- MIT `LICENSE`.
- `docs/security.md`: threat model, how to block a user, how to deploy and test the rules.

### Changed
- Project reorganized into the Flutter app-architecture layout (`config/`, `routing/`, `domain/models/`, `data/repositories|services/`, `ui/<feature>/{bloc,widgets}`, `ui/core/`, `utils/`), with `test/` mirroring `lib/`. Barrel files and `part`-based screen libraries replaced by direct imports. Classes renamed after their role (`FirebaseManager` → `FirestoreService`, `HomeScreen` → `NotesPage`, `TextEditor` → `NoteEditorPage`, `TaskScreen` → `TasksPage`, `SettingProfileScreen` → `SettingsPage`, `NavigationHomeScreen` → `AppShell`, ...); route paths unchanged. See `PROJECT_STRUCTURE.md` and ADR 0002.
- `User` only holds Firebase Auth data. `isBlocked`, `verifiedAccount` and `isDataCloud` were removed: account status is managed in Firebase Auth (disabled account or `blocked` custom claim), not in a document the user can write.
- `FirebaseManager` no longer swallows Firestore errors and no longer logs note contents or user emails.
- The editor autosave writes title, text and modification time in one update (`updateNoteContent`) instead of three.
- Root `README.md` expanded with setup, configuration, troubleshooting, and contribution sections.

### Fixed
- Bottom navigation bar: the highlighted tab now follows the page shown, including after the back button; switching tabs no longer stacks pages, and back from You returns to Notes instead of closing the app.
- Failed Firestore writes (e.g. permission denied) are no longer lost silently: `saveInBackground` reports them in a snack bar with Retry, and the task quick add puts a rejected task back in its form. Writes still do not wait for the server, so the app keeps working offline.
- "Move in archive" on the home screen archived nothing and moved the note to the bin; it now archives it.
- Deleting a task from the task editor while offline no longer leaves the editor open forever waiting for the server.
- Tasks screen updates live: a task added, edited or deleted shows up immediately instead of after leaving and reopening the page (`FirebaseManager.watchTasks`).
- App bars stay transparent when content scrolls under them (Material 3 tinted them with the primary color).
- Settings profile photo: show a placeholder when the account has no photo or it cannot be downloaded (offline), instead of loading the URL `"null"` and logging an image exception.
- Build with Flutter 3.47: upgrade `font_awesome_flutter` to 11 and render its icons with `FaIcon` (`IconData` is now `final`).
- App crash on start in debug: the About route under settings reused the name `about`, which go_router rejects; it now has its own name and shows `AboutPage` instead of the trash.
- The user profile is read and written by uid; it used to be looked up by email (`addUserInCloud`, now `saveUserProfile`).
- Archived and trashed notes no longer depend on a stored `email` field matching.
- `getNoteInCloud` returns `null` for a missing note instead of throwing.
- Signing in without an email (anonymous account) no longer crashes.

### Removed
- Dead code unreachable from `main.dart` or unused: old text editor, splash/log/generate pages, drawer, calendar screen, ObjectBox `DatabaseManager`, `AppData`/`LocationData`/`SettingData` models, empty files; and the unused `hive`, `hive_flutter` and `hydrated_bloc` dependencies.
- Unused and unsafe `FirebaseManager` methods: arbitrary key updates, hard-coded location writes, random-id user documents (`addUserData`), and a stream over the whole `K_NOTE` collection.
- `UserData` model.

## Process

For each pull request:
1. Add an entry under `Unreleased` using `Added`/`Changed`/`Fixed`/`Removed`.
2. Keep entries factual and tied to merged code.
3. During release, move `Unreleased` entries to a versioned section (`[x.y.z] - YYYY-MM-DD`).
4. Keep links/sections aligned with repository tags when tags are created.
