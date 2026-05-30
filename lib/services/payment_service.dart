import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supabase_service.dart';

class PaymentService {
  PaymentService(this._supabaseService);

  final SupabaseService _supabaseService;

  Future<String> initializePayment({
    required int campaignId,
    required double amount,
    required bool isAnonymous,
    required String email,
    required String firstName,
    required String lastName,
    String? userId,
  }) async {
    final response = await _supabaseService.client.functions.invoke(
      'chapa-initiate-payment',
      body: {
        // existing fields
        'campaignId': campaignId,
        'amount': amount,
        'isAnonymous': isAnonymous,

        //  REQUIRED BY CHAPA
        'email': email,
        'first_name': firstName,
        'last_name': lastName,

        // IMPORTANT: webhook routing + tracking
        'metadata': {
          'source': 'mobile',
          'db': 'supabase',
          'campaignId': campaignId,
          'isAnonymous': isAnonymous,
          'userId': userId,
        },
      },
    );

    final payload = response.data;

    if (payload is! Map) {
      throw StateError('Payment service returned an invalid response.');
    }

    //  improved checkout URL extraction (robust for Chapa response variations)
    final checkoutUrl =
        payload['checkout_url']?.toString() ??
        payload['checkoutUrl']?.toString() ??
        payload['data']?['checkout_url']?.toString() ??
        payload['data']?['checkoutUrl']?.toString() ??
        '';

    if (checkoutUrl.isEmpty) {
      throw StateError('Payment service did not provide a checkout URL.');
    }

    return checkoutUrl;
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService(ref.read(supabaseServiceProvider));
});