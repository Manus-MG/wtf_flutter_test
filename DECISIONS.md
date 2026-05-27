# Decisions

## ADR 1 — State management

**Status:** Accepted

**Decision:** Use Riverpod 2.x for app state and dependency injection.

**Why:** Scales cleanly for chat state, scheduler state, and call state without heavy boilerplate. `StateNotifierProvider` for mutable state, `StreamProvider` for Firestore streams, `Provider` for services.

## ADR 2 — Cross-app sync transport

**Status:** Accepted

**Decision:** Use Firebase Firestore as the real-time sync layer between guru_app and trainer_app.

**Why:** Assessment allows Firebase. Both apps share one Firestore project, so chat messages, call requests, room metadata, and session logs are visible to both sides without any custom server. Firestore's `snapshots()` API maps directly to Riverpod `StreamProvider`.

**Trade-off:** Firestore costs money at scale; acceptable for a demo and assessment scope.

## ADR 3 — RTC strategy

**Status:** Accepted

**Decision:** Use 100ms SDK (`hmssdk_flutter`) for video calls with a local Node.js token server during development.

**Why:** Assessment explicitly requires 100ms. Local token server at `http://10.0.2.2:3001` generates real HS256 JWTs so the SDK joins actual 100ms rooms. This keeps the implementation fully testable on-device without a deployed backend.

**Token server flow:**
1. Trainer approves request → `POST /room` creates HMS room → `RoomMeta` saved to Firestore.
2. Both apps fetch `GET /token?userId=&role=&roomId=` on pre-join → SDK joins room.

## ADR 4 — Auth approach

**Status:** Accepted

**Decision:** Use SharedPreferences-backed auth (no network auth) with hardcoded users (DK / Aarav) for the assessment scope.

**Why:** The assessment defines exactly two users. A full Firebase Auth flow would add complexity with no assessment benefit. `FirebaseAuthService` stores the selected user as JSON in SharedPreferences; `SeedService` ensures both user docs exist in Firestore on first run.
