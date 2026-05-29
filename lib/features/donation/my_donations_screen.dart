import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donation_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/status_badge.dart';

class MyDonationsScreen extends ConsumerWidget {
  const MyDonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(myDonationsProvider);
    final showStatus = ref.watch(userRoleProvider) == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('My Donations')),
      body: donationsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading donations...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(myDonationsProvider),
        ),
        data: (donations) {
          if (donations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No donations yet. Browse campaigns to make your first contribution.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final donation = donations[index];
              return Card(
                child: ListTile(
                  onTap: () => context.push('/campaigns/${donation.campaignId}'),
                  leading: const Icon(Icons.volunteer_activism, color: AppColors.primary),
                  title: Text(donation.campaignTitle ?? 'Campaign #${donation.campaignId}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(formatDate(donation.donationDate)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatEtb(donation.amount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      if (showStatus) StatusBadge(status: donation.paymentStatus),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: donations.length,
          );
        },
      ),
    );
  }
}