# AI Ledger

Record every meaningful AI-assisted step here.

## Entry format

- Prompt #
- Tool/model used
- Intent
- Output summary or snippet
- Commit/branch reference
- Notes about how the output was adapted

## Entries

1. Initial assessment analysis and scaffold planning
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: analyse assessment brief, identify mono-repo structure, plan feature roadmap
   - Output: full implementation plan covering deps, Firebase schema, provider hierarchy, routes, HMS flow, test plan
   - Notes: used to define the starter workspace and sequencing of all 10 implementation phases

2. Repository scaffold implementation
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: create initial mono-repo folder structure and starter files
   - Output: `wtf_flutter_test/` with root docs, shared package, both app shells, and token server scaffold
   - Notes: aligned folder layout to assessment brief

3. Shared package — models and service interfaces
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: define all data models (`User`, `Message`, `CallRequest`, `SessionLog`, `DevLogEntry`), abstract service interfaces (`AuthService`, `ChatService`, `CallService`, `LogService`)
   - Output: fully typed models with `toJson`/`fromJson` and `copyWith`; clean interfaces with no Firestore leakage

4. Firebase service implementations
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: implement `FirebaseChatService`, `FirebaseCallService`, `FirebaseLogService`, `FirebaseAuthService`, `SeedService`, `DevLogger`
   - Output: Firestore-backed stream services; `SeedService` seeds DK and Aarav users on first run via SharedPreferences gate; `DevLogger` singleton writes structured logs to `dev_logs` collection
   - Notes: Firestore `fromDoc`/`toDoc` helpers kept inside service files to avoid coupling models to Firebase

5. Token server — real HMS JWT generation
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: replace stub token server with real HS256 JWT generation for 100ms
   - Output: `hms_token.js` generates management + app tokens; `hms_management.js` creates HMS rooms via REST API; `index.js` exposes `/token` and `/room` endpoints; `.env` holds credentials (not committed)
   - Notes: Android emulator reaches host at `10.0.2.2:3001`; template ID sourced from dashboard

6. GoRouter setup with auth guards (both apps)
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: wire all feature routes with redirect guard that sends unauthenticated users to `/onboarding`
   - Output: guru_app routes (`/home`, `/chat/:chatId`, `/schedule`, `/schedule/request`, `/sessions`, `/sessions/:id`, `/sessions/:id/rate`, `/call/*`, `/dev-panel`); trainer_app mirror with request management routes
   - Notes: `ref.listen` on `authNotifierProvider` triggers router refresh on auth state changes

7. Chat feature — full cross-app messaging
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: implement real-time chat with typing indicators, read receipts, and message status ticks
   - Output: `ChatNotifier` with 3-second typing debounce; `messagesProvider(chatId)` streams from Firestore; `TypingIndicator` widget with 3-dot staggered animation; `MessageBubble` with role-aware colours and status icons; batch mark-as-read on chat open
   - Notes: `chatId` is sorted join of memberId + trainerId → deterministic, collision-free

8. Scheduler + conflict detection
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: member can request calls in next-3-days time grid; trainer can approve/decline; conflict checker prevents double-booking
   - Output: `RequestCallPage` with 30-min slot grid; `hasConflict()` pure function (±1h window on approved requests); `RequestsPage` in trainer_app with inline approve/decline; approve flow creates HMS room via token server and saves `RoomMeta` to Firestore
   - Notes: past-time validation and conflict check run in `SchedulerNotifier._submit()` before writing to Firestore

9. 100ms video call flow — PreJoin → InCall → PostCall
   - Tool/model: Claude Sonnet 4.6 (Claude Code)
   - Intent: full call lifecycle using hmssdk_flutter
   - Output: `CallNotifier` implements all `HMSUpdateListener` + `HMSActionResultListener` callbacks; `PreJoinScreen` shows device check and controls; `InCallScreen` renders remote video tile + local PiP, duration timer, control bar; `PostCallScreen` auto-writes `SessionLog` on leave; member rates session (1-5 stars); trainer adds notes
   - Notes: HMS role fetched from `RoomMeta` so both apps use correct role; `_writeSessionLog()` guarded by `_sessionWritten` flag to prevent duplicate writes on multiple leave callbacks

10. DevPanel + structured logging
    - Tool/model: Claude Sonnet 4.6 (Claude Code)
    - Intent: real-time structured log viewer for debugging during assessment demo
    - Output: `DevLogger.instance.log/warn/error(tag, message)` writes to Firestore `dev_logs`; `DevPanelPage` streams and filters by `[AUTH]`, `[CHAT]`, `[RTC]`, `[SCHEDULE]` tags; long-press to copy; delete-all action
    - Notes: called inside every state transition in all notifiers; level-colour coded (blue/amber/red)

11. Lint cleanup and zero-warning pass
    - Tool/model: Claude Sonnet 4.6 (Claude Code)
    - Intent: reach `flutter analyze` zero issues on all three packages
    - Output: fixed `CardTheme` → `CardThemeData`, added `icon`/`action` params to `EmptyState`, mass-replaced `withOpacity` → `withValues`, added `@override` annotations, removed unused imports and variables, added curly braces to single-statement for-loops, removed deprecated `matchParent` from `HMSVideoView`
    - Notes: all three packages now produce "No issues found"

12. Test suite
    - Tool/model: Claude Sonnet 4.6 (Claude Code)
    - Intent: add meaningful tests beyond the generated smoke test
    - Output: 5 conflict-checker scenarios (empty list, pending-only, exact overlap, partial overlap, adjacent slot); `copyWith` round-trip tests for `Message`, `CallRequest`, `SessionLog`; all 14 tests pass across shared + guru_app
