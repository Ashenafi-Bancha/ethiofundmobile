import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../models/campaign_model.dart';
import '../../providers/campaign_provider.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/status_badge.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final campaignsAsync = ref.watch(campaignsProvider);
    final filteredCampaigns = ref.watch(filteredCampaignsProvider(_selectedCategory));
    final showStatus = ref.watch(userRoleProvider) == 'admin';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text('Browse Campaigns'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(campaignsProvider),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: campaignsAsync.when(
        loading: () => const LoadingWidget(message: 'Loading campaigns...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(campaignsProvider),
        ),
        data: (campaigns) {
          if (campaigns.isEmpty) {
            return const Center(child: Text('No campaigns available yet.'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(campaignsProvider),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final cards = filteredCampaigns
                  .map((campaign) => _CampaignCard(campaign: campaign, showStatus: showStatus))
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const _BrowseHeader(),
                    const SizedBox(height: 16),
                    _CategoryChips(
                      selectedCategory: _selectedCategory,
                      onSelected: (category) => setState(() => _selectedCategory = category),
                    ),
                    const SizedBox(height: 16),
                    if (isWide)
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: cards
                            .map(
                              (card) => SizedBox(
                                width: (constraints.maxWidth - 48) / 2,
                                child: card,
                              ),
                            )
                            .toList(),
                      )
                    else
                      ...cards.map((card) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: card,
                          )),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BrowseHeader extends StatelessWidget {
  const _BrowseHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discover campaigns', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text(
              'Tap a campaign to view more details, or donate directly when you are ready.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selectedCategory, required this.onSelected});

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final categories = ['all', 'education', 'health', 'community', 'startup', 'emergency'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map(
            (category) => ChoiceChip(
              label: Text(category[0].toUpperCase() + category.substring(1)),
              selected: selectedCategory == category,
              onSelected: (_) => onSelected(category),
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
            ),
          )
          .toList(),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.showStatus});

  final CampaignModel campaign;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final progress = campaign.progressPercentage.clamp(0.0, 1.0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/campaigns/${campaign.campaignId}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
              Image.network(
                campaign.imageUrl!,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 140,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.black26),
                ),
              ),
            Padding(
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
                            Text(
                              campaign.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              campaign.organizerName ?? 'EthioFund Organizer',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (showStatus) StatusBadge(status: campaign.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(truncateText(campaign.description, 120)),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(value: progress, minHeight: 8),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(formatEtb(campaign.raisedAmount), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      TextButton.icon(
                        onPressed: () => context.push('/campaigns/${campaign.campaignId}'),
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('View more'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}