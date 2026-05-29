class CommentModel {
  const CommentModel({
    required this.commentId,
    required this.content,
    required this.userId,
    required this.campaignId,
    required this.createdAt,
    required this.fullName,
  });

  final int commentId;
  final String content;
  final int userId;
  final int campaignId;
  final DateTime createdAt;
  final String? fullName;

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        commentId: (json['comment_id'] ?? json['commentId'] ?? 0) as int,
        content: (json['content'] ?? '') as String,
        userId: (json['user_id'] ?? json['userId'] ?? 0) as int,
        campaignId: (json['campaign_id'] ?? json['campaignId'] ?? 0) as int,
        createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()).toString()) ?? DateTime.now(),
        fullName: json['full_name']?.toString() ?? json['fullName']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'comment_id': commentId,
        'content': content,
        'user_id': userId,
        'campaign_id': campaignId,
        'created_at': createdAt.toIso8601String(),
        'full_name': fullName,
      };

  CommentModel copyWith({int? commentId, String? content, int? userId, int? campaignId, DateTime? createdAt, String? fullName}) {
    return CommentModel(
      commentId: commentId ?? this.commentId,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
    );
  }
}