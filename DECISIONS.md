# Decisions

## ADR 1 — State management

**Status:** Proposed

**Decision:** Use Riverpod for app state and dependency injection.

**Why:** It scales cleanly for the app shells, chat state, scheduler state, and call state without forcing heavy boilerplate.

## ADR 2 — Local storage

**Status:** Proposed

**Decision:** Use a local database layer for durable data and a stream-based in-memory layer for live updates.

**Why:** The app needs offline-friendly persistence plus a live feel for chat, requests, and session logs.

## ADR 3 — RTC strategy

**Status:** Proposed

**Decision:** Use 100ms for the call layer with a local token server during development.

**Why:** The assessment explicitly requires 100ms, and the local token server keeps the implementation testable on-device.
