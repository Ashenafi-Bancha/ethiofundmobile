class WithdrawalModel {
  const WithdrawalModel({
    required this.withdrawalId,
    required this.amount,
    required this.status,
    required this.bankAccount,
    required this.requestDate,
    required this.campaignId,
    required this.campaignTitle,
  });

  final int withdrawalId;
  final double amount;
  final String status;
  final String? bankAccount;
  final DateTime requestDate;
  final int campaignId;
  final String? campaignTitle;

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) => WithdrawalModel(
        withdrawalId: (json['withdrawal_id'] ?? json['withdrawalId'] ?? 0) as int,
        amount: (json['amount'] ?? 0).toDouble(),
        status: (json['status'] ?? 'pending') as String,
        bankAccount: json['bank_account']?.toString() ?? json['bankAccount']?.toString(),
        requestDate: DateTime.tryParse((json['request_date'] ?? json['requestDate'] ?? DateTime.now().toIso8601String()).toString()) ?? DateTime.now(),
        campaignId: (json['campaign_id'] ?? json['campaignId'] ?? 0) as int,
        campaignTitle: json['campaign_title']?.toString() ?? json['campaignTitle']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'withdrawal_id': withdrawalId,
        'amount': amount,
        'status': status,
        'bank_account': bankAccount,
        'request_date': requestDate.toIso8601String(),
        'campaign_id': campaignId,
        'campaign_title': campaignTitle,
      };

  WithdrawalModel copyWith({int? withdrawalId, double? amount, String? status, String? bankAccount, DateTime? requestDate, int? campaignId, String? campaignTitle}) {
    return WithdrawalModel(
      withdrawalId: withdrawalId ?? this.withdrawalId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      bankAccount: bankAccount ?? this.bankAccount,
      requestDate: requestDate ?? this.requestDate,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
    );
  }
}