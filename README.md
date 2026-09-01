# Field Operations App

An offline-first field operations application for a fictitious logistics company.

## Functions
- A list screen shows all Job Visits, sortable by status and by needs sync state, with a visible indicator per item showing
sync state: pending, synced, or conflict resolved.
- Job Visits must be created and edited while fully offline, and must sync to a mock backend (a local JSON file or an in
memory fake service you write; no real backend required) the next time connectivity is restored, simulated via a toggle
in a debug menu.
- A field technician can log a Job Visit: timestamp, GPS coordinate, a status (En Route, On Site, Completed, Blocked),
and an optional photo attachment.
- The app must remain usable, with no crashes and no frozen UI, if the mock sync fails midway through a batch. Partial
sync must be resumable, not restarted from zero.

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

## Local Persistence

Drift is used for local persistence because the application requires reliable structured relational data, transactional updates, queries, and durable offline storage.

## Offline First

The local database is the source of truth for application UI state.

Changes are persisted locally before synchronization is attempted.