# WTF Flutter Test

Mono-repo starter for the Guru ↔ Trainer chat and video call assessment.

## Workspace layout

- `guru_app/` — member-facing Flutter app
- `trainer_app/` — trainer-facing Flutter app
- `shared/` — reusable models, services, widgets, and utilities
- `token_server/` — local token server for 100ms
- `AI_LEDGER.md` — required AI usage log
- `ARCHITECTURE.md` — system design and sync strategy
- `DECISIONS.md` — ADRs for state, storage, and RTC

## Next steps

1. Wire both apps to the shared package.
2. Add local seed data for DK and Aarav.
3. Implement chat, scheduler, and call flows.
4. Connect the 100ms token server.
