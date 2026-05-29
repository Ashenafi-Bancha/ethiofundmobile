import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({super.key, required this.name, this.radius = 24});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? 'EF'
        : name.trim().split(RegExp(r'\s+')).take(2).map((part) => part.isNotEmpty ? part[0] : '').join().toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
    );
  }
}