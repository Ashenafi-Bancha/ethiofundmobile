import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/donation_provider.dart';
import '../../shared/widgets/primary_button.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key, this.campaignId});

  final int? campaignId;

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.campaignId != null) {
        ref.invalidate(campaignDetailProvider(widget.campaignId!));
      }
      ref.invalidate(campaignsProvider);
      ref.invalidate(myDonationsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 72),
              const SizedBox(height: 16),
              Text('Payment submitted', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Your checkout opened in Chapa. Donation status will update after Supabase confirms the payment.'),
              const SizedBox(height: 24),
              PrimaryButton(
                label: widget.campaignId == null ? 'Back to Home' : 'Back to Campaign',
                onPressed: () {
                  if (widget.campaignId == null) {
                    context.go('/home');
                  } else {
                    context.go('/campaigns/${widget.campaignId}');
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