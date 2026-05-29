import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_provider.dart';
import '../models/campaign_model.dart';
import '../services/campaign_service.dart';
import '../services/supabase_service.dart';

final campaignsProvider = AsyncNotifierProvider<CampaignsNotifier, List<CampaignModel>>(CampaignsNotifier.new);

class CampaignsNotifier extends AsyncNotifier<List<CampaignModel>> {
  RealtimeChannel? _channel;

  @override
  Future<List<CampaignModel>> build() async {
    final client = ref.read(supabaseServiceProvider).client;

    _channel = client
        .channel('public:campaigns')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'campaigns',
          callback: (payload) {
            refresh();
          },
        );
    _channel?.subscribe();

    ref.onDispose(() {
      if (_channel != null) {
        client.removeChannel(_channel!);
      }
    });

    return ref.read(campaignServiceProvider).getCampaigns();
  }

  Future<void> refresh() async {
    try {
      final campaigns = await ref.read(campaignServiceProvider).getCampaigns();
      state = AsyncValue.data(campaigns);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final campaignDetailProvider = FutureProvider.family<CampaignModel, int>((ref, id) {
  return ref.read(campaignServiceProvider).getCampaignById(id);
});

final filteredCampaignsProvider = Provider.family<List<CampaignModel>, String>((ref, category) {
  final campaigns = ref.watch(campaignsProvider).valueOrNull ?? const <CampaignModel>[];
  if (category == 'all') return campaigns;
  return campaigns.where((campaign) => campaign.category.toLowerCase() == category.toLowerCase()).toList();
});

final myCampaignsProvider = FutureProvider<List<CampaignModel>>((ref) async {
  final campaigns = await ref.read(campaignServiceProvider).getCampaigns();
  final role = ref.watch(userRoleProvider);
  if (role == 'organizer' || role == 'admin') return campaigns;
  return const <CampaignModel>[];
});