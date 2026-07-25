import 'package:flutter/material.dart';

import 'responsive_form_field.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveFormField(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(widthFactor: 1, child: suffix),
                ),
          suffixIconConstraints: const BoxConstraints(minHeight: 40),
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
