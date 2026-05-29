class CampaignUpdateModel {
  const CampaignUpdateModel({
    required this.updateId,
    required this.campaignId,
    required this.content,
    required this.postedAt,
  });

  final int updateId;
  final int campaignId;
  final String content;
  final DateTime postedAt;

  factory CampaignUpdateModel.fromJson(Map<String, dynamic> json) => CampaignUpdateModel(
        updateId: (json['update_id'] ?? json['updateId'] ?? 0) as int,
        campaignId: (json['campaign_id'] ?? json['campaignId'] ?? 0) as int,
        content: (json['content'] ?? '') as String,
        postedAt: DateTime.tryParse((json['posted_at'] ?? json['postedAt'] ?? DateTime.now().toIso8601String()).toString()) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'update_id': updateId,
        'campaign_id': campaignId,
        'content': content,
        'posted_at': postedAt.toIso8601String(),
      };

  CampaignUpdateModel copyWith({int? updateId, int? campaignId, String? content, DateTime? postedAt}) {
    return CampaignUpdateModel(
      updateId: updateId ?? this.updateId,
      campaignId: campaignId ?? this.campaignId,
      content: content ?? this.content,
      postedAt: postedAt ?? this.postedAt,
    );
  }
}