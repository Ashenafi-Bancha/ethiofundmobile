import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'supabase_service.dart';
import '../models/withdrawal_model.dart';

class WithdrawalService {
  WithdrawalService(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<WithdrawalModel> requestWithdrawal({required int campaignId, required double amount, required String bankAccount}) async {
    final client = _supabaseService.client;
    
    // Fetch campaign title dynamically
    final campaign = await client.from('campaigns').select('title').eq('campaign_id', campaignId).single();
    final campaignTitle = (campaign as Map)['title']?.toString();

    final payload = {
      'campaign_id': campaignId,
      'amount': amount,
      'bank_account': bankAccount,
      'organizer_id': await _supabaseService.currentProfileId(),
      'campaign_title': campaignTitle,
    };

    final response = await client.from('withdrawals').insert(payload).select().single();
    return WithdrawalModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<List<WithdrawalModel>> getMyWithdrawals() async {
    final client = _supabaseService.client;
    final organizerId = await _supabaseService.currentProfileId();
    if (organizerId == null) {
      return const <WithdrawalModel>[];
    }
    
    final response = await client.from('withdrawals').select().eq('organizer_id', organizerId).order('request_date', ascending: false);
    return (response as List)
        .map((item) => WithdrawalModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}

final withdrawalServiceProvider = Provider<WithdrawalService>((ref) {
  return WithdrawalService(ref.read(supabaseServiceProvider));
});