# Contributing

Thanks for contributing to K.Note.

## Branch and PR workflow

1. Create a branch from `main` (or active integration branch):
   - `feat/<short-description>`
   - `fix/<short-description>`
   - `docs/<short-description>`
2. Keep changes scoped and atomic.
3. Open a PR to `main`, `master`, or `dev` according to team policy.

## PR checklist

- [ ] Code is formatted (`dart format .`).
- [ ] Analyzer passes (`flutter analyze --no-fatal-warnings --no-fatal-infos`).
- [ ] Tests pass (`flutter test`).
- [ ] Docs updated (`README.md`, `docs/*`, changelog) when behavior changes.
- [ ] No secrets accidentally committed.

## Coding standards

- Follow `flutter_lints` from `analysis_options.yaml`.
- Keep routing updates in `lib/routing/router.dart`.
- Put new code where [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) says.
- Keep auth/session logic in bloc/repository layers.
- Keep Firestore operations in `lib/data/` (`FirestoreService`, repositories).

## Commit message recommendation

Use Conventional Commits:

- `feat/ ...`
- `fix/ ...`
- `docs/ ...`
- `refactor/ ...`
- `test/ ...`
- `chore/ ...`
