import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../providers/campaign_provider.dart';
import '../../services/withdrawal_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';

class RequestWithdrawalScreen extends ConsumerStatefulWidget {
  const RequestWithdrawalScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<RequestWithdrawalScreen> createState() => _RequestWithdrawalScreenState();
}

class _RequestWithdrawalScreenState extends ConsumerState<RequestWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bankController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _bankController.dispose();
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
      appBar: AppBar(title: const Text('Request Withdrawal')),
      body: campaignAsync.when(
        loading: () => const LoadingWidget(message: 'Preparing withdrawal form...'),
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
              Text('Available balance ${formatEtb(campaign.raisedAmount)}', style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Withdrawal amount', prefixText: 'ETB '),
                          validator: (value) {
                            final validation = validateAmount(value);
                            if (validation != null) return validation;
                            final amount = double.tryParse(value!.trim()) ?? 0;
                            if (amount > campaign.raisedAmount) return 'Amount cannot exceed available balance';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bankController,
                          decoration: const InputDecoration(labelText: 'Bank account number'),
                          validator: (value) => validateRequired(value, 'Bank account'),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Submit Request',
                          isLoading: _isSubmitting,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(withdrawalServiceProvider).requestWithdrawal(
            campaignId: int.parse(widget.campaignId),
            amount: double.parse(_amountController.text.trim()),
            bankAccount: _bankController.text.trim(),
          );
      if (!mounted) return;
      context.go('/my-withdrawals');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Withdrawal request failed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}