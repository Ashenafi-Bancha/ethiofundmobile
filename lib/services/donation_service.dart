import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/donation_model.dart';
import 'supabase_service.dart';

class DonationService {
  DonationService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Future<DonationModel> createDonation({
    required int campaignId,
    required double amount,
    required bool isAnonymous,
    String paymentStatus = 'completed',
  }) async {
    final profile = await _supabaseService.fetchCurrentProfile();
    if (profile == null) {
      throw StateError('You must be signed in to donate.');
    }

    final campaign = await _client.from('campaigns').select('campaign_id,title').eq('campaign_id', campaignId).single();
    final response = await _client.from('donations').insert({
      'campaign_id': campaignId,
      'donor_id': profile.userId,
      'amount': amount,
      'payment_status': paymentStatus,
      'is_anonymous': isAnonymous,
      'campaign_title': (campaign as Map)['title']?.toString(),
    }).select().single();

    return DonationModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<DonationModel>> getMyDonations() async {
    final profile = await _supabaseService.fetchCurrentProfile();
    if (profile == null) {
      return const <DonationModel>[];
    }

    final response = await _client.from('donations').select().eq('donor_id', profile.userId).order('created_at', ascending: false);
    return (response as List)
        .map((item) => DonationModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<List<DonationModel>> getCampaignDonations(int campaignId) async {
    final response = await _client.from('donations').select().eq('campaign_id', campaignId).order('created_at', ascending: false);
    return (response as List)
        .map((item) => DonationModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<double> calculateTotalDonations(int campaignId) async {
    final donations = await getCampaignDonations(campaignId);
    return donations.fold<double>(0, (total, donation) => total + donation.amount);
  }
}

final donationServiceProvider = Provider<DonationService>((ref) {
  return DonationService(ref.read(supabaseServiceProvider));
});
