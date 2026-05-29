import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'brand_mark.dart';

class EthioFundAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EthioFundAppBar({super.key, required this.title, this.actions, this.showBackButton = false});

  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      leading: showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop())
          : const Padding(
              padding: EdgeInsets.all(12.0),
              child: BrandMark(size: 28, radius: 8),
            ),
      title: Text(title),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}