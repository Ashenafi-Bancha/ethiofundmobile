import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/campaign_model.dart';
import '../models/campaign_update_model.dart';
import 'supabase_service.dart';

class CampaignService {
  CampaignService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Future<List<CampaignModel>> getCampaigns() async {
    final response = await _client.from('campaigns').select().order('created_at', ascending: false);
    return (response as List)
        .map((item) => CampaignModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<CampaignModel> getCampaignById(int id) async {
    final response = await _client.from('campaigns').select().eq('campaign_id', id).single();
    return CampaignModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<CampaignModel> createCampaign({
    required String title,
    required String description,
    required double goalAmount,
    required String category,
    String? imageUrl,
  }) async {
    final profile = await _supabaseService.fetchCurrentProfile();
    if (profile == null) {
      throw StateError('You must be signed in to create a campaign.');
    }

    final response = await _client.from('campaigns').insert({
      'title': title,
      'description': description,
      'goal_amount': goalAmount,
      'organizer_id': profile.userId,
      'image_url': imageUrl,
    }).select().single();

    return CampaignModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<CampaignModel> updateCampaign(int id, Map<String, dynamic> data) async {
    final response = await _client.from('campaigns').update(data).eq('campaign_id', id).select().single();
    return CampaignModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<CampaignUpdateModel>> getCampaignUpdates(int id) async {
    final response = await _client.from('campaign_updates').select().eq('campaign_id', id).order('posted_at', ascending: false);
    return (response as List)
        .map((item) => CampaignUpdateModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<CampaignUpdateModel> postCampaignUpdate(int id, String content) async {
    final response = await _client.from('campaign_updates').insert({
      'campaign_id': id,
      'content': content,
    }).select().single();
    return CampaignUpdateModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<void> approveCampaign(int id) async {
    await _client.from('campaigns').update({'status': 'approved'}).eq('campaign_id', id);
  }

  Future<void> rejectCampaign(int id) async {
    await _client.from('campaigns').update({'status': 'rejected'}).eq('campaign_id', id);
  }

  Future<String> uploadCampaignImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await _client.storage.from('campaign-images').upload(fileName, file);

    final url = _client.storage.from('campaign-images').getPublicUrl(fileName);

    return url;
  }
}

final campaignServiceProvider = Provider<CampaignService>((ref) {
  return CampaignService(ref.read(supabaseServiceProvider));
});
