import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/comment_model.dart';
import '../services/comment_service.dart';
import '../services/supabase_service.dart';

final commentProvider = StreamProvider.family<List<CommentModel>, int>((ref, campaignId) {
  final client = ref.read(supabaseServiceProvider).client;
  
  return client
      .from('comments')
      .stream(primaryKey: ['comment_id'])
      .eq('campaign_id', campaignId)
      .order('created_at', ascending: false)
      .map((maps) => maps
          .map((item) => CommentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false));
});

final addCommentProvider = FutureProvider.family<CommentModel, ({int campaignId, String content})>((ref, payload) {
  return ref.read(commentServiceProvider).addComment(payload.campaignId, payload.content);
});