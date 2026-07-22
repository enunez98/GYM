import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/teacher_action_row.dart';
import '../../../models/student_profile.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/student_attendance_service.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentProfile student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final attendance = StudentAttendanceService.getSummary(student);
    final evaluation = BodyEvaluationStore.getLastByUserId(student.userId);
    final bodyScore = evaluation?.bodyScore ?? student.bodyScore;

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
                            value: attendance.monthlyText,
                            subtitle: 'mensual',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Evaluación',
                            value: '$bodyScore/100',
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
                            icon: Icons.badge_outlined,
                            label: 'RUT',
                            value: student.rut,
                          ),
                          InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Plan',
                            value: student.plan,
                          ),
                          InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Fecha de inicio',
                            value: student.startDate,
                          ),
                          InfoRow(
                            icon: Icons.event_available,
                            label: 'Vencimiento',
                            value: student.endDate,
                          ),
                          InfoRow(
                            icon: Icons.hourglass_bottom,
                            label: 'Días restantes',
                            value: '${student.daysRemaining}',
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
                        children: [
                          const Text(
                            'Acciones del profesor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const TeacherActionRow(
                            icon: Icons.fitness_center,
                            title: 'Ver rutina actual',
                            subtitle: 'Semana y sesión pendiente',
                          ),
                          const TeacherActionRow(
                            icon: Icons.monitor_weight,
                            title: 'Registrar nueva evaluación',
                            subtitle: 'Body Go Pro / Fitdays',
                          ),
                          TeacherActionRow(
                            icon: Icons.calendar_month,
                            title: 'Ver asistencia',
                            subtitle:
                                '${attendance.weeklyText} semanal · ${attendance.monthlyText} mensual',
                          ),
                          const TeacherActionRow(
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
                        children: [
                          const Text(
                            'Evaluación corporal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (evaluation == null)
                            const Text(
                              'Sin evaluación corporal registrada.',
                              style: TextStyle(color: Colors.black54),
                            )
                          else ...[
                            InfoRow(
                              icon: Icons.monitor_weight,
                              label: 'Peso actual',
                              value: '${evaluation.weightKg} kg',
                            ),
                            InfoRow(
                              icon: Icons.percent,
                              label: 'Grasa corporal',
                              value: '${evaluation.bodyFatPercent}%',
                            ),
                            InfoRow(
                              icon: Icons.accessibility_new,
                              label: 'Masa muscular',
                              value: '${evaluation.muscleMassKg} kg',
                            ),
                          ],
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
