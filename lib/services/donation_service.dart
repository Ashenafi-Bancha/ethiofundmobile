import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/donation_model.dart';
import 'supabase_service.dart';

class DonationCheckoutResult {
  const DonationCheckoutResult({
    required this.checkoutUrl,
    required this.paymentReference,
    required this.donationId,
  });

  final String checkoutUrl;
  final String paymentReference;
  final int donationId;
}

class DonationService {
  DonationService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Future<DonationCheckoutResult> initiateChapaPayment({
    required double amount,
    required String email,
    required String firstName,
    required String lastName,
    required int campaignId,
    required int userId,
    bool isAnonymous = false,
  }) async {
    final session = _client.auth.currentSession;
    final accessToken = session?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('You must be signed in to donate.');
    }

    final response = await Dio().post<Map<String, dynamic>>(
      'https://ujpzjgsrhtoumhpuxywh.supabase.co/functions/v1/chapa-initiate-payment',
      data: {
        'amount': amount,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'campaign_id': campaignId,
        'user_id': userId,
        'is_anonymous': isAnonymous,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    final payload = response.data;
    if (payload == null) {
      throw StateError('Payment service returned an empty response.');
    }

    final checkoutUrl = payload['checkout_url']?.toString() ?? payload['checkoutUrl']?.toString() ?? '';
    final paymentReference = payload['payment_reference']?.toString() ?? payload['paymentReference']?.toString() ?? '';
    final donationIdRaw = payload['donation_id'] ?? payload['donationId'];
    final donationId = donationIdRaw is num ? donationIdRaw.toInt() : int.tryParse(donationIdRaw?.toString() ?? '') ?? 0;

    if (checkoutUrl.isEmpty) {
      throw StateError('Payment service did not provide a checkout URL.');
    }

    return DonationCheckoutResult(
      checkoutUrl: checkoutUrl,
      paymentReference: paymentReference,
      donationId: donationId,
    );
  }

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
