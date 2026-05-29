import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/campaign_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';

class MyCampaignsScreen extends ConsumerWidget {
  const MyCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final campaignsAsync = ref.watch(campaignsProvider);
    final showStatus = currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Campaigns'),
        actions: [
          IconButton(onPressed: () => context.push('/campaigns/create'), icon: const Icon(Icons.add)),
        ],
      ),
      body: campaignsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading campaign tools...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(campaignsProvider),
        ),
        data: (campaigns) {
          final visibleCampaigns = currentUser == null
              ? campaigns
              : campaigns.where((campaign) => campaign.organizerId == currentUser.userId || currentUser.role == 'admin').toList();

          if (visibleCampaigns.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No organizer campaigns yet. Create your first campaign to get started.'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(campaignsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => _OrganizerCampaignCard(campaign: visibleCampaigns[index], showStatus: showStatus),
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemCount: visibleCampaigns.length,
            ),
          );
        },
      ),
    );
  }
}

class _OrganizerCampaignCard extends ConsumerWidget {
  const _OrganizerCampaignCard({required this.campaign, required this.showStatus});

  final CampaignModel campaign;
  final bool showStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = campaign.progressPercentage.clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campaign.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(campaign.category.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                if (showStatus) StatusBadge(status: campaign.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(truncateText(campaign.description, 110)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress, minHeight: 8),
            ),
            const SizedBox(height: 8),
            Text('${formatEtb(campaign.raisedAmount)} raised of ${formatEtb(campaign.goalAmount)}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 112,
                  child: PrimaryButton(
                    label: 'Edit',
                    onPressed: () => context.push('/campaigns/${campaign.campaignId}/edit'),
                  ),
                ),
                SizedBox(
                  width: 112,
                  child: PrimaryButton(
                    label: 'Update',
                    onPressed: () => _showUpdateDialog(context, ref, campaign),
                  ),
                ),
                SizedBox(
                  width: 112,
                  child: PrimaryButton(
                    label: 'Withdraw',
                    onPressed: () => context.push('/withdrawals/request/${campaign.campaignId}'),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => context.push('/campaigns/${campaign.campaignId}'),
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUpdateDialog(BuildContext context, WidgetRef ref, CampaignModel campaign) async {
    final controller = TextEditingController();
    try {
      final result = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Post update for ${campaign.title}'),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Update message'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Post')),
            ],
          );
        },
      );

      if (result == null || result.isEmpty) {
        return;
      }

      await ref.read(campaignServiceProvider).postCampaignUpdate(campaign.campaignId, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Campaign update posted')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post update: $error')));
      }
    } finally {
      controller.dispose();
    }
  }
}