import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/primary_button.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key, this.campaignId});

  final int? campaignId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 72),
              const SizedBox(height: 16),
              Text('Payment Failed', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('We could not open or initialize the payment checkout.'),
              const SizedBox(height: 24),
              PrimaryButton(
                label: campaignId == null ? 'Try Again' : 'Try Again',
                onPressed: () {
                  if (campaignId == null) {
                    context.go('/campaigns');
                  } else {
                    context.go('/donate/$campaignId');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}