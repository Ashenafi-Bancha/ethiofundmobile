String? validateEmail(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) return 'Email is required';
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!regex.hasMatch(input)) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  final input = value ?? '';
  if (input.isEmpty) return 'Password is required';
  if (input.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validatePhone(String? value) {
  final input = value?.trim() ?? '';
  if (input.isEmpty) return 'Phone number is required';
  final regex = RegExp(r'^(\+2519\d{8}|09\d{8})$');
  if (!regex.hasMatch(input)) return 'Enter a valid Ethiopian phone number';
  return null;
}

String? validateRequired(String? value, String fieldName) {
  if ((value ?? '').trim().isEmpty) return '$fieldName is required';
  return null;
}

String? validateAmount(String? value) {
  final amount = double.tryParse((value ?? '').trim());
  if (amount == null || amount <= 0) return 'Enter a valid positive amount';
  return null;
}

String? validateCampaignGoal(String? value) {
  final amount = double.tryParse((value ?? '').trim());
  if (amount == null || amount <= 0) return 'Campaign goal must be greater than 0';
  return null;
}