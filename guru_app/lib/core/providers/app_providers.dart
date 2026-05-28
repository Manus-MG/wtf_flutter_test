import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtf_shared/shared.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);

final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Override in ProviderScope'),
);

final authServiceProvider = Provider<AuthService>((ref) {
  return FirebaseAuthService(ref.watch(sharedPrefsProvider));
});

final themePreferenceServiceProvider = Provider<ThemeService>((ref) {
  return SharedPrefsThemeService(ref.watch(sharedPrefsProvider));
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(this._service) : super(ThemeMode.system) {
    _load();
  }

  final ThemeService _service;

  Future<void> _load() async {
    state = await _service.loadThemeMode();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _service.saveThemeMode(mode);
  }
}

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(themePreferenceServiceProvider));
});

final chatServiceProvider = Provider<FirebaseChatService>((ref) {
  return FirebaseChatService(ref.watch(firestoreProvider));
});

final attachmentStorageServiceProvider =
    Provider<AttachmentStorageService>((ref) {
  return FirebaseAttachmentStorageService(FirebaseStorage.instance);
});

final callServiceProvider = Provider<FirebaseCallService>((ref) {
  final user = ref.watch(currentUserProvider);
  return FirebaseCallService(
    ref.watch(firestoreProvider),
    currentUserId: user?.id ?? '',
    currentUserRole: user?.role.name ?? 'member',
  );
});

final logServiceProvider = Provider<FirebaseLogService>((ref) {
  final user = ref.watch(currentUserProvider);
  return FirebaseLogService(
    ref.watch(firestoreProvider),
    currentUserId: user?.id ?? '',
  );
});

// Auth state
class AuthState {
  const AuthState({this.user, this.isLoading = true, this.error});
  final User? user;
  final bool isLoading;
  final String? error;
  AuthState copyWith({User? user, bool? isLoading, String? error}) => AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState()) {
    _load();
  }

  final AuthService _authService;

  Future<void> _load() async {
    final user = await _authService.getCurrentUser();
    state = AuthState(user: user, isLoading: false);
  }

  Future<void> signInAs(User user) async {
    await _authService.saveCurrentUser(user);
    state = AuthState(user: user, isLoading: false);
    DevLogger.instance.log('[AUTH]', 'Signed in as ${user.name}');
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(isLoading: false);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

final currentUserProvider =
    Provider<User?>((ref) => ref.watch(authNotifierProvider).user);
