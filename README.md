# Field Operations App

An offline-first field operations application for a fictitious logistics company.

## Architecture


The application uses feature-first Clean Architecture.

```text
lib/
├── core/
├── database/
└── features/

Each major feature is divided into:

data/
domain/
presentation/
```
State management is handled with BLoC/Cubit.

## State Management

BLoC was selected because the application contains several asynchronous workflows, including offline persistence, synchronization, background location tracking, notifications, and connectivity changes.

BLoC provides explicit event/state transitions and keeps UI state separate from business logic. Feature-level BLoCs also allow the application to scale without introducing a single global state object.

## Dependency Injection

GetIt is used for dependency injection which allows for easier decoupling of code and making clean architecture easier.

## Local Persistence

Drift is used for local persistence because the application requires reliable structured relational data, transactional updates, queries, and durable offline storage.

## Offline First

The local database is the source of truth for application UI state.

Changes are persisted locally before synchronization is attempted.