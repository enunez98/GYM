import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/logout_option.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/teacher_action_row.dart';
import '../../../services/session_store.dart';

import '../../auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) {
    SessionStore.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Panel Admin',
              subtitle: 'Resumen general del gimnasio',
              icon: Icons.admin_panel_settings,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: MetricCard(
                            title: 'Alumnos',
                            value: '128',
                            subtitle: 'activos',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Vencen pronto',
                            value: '9',
                            subtitle: 'planes',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Asistencia',
                            value: '76%',
                            subtitle: 'mes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Gestión del gimnasio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          TeacherActionRow(
                            icon: Icons.groups,
                            title: 'Usuarios registrados',
                            subtitle: 'Alumnos, profesores y administradores',
                          ),
                          TeacherActionRow(
                            icon: Icons.calendar_month,
                            title: 'Planes y vencimientos',
                            subtitle: '2, 3 o 4 sesiones por semana',
                          ),
                          TeacherActionRow(
                            icon: Icons.insert_chart_outlined,
                            title: 'Reporte de asistencia',
                            subtitle: 'Cumplimiento por alumno y plan',
                          ),
                          TeacherActionRow(
                            icon: Icons.upload_file,
                            title: 'Importar planificación',
                            subtitle: 'Cargar Excel de rutinas',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Alertas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _AdminAlertRow(
                            icon: Icons.warning_amber,
                            title: '9 alumnos con plan por vencer',
                            subtitle: 'Revisar renovaciones esta semana',
                          ),
                          _AdminAlertRow(
                            icon: Icons.trending_down,
                            title: '12 alumnos con baja asistencia',
                            subtitle: 'Menos del 50% de cumplimiento mensual',
                          ),
                          _AdminAlertRow(
                            icon: Icons.monitor_weight,
                            title: '6 evaluaciones corporales pendientes',
                            subtitle: 'Alumnos sin pesaje actualizado',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    LogoutOption(onTap: () => _logout(context)),
                    const SizedBox(height: 24),
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

class _AdminAlertRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminAlertRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFF2D9),
            child: Icon(icon, color: const Color(0xFFD98200), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF616B76),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
