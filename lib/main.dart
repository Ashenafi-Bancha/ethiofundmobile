import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

export 'app.dart';

String _requiredEnv(String key) {
  final value = dotenv.env[key];
  if (value == null || value.isEmpty) {
    throw StateError('Missing $key in .env');
  }
  return value;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep the app in portrait so the mobile layout stays consistent.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: _requiredEnv('SUPABASE_URL'),
    anonKey: _requiredEnv('SUPABASE_ANON_KEY'),
  );
  // ProviderScope makes all Riverpod providers available from the root.
  runApp(const ProviderScope(child: EthioFundApp()));
}
