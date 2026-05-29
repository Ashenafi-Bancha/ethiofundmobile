class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  static const String campaigns = '/campaigns';
  static const String campaignById = '/campaigns/';
  static const String campaignUpdates = '/updates';
  static const String campaignApprove = '/approve';
  static const String campaignReject = '/reject';
  static const String campaignSuspend = '/suspend';

  static const String donationsMy = '/donations/my';
  static const String donationsByCampaign = '/donations/campaign/';

  static const String paymentsInitialize = '/payments/initialize';
  static const String paymentsVerify = '/payments/verify/';

  static const String comments = '/comments';
  static const String commentsByCampaign = '/comments/campaign/';

  static const String withdrawals = '/withdrawals';
  static const String withdrawalsMy = '/withdrawals/my';
  static const String withdrawalsPending = '/withdrawals/pending';

  static const String usersMe = '/users/me';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminCampaigns = '/admin/campaigns';
  static const String reports = '/reports';
}