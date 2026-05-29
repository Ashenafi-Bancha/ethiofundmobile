import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/comment_model.dart';
import 'supabase_service.dart';

class CommentService {
  CommentService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Future<CommentModel> addComment(int campaignId, String content) async {
    final profile = await _supabaseService.fetchCurrentProfile();
    if (profile == null) {
      throw StateError('You must be signed in to post a comment.');
    }

    final response = await _client.from('comments').insert({
      'campaign_id': campaignId,
      'user_id': profile.userId,
      'content': content,
      'full_name': profile.fullName,
    }).select().single();

    return CommentModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<CommentModel>> getComments(int campaignId) async {
    final response = await _client.from('comments').select().eq('campaign_id', campaignId).order('created_at', ascending: false);
    return (response as List)
        .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }
}

final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService(ref.read(supabaseServiceProvider));
});
