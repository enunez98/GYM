import 'package:flutter/material.dart';

class ResponsiveActionButton extends StatelessWidget {
  final Widget child;
  final double webMaxWidth;
  final Alignment alignment;

  const ResponsiveActionButton({
    super.key,
    required this.child,
    this.webMaxWidth = 360,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 900) {
      return SizedBox(width: double.infinity, child: child);
    }

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: webMaxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
