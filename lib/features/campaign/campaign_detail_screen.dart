import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/comment_provider.dart';
import '../../services/comment_service.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_widget.dart';
import '../../shared/widgets/status_badge.dart';

class CampaignDetailScreen extends ConsumerStatefulWidget {
  const CampaignDetailScreen({super.key, required this.campaignId});

  final String campaignId;

  @override
  ConsumerState<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends ConsumerState<CampaignDetailScreen> {
  final _commentController = TextEditingController();
  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedId = int.tryParse(widget.campaignId);
    if (parsedId == null) {
      return const Scaffold(body: Center(child: Text('Invalid campaign id')));
    }

    final campaignAsync = ref.watch(campaignDetailProvider(parsedId));
    final commentsAsync = ref.watch(commentProvider(parsedId));
    final showStatus = ref.watch(userRoleProvider) == 'admin';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/campaigns');
            }
          },
        ),
        title: const Text('Campaign Details'),
        actions: [
          IconButton(
            onPressed: () => context.push('/donate/${widget.campaignId}'),
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Donate',
          ),
          IconButton(
            onPressed: () {
              Share.share('Support ${widget.campaignId} on EthioFund: https://ethiofund.test/campaigns/${widget.campaignId}');
            },
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
        ],
      ),
      body: campaignAsync.when(
        loading: () => const LoadingWidget(message: 'Loading campaign...'),
        error: (error, stackTrace) => AppErrorWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(campaignDetailProvider(parsedId)),
        ),
        data: (campaign) {
          final progress = campaign.progressPercentage.clamp(0.0, 1.0);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (campaign.imageUrl != null && campaign.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      campaign.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.black26),
                      ),
                    ),
                  ),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showStatus) StatusBadge(status: campaign.status),
                      const SizedBox(height: 12),
                      Text(campaign.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(campaign.organizerName ?? 'EthioFund Organizer', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Text(campaign.description),
                      const SizedBox(height: 18),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(value: progress, minHeight: 10),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text('${formatEtb(campaign.raisedAmount)} raised', style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text('Goal ${formatEtb(campaign.goalAmount)}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.push('/donate/${widget.campaignId}'),
                          child: const Text('Donate Now'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Updates & Comments', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Write a comment',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSendingComment ? null : () => _submitComment(parsedId),
                          icon: _isSendingComment
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.send),
                          label: Text(_isSendingComment ? 'Posting...' : 'Post Comment'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              commentsAsync.when(
                loading: () => const LoadingWidget(message: 'Loading comments...'),
                error: (error, stackTrace) => AppErrorWidget(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(commentProvider(parsedId)),
                ),
                data: (comments) {
                  if (comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('Be the first to leave a comment.')),
                    );
                  }

                  return Column(
                    children: comments
                        .map(
                          (comment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CommentCard(comment: comment.fullName ?? 'EthioFund Member', content: comment.content, dateLabel: formatRelativeTime(comment.createdAt)),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitComment(int campaignId) async {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      return;
    }

    setState(() => _isSendingComment = true);
    try {
      await ref.read(commentServiceProvider).addComment(campaignId, message);
      _commentController.clear();
      ref.invalidate(commentProvider(campaignId));
    } finally {
      if (mounted) {
        setState(() => _isSendingComment = false);
      }
    }
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, required this.content, required this.dateLabel});

  final String comment;
  final String content;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(comment.isNotEmpty ? comment[0].toUpperCase() : 'E', style: const TextStyle(color: AppColors.primary)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(comment, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                Text(dateLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content),
          ],
        ),
      ),
    );
  }
}