import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';

class AdminWithdrawalsScreen extends ConsumerWidget {
  const AdminWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(adminWithdrawalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Withdrawal Requests')),
      body: withdrawalsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading withdrawal requests...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminWithdrawalsProvider),
        ),
        data: (withdrawals) {
          if (withdrawals.isEmpty) {
            return const Center(child: Text('No pending withdrawal requests.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final withdrawal = withdrawals[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(withdrawal.campaignTitle ?? 'Campaign #${withdrawal.campaignId}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                          StatusBadge(status: withdrawal.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(formatEtb(withdrawal.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Bank ${withdrawal.bankAccount ?? 'N/A'}', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(formatDate(withdrawal.requestDate), style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: 'Approve',
                              onPressed: () => _moderateWithdrawal(context, ref, withdrawal.withdrawalId, true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Reject',
                              onPressed: () => _moderateWithdrawal(context, ref, withdrawal.withdrawalId, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: withdrawals.length,
          );
        },
      ),
    );
  }

  Future<void> _moderateWithdrawal(BuildContext context, WidgetRef ref, int withdrawalId, bool approve) async {
    try {
      if (approve) {
        await ref.read(adminServiceProvider).approveWithdrawal(withdrawalId);
      } else {
        await ref.read(adminServiceProvider).rejectWithdrawal(withdrawalId);
      }
      ref.invalidate(adminWithdrawalsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? 'Withdrawal approved' : 'Withdrawal rejected')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moderation failed: $error')));
      }
    }
  }
}