import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/admin_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: dashboardAsync.when(
        loading: () => const LoadingWidget(message: 'Loading admin overview...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminDashboardProvider),
        ),
        data: (stats) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatsGrid(stats: stats),
              const SizedBox(height: 20),
              _AdminLinkCard(title: 'Campaign management', description: 'Review and moderate campaign approvals.', icon: Icons.campaign_outlined, onTap: () => context.push('/admin/campaigns')),
              _AdminLinkCard(title: 'User management', description: 'Suspend or activate user accounts.', icon: Icons.people_outline, onTap: () => context.push('/admin/users')),
              _AdminLinkCard(title: 'Withdrawal requests', description: 'Approve or reject pending withdrawals.', icon: Icons.payments_outlined, onTap: () => context.push('/admin/withdrawals')),
              _AdminLinkCard(title: 'Reports', description: 'Inspect summary reports and exports.', icon: Icons.bar_chart_outlined, onTap: () => context.push('/admin/reports')),
            ],
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final dynamic stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ('Users', stats.totalUsers.toString(), Icons.people_outline),
      ('Campaigns', stats.totalCampaigns.toString(), Icons.campaign_outlined),
      ('Donations', stats.totalDonations.toString(), Icons.volunteer_activism_outlined),
      ('Raised', formatEtb(stats.totalRaised), Icons.savings_outlined),
      ('Pending campaigns', stats.pendingCampaigns.toString(), Icons.pending_actions_outlined),
      ('Pending withdrawals', stats.pendingWithdrawals.toString(), Icons.account_balance_wallet_outlined),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.35),
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(tile.$3, color: AppColors.primary),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tile.$1, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(tile.$2, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminLinkCard extends StatelessWidget {
  const _AdminLinkCard({required this.title, required this.description, required this.icon, required this.onTap});

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}