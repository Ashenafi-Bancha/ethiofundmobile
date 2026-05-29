import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
      'raised_amount': 0,
      'category': category,
      'status': 'pending',
      'organizer_id': profile.userId,
      'organizer_name': profile.fullName,
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

  Future<String> uploadCampaignImage(XFile xFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${xFile.name}';
    final bytes = await xFile.readAsBytes();
    
    await _client.storage.from('campaign-images').uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(contentType: 'image/jpeg', cacheControl: '3600'),
    );
    
    return _client.storage.from('campaign-images').getPublicUrl(fileName);
  }
}

final campaignServiceProvider = Provider<CampaignService>((ref) {
  return CampaignService(ref.read(supabaseServiceProvider));
});
