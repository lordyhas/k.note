# ADR 0002: Project structure

- **Status**: Accepted
- **Date**: 2026-10-24
- **Updates**: the file paths listed in [ADR 0001](0001-architecture-overview.md)

## Context

The code had grown since 2022 without a consistent layout:

- blocs, models and Firebase access were mixed under `lib/data/`, screens under
  `lib/src/pages/` and `lib/src/pages/pages/`, other screens at the root of `lib/`;
- barrel files and `part`-based screen libraries hid where symbols came from;
- about 2,500 lines were unreachable from `main.dart` or fully commented out
  (old editor, splash and log pages, drawer, ObjectBox manager, unused models),
  along with unused dependencies (`hive`, `hive_flutter`, `hydrated_bloc`);
- names did not say what a class was (`FirebaseManager`, `HomeScreen` for the
  notes tab, `TextEditor` for the note editor, `NoteTrash`).

## Decision

Adopt the layered structure of the official Flutter architecture guide
(docs.flutter.dev/app-architecture): `domain/models`, `data/repositories` and
`data/services`, `ui/<feature>` with `ui/core` for shared UI, plus `routing/`,
`config/` and `utils/`. BLoC/Cubit play the role of the guide's view models and
live in `ui/<feature>/bloc/`. `test/` mirrors `lib/`.

The layout itself is documented in [PROJECT_STRUCTURE.md](../../PROJECT_STRUCTURE.md).

Along with the move:

- imports are direct `package:knote/...` imports; barrel files and `part`-based
  screen libraries are removed (`part` stays for bloc events and states);
- screens are named `*Page` after their role, and `FirebaseManager` becomes
  `FirestoreService`; route names and paths do not change;
- dead code and unused dependencies are deleted. They remain in git history.

A feature-first layout (`features/<feature>/{bloc,view}`) was considered. The
official guide's layered layout was preferred as the reference most Flutter
developers will recognise.

## Consequences

### Positive

- A file's location says its layer and feature; there are rules for where new
  code goes.
- No dead code to read around or keep compiling.
- Tests are found next to the path of the code they cover.

### Trade-offs

- Every file moved once: branches started before this change need a rebase,
  and `git log --follow` is needed to see a file's history across the move.
- Code of one feature is split between `domain/`, `data/` and `ui/<feature>/`.
