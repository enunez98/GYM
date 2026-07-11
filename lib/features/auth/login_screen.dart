import 'package:flutter/material.dart';

import '../student/screens/home_shell.dart';
import '../teacher/screens/teacher_dashboard_screen.dart';
import '../admin/screens/admin_dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Color(0xFF20B2AA),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'GYM Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gestión de alumnos, rutinas y progreso',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 34),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona un perfil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Entrada de prueba antes de conectar Firebase.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 18),
                      _RoleButton(
                        icon: Icons.person,
                        title: 'Entrar como Alumno',
                        subtitle:
                            'Dashboard, entrenamiento, progreso y corporal',
                        color: const Color(0xFF20B2AA),
                        onTap: () => _goTo(context, const HomeShell()),
                      ),
                      const SizedBox(height: 12),
                      _RoleButton(
                        icon: Icons.sports,
                        title: 'Entrar como Profesor',
                        subtitle: 'Alumnos, rutinas, pesajes y asistencia',
                        color: const Color(0xFF2563EB),
                        onTap: () =>
                            _goTo(context, const TeacherDashboardScreen()),
                      ),
                      const SizedBox(height: 12),
                      _RoleButton(
                        icon: Icons.admin_panel_settings,
                        title: 'Entrar como Admin / Dueño',
                        subtitle: 'Panel general del gimnasio',
                        color: const Color(0xFF7C3AED),
                        onTap: () =>
                            _goTo(context, const AdminDashboardScreen()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F8FA),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
