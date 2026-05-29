import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class EthioFundApp extends ConsumerWidget {
  const EthioFundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The router is driven by provider state so auth and onboarding can redirect cleanly.
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EthioFund',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      locale: const Locale('en', 'ET'),
      supportedLocales: const [Locale('en', 'ET')],
    );
  }
}