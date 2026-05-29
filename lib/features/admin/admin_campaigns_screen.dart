import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/admin_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';

class AdminCampaignsScreen extends ConsumerWidget {
  const AdminCampaignsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(adminCampaignsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Campaign Management')),
      body: campaignsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading campaigns...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminCampaignsProvider),
        ),
        data: (campaigns) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              final progress = campaign.progressPercentage.clamp(0.0, 1.0);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(campaign.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                          ),
                          StatusBadge(status: campaign.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(campaign.category.toUpperCase(), style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Text('${formatEtb(campaign.raisedAmount)} of ${formatEtb(campaign.goalAmount)}'),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(value: progress, minHeight: 8),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SizedBox(
                            width: 110,
                            child: PrimaryButton(
                              label: 'Approve',
                              onPressed: () => _moderateCampaign(context, ref, campaign.campaignId, true),
                            ),
                          ),
                          SizedBox(
                            width: 110,
                            child: PrimaryButton(
                              label: 'Reject',
                              onPressed: () => _moderateCampaign(context, ref, campaign.campaignId, false),
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
            itemCount: campaigns.length,
          );
        },
      ),
    );
  }

  Future<void> _moderateCampaign(BuildContext context, WidgetRef ref, int campaignId, bool approve) async {
    try {
      if (approve) {
        await ref.read(campaignServiceProvider).approveCampaign(campaignId);
      } else {
        await ref.read(campaignServiceProvider).rejectCampaign(campaignId);
      }
      ref.invalidate(adminCampaignsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(approve ? 'Campaign approved' : 'Campaign rejected')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Moderation failed: $error')));
      }
    }
  }
}