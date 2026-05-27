# Architecture

## Overview

This project is a mono-repo with:

- `guru_app/` for the member experience
- `trainer_app/` for the trainer experience
- `shared/` for common domain models, service abstractions, widgets, and utilities
- `token_server/` for local 100ms token generation

## Early design decisions

- Shared code is isolated in a real Dart package so both apps use the same models and contracts.
- Storage is intended to be local-first, with a lightweight live sync layer for cross-app updates.
- The initial implementation will use mock/dev-friendly scaffolding where external credentials are not yet available.

## Open implementation point

The assessment requires real-time chat and request updates across both apps while they are running. Local persistence alone is not enough, so a live sync transport still needs to be selected and implemented.

## 100ms approach

- Token requests will flow through `token_server/`.
- The first pass uses a local endpoint interface so the Flutter apps can be wired before final credentials are available.
- The final token format/SDK details should be documented once the 100ms integration is finalized.
