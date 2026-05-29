import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    required this.user,
    required this.isLoading,
    required this.error,
  });

  final bool isAuthenticated;
  final UserModel? user;
  final bool isLoading;
  final String? error;

  factory AuthState.unauthenticated() => const AuthState(isAuthenticated: false, user: null, isLoading: false, error: null);

  AuthState copyWith({bool? isAuthenticated, UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (user != null) {
      return AuthState(isAuthenticated: true, user: user, isLoading: false, error: null);
    }
    return AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await ref.read(authServiceProvider).login(email, password);
      final user = response['user'] as UserModel;
      state = AsyncValue.data(AuthState(isAuthenticated: true, user: user, isLoading: false, error: null));
    } catch (e) {
      state = AsyncValue.data(AuthState(isAuthenticated: false, user: null, isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await ref.read(authServiceProvider).register(
            fullName: fullName,
            email: email,
            phoneNumber: phone,
            password: password,
            role: role,
          );
      state = AsyncValue.data(AuthState(isAuthenticated: true, user: user, isLoading: false, error: null));
    } catch (e) {
      state = AsyncValue.data(AuthState(isAuthenticated: false, user: null, isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(authServiceProvider).logout();
    state = AsyncValue.data(AuthState.unauthenticated());
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
final currentUserProvider = Provider<UserModel?>((ref) => ref.watch(authNotifierProvider).valueOrNull?.user);
final isAuthenticatedProvider = Provider<bool>((ref) => ref.watch(authNotifierProvider).valueOrNull?.isAuthenticated ?? false);
final userRoleProvider = Provider<String>((ref) => ref.watch(currentUserProvider)?.role ?? 'guest');