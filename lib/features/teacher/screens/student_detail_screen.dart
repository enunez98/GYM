import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/teacher_action_row.dart';
import '../../../models/routine_assignment.dart';
import '../../../models/student_profile.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/imported_routine_store.dart';
import '../../../services/routine_assignment_store.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_profile_store.dart';
import '../../../services/student_workout_progress_store.dart';

import 'edit_student_screen.dart';
import 'student_workout_history_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final StudentProfile student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  StudentProfile get student {
    return StudentProfileStore.getById(widget.student.id) ?? widget.student;
  }

  bool samePlan(String first, String second) {
    String normalize(String value) {
      return value
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll(' ', '')
          .trim();
    }

    return normalize(first) == normalize(second);
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  void assignImportedRoutine() {
    if (!ImportedRoutineStore.hasData) {
      showMessage('Primero carga una rutina desde Excel');
      return;
    }
    if (!samePlan(student.plan, ImportedRoutineStore.plan)) {
      showMessage('La rutina importada no corresponde al plan del alumno');
      return;
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    RoutineAssignmentStore.assign(
      RoutineAssignment(
        id: 'assignment_$timestamp',
        userId: student.userId,
        studentProfileId: student.id,
        studentName: student.name,
        plan: student.plan,
        routineName: 'Rutina importada',
        sourceFileName: ImportedRoutineStore.fileName,
        assignedAt: DateTime.now(),
        sessions: List.from(ImportedRoutineStore.sessions),
      ),
    );
    StudentWorkoutProgressStore.resetProgress(student);
    setState(() {});
    showMessage('Rutina asignada a ${student.name}');
  }

  void removeAssignedRoutine() {
    RoutineAssignmentStore.removeByUserId(student.userId);
    StudentWorkoutProgressStore.resetProgress(student);
    setState(() {});
    showMessage('Rutina asignada eliminada');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final attendance = StudentAttendanceService.getSummary(student);
    final evaluation = BodyEvaluationStore.getLastByUserId(student.userId);
    final bodyScore = evaluation?.bodyScore ?? student.bodyScore;
    final assignment = RoutineAssignmentStore.getByUserId(student.userId);
    final importedRoutineAvailable = ImportedRoutineStore.hasData;
    final importedPlanMatches =
        importedRoutineAvailable &&
        samePlan(student.plan, ImportedRoutineStore.plan);
    final assignmentHelpText = !importedRoutineAvailable
        ? 'Primero carga una rutina desde Excel'
        : !importedPlanMatches
        ? 'La rutina importada no corresponde al plan del alumno'
        : 'La rutina importada está disponible para este alumno';

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
                            'Rutina asignada',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (assignment == null)
                            const Text(
                              'Este alumno aún no tiene rutina asignada.',
                              style: TextStyle(color: Colors.black54),
                            )
                          else ...[
                            InfoRow(
                              icon: Icons.description_outlined,
                              label: 'Rutina',
                              value: assignment.routineName,
                            ),
                            InfoRow(
                              icon: Icons.file_present_outlined,
                              label: 'Archivo',
                              value: assignment.sourceFileName.isEmpty
                                  ? 'Rutina importada'
                                  : assignment.sourceFileName,
                            ),
                            InfoRow(
                              icon: Icons.fitness_center,
                              label: 'Plan',
                              value: assignment.plan,
                            ),
                            InfoRow(
                              icon: Icons.calendar_view_week_outlined,
                              label: 'Contenido',
                              value:
                                  '${assignment.totalWeeks} semanas · ${assignment.totalSessions} sesiones · ${assignment.totalExercises} ejercicios',
                            ),
                            InfoRow(
                              icon: Icons.schedule,
                              label: 'Asignada',
                              value: formatDate(assignment.assignedAt),
                            ),
                          ],
                          const SizedBox(height: 14),
                          Text(
                            assignmentHelpText,
                            style: TextStyle(
                              color: importedPlanMatches
                                  ? const Color(0xFF12985C)
                                  : const Color(0xFFD98200),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: importedPlanMatches
                                  ? assignImportedRoutine
                                  : null,
                              icon: const Icon(Icons.assignment_add),
                              label: Text(
                                assignment == null
                                    ? 'Asignar rutina importada'
                                    : 'Reasignar rutina importada',
                              ),
                            ),
                          ),
                          if (assignment != null) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: removeAssignedRoutine,
                                icon: const Icon(Icons.link_off),
                                label: const Text('Quitar rutina asignada'),
                              ),
                            ),
                          ],
                        ],
                      ),
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
                          TeacherActionRow(
                            icon: Icons.history,
                            title: 'Ver historial de entrenamientos',
                            subtitle:
                                'Sesiones completadas, omitidas, kg, reps y volumen',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => StudentWorkoutHistoryScreen(
                                    profile: student,
                                  ),
                                ),
                              );
                            },
                          ),
                          TeacherActionRow(
                            icon: Icons.edit_outlined,
                            title: 'Editar datos del alumno',
                            subtitle: 'Nombre, RUT, teléfono, plan y estado',
                            onTap: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute<bool>(
                                  builder: (_) =>
                                      EditStudentScreen(profile: student),
                                ),
                              );
                              if (updated == true && mounted) {
                                setState(() {});
                              }
                            },
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
