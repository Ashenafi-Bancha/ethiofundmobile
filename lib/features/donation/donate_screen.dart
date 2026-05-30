import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../providers/campaign_provider.dart';
import '../../services/donation_service.dart';
import '../../services/supabase_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';

/// DonateScreen
///
/// Presents a donation form and initiates the Chapa checkout flow. Behavior:
/// - Calls `DonationService.initiateChapaPayment` which creates a pending
///   donation server-side and returns a checkout URL.
/// - Opens the checkout in the external browser (`LaunchMode.externalApplication`).
/// - The server-side webhook (`chapa-webhook`) is relied upon to mark the
///   donation `completed`; the client refreshes data after returning to the app.
class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedId = int.tryParse(widget.campaignId);
    if (parsedId == null) {
      return const Scaffold(body: Center(child: Text('Invalid campaign id')));
    }

    final campaignAsync = ref.watch(campaignDetailProvider(parsedId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/campaigns/$parsedId');
            }
          },
        ),
        title: const Text('Donate'),
      ),
      body: campaignAsync.when(
        loading: () => const LoadingWidget(message: 'Preparing donation flow...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(campaignDetailProvider(parsedId)),
        ),
        data: (campaign) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(campaign.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(campaign.organizerName ?? 'EthioFund Organizer', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Donation amount',
                              prefixText: 'ETB ',
                            ),
                            validator: validateAmount,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _noteController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Message to organizer (optional)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Donate anonymously'),
                            value: _isAnonymous,
                            onChanged: (value) => setState(() => _isAnonymous = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your contribution helps ${campaign.title.toLowerCase()} and is processed securely through the payment provider.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Continue to Payment',
                      isLoading: _isSubmitting,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Raised ${formatEtb(campaign.raisedAmount)} of ${formatEtb(campaign.goalAmount)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final router = GoRouter.of(context);
    final amount = double.parse(_amountController.text.trim());
    final campaignId = int.parse(widget.campaignId);
    final profile = await ref.read(supabaseServiceProvider).fetchCurrentProfile();
    if (profile == null) {
      if (!mounted) return;
      router.go('/login');
      return;
    }

    final nameParts = profile.fullName.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList(growable: false);
    final firstName = nameParts.isNotEmpty ? nameParts.first : 'EthioFund';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : 'Supporter';

    setState(() => _isSubmitting = true);
    try {
      final result = await ref.read(donationServiceProvider).initiateChapaPayment(
            amount: amount,
            email: profile.email,
            firstName: firstName,
            lastName: lastName,
            campaignId: campaignId,
            userId: profile.userId,
            isAnonymous: _isAnonymous,
          );

      if (!mounted) return;
      final launched = await launchUrl(
        Uri.parse(result.checkoutUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        router.go('/payment/failed', extra: campaignId);
        return;
      }

      router.go('/payment/success', extra: campaignId);
    } catch (error) {
      if (!mounted) return;
      router.go('/payment/failed', extra: campaignId);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}