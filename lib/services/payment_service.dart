import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'donation_service.dart';

class PaymentService {
  PaymentService(this._donationService);

  final DonationService _donationService;

  Future<String> initializePayment({required int campaignId, required double amount, required bool isAnonymous}) async {
    await _donationService.createDonation(
      campaignId: campaignId,
      amount: amount,
      isAnonymous: isAnonymous,
      paymentStatus: 'completed',
    );

    return 'about:blank#payment-success';
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.read(donationServiceProvider));
});
