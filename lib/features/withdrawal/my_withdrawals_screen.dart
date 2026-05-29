import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/withdrawal_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/status_badge.dart';

class MyWithdrawalsScreen extends ConsumerWidget {
  const MyWithdrawalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawalsAsync = ref.watch(myWithdrawalsProvider);
    final showStatus = ref.watch(userRoleProvider) == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('My Withdrawals')),
      body: withdrawalsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading withdrawals...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(myWithdrawalsProvider),
        ),
        data: (withdrawals) {
          if (withdrawals.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No withdrawal requests yet.'),
              ),
            );
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
                          if (showStatus) StatusBadge(status: withdrawal.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(formatEtb(withdrawal.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('Bank ${withdrawal.bankAccount ?? 'N/A'}', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(formatDate(withdrawal.requestDate), style: const TextStyle(color: AppColors.textSecondary)),
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
}