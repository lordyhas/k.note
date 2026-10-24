# ADR 0001: Architecture Overview

- **Status**: Accepted (current implementation)
- **Date**: 2026-02-22

## Context

The application needs:

- Cross-platform Flutter UI
- Authenticated and unauthenticated flows
- Cloud synchronization
- Structured state management for forms/session/navigation

## Decision

Adopt a layered Flutter architecture based on:

- `go_router` for centralized declarative routing
- BLoC/Cubit (`flutter_bloc`) for application state
- Repository/manager classes for Firebase auth and Firestore data access
- Dedicated model mapping classes for persistence boundaries

## Consequences

### Positive

- Auth and route guards are explicit and centralized.
- State transitions are testable with bloc_test.
- Data access logic is separated from UI widgets.

### Trade-offs

- Multiple abstractions increase onboarding complexity.
- Legacy and active persistence approaches can coexist and require cleanup discipline.

## Verification pointers

> Paths below predate the restructuring in [ADR 0002](0002-project-structure.md):
> `lib/routing/router.dart`, `lib/ui/auth/bloc/authentication_bloc.dart`,
> `lib/data/repositories/auth_repository.dart`, `lib/data/services/firestore_service.dart`.


- Router and redirects: `lib/routes.dart`
- Session state handling: `lib/data/app_bloc/authentication/authentication_bloc.dart`
- Auth integration: `lib/data/app_bloc/auth_repository/repository.dart`
- Firestore data access: `lib/data/database/firebase_manager.dart`
