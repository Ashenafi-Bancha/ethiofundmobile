import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'brand_mark.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BrandMark(size: 44, radius: 12),
          const SizedBox(height: 16),
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message ?? 'Loading...'),
        ],
      ),
    );
  }
}