import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/student_profile.dart';
import '../../../models/workout_log.dart';
import '../../../services/workout_history_store.dart';
import '../../../services/workout_progress_service.dart';

class StudentWorkoutHistoryScreen extends StatelessWidget {
  final StudentProfile profile;

  const StudentWorkoutHistoryScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final logs = WorkoutHistoryStore.getByUserId(
      profile.userId,
    ).reversed.toList();
    final completedLogs = logs.where((log) => log.isCompleted).toList();
    final skippedLogs = logs.where((log) => log.isSkipped).toList();
    final summary = WorkoutProgressService.getSummaryByUserId(profile.userId);

    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Historial',
              subtitle: profile.name,
              icon: Icons.history,
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
                            title: 'Completados',
                            value: '${completedLogs.length}',
                            subtitle: 'sesiones',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Omitidos',
                            value: '${skippedLogs.length}',
                            subtitle: 'sesiones',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Volumen',
                            value: WorkoutProgressService.formatVolume(
                              summary.totalVolume,
                            ),
                            subtitle: 'kg',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (logs.isEmpty)
                      const AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sin historial',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Este alumno todavía no tiene entrenamientos guardados ni sesiones omitidas.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      )
                    else
                      for (final log in logs) ...[
                        _WorkoutLogCard(log: log),
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

class _WorkoutLogCard extends StatelessWidget {
  final WorkoutLog log;

  const _WorkoutLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  log.sessionTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusChip(
                text: log.status.label,
                background: log.isCompleted
                    ? const Color(0xFFDFF9EA)
                    : const Color(0xFFFFF2D9),
                textColor: log.isCompleted
                    ? const Color(0xFF12985C)
                    : const Color(0xFFD98200),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InfoRow(
            icon: Icons.calendar_month,
            label: 'Fecha',
            value: WorkoutProgressService.formatDate(log.createdAt),
          ),
          InfoRow(
            icon: Icons.view_week_outlined,
            label: 'Semana',
            value: log.weekLabel,
          ),
          InfoRow(
            icon: Icons.fitness_center,
            label: 'Sesión',
            value: log.sessionLabel,
          ),
          InfoRow(
            icon: Icons.assignment_outlined,
            label: 'Plan',
            value: log.plan,
          ),
          if (log.isCompleted) ...[
            InfoRow(
              icon: Icons.bolt,
              label: 'Volumen',
              value:
                  '${WorkoutProgressService.formatVolume(log.totalVolume)} kg',
            ),
            InfoRow(
              icon: Icons.list_alt,
              label: 'Series',
              value: '${log.totalSets}',
            ),
          ],
          if (log.isCompleted && log.exercises.isNotEmpty) ...[
            const SizedBox(height: 4),
            const Text(
              'Ejercicios',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final exercise in log.exercises)
              _ExerciseLogCard(exercise: exercise),
          ],
          if (log.isSkipped) ...[
            const SizedBox(height: 2),
            const Text(
              'Esta sesión fue omitida, por eso no suma asistencia ni progreso.',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseLogCard extends StatelessWidget {
  final WorkoutExerciseLog exercise;

  const _ExerciseLogCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.exerciseName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Objetivo: ${exercise.targetReps} · ${exercise.completedSets}/${exercise.plannedSeries} series · Volumen ${WorkoutProgressService.formatVolume(exercise.totalVolume)} kg',
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          for (final set in exercise.sets)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text('Serie ${set.setNumber}')),
                  Text(
                    '${WorkoutProgressService.formatKg(set.kg)} kg x ${set.reps} reps',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
