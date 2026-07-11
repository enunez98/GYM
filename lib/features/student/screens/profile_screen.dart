import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/logout_option.dart';
import '../../../services/session_store.dart';

import '../../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    SessionStore.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final userName = user?.name ?? 'Alumno';
    final userRut = user?.rut ?? '-';

    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF20B2AA),
              child: Icon(Icons.person, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 12),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'RUT: $userRut',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    const _ProfileOption(
                      icon: Icons.person_outline,
                      title: 'Información personal',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.credit_card,
                      title: 'Plan y pagos',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.calendar_month,
                      title: 'Asistencia',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.monitor_weight,
                      title: 'Evaluación corporal',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Ayuda y soporte',
                    ),
                    const SizedBox(height: 16),
                    LogoutOption(onTap: () => _logout(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileOption({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF20B2AA)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}
