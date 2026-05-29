class DonationModel {
  const DonationModel({
    required this.donationId,
    required this.amount,
    required this.donationDate,
    required this.paymentStatus,
    required this.isAnonymous,
    required this.donorId,
    required this.campaignId,
    required this.campaignTitle,
  });

  final int donationId;
  final double amount;
  final DateTime donationDate;
  final String paymentStatus;
  final bool isAnonymous;
  final int donorId;
  final int campaignId;
  final String? campaignTitle;

  factory DonationModel.fromJson(Map<String, dynamic> json) => DonationModel(
        donationId: (json['donation_id'] ?? json['donationId'] ?? 0) as int,
        amount: (json['amount'] ?? 0).toDouble(),
        donationDate: DateTime.tryParse((json['donation_date'] ?? json['donationDate'] ?? DateTime.now().toIso8601String()).toString()) ?? DateTime.now(),
        paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? 'pending') as String,
        isAnonymous: (json['is_anonymous'] ?? json['isAnonymous'] ?? false) as bool,
        donorId: (json['donor_id'] ?? json['donorId'] ?? 0) as int,
        campaignId: (json['campaign_id'] ?? json['campaignId'] ?? 0) as int,
        campaignTitle: json['campaign_title']?.toString() ?? json['campaignTitle']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'donation_id': donationId,
        'amount': amount,
        'donation_date': donationDate.toIso8601String(),
        'payment_status': paymentStatus,
        'is_anonymous': isAnonymous,
        'donor_id': donorId,
        'campaign_id': campaignId,
        'campaign_title': campaignTitle,
      };

  DonationModel copyWith({int? donationId, double? amount, DateTime? donationDate, String? paymentStatus, bool? isAnonymous, int? donorId, int? campaignId, String? campaignTitle}) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      amount: amount ?? this.amount,
      donationDate: donationDate ?? this.donationDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      donorId: donorId ?? this.donorId,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
    );
  }
}