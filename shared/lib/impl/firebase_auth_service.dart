import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

const _kCurrentUserKey = 'current_user_json';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<User?> getCurrentUser() async {
    final raw = _prefs.getString(_kCurrentUserKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, Object?>);
  }

  @override
  Future<void> saveCurrentUser(User user) async {
    await _prefs.setString(_kCurrentUserKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_kCurrentUserKey);
  }
}
