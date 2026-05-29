import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _onboardingSeenKey = 'ethiofund_onboarding_seen';

  bool get onboardingSeen => _prefs.getBool(_onboardingSeenKey) ?? false;

  Future<void> setOnboardingSeen(bool value) async {
    await _prefs.setBool(_onboardingSeenKey, value);
  }
}

final appPreferencesProvider = FutureProvider<AppPreferences>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AppPreferences(prefs);
});