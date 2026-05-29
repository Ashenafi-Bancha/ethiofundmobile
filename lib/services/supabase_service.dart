import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class SupabaseService {
  SupabaseService(this.client);

  final SupabaseClient client;

  Future<UserModel?> fetchProfileByAuthUserId(String authUserId) async {
    final response = await client.from('profiles').select().eq('auth_user_id', authUserId).maybeSingle();
    if (response == null) {
      return null;
    }

    return UserModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<UserModel?> fetchCurrentProfile() async {
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      return null;
    }
    return fetchProfileByAuthUserId(authUser.id);
  }

  Future<UserModel> upsertProfile({
    required String authUserId,
    required String email,
    required String fullName,
    required String role,
    String? phoneNumber,
    String status = 'active',
  }) async {
    final payload = <String, dynamic>{
      'auth_user_id': authUserId,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'role': role,
      'status': status,
    };

    final response = await client.from('profiles').upsert(payload, onConflict: 'auth_user_id').select().single();
    return UserModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<UserModel> ensureProfileForCurrentUser({
    required String email,
    required String fullName,
    required String role,
    String? phoneNumber,
    String status = 'active',
  }) async {
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      throw StateError('No authenticated user found.');
    }

    return upsertProfile(
      authUserId: authUser.id,
      email: email,
      fullName: fullName,
      role: role,
      phoneNumber: phoneNumber,
      status: status,
    );
  }

  Future<int?> currentProfileId() async {
    return (await fetchCurrentProfile())?.userId;
  }
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});
