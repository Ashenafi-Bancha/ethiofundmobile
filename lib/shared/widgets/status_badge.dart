import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Color background;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'active':
        background = AppColors.approvedBadge;
        break;
      case 'rejected':
      case 'suspended':
        background = AppColors.rejectedBadge;
        break;
      case 'closed':
        background = Colors.grey;
        break;
      default:
        background = AppColors.pendingBadge;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}