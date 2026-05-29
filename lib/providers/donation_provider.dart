import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/donation_model.dart';
import '../services/donation_service.dart';

final myDonationsProvider = AsyncNotifierProvider<MyDonationsNotifier, List<DonationModel>>(MyDonationsNotifier.new);

class MyDonationsNotifier extends AsyncNotifier<List<DonationModel>> {
  @override
  Future<List<DonationModel>> build() => ref.read(donationServiceProvider).getMyDonations();

  Future<void> refresh() async {
    state = AsyncValue.data(await ref.read(donationServiceProvider).getMyDonations());
  }
}

final campaignDonationsProvider = FutureProvider.family<List<DonationModel>, int>((ref, campaignId) {
  return ref.read(donationServiceProvider).getCampaignDonations(campaignId);
});