import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import 'supabase_service.dart';

class UserService {
  UserService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Future<UserModel> getProfile() async {
    final profile = await _supabaseService.fetchCurrentProfile();
    if (profile == null) {
      throw StateError('No profile found for the current user.');
    }
    return profile;
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final authUser = _client.auth.currentUser;
    final profile = await _supabaseService.fetchCurrentProfile();
    if (authUser == null || profile == null) {
      throw StateError('You must be signed in to update your profile.');
    }

    final email = data['email']?.toString() ?? profile.email;
    final fullName = data['full_name']?.toString() ?? profile.fullName;
    final phoneNumber = data['phone_number']?.toString();

    await _client.auth.updateUser(
      UserAttributes(
        email: email,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'role': profile.role,
        },
      ),
    );

    final response = await _client.from('profiles').update({
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
    }).eq('auth_user_id', authUser.id).select().single();

    return UserModel.fromJson(Map<String, dynamic>.from(response));
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.read(supabaseServiceProvider));
});
