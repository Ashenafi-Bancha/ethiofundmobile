import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/primary_button.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

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
              const Text('We could not complete the payment checkout.'),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Try Again',
                onPressed: () => context.go('/campaigns'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}