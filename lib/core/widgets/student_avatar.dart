import 'dart:convert';

import 'package:flutter/material.dart';

import '../../services/session_store.dart';

String studentInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'A';
  final first = parts.first.characters.first.toUpperCase();
  if (parts.length == 1) return first;
  final surname = parts.length >= 3 ? parts[parts.length - 2] : parts.last;
  return '$first${surname.characters.first.toUpperCase()}';
}

class StudentAvatar extends StatelessWidget {
  final double radius;
  final String fallbackName;

  const StudentAvatar({
    super.key,
    required this.radius,
    required this.fallbackName,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SessionStore.userNotifier,
      builder: (context, user, _) {
        final name = user?.name ?? fallbackName;
        final initials = studentInitials(name);
        final photoData = user?.photoData;
        Widget fallback() => Center(
          child: Text(
            initials,
            style: TextStyle(
              color: const Color(0xFF111214),
              fontSize: radius * .75,
              fontWeight: FontWeight.w800,
            ),
          ),
        );

        return CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF59D52D),
          child: photoData == null || photoData.isEmpty
              ? fallback()
              : ClipOval(
                  child: Image.memory(
                    base64Decode(photoData),
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => fallback(),
                  ),
                ),
        );
      },
    );
  }
}
