import 'package:flutter/material.dart';

import 'app_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF20B2AA),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
