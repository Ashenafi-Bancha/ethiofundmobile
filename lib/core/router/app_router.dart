import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_campaigns_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/admin_reports_screen.dart';
import '../../features/admin/admin_users_screen.dart';
import '../../features/admin/admin_withdrawals_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/campaign/campaign_detail_screen.dart';
import '../../features/campaign/create_campaign_screen.dart';
import '../../features/campaign/edit_campaign_screen.dart';
import '../../features/campaign/my_campaigns_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/donation/donate_screen.dart';
import '../../features/donation/my_donations_screen.dart';
import '../../features/donation/payment_failed_screen.dart';
import '../../features/donation/payment_success_screen.dart';
import '../../features/donation/payment_webview_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/browse_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/withdrawal/my_withdrawals_screen.dart';
import '../../features/withdrawal/request_withdrawal_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../../providers/auth_provider.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authAsync = ref.watch(authNotifierProvider);

  String role() => authAsync.valueOrNull?.user?.role ?? 'guest';
  bool isAuthenticated() => authAsync.valueOrNull?.isAuthenticated ?? false;

  // Centralized route protection keeps the role checks in one place.
  bool isProtected(String location) {
    return location.startsWith('/campaigns/create') ||
        location.startsWith('/campaigns/') && location.endsWith('/edit') ||
        location == '/my-campaigns' ||
        location.startsWith('/donate/') ||
        location == '/payment' ||
        location == '/my-donations' ||
      location == '/dashboard' ||
        location.startsWith('/withdrawals/') ||
        location == '/my-withdrawals' ||
        location == '/profile' ||
        location.startsWith('/admin');
  }

  bool isOrganizerRoute(String location) {
    return location.startsWith('/campaigns/create') ||
        location.startsWith('/campaigns/') && location.endsWith('/edit') ||
        location == '/my-campaigns' ||
        location.startsWith('/withdrawals/') ||
        location == '/my-withdrawals';
  }

  bool isAdminRoute(String location) => location.startsWith('/admin');

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final location = state.uri.toString();
      final loggedIn = isAuthenticated();
      final userRole = role();

      // Splash decides whether to continue to onboarding, login, or the home shell.
      if (location == '/splash') return null;

      if (!loggedIn && isProtected(location)) {
        return '/login';
      }

      if (loggedIn && (location == '/login' || location == '/register')) {
        return '/dashboard';
      }

      if (userRole == 'donor' && (isOrganizerRoute(location) || isAdminRoute(location))) {
        return '/unauthorized';
      }

      if (userRole == 'organizer' && isAdminRoute(location)) {
        return '/unauthorized';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(initialRole: state.uri.queryParameters['role'] ?? 'donor'),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(initialRole: state.uri.queryParameters['role'] ?? 'donor'),
      ),
      GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/campaigns', builder: (context, state) => const BrowseScreen()),
              GoRoute(path: '/campaigns/create', builder: (context, state) => const CreateCampaignScreen()),
              GoRoute(path: '/campaigns/:id/edit', builder: (context, state) => EditCampaignScreen(campaignId: state.pathParameters['id']!)),
              GoRoute(path: '/campaigns/:id', builder: (context, state) => CampaignDetailScreen(campaignId: state.pathParameters['id']!)),
              GoRoute(path: '/my-campaigns', builder: (context, state) => const MyCampaignsScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/my-donations', builder: (context, state) => const MyDonationsScreen()),
              GoRoute(path: '/donate/:id', builder: (context, state) => DonateScreen(campaignId: state.pathParameters['id']!)),
              GoRoute(path: '/payment', builder: (context, state) => PaymentWebViewScreen(checkoutUrl: state.extra as String? ?? '')),
              GoRoute(path: '/payment/success', builder: (context, state) => PaymentSuccessScreen(campaignId: state.extra as int?)),
              GoRoute(path: '/payment/failed', builder: (context, state) => PaymentFailedScreen(campaignId: state.extra as int?)),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
              GoRoute(path: '/withdrawals/request/:id', builder: (context, state) => RequestWithdrawalScreen(campaignId: state.pathParameters['id']!)),
              GoRoute(path: '/my-withdrawals', builder: (context, state) => const MyWithdrawalsScreen()),
              GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
              GoRoute(path: '/admin/campaigns', builder: (context, state) => const AdminCampaignsScreen()),
              GoRoute(path: '/admin/users', builder: (context, state) => const AdminUsersScreen()),
              GoRoute(path: '/admin/withdrawals', builder: (context, state) => const AdminWithdrawalsScreen()),
              GoRoute(path: '/admin/reports', builder: (context, state) => const AdminReportsScreen()),
            ],
          ),
        ],
      ),
        // The shell keeps the main app sections alive while switching tabs.
      GoRoute(path: '/unauthorized', builder: (context, state) => const _UnauthorizedScreen()),
    ],
  );
});

class _UnauthorizedScreen extends StatelessWidget {
  const _UnauthorizedScreen();

  @override
  Widget build(BuildContext context) => const HomeScreen();
}