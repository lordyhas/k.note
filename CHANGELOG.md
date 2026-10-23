# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) where applicable.

## [Unreleased]

### Added
- Professional documentation set under `docs/` (setup, architecture, configuration, testing, style guide).
- Initial architecture ADR at `docs/decisions/0001-architecture-overview.md`.
- Contributor workflow guide in `CONTRIBUTING.md`.

- `firestore.rules`: each user can only read and write `K_NOTE/general_data/USERS/{uid}`, writes are schema-validated, and everything else is denied.
- Emulator-based security rules tests (`test/firestore_rules/`) and a `firestore-rules` CI job.
- MIT `LICENSE`.
- `docs/security.md`: threat model, how to block a user, how to deploy and test the rules.

### Changed
- `User` only holds Firebase Auth data. `isBlocked`, `verifiedAccount` and `isDataCloud` were removed: account status is managed in Firebase Auth (disabled account or `blocked` custom claim), not in a document the user can write.
- `FirebaseManager` no longer swallows Firestore errors and no longer logs note contents or user emails.
- The editor autosave writes title, text and modification time in one update (`updateNoteContent`) instead of three.
- Root `README.md` expanded with setup, configuration, troubleshooting, and contribution sections.

### Fixed
- Build with Flutter 3.47: upgrade `font_awesome_flutter` to 11 and render its icons with `FaIcon` (`IconData` is now `final`).
- App crash on start in debug: the About route under settings reused the name `about`, which go_router rejects; it now has its own name and shows `AboutPage` instead of the trash.
- The user profile is read and written by uid; it used to be looked up by email (`addUserInCloud`, now `saveUserProfile`).
- Archived and trashed notes no longer depend on a stored `email` field matching.
- `getNoteInCloud` returns `null` for a missing note instead of throwing.
- Signing in without an email (anonymous account) no longer crashes.

### Removed
- Unused and unsafe `FirebaseManager` methods: arbitrary key updates, hard-coded location writes, random-id user documents (`addUserData`), and a stream over the whole `K_NOTE` collection.
- `UserData` model.

## Process

For each pull request:
1. Add an entry under `Unreleased` using `Added`/`Changed`/`Fixed`/`Removed`.
2. Keep entries factual and tied to merged code.
3. During release, move `Unreleased` entries to a versioned section (`[x.y.z] - YYYY-MM-DD`).
4. Keep links/sections aligned with repository tags when tags are created.
