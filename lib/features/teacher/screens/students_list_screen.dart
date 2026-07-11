import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/demo_student.dart';

import 'student_detail_screen.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final students = [
      DemoStudent(
        name: 'Felipe Durán',
        phone: '+569 1234 5678',
        plan: 'Plan 3 sesiones',
        status: 'Activo',
        attendance: '5/12',
        bodyScore: '72/100',
        expiresAt: '30-07-2026',
      ),
      DemoStudent(
        name: 'Camila Rojas',
        phone: '+569 9876 5432',
        plan: 'Plan 2 sesiones',
        status: 'Activo',
        attendance: '3/8',
        bodyScore: '68/100',
        expiresAt: '04-08-2026',
      ),
      DemoStudent(
        name: 'Matías Soto',
        phone: '+569 5555 4444',
        plan: 'Plan 4 sesiones',
        status: 'Por vencer',
        attendance: '7/16',
        bodyScore: '75/100',
        expiresAt: '08-07-2026',
      ),
      DemoStudent(
        name: 'Valentina Pérez',
        phone: '+569 2222 1111',
        plan: 'Plan 3 sesiones',
        status: 'Vencido',
        attendance: '2/12',
        bodyScore: '70/100',
        expiresAt: '01-07-2026',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
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
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    AppCard(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar alumno...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color(0xFFF6F8FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(
                          child: MetricCard(
                            title: 'Activos',
                            value: '42',
                            subtitle: 'alumnos',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Por vencer',
                            value: '9',
                            subtitle: 'planes',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Vencidos',
                            value: '4',
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
  final DemoStudent student;

  const _StudentListCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final isWarning = student.status == 'Por vencer';
    final isExpired = student.status == 'Vencido';

    Color background = const Color(0xFFDFF9EA);
    Color textColor = const Color(0xFF12985C);

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
                backgroundColor: Color(0xFF20B2AA),
                child: Icon(Icons.person, color: Colors.white),
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
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Vence: ${student.expiresAt}',
                      style: const TextStyle(
                        color: Colors.black45,
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
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
