# Architecture

## Overview

Mono-repo with four packages:

| Package | Role |
|---|---|
| `guru_app/` | Member (DK) Flutter app |
| `trainer_app/` | Trainer (Aarav) Flutter app |
| `shared/` | Domain models, service interfaces, Firebase implementations, shared widgets |
| `token_server/` | Node.js server — generates 100ms JWTs and creates HMS rooms |

---

## Firestore Collections

```
users/{userId}
  id, role, name, email, assignedTrainerId?
  isTyping, typingChatId          ← live typing state

chats/{chatId}                    ← chatId = sorted join: "user_dk_user_aarav"
  lastMessage, lastMessageAt
  unreadCountMember, unreadCountTrainer

chats/{chatId}/messages/{msgId}
  id, chatId, senderId, receiverId, text, createdAt, status

call_requests/{requestId}
  id, memberId, trainerId, scheduledFor, note, status, declineReason?

room_meta/{requestId}
  id, hmsRoomId, hmsRoleMember, hmsRoleTrainer

session_logs/{logId}
  id, memberId, trainerId, startedAt, endedAt, durationSec
  rating?, memberNotes?, trainerNotes?

dev_logs/{logId}
  id, level (info|warn|error), tag, message, createdAt
```

---

## Token Server Flow

```
Trainer approves request
  → POST http://10.0.2.2:3001/room
      body: { name, templateId }
  → 100ms API creates room, returns roomId
  → trainer_app writes RoomMeta to Firestore

Both apps, on PreJoinScreen:
  → GET http://10.0.2.2:3001/token?userId=&role=&roomId=
  → server builds HS256 JWT (jsonwebtoken, 24h expiry)
  → Flutter app calls HMSSDK.join(config)
```

---

## Provider Hierarchy (both apps)

```
firestoreProvider          → FirebaseFirestore.instance
sharedPrefsProvider        → SharedPreferences (overridden in main)
authServiceProvider        → FirebaseAuthService
chatServiceProvider        → FirebaseChatService
callServiceProvider        → FirebaseCallService
logServiceProvider         → FirebaseLogService
authNotifierProvider       → StateNotifierProvider<AuthNotifier, AuthState>
currentUserProvider        → Provider<User?> (derived from authNotifierProvider)
guruRouterProvider         → GoRouter (redirect on currentUser == null)
```

---

## Call Lifecycle

```
CallPhase.idle
  → initCall() fetches RoomMeta + JWT
CallPhase.joining
  → HMSSDK.join()
CallPhase.inCall
  → onJoin() callback; render HMSVideoView
CallPhase.postCall
  → onSuccess(leave) or onRemovedFromRoom()
  → _writeSessionLog() creates SessionLog in Firestore
  → navigate to PostCallScreen
```

---

## Layer Boundaries

- **Models** (`shared/lib/models/`): pure Dart, no framework imports
- **Service interfaces** (`shared/lib/services/`): abstract classes, no Firebase
- **Implementations** (`shared/lib/impl/`): Firestore code lives here only
- **App providers** (`{app}/lib/core/providers/`): wire implementations to Riverpod providers
- **Feature notifiers** (`{app}/lib/features/*/`): consume providers, no direct Firestore access
