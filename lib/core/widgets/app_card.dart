import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double webContentMaxWidth;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.webContentMaxWidth = 1120,
  });

  @override
  Widget build(BuildContext context) {
    final isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: isWebLayout
          ? Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: webContentMaxWidth),
                child: SizedBox(width: double.infinity, child: child),
              ),
            )
          : child,
    );
  }
}
