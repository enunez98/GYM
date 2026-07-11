import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool chip;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.chip = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = chip
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF9EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF12985C),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Text(value, style: const TextStyle(fontWeight: FontWeight.bold));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF20B2AA)),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          valueWidget,
        ],
      ),
    );
  }
}
