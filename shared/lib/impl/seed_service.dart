import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSeedKey = 'seeded_v1';

const _seedUsers = [
  {
    'id': 'user_dk',
    'role': 'member',
    'name': 'DK',
    'email': 'dk@wtf.com',
    'assignedTrainerId': 'user_aarav',
    'isTyping': false,
    'typingChatId': null,
  },
  {
    'id': 'user_aarav',
    'role': 'trainer',
    'name': 'Aarav',
    'email': 'aarav@wtf.com',
    'assignedTrainerId': null,
    'isTyping': false,
    'typingChatId': null,
  },
];

class SeedService {
  SeedService(this._db, this._prefs);

  final FirebaseFirestore _db;
  final SharedPreferences _prefs;

  Future<void> seed() async {
    if (_prefs.getBool(_kSeedKey) == true) return;

    final batch = _db.batch();

    for (final u in _seedUsers) {
      batch.set(_db.collection('users').doc(u['id'] as String), u, SetOptions(merge: true));
    }

    // Initial chat document
    batch.set(
      _db.collection('chats').doc('user_dk_user_aarav'),
      {
        'id': 'user_dk_user_aarav',
        'memberId': 'user_dk',
        'trainerId': 'user_aarav',
        'lastMessage': '',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCountMember': 0,
        'unreadCountTrainer': 0,
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    await _prefs.setBool(_kSeedKey, true);
  }
}
