class CampaignModel {
  const CampaignModel({
    required this.campaignId,
    required this.title,
    required this.description,
    required this.goalAmount,
    required this.raisedAmount,
    required this.status,
    required this.category,
    required this.organizerId,
    required this.organizerName,
    this.imageUrl,
    required this.createdAt,
  });

  final int campaignId;
  final String title;
  final String description;
  final double goalAmount;
  final double raisedAmount;
  final String status;
  final String category;
  final int organizerId;
  final String? organizerName;
  final String? imageUrl;
  final DateTime createdAt;

  double get progressPercentage => goalAmount <= 0 ? 0 : raisedAmount / goalAmount;
  bool get isActive => status == 'active' || status == 'approved';

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      campaignId: (json['campaign_id'] ?? json['campaignId'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      goalAmount: (json['goal_amount'] ?? json['goalAmount'] ?? 0).toDouble(),
      raisedAmount: (json['raised_amount'] ?? json['raisedAmount'] ?? 0).toDouble(),
      status: (json['status'] ?? 'pending') as String,
      category: (json['category'] ?? 'community') as String,
      organizerId: (json['organizer_id'] ?? json['organizerId'] ?? 0) as int,
      organizerName: json['organizer_name']?.toString() ?? json['organizerName']?.toString(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'campaign_id': campaignId,
        'title': title,
        'description': description,
        'goal_amount': goalAmount,
        'raised_amount': raisedAmount,
        'status': status,
        'category': category,
        'organizer_id': organizerId,
        'organizer_name': organizerName,
        'image_url': imageUrl,
        'created_at': createdAt.toIso8601String(),
      };

  CampaignModel copyWith({
    int? campaignId,
    String? title,
    String? description,
    double? goalAmount,
    double? raisedAmount,
    String? status,
    String? category,
    int? organizerId,
    String? organizerName,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return CampaignModel(
      campaignId: campaignId ?? this.campaignId,
      title: title ?? this.title,
      description: description ?? this.description,
      goalAmount: goalAmount ?? this.goalAmount,
      raisedAmount: raisedAmount ?? this.raisedAmount,
      status: status ?? this.status,
      category: category ?? this.category,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}