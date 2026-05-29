import 'package:intl/intl.dart';

String formatEtb(double amount) => 'ETB ${NumberFormat('#,##0.00').format(amount)}';

String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);

String formatRelativeTime(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  }
  return formatDate(date);
}

String formatProgress(double raised, double goal) {
  if (goal <= 0) return '0%';
  return '${((raised / goal) * 100).clamp(0, 100).toStringAsFixed(0)}%';
}

String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength).trim()}...';
}