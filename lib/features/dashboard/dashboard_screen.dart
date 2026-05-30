import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/donation_provider.dart';
import '../../shared/widgets/loading_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(userRoleProvider);
    final campaignsAsync = ref.watch(campaignsProvider);
    final donationsAsync = ref.watch(myDonationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(campaignsProvider);
          ref.invalidate(myDonationsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome${user != null ? ', ${user.fullName}' : ''}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text('Role: ${role.toUpperCase()}', style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Text(
                      'This is your control center for donations, campaigns, and administration.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _QuickActionGrid(role: role),
            const SizedBox(height: 16),
            campaignsAsync.when(
              loading: () => const LoadingWidget(message: 'Loading your campaigns...'),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Campaigns unavailable: $error'),
                  ),
                ),
              ),
              data: (campaigns) {
                final organizerCampaigns = role == 'organizer' || role == 'admin'
                    ? campaigns.where((campaign) => user == null || campaign.organizerId == user.userId || role == 'admin').toList()
                    : const [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Organizer summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.campaign_outlined, color: AppColors.primary),
                        title: const Text('Campaigns created'),
                        subtitle: Text(organizerCampaigns.isEmpty ? 'No campaigns yet' : '${organizerCampaigns.length} campaigns active'),
                        trailing: role == 'organizer' || role == 'admin'
                            ? TextButton(
                                onPressed: () => context.push('/my-campaigns'),
                                child: const Text('View'),
                              )
                            : null,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            donationsAsync.when(
              loading: () => const LoadingWidget(message: 'Loading donation summary...'),
              error: (error, stackTrace) => const SizedBox.shrink(),
              data: (donations) {
                final totalDonated = donations.fold<double>(0, (total, donation) => total + donation.amount);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Donation summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.volunteer_activism_outlined, color: AppColors.primary),
                        title: const Text('Total donated'),
                        subtitle: Text('${donations.length} donations'),
                        trailing: Text(formatEtb(totalDonated), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            if (role == 'admin')
              Card(
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined, color: AppColors.primary),
                  title: const Text('Admin dashboard'),
                  subtitle: const Text('Review users, campaigns, withdrawals, and reports.'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/admin'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction(icon: Icons.explore_outlined, title: 'Browse campaigns', subtitle: 'Find causes to support', onTap: () => context.go('/campaigns')),
      _QuickAction(icon: Icons.receipt_long_outlined, title: 'My donations', subtitle: 'Track your contributions', onTap: () => context.go('/my-donations')),
    ];

    if (role == 'organizer' || role == 'admin') {
      actions.addAll([
        _QuickAction(icon: Icons.add_business_outlined, title: 'Create campaign', subtitle: 'Start a fundraiser', onTap: () => context.go('/campaigns/create')),
        _QuickAction(icon: Icons.rocket_launch_outlined, title: 'My campaigns', subtitle: 'Manage active campaigns', onTap: () => context.go('/my-campaigns')),
      ]);
    }

    if (role == 'admin') {
      actions.add(
        _QuickAction(icon: Icons.admin_panel_settings_outlined, title: 'Admin tools', subtitle: 'Moderate the platform', onTap: () => context.go('/admin')),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return Card(
          child: InkWell(
            onTap: action.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(action.icon, color: AppColors.primary),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(action.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(action.subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}