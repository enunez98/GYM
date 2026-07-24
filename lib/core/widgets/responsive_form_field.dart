import 'package:flutter/material.dart';

class ResponsiveFormField extends StatelessWidget {
  final Widget child;
  final double webMaxWidth;

  const ResponsiveFormField({
    super.key,
    required this.child,
    this.webMaxWidth = 520,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 900) {
      return SizedBox(width: double.infinity, child: child);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: webMaxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
