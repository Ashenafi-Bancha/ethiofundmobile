import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isAdmin => ProviderScope.containerOf(this, listen: false).read(userRoleProvider) == 'admin';
  bool get isOrganizer => ProviderScope.containerOf(this, listen: false).read(userRoleProvider) == 'organizer';
  bool get isDonor => ProviderScope.containerOf(this, listen: false).read(userRoleProvider) == 'donor';

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(this).colorScheme.error : null,
      ),
    );
  }

  void showSuccessSnackBar(String message) => showSnackBar(message);
}