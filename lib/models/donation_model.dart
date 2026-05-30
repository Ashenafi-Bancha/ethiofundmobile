class DonationModel {
  const DonationModel({
    required this.donationId,
    required this.amount,
    required this.donationDate,
    required this.paymentStatus,
    required this.paymentProvider,
    required this.isAnonymous,
    required this.donorId,
    required this.campaignId,
    required this.campaignTitle,
    this.paymentReference,
    this.checkoutUrl,
    this.paidAt,
  });

  final int donationId;
  final double amount;
  final DateTime donationDate;
  final String paymentStatus;
  final String paymentProvider;
  final bool isAnonymous;
  final int donorId;
  final int campaignId;
  final String? campaignTitle;
  final String? paymentReference;
  final String? checkoutUrl;
  final DateTime? paidAt;

  factory DonationModel.fromJson(Map<String, dynamic> json) => DonationModel(
        donationId: (json['donation_id'] ?? json['donationId'] ?? 0) as int,
        amount: (json['amount'] ?? 0).toDouble(),
        donationDate: DateTime.tryParse((json['donation_date'] ?? json['donationDate'] ?? DateTime.now().toIso8601String()).toString()) ?? DateTime.now(),
        paymentStatus: (json['payment_status'] ?? json['paymentStatus'] ?? 'pending') as String,
        paymentProvider: (json['payment_provider'] ?? json['paymentProvider'] ?? 'chapa') as String,
        isAnonymous: (json['is_anonymous'] ?? json['isAnonymous'] ?? false) as bool,
        donorId: (json['donor_id'] ?? json['donorId'] ?? 0) as int,
        campaignId: (json['campaign_id'] ?? json['campaignId'] ?? 0) as int,
        campaignTitle: json['campaign_title']?.toString() ?? json['campaignTitle']?.toString(),
        paymentReference: json['payment_reference']?.toString() ?? json['paymentReference']?.toString(),
        checkoutUrl: json['checkout_url']?.toString() ?? json['checkoutUrl']?.toString(),
        paidAt: DateTime.tryParse((json['paid_at'] ?? json['paidAt'] ?? '').toString()),
      );

  Map<String, dynamic> toJson() => {
        'donation_id': donationId,
        'amount': amount,
        'donation_date': donationDate.toIso8601String(),
        'payment_status': paymentStatus,
        'payment_provider': paymentProvider,
        'is_anonymous': isAnonymous,
        'donor_id': donorId,
        'campaign_id': campaignId,
        'campaign_title': campaignTitle,
        'payment_reference': paymentReference,
        'checkout_url': checkoutUrl,
        'paid_at': paidAt?.toIso8601String(),
      };

  DonationModel copyWith({
    int? donationId,
    double? amount,
    DateTime? donationDate,
    String? paymentStatus,
    String? paymentProvider,
    bool? isAnonymous,
    int? donorId,
    int? campaignId,
    String? campaignTitle,
    String? paymentReference,
    String? checkoutUrl,
    DateTime? paidAt,
  }) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      amount: amount ?? this.amount,
      donationDate: donationDate ?? this.donationDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentProvider: paymentProvider ?? this.paymentProvider,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      donorId: donorId ?? this.donorId,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      paymentReference: paymentReference ?? this.paymentReference,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}