class DashboardStatsModel {
  const DashboardStatsModel({
    required this.totalUsers,
    required this.totalCampaigns,
    required this.totalDonations,
    required this.totalRaised,
    required this.pendingCampaigns,
    required this.pendingWithdrawals,
  });

  final int totalUsers;
  final int totalCampaigns;
  final int totalDonations;
  final double totalRaised;
  final int pendingCampaigns;
  final int pendingWithdrawals;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) => DashboardStatsModel(
        totalUsers: (json['total_users'] ?? json['totalUsers'] ?? 0) as int,
        totalCampaigns: (json['total_campaigns'] ?? json['totalCampaigns'] ?? 0) as int,
        totalDonations: (json['total_donations'] ?? json['totalDonations'] ?? 0) as int,
        totalRaised: (json['total_raised'] ?? json['totalRaised'] ?? 0).toDouble(),
        pendingCampaigns: (json['pending_campaigns'] ?? json['pendingCampaigns'] ?? 0) as int,
        pendingWithdrawals: (json['pending_withdrawals'] ?? json['pendingWithdrawals'] ?? 0) as int,
      );

  Map<String, dynamic> toJson() => {
        'total_users': totalUsers,
        'total_campaigns': totalCampaigns,
        'total_donations': totalDonations,
        'total_raised': totalRaised,
        'pending_campaigns': pendingCampaigns,
        'pending_withdrawals': pendingWithdrawals,
      };

  DashboardStatsModel copyWith({int? totalUsers, int? totalCampaigns, int? totalDonations, double? totalRaised, int? pendingCampaigns, int? pendingWithdrawals}) {
    return DashboardStatsModel(
      totalUsers: totalUsers ?? this.totalUsers,
      totalCampaigns: totalCampaigns ?? this.totalCampaigns,
      totalDonations: totalDonations ?? this.totalDonations,
      totalRaised: totalRaised ?? this.totalRaised,
      pendingCampaigns: pendingCampaigns ?? this.pendingCampaigns,
      pendingWithdrawals: pendingWithdrawals ?? this.pendingWithdrawals,
    );
  }
}