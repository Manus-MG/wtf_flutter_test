import '../models/user.dart';

abstract class AuthService {
  Future<User?> getCurrentUser();
  Future<void> saveCurrentUser(User user);
  Future<void> signOut();
}
