import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/teacher_action_row.dart';
import '../../../models/demo_student.dart';

class StudentDetailScreen extends StatelessWidget {
  final DemoStudent student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: student.name,
              subtitle: student.plan,
              icon: Icons.person,
              onBack: () => Navigator.pop(context),
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
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Asistencia',
                            value: student.attendance,
                            subtitle: 'mensual',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Evaluación',
                            value: student.bodyScore,
                            subtitle: 'corporal',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Estado',
                            value: student.status,
                            subtitle: 'plan',
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
                            'Datos del alumno',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Teléfono',
                            value: student.phone,
                          ),
                          InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Plan',
                            value: student.plan,
                          ),
                          InfoRow(
                            icon: Icons.event_available,
                            label: 'Vencimiento',
                            value: student.expiresAt,
                          ),
                          InfoRow(
                            icon: Icons.verified_user_outlined,
                            label: 'Estado',
                            value: student.status,
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
                            'Acciones del profesor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          TeacherActionRow(
                            icon: Icons.fitness_center,
                            title: 'Ver rutina actual',
                            subtitle: 'Semana y sesión pendiente',
                          ),
                          TeacherActionRow(
                            icon: Icons.monitor_weight,
                            title: 'Registrar nueva evaluación',
                            subtitle: 'Body Go Pro / Fitdays',
                          ),
                          TeacherActionRow(
                            icon: Icons.calendar_month,
                            title: 'Ver asistencia',
                            subtitle: 'Cumplimiento mensual',
                          ),
                          TeacherActionRow(
                            icon: Icons.edit_outlined,
                            title: 'Editar datos del alumno',
                            subtitle: 'Plan, teléfono o vencimiento',
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
                            'Resumen rápido',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.monitor_weight,
                            label: 'Peso actual',
                            value: '70.0 kg',
                          ),
                          InfoRow(
                            icon: Icons.percent,
                            label: 'Grasa corporal',
                            value: '21.7%',
                          ),
                          InfoRow(
                            icon: Icons.accessibility_new,
                            label: 'Masa muscular',
                            value: '51.2 kg',
                          ),
                          InfoRow(
                            icon: Icons.bar_chart,
                            label: 'Mejor progreso',
                            value: 'Press banca +12.5 kg',
                          ),
                        ],
                      ),
                    ),
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
