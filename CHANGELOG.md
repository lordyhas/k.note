# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) where applicable.

## [Unreleased]

### Fixed
- Google Sign-In failed ("not configured for this build") in release builds: the app's `res/raw/keep.xml` (keeping the notification icon) replaced the one from `google_sign_in_android`, so resource shrinking removed `default_web_client_id`. The app's file is now `knote_keep.xml` and keeps both. The `GOOGLE_SERVICES_JSON_BASE64` secret was also refreshed, and the release workflow now fails when the config or the APK lacks the web client ID. Version 0.5.9.

### Security
- Email verification. Signing up with an email address sends a verification link, and the app keeps the account on a "Verify your email" page (resend the link, check again, log out) until it is opened. `firestore.rules` now requires a verified email (`email_verified` in the token), so an account created with someone else's address cannot use the app. Google accounts are already verified. Existing unverified email accounts must verify before seeing their notes again.

### Added
- Profile page (Settings > My profile): edit the display name, see the email, sign-in method and join date. Accounts without a photo show their initials, and accounts without a name no longer show "null" in the settings.
- Preferences page (Settings > Preferences), saved to the account (`users/{uid}/settings/preferences`) and applied on every device: language (device, English, French), notes layout (list or grid, also remembered from the notes screen toggle), task reminders on or off, default reminder time for "Tomorrow" and "Next week", and first day of the week (calendar and "Next week").
- Release workflow: merging into `production` builds a signed app bundle and APK and publishes them as a GitHub release (`.github/workflows/release.yml`, see `docs/release.md`). New upload key (alias `lordyhas`), registered in Firebase.
- Task reminders: a notification at the reminder time of each open task, on Android (and iOS once configured), scheduled again when tasks change on any device and cancelled on sign-out. Not available on the web.
- Repeating tasks: completing one adds its next occurrence, due on the next date of its rule, with its reminder moved by the same number of days and its steps unchecked.
- Calendar page: a month view of tasks by due date (or reminder date), with the selected day's tasks; side by side on wide screens.
- "Forgot password?" on the login page, and "Change password" in the settings for email accounts: both send a reset link.
- Delete account in the settings: after signing in again (password or Google), deletes the notes, tasks, feedback, profile and Firebase Auth account.
- The Feedback page sends the message to the team (`feedback/{id}` in Firestore, allowed by `firestore.rules`), and is linked from the settings.
- Web layout: in a wide browser window, a drawer on the left (Notes, Tasks, Calendar, Archived notes, Bin, Profile & settings) replaces the bottom bar, and the settings page no longer repeats Bin, Archived notes and Calendar. Phones and narrow windows keep the bottom bar.
- French translation. The app follows the device language (English or French, English otherwise). All text lives in `lib/ui/core/localization/app_en.arb` and `app_fr.arb` (`flutter gen-l10n`); dates, weekdays and times are formatted for the language.
- Tooltips on every icon-only button (also read by screen readers), and a labelled 48 dp touch target for the task completion circle.
- Note search: the search bar on the notes screen filters notes live by title and text, ignoring case and accents; back clears the search.
- Undo after archiving a note, moving it to the bin, or swiping a task away. Moving a note to the bin no longer asks for confirmation.
- Quick add on the tasks screen: the + button opens an "Add a task" bar above the keyboard with due date, reminder and repeat options; tasks are added without leaving the page.
- "Set due date" in the task quick add opens a Today / Tomorrow / Next week / Pick a date menu instead of going straight to the calendar.
- "Remind me" in the task quick add opens a Later today / Tomorrow / Next week / Pick a date & time menu.
- "Repeat" offers Daily, Weekdays, Weekly, Monthly, Yearly and Custom (every N days, weeks, months or years, with weekdays for weeks). Custom rules are stored in `CheckList.repeat` as `custom:<n>:<unit>[:<days>]` (see `TaskRepeat`); existing values are unchanged.
- Professional documentation set under `docs/` (setup, architecture, configuration, testing, style guide).
- Initial architecture ADR at `docs/decisions/0001-architecture-overview.md`.
- Contributor workflow guide in `CONTRIBUTING.md`.

- `firestore.rules`: each user can only read and write `users/{uid}`, writes are schema-validated, and everything else is denied.
- Emulator-based security rules tests (`test/firestore_rules/`) and a `firestore-rules` CI job.
- MIT `LICENSE`.
- `docs/security.md`: threat model, how to block a user, how to deploy and test the rules.

