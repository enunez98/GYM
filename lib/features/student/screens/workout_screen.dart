import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/demo_exercise.dart';
import '../../../models/app_user.dart';
import '../../../models/routine_models.dart';
import '../../../models/student_profile.dart';
import '../../../models/workout_log.dart';
import '../../../services/demo_student_profile_service.dart';
import '../../../services/session_store.dart';
import '../../../services/student_routine_service.dart';
import '../../../services/student_workout_progress_store.dart';
import '../../../services/workout_history_store.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final Map<String, TextEditingController> _workoutControllers = {};

  String _controllerKey({
    required String type,
    required int exerciseIndex,
    required int seriesNumber,
  }) {
    return '$type-$exerciseIndex-$seriesNumber';
  }

  TextEditingController _controllerFor({
    required String type,
    required int exerciseIndex,
    required int seriesNumber,
  }) {
    final key = _controllerKey(
      type: type,
      exerciseIndex: exerciseIndex,
      seriesNumber: seriesNumber,
    );
    _workoutControllers.putIfAbsent(key, TextEditingController.new);
    return _workoutControllers[key]!;
  }

  double _parseKg(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  int _parseReps(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  void _clearWorkoutInputs() {
    for (final controller in _workoutControllers.values) {
      controller.clear();
    }
  }

  @override
  void dispose() {
    for (final controller in _workoutControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  WorkoutLog _buildCompletedWorkoutLog({
    required AppUser? user,
    required StudentProfile? profile,
    required DemoRoutineSession session,
  }) {
    final exerciseLogs = <WorkoutExerciseLog>[];

    for (
      int exerciseIndex = 0;
      exerciseIndex < session.exercises.length;
      exerciseIndex++
    ) {
      final exercise = session.exercises[exerciseIndex];
      final totalSeries = exercise.series <= 0 ? 1 : exercise.series;
      final setLogs = <WorkoutSetLog>[];

      for (int seriesNumber = 1; seriesNumber <= totalSeries; seriesNumber++) {
        final kg = _parseKg(
          _controllerFor(
            type: 'kg',
            exerciseIndex: exerciseIndex,
            seriesNumber: seriesNumber,
          ).text,
        );
        final reps = _parseReps(
          _controllerFor(
            type: 'reps',
            exerciseIndex: exerciseIndex,
            seriesNumber: seriesNumber,
          ).text,
        );

        if (kg > 0 || reps > 0) {
          setLogs.add(
            WorkoutSetLog(setNumber: seriesNumber, kg: kg, reps: reps),
          );
        }
      }

      if (setLogs.isNotEmpty) {
        exerciseLogs.add(
          WorkoutExerciseLog(
            exerciseName: exercise.name,
            plannedSeries: totalSeries,
            targetReps: exercise.reps,
            sets: setLogs,
          ),
        );
      }
    }

    return WorkoutLog(
      id: 'workout_${DateTime.now().microsecondsSinceEpoch}',
      userId: profile?.userId ?? user?.id ?? '',
      studentProfileId: profile?.id ?? '',
      studentName: profile?.name ?? user?.name ?? 'Alumno',
      plan: profile?.plan ?? '',
      weekLabel: profile?.currentWeekLabel ?? session.session,
      sessionLabel: session.session,
      sessionTitle: session.title,
      createdAt: DateTime.now(),
      status: WorkoutLogStatus.completed,
      exercises: exerciseLogs,
    );
  }

  void _saveWorkout({
    required AppUser? user,
    required StudentProfile? profile,
    required DemoRoutineSession? assignedSession,
    required int totalSessions,
  }) {
    if (assignedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesión asignada para guardar')),
      );
      return;
    }

    final log = _buildCompletedWorkoutLog(
      user: user,
      profile: profile,
      session: assignedSession,
    );

    if (log.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa al menos una serie con kg o repeticiones'),
        ),
      );
      return;
    }

    WorkoutHistoryStore.add(log);
    StudentWorkoutProgressStore.completeCurrentSession(profile, totalSessions);
    _clearWorkoutInputs();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Entrenamiento guardado: ${log.totalSets} series, ${log.totalVolume.toStringAsFixed(0)} kg de volumen',
        ),
      ),
    );
  }

  void _skipWorkout({
    required AppUser? user,
    required StudentProfile? profile,
    required DemoRoutineSession? assignedSession,
    required int totalSessions,
  }) {
    if (assignedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sesión asignada para omitir')),
      );
      return;
    }

    final log = WorkoutLog(
      id: 'workout_${DateTime.now().microsecondsSinceEpoch}',
      userId: profile?.userId ?? user?.id ?? '',
      studentProfileId: profile?.id ?? '',
      studentName: profile?.name ?? user?.name ?? 'Alumno',
      plan: profile?.plan ?? '',
      weekLabel: profile?.currentWeekLabel ?? assignedSession.session,
      sessionLabel: assignedSession.session,
      sessionTitle: assignedSession.title,
      createdAt: DateTime.now(),
      status: WorkoutLogStatus.skipped,
      exercises: const [],
    );

    WorkoutHistoryStore.add(log);
    StudentWorkoutProgressStore.skipCurrentSession(profile, totalSessions);
    _clearWorkoutInputs();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sesión omitida. Avanzaste sin sumar asistencia.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final weekSessions = StudentRoutineService.getCurrentWeekSessions(profile);
    final assignedSession = StudentRoutineService.getCurrentSession(profile);
    final hasAssignedWorkout = assignedSession != null;
    final weekFinished = weekSessions.isNotEmpty && assignedSession == null;

    final exercises = [
      DemoExercise(
        name: 'Press Banca Plano',
        muscleGroup: 'Pecho',
        series: [
          DemoSet(serie: 1, kg: 60, reps: 10),
          DemoSet(serie: 2, kg: 65, reps: 10),
          DemoSet(serie: 3, kg: 65, reps: 8),
          DemoSet(serie: 4, kg: 60, reps: 10),
        ],
      ),
      DemoExercise(
        name: 'Press Inclinado Mancuernas',
        muscleGroup: 'Pecho',
        series: [
          DemoSet(serie: 1, kg: 28, reps: 12),
          DemoSet(serie: 2, kg: 30, reps: 10),
          DemoSet(serie: 3, kg: 30, reps: 10),
          DemoSet(serie: 4, kg: 28, reps: 12),
        ],
      ),
      DemoExercise(
        name: 'Extensión de Tríceps',
        muscleGroup: 'Tríceps',
        series: [
          DemoSet(serie: 1, kg: 25, reps: 12),
          DemoSet(serie: 2, kg: 30, reps: 10),
          DemoSet(serie: 3, kg: 30, reps: 10),
        ],
      ),
    ];

    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Entrenamiento',
              subtitle: 'Sesión actual del alumno',
              icon: Icons.fitness_center,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weekFinished
                                ? 'Semana completada'
                                : hasAssignedWorkout
                                ? assignedSession.session
                                : 'Semana 2 - Ordinario',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  weekFinished
                                      ? 'Sin sesiones pendientes'
                                      : hasAssignedWorkout
                                      ? assignedSession.title
                                      : 'Sesión 1',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusChip(
                                text: hasAssignedWorkout
                                    ? 'Excel'
                                    : 'Pendiente',
                                background: hasAssignedWorkout
                                    ? const Color(0xFFDFF9EA)
                                    : const Color(0xFFFFF2D9),
                                textColor: hasAssignedWorkout
                                    ? const Color(0xFF12985C)
                                    : const Color(0xFFD98200),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            weekFinished
                                ? 'Todas las sesiones de esta semana ya fueron avanzadas'
                                : hasAssignedWorkout
                                ? '${assignedSession.exercises.length} ejercicios importados'
                                : 'Pecho - Tríceps',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              hasAssignedWorkout
                                  ? 'Esta clase corresponde al plan del alumno y viene desde la planificación cargada por el admin.'
                                  : 'Debes completar esta sesión para avanzar a la siguiente clase.',
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (hasAssignedWorkout)
                      for (
                        int i = 0;
                        i < assignedSession.exercises.length;
                        i++
                      ) ...[
                        _ImportedWorkoutExerciseCard(
                          number: i + 1,
                          exerciseIndex: i,
                          exercise: assignedSession.exercises[i],
                          kgControllerFor: (seriesNumber) => _controllerFor(
                            type: 'kg',
                            exerciseIndex: i,
                            seriesNumber: seriesNumber,
                          ),
                          repsControllerFor: (seriesNumber) => _controllerFor(
                            type: 'reps',
                            exerciseIndex: i,
                            seriesNumber: seriesNumber,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ]
                    else
                      for (int i = 0; i < exercises.length; i++) ...[
                        _ExerciseCard(number: i + 1, exercise: exercises[i]),
                        const SizedBox(height: 14),
                      ],
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20B2AA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: hasAssignedWorkout
                            ? () {
                                _saveWorkout(
                                  user: user,
                                  profile: profile,
                                  assignedSession: assignedSession,
                                  totalSessions: weekSessions.length,
                                );
                              }
                            : null,
                        child: const Text(
                          'Guardar entrenamiento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: hasAssignedWorkout
                            ? () {
                                _skipWorkout(
                                  user: user,
                                  profile: profile,
                                  assignedSession: assignedSession,
                                  totalSessions: weekSessions.length,
                                );
                              }
                            : null,
                        child: const Text(
                          'Omitir sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

class _ExerciseCard extends StatelessWidget {
  final int number;
  final DemoExercise exercise;

  const _ExerciseCard({required this.number, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE9F8F7),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF20B2AA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${exercise.series.length} series',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exercise.muscleGroup,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Serie',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 76,
                child: Text(
                  'kg',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 76,
                child: Text(
                  'reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in exercise.series)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('Serie ${item.serie}')),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '${item.kg}',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '${item.reps}',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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

class _ImportedWorkoutExerciseCard extends StatelessWidget {
  final int number;
  final int exerciseIndex;
  final DemoRoutineExercise exercise;
  final TextEditingController Function(int seriesNumber) kgControllerFor;
  final TextEditingController Function(int seriesNumber) repsControllerFor;

  const _ImportedWorkoutExerciseCard({
    required this.number,
    required this.exerciseIndex,
    required this.exercise,
    required this.kgControllerFor,
    required this.repsControllerFor,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeries = exercise.series <= 0 ? 1 : exercise.series;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE9F8F7),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF20B2AA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$totalSeries series',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Objetivo: ${exercise.reps}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Serie',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 76,
                child: Text(
                  'kg',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 76,
                child: Text(
                  'reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (
            int seriesNumber = 1;
            seriesNumber <= totalSeries;
            seriesNumber++
          )
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('Serie $seriesNumber')),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      controller: kgControllerFor(seriesNumber),
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'kg',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      controller: repsControllerFor(seriesNumber),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'reps',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
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
