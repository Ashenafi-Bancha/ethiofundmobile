import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/campaign_model.dart';
import '../models/dashboard_stats_model.dart';
import '../models/user_model.dart';
import '../models/withdrawal_model.dart';
import '../services/admin_service.dart';

final adminDashboardProvider = FutureProvider<DashboardStatsModel>((ref) {
  return ref.read(adminServiceProvider).getDashboard();
});

final adminCampaignsProvider = FutureProvider<List<CampaignModel>>((ref) {
  return ref.read(adminServiceProvider).getCampaigns();
});

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) {
  return ref.read(adminServiceProvider).getUsers();
});

final adminWithdrawalsProvider = FutureProvider<List<WithdrawalModel>>((ref) {
  return ref.read(adminServiceProvider).getPendingWithdrawals();
});

final adminReportsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, type) {
  return ref.read(adminServiceProvider).getReports(type);
});