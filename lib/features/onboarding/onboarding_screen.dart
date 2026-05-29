import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/app_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/primary_button.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = [
      _OnboardingPage(
        icon: Icons.volunteer_activism_outlined,
        title: 'Support real causes',
        description: 'Discover community campaigns, medical needs, education drives, and local initiatives across Ethiopia.',
      ),
      _OnboardingPage(
        icon: Icons.verified_outlined,
        title: 'Donate securely',
        description: 'Track donations, follow secure payment checkout, and keep every contribution transparent.',
      ),
      _OnboardingPage(
        icon: Icons.groups_outlined,
        title: 'Create impact',
        description: 'Organizers can launch campaigns, post updates, and manage withdrawals from one place.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _completeOnboarding(context, ref),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  itemCount: pages.length,
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Get Started',
                onPressed: () => _completeOnboarding(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    final preferences = await ref.read(appPreferencesProvider.future);
    // Persist the first-run flag so the splash screen can skip onboarding next time.
    await preferences.setOnboardingSeen(true);

    final authState = await ref.read(authNotifierProvider.future);
    if (!context.mounted) return;
    context.go(authState.isAuthenticated ? '/home' : '/login');
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.icon, required this.title, required this.description});

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 60, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}