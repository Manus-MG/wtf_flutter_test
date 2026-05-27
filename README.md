# WTF Flutter Test — Guru ↔ Trainer Chat + Video Call

## Workspace layout

```
wtf_flutter_test/
├── guru_app/        Member (DK) Flutter app
├── trainer_app/     Trainer (Aarav) Flutter app
├── shared/          Models, service interfaces, Firebase implementations, widgets
├── token_server/    Node.js server — 100ms JWT generation + room creation
├── AI_LEDGER.md     AI usage log (12 entries)
├── ARCHITECTURE.md  System design: Firestore schema, call flow, provider hierarchy
└── DECISIONS.md     ADRs 1-4
```

---

## Prerequisites

- Flutter 3.x (`flutter --version`)
- Node.js 18+ (`node --version`)
- Android emulator or physical device (minSdk 21)
- Firebase project `testing-6edfc` (Firestore in test mode)

---

## 1. Token server

```bash
cd token_server
npm install

# Copy env template and fill in your 100ms credentials
cp .env.example .env
# Edit .env: HMS_ACCESS_KEY, HMS_SECRET, HMS_TEMPLATE_ID

node src/index.js
# Server starts on http://localhost:3001

# Verify:
curl "http://localhost:3001/health"
curl "http://localhost:3001/token?userId=dk&role=member&roomId=test"
```

---

## 2. Flutter apps

Both apps share the same setup steps.

```bash
# Shared package (run once)
cd shared && flutter pub get

# guru_app
cd guru_app
flutter pub get
flutter run

# trainer_app (separate terminal)
cd trainer_app
flutter pub get
flutter run
```

On first launch, each app shows an onboarding screen:
- **guru_app** → "Start as DK" → signs in as member
- **trainer_app** → "Sign in as Aarav" → signs in as trainer

`SeedService` writes both user docs and the initial chat doc to Firestore on first run.

---

## 3. Run tests

```bash
cd shared && flutter test        # 6 model + validation tests
cd guru_app && flutter test      # 5 conflict-checker + smoke tests
cd trainer_app && flutter test   # smoke test
```

---

## 4. Manual test flow

1. Launch both apps on the same device/emulator pair (or two emulators).
2. **DK** opens Chat → sends a message → **Aarav** sees it in real time.
3. **Aarav** replies → typing indicator appears for DK.
4. **DK** opens Schedule → requests a call (pick a future slot, add a note).
5. **Aarav** opens Requests → taps Approve → HMS room is created.
6. Both apps show "Join Call" button 10 min before the session.
7. Both tap Join → pre-join screen → Join → video call starts.
8. End call → session auto-logged → DK rates it → Aarav adds notes.
9. Both see the session in Sessions tab.
10. Open Dev Panel (⋮ button) → view structured logs filtered by tag.

---

## Firebase project

Project ID: `testing-6edfc`
Both apps are registered and include `google-services.json`.
Firestore rules: allow read/write (test mode).
