import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService {
  AuthService(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<UserModel?> getCurrentUser() async {
    try {
      return await _supabaseService.fetchCurrentProfile();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final profile = await _supabaseService.fetchCurrentProfile();
      if (profile == null) {
        final authUser = response.user;
        if (authUser == null) {
          throw StateError('Unable to load signed-in profile.');
        }
        final fallbackProfile = await _supabaseService.upsertProfile(
          authUserId: authUser.id,
          email: authUser.email ?? email,
          fullName: authUser.userMetadata?['full_name']?.toString() ?? authUser.email?.split('@').first ?? email.split('@').first,
          role: authUser.userMetadata?['role']?.toString() ?? 'donor',
          phoneNumber: authUser.userMetadata?['phone_number']?.toString(),
        );
        return {'token': response.session?.accessToken ?? '', 'user': fallbackProfile};
      }

      return {'token': response.session?.accessToken ?? '', 'user': profile};
    } on AuthException catch (error) {
      throw StateError(error.message);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String role,
  }) async {
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'role': role,
        },
      );

      final authUser = response.user;
      if (authUser == null) {
        throw StateError('Registration succeeded, but the auth user was not returned.');
      }

      return _supabaseService.upsertProfile(
        authUserId: authUser.id,
        email: authUser.email ?? email,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
      );
    } on AuthException catch (error) {
      throw StateError(error.message);
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      throw StateError(error.message);
    } finally {
      // Supabase persists the session; no local token storage is needed.
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(supabaseServiceProvider));
});