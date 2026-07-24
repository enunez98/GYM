import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/student_profile.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_profile_store.dart';

import 'student_detail_screen.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = StudentProfileStore.all;
    final activeCount = students
        .where((student) => student.status == 'Activo')
        .length;
    final expiringCount = students
        .where((student) => student.status == 'Por vencer')
        .length;
    final expiredCount = students
        .where((student) => student.status == 'Vencido')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Alumnos',
              subtitle: 'Listado general del gimnasio',
              icon: Icons.groups,
              onBack: () => Navigator.pop(context),
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
                    AppCard(
                      child: ResponsiveFormField(
                        webMaxWidth: 620,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar alumno...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xFFF6F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Activos',
                            value: '$activeCount',
                            subtitle: 'alumnos',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Por vencer',
                            value: '$expiringCount',
                            subtitle: 'planes',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Vencidos',
                            value: '$expiredCount',
                            subtitle: 'planes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final student in students) ...[
                      _StudentListCard(student: student),
                      const SizedBox(height: 12),
                    ],
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

class _StudentListCard extends StatelessWidget {
  final StudentProfile student;

  const _StudentListCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final attendance = StudentAttendanceService.getSummary(student);
    final evaluation = BodyEvaluationStore.getLastByUserId(student.userId);
    final bodyScore = evaluation?.bodyScore ?? student.bodyScore;
    final isWarning = student.status == 'Por vencer';
    final isExpired = student.status == 'Vencido';

    Color background = const Color(0xFFEDF9E8);
    Color textColor = const Color(0xFF59D52D);

    if (isWarning) {
      background = const Color(0xFFFFF2D9);
      textColor = const Color(0xFFD98200);
    }
    if (isExpired) {
      background = const Color(0xFFFFE4E6);
      textColor = const Color(0xFFE11D48);
    }

    return AppCard(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentDetailScreen(student: student),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF59D52D),
                child: Icon(Icons.person, color: Color(0xFF111214)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student.plan,
                      style: const TextStyle(color: Color(0xFF616B76)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      student.phone,
                      style: const TextStyle(
                        color: Color(0xFF616B76),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Asistencia: ${attendance.monthlyText} · Evaluación: $bodyScore/100',
                      style: const TextStyle(
                        color: Color(0xFF616B76),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Vence: ${student.endDate}',
                      style: const TextStyle(
                        color: Color(0xFF616B76),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                text: student.status,
                background: background,
                textColor: textColor,
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Color(0xFF7A838C)),
            ],
          ),
        ),
      ),
    );
  }
}
