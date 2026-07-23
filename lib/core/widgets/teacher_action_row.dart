import 'package:flutter/material.dart';

class TeacherActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const TeacherActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rowContent = Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFEDF9E8),
          child: Icon(icon, color: const Color(0xFF59D52D), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Color(0xFF7A838C)),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: rowContent,
          ),
        ),
      ),
    );
  }
}
