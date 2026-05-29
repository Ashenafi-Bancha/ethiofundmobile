import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/campaign_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/user_model.dart';
import '../models/withdrawal_model.dart';
import 'supabase_service.dart';

class AdminService {
  AdminService(this._supabaseService);

  final SupabaseService _supabaseService;

  SupabaseClient get _client => _supabaseService.client;

  Future<DashboardStatsModel> getDashboard() async {
    final users = await _client.from('profiles').select('user_id');
    final campaigns = await _client.from('campaigns').select('campaign_id,status,raised_amount');
    final donations = await _client.from('donations').select('donation_id,amount,payment_status');
    final withdrawals = await _client.from('withdrawals').select('withdrawal_id,status');

    final campaignRows = (campaigns as List).cast<Map<String, dynamic>>();
    final donationRows = (donations as List).cast<Map<String, dynamic>>();
    final withdrawalRows = (withdrawals as List).cast<Map<String, dynamic>>();

    return DashboardStatsModel(
      totalUsers: (users as List).length,
      totalCampaigns: campaignRows.length,
      totalDonations: donationRows.length,
      totalRaised: donationRows.fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble()),
      pendingCampaigns: campaignRows.where((item) => item['status']?.toString() == 'pending').length,
      pendingWithdrawals: withdrawalRows.where((item) => item['status']?.toString() == 'pending').length,
    );
  }

  Future<List<UserModel>> getUsers() async {
    final response = await _client.from('profiles').select().order('created_at', ascending: false);
    return (response as List)
        .map((item) => UserModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<void> suspendUser(int id) async {
    await _client.from('profiles').update({'status': 'suspended'}).eq('user_id', id);
  }

  Future<void> activateUser(int id) async {
    await _client.from('profiles').update({'status': 'active'}).eq('user_id', id);
  }

  Future<List<CampaignModel>> getCampaigns() async {
    final response = await _client.from('campaigns').select().order('created_at', ascending: false);
    return (response as List)
        .map((item) => CampaignModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<List<WithdrawalModel>> getPendingWithdrawals() async {
    final response = await _client.from('withdrawals').select().eq('status', 'pending').order('request_date', ascending: false);
    return (response as List)
        .map((item) => WithdrawalModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  Future<void> approveWithdrawal(int id) async {
    await _client.from('withdrawals').update({'status': 'approved'}).eq('withdrawal_id', id);
  }

  Future<void> rejectWithdrawal(int id) async {
    await _client.from('withdrawals').update({'status': 'rejected'}).eq('withdrawal_id', id);
  }

  Future<List<Map<String, dynamic>>> getReports(String type) async {
    final response = await _client.from('reports').select().eq('object_type', type).order('created_at', ascending: false);
    return (response as List).map((item) => Map<String, dynamic>.from(item as Map)).toList(growable: false);
  }
}

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.read(supabaseServiceProvider));
});