### Changed
- License: the project is now under the GNU Affero General Public License v3.0 (`AGPL-3.0-only`) instead of MIT. Anyone who distributes the app, or runs a modified version used over a network, must provide its source code under the same license. Versions up to 0.5.9 remain under MIT.
- `google_sign_in` 6 → 7 (`GoogleSignIn.instance`, `authenticate()`).
- Settings only show working entries: Change password (email accounts), Send feedback, About, version, Log out, Delete account.
- Android build: Android Gradle Plugin 8.13.0 → 9.0.1 and Kotlin 2.2.20 → 2.3.20, as required by upcoming Flutter versions. The app module uses AGP's built-in Kotlin (`android.builtInKotlin=true`) instead of applying the Kotlin Gradle Plugin.
- `package_info_plus` 8 → 10.
- The app now uses its own Firebase project, `k8note`, instead of the project it shared with another app (`parents-data-8c0ee`). Existing accounts and data were not migrated. The leftover iOS config, which still pointed to the old project, was removed.
- Firestore data moved from `K_NOTE/general_data/USERS/{uid}` (a namespace needed in the shared project) to `users/{uid}`, with `notes` and `tasks` below it.
- Auth failures carry an `AuthError` code, translated by the UI, instead of an English sentence shown as is. Task repeat rules are described by the UI (`repeatText`) instead of `TaskRepeat.describe()`.
- Colors are read from the `AppColors` theme extension instead of literals spread across widgets; the theme moved to `AppTheme.dark`. The look is unchanged.
- Task due dates in the list read Yesterday / Today / Tomorrow or a short date ("Fri, Oct 30") instead of "30/10".
- Empty and error states of the tasks screen explain what to do instead of "No tasks found" or a raw error.
- The notes, archive and bin lists update live (`FirestoreService.watchNotes`, `watchArchivedNotes`, `watchDeletedNotes`), most recently modified first.
- The note editor saves one second after typing stops, when the page is left by any means (including the system back button) and when the app goes to the background, instead of every 10 changes and on the done button only. Opening a note and leaving it unchanged no longer writes it.
- Project reorganized into the Flutter app-architecture layout (`config/`, `routing/`, `domain/models/`, `data/repositories|services/`, `ui/<feature>/{bloc,widgets}`, `ui/core/`, `utils/`), with `test/` mirroring `lib/`. Barrel files and `part`-based screen libraries replaced by direct imports. Classes renamed after their role (`FirebaseManager` → `FirestoreService`, `HomeScreen` → `NotesPage`, `TextEditor` → `NoteEditorPage`, `TaskScreen` → `TasksPage`, `SettingProfileScreen` → `SettingsPage`, `NavigationHomeScreen` → `AppShell`, ...); route paths unchanged. See `PROJECT_STRUCTURE.md` and ADR 0002.
- `User` only holds Firebase Auth data. `isBlocked`, `verifiedAccount` and `isDataCloud` were removed: account status is managed in Firebase Auth (disabled account or `blocked` custom claim), not in a document the user can write.
- `FirebaseManager` no longer swallows Firestore errors and no longer logs note contents or user emails.
- The editor autosave writes title, text and modification time in one update (`updateNoteContent`) instead of three.
- Root `README.md` expanded with setup, configuration, troubleshooting, and contribution sections.

### Fixed
- The login and sign-up buttons never turned on: they only redrew when a request started or ended, not when the form became valid. They now use the app's accent color when they can be pressed and are clearly faded otherwise (the enabled and disabled greys looked alike), and "Done" on the password keyboard logs in.
- The login button stayed disabled for valid passwords: the login form applied the sign-up strength rule, which only allowed letters and digits. Login now only needs a non-empty password (`LoginPassword`), sign-up accepts symbols and accents (still 8+ characters with a letter and a digit), and a trailing space after the email is ignored.
- Logging out left the confirmation dialog open and stayed on the home page until a second try. The dialog now closes first, and the router sends signed-out users to the login page from any screen (`redirectForAuth`) instead of the page navigating while the sign-out is still running. The unused `/logout` route was removed.
- Mixed French and English text and typos ("Welcome to konte", "Welcome to K22D", "Find a documents", "Se deconnecter", ...).
- The About screen printed its update date as a raw timestamp.
- The bin and archive showed the raw Quill JSON of notes instead of their text.
- A task due today was shown as overdue (red) all day.
- Changing a note's color could overwrite edits not yet saved.
- The note actions sheet overflowed on small screens.
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
- Buttons and pages that did nothing: Invite a friend, Facebook sign-in, Edit profile, the dark mode / notifications / email update switches, More, About us, the notifications bell on the notes screen, "Change color" and "Saving mode" in the note actions, the tasks "More options" menu, and the unreachable Help and Offline notes pages.
- The unused `file_picker` dependency, which did not compile with Android Gradle Plugin 9.
- The unused `device_info_plus` dependency.
- `LanguageBloc` and `strings.dart`, left over from another app and only used by the About screen.
- Dead code unreachable from `main.dart` or unused: old text editor, splash/log/generate pages, drawer, calendar screen, ObjectBox `DatabaseManager`, `AppData`/`LocationData`/`SettingData` models, empty files; and the unused `hive`, `hive_flutter` and `hydrated_bloc` dependencies.
- Unused and unsafe `FirebaseManager` methods: arbitrary key updates, hard-coded location writes, random-id user documents (`addUserData`), and a stream over the whole `K_NOTE` collection.
- `UserData` model.

## Process

For each pull request:
1. Add an entry under `Unreleased` using `Added`/`Changed`/`Fixed`/`Removed`.
2. Keep entries factual and tied to merged code.
3. During release, move `Unreleased` entries to a versioned section (`[x.y.z] - YYYY-MM-DD`).
4. Keep links/sections aligned with repository tags when tags are created.
