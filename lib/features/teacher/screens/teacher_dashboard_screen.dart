import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/logout_option.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/teacher_action_row.dart';

import '../../auth/login_screen.dart';
import 'import_routines_screen.dart';
import 'register_body_evaluation_screen.dart';
import 'register_student_screen.dart';
import 'students_list_screen.dart';
import 'weekly_routine_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openRegisterStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterStudentScreen()),
    );
  }

  void _openRegisterBodyEvaluation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterBodyEvaluationScreen()),
    );
  }

  void _openStudentsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentsListScreen()),
    );
  }

  void _openWeeklyRoutine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WeeklyRoutineScreen()),
    );
  }

  void _openImportRoutines(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportRoutinesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Panel Profesor',
              subtitle: 'Gestión diaria de alumnos',
              icon: Icons.sports,
            ),
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
                    Row(
                      children: const [
                        Expanded(
                          child: MetricCard(
                            title: 'Alumnos activos',
                            value: '42',
                            subtitle: 'activos',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Clases hoy',
                            value: '18',
                            subtitle: 'agendadas',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Pesajes',
                            value: '6',
                            subtitle: 'semana',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acciones rápidas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TeacherActionRow(
                            icon: Icons.person_add_alt,
                            title: 'Registrar alumno',
                            subtitle: 'Nombre, teléfono, plan y vencimiento',
                            onTap: () => _openRegisterStudent(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.groups,
                            title: 'Ver alumnos',
                            subtitle:
                                'Listado, estado, plan y ficha del alumno',
                            onTap: () => _openStudentsList(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.monitor_weight,
                            title: 'Registrar evaluación corporal',
                            subtitle: 'Datos de Body Go Pro / Fitdays',
                            onTap: () => _openRegisterBodyEvaluation(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.fitness_center,
                            title: 'Ver rutina semanal',
                            subtitle: 'Plan 2, 3 o 4 sesiones',
                            onTap: () => _openWeeklyRoutine(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.upload_file,
                            title: 'Cargar rutinas desde Excel',
                            subtitle: 'Importar planificación del gimnasio',
                            onTap: () => _openImportRoutines(context),
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
                            'Alumnos recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _StudentMiniRow(
                            name: 'Felipe Durán',
                            plan: 'Plan 3 sesiones',
                            status: 'Activo',
                          ),
                          _StudentMiniRow(
                            name: 'Camila Rojas',
                            plan: 'Plan 2 sesiones',
                            status: 'Activo',
                          ),
                          _StudentMiniRow(
                            name: 'Matías Soto',
                            plan: 'Plan 4 sesiones',
                            status: 'Por vencer',
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

class _StudentMiniRow extends StatelessWidget {
  final String name;
  final String plan;
  final String status;

  const _StudentMiniRow({
    required this.name,
    required this.plan,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = status == 'Por vencer';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 21,
            backgroundColor: Color(0xFF20B2AA),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  plan,
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          StatusChip(
            text: status,
            background: isWarning
                ? const Color(0xFFFFF2D9)
                : const Color(0xFFDFF9EA),
            textColor: isWarning
                ? const Color(0xFFD98200)
                : const Color(0xFF12985C),
          ),
        ],
      ),
    );
  }
}
