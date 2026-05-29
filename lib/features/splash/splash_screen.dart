import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/storage/app_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/brand_mark.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_decideNextRoute);
  }

  Future<void> _decideNextRoute() async {
    if (_navigated) return;
    _navigated = true;

    final preferences = await ref.read(appPreferencesProvider.future);

    if (!mounted) return;

    if (!preferences.onboardingSeen) {
      context.go('/onboarding');
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 132,
              height: 132,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 10)),
                ],
              ),
              child: const Center(child: BrandMark(size: 96, radius: 18)),
            ),
            const SizedBox(height: 18),
            const Text('EthioFund', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text('Crowdfunding for Ethiopia', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}