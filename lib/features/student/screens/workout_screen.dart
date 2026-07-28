import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/exercise_motion_preview.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
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

    if (MediaQuery.sizeOf(context).width >= 900) {
      return _buildWebWorkout(
        user: user,
        profile: profile,
        weekSessions: weekSessions,
        assignedSession: assignedSession,
        weekFinished: weekFinished,
      );
    }

    return Container(
      color: const Color(0xFF111214),
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
                  color: Color(0xFFF6F7F7),
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
                                : profile?.currentWeekLabel ?? 'Semana actual',
                            style: TextStyle(color: Color(0xFF616B76)),
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
                                      : 'Sin rutina asignada',
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
                                    ? const Color(0xFFEDF9E8)
                                    : const Color(0xFFFFF2D9),
                                textColor: hasAssignedWorkout
                                    ? const Color(0xFF59D52D)
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
                                : 'El administrador debe asignar una rutina a este alumno',
                            style: TextStyle(color: Color(0xFF616B76)),
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
                                  : 'Sin rutina asignada. Guardar y omitir permanecerán deshabilitados.',
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
                      const AppCard(
                        child: Text(
                          'Aún no tienes ejercicios asignados para esta semana.',
                          style: TextStyle(color: Color(0xFF616B76)),
                        ),
                      ),
                    ResponsiveActionButton(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59D52D),
                            foregroundColor: const Color(0xFF111214),
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
                    ),
                    const SizedBox(height: 10),
                    ResponsiveActionButton(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111214),
                            side: const BorderSide(color: Color(0xFFC9CED2)),
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

  Widget _buildWebWorkout({
    required AppUser? user,
    required StudentProfile? profile,
    required List<DemoRoutineSession> weekSessions,
    required DemoRoutineSession? assignedSession,
    required bool weekFinished,
  }) {
    final hasAssignedWorkout = assignedSession != null;
    final completedSessions =
        StudentWorkoutProgressStore.getProgress(
          profile,
        )?.completedSessionIndexes.length ??
        0;
    final totalSessions = weekSessions.length;
    final progressPercent = totalSessions == 0
        ? 0
        : ((completedSessions / totalSessions) * 100).round();
    final totalExercises = assignedSession?.exercises.length ?? 0;
    final plan = profile?.plan ?? 'Plan no asignado';

    return ColoredBox(
      color: const Color(0xFF111214),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F5F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              AppCard(
                                padding: const EdgeInsets.all(24),
                                webContentMaxWidth: double.infinity,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Plan actual',
                                            style: TextStyle(
                                              color: Color(0xFF616B76),
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            weekFinished
                                                ? 'Semana completada'
                                                : hasAssignedWorkout
                                                ? assignedSession.title
                                                : 'Sin rutina asignada',
                                            style: const TextStyle(
                                              color: Color(0xFF07111D),
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Text(
                                            profile?.currentWeekLabel ??
                                                'Semana actual',
                                            style: const TextStyle(
                                              color: Color(0xFF616B76),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _WebPlanFact(
                                      icon: Icons.schedule,
                                      value: '${totalExercises * 6 + 25} min',
                                      label: 'Duración estimada',
                                    ),
                                    const SizedBox(width: 28),
                                    _WebPlanFact(
                                      icon: Icons.local_fire_department,
                                      value: '${totalExercises * 35} kcal',
                                      label: 'Calorías estimadas',
                                    ),
                                    const SizedBox(width: 28),
                                    const _WebPlanFact(
                                      icon: Icons.bar_chart_rounded,
                                      value: 'Nivel intermedio',
                                      label: 'Dificultad',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppCard(
                                padding: const EdgeInsets.all(22),
                                webContentMaxWidth: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            'Progreso de la sesión',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$progressPercent%',
                                          style: const TextStyle(
                                            color: Color(0xFF4AC51F),
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: progressPercent / 100,
                                        minHeight: 12,
                                        backgroundColor: const Color(
                                          0xFFE9ECEE,
                                        ),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              Color(0xFF59D52D),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 9),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '$completedSessions de $totalSessions entrenamientos completados',
                                        style: const TextStyle(
                                          color: Color(0xFF616B76),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: Color(0xFF4AC51F),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Ejercicios ($totalExercises)',
                                    style: const TextStyle(
                                      color: Color(0xFF3FB52A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xFF59D52D),
                                thickness: 2,
                              ),
                              const SizedBox(height: 8),
                              if (hasAssignedWorkout)
                                for (
                                  var index = 0;
                                  index < assignedSession.exercises.length;
                                  index++
                                ) ...[
                                  _WebWorkoutExerciseCard(
                                    number: index + 1,
                                    exerciseIndex: index,
                                    exercise: assignedSession.exercises[index],
                                    kgControllerFor: (seriesNumber) =>
                                        _controllerFor(
                                          type: 'kg',
                                          exerciseIndex: index,
                                          seriesNumber: seriesNumber,
                                        ),
                                    repsControllerFor: (seriesNumber) =>
                                        _controllerFor(
                                          type: 'reps',
                                          exerciseIndex: index,
                                          seriesNumber: seriesNumber,
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                ]
                              else
                                const AppCard(
                                  webContentMaxWidth: double.infinity,
                                  child: Text(
                                    'Aún no tienes ejercicios asignados para esta semana.',
                                    style: TextStyle(color: Color(0xFF616B76)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 260,
                          child: Column(
                            children: [
                              _WebWorkoutSideCard(
                                title: 'Resumen del plan',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _WebSideFact(label: 'Plan', value: plan),
                                    _WebSideFact(
                                      label: 'Frecuencia',
                                      value: '$totalSessions días por semana',
                                    ),
                                    _WebSideFact(
                                      label: 'Sesión actual',
                                      value:
                                          assignedSession?.title ??
                                          'Sin sesión',
                                    ),
                                    _WebSideFact(
                                      label: 'Entrenamientos completados',
                                      value:
                                          '$completedSessions de $totalSessions',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _WebWorkoutSideCard(
                                title: 'Próximo entrenamiento',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      assignedSession?.title ??
                                          'Sin sesión pendiente',
                                      style: const TextStyle(
                                        color: Color(0xFF07111D),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      '$totalExercises ejercicios · ${totalExercises * 6 + 25} min aprox.',
                                      style: const TextStyle(
                                        color: Color(0xFF616B76),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _WebWorkoutSideCard(
                                title: 'Acciones de la sesión',
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 48,
                                      child: ElevatedButton.icon(
                                        onPressed: hasAssignedWorkout
                                            ? () => _saveWorkout(
                                                user: user,
                                                profile: profile,
                                                assignedSession:
                                                    assignedSession,
                                                totalSessions: totalSessions,
                                              )
                                            : null,
                                        icon: const Icon(Icons.check_rounded),
                                        label: const Text(
                                          'Guardar entrenamiento',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46,
                                      child: OutlinedButton(
                                        onPressed: hasAssignedWorkout
                                            ? () => _skipWorkout(
                                                user: user,
                                                profile: profile,
                                                assignedSession:
                                                    assignedSession,
                                                totalSessions: totalSessions,
                                              )
                                            : null,
                                        child: const Text('Omitir sesión'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _WebPlanFact extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WebPlanFact({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFA000), size: 23),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF07111D),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF616B76), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}

class _WebWorkoutSideCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _WebWorkoutSideCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      webContentMaxWidth: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF07111D),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _WebSideFact extends StatelessWidget {
  final String label;
  final String value;

  const _WebSideFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF07111D),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebWorkoutExerciseCard extends StatelessWidget {
  final int number;
  final int exerciseIndex;
  final DemoRoutineExercise exercise;
  final TextEditingController Function(int seriesNumber) kgControllerFor;
  final TextEditingController Function(int seriesNumber) repsControllerFor;

  const _WebWorkoutExerciseCard({
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
      padding: const EdgeInsets.all(20),
      webContentMaxWidth: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFDDF6C7),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Color(0xFF3FB52A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 150,
            height: 170,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ExerciseMotionPreview(exerciseName: exercise.name),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF07111D),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Objetivo · ${exercise.reps} repeticiones',
                  style: const TextStyle(color: Color(0xFF616B76)),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.track_changes, color: Color(0xFF4AC51F)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Completa $totalSeries series de ${exercise.reps} reps',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                if (exercise.rest.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Descanso: ${exercise.rest}',
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 22),
          SizedBox(
            width: 315,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$totalSeries series',
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (
                  var seriesNumber = 1;
                  seriesNumber <= totalSeries;
                  seriesNumber++
                )
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 62,
                          child: Text(
                            'Serie $seriesNumber',
                            style: const TextStyle(
                              color: Color(0xFF25303A),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: kgControllerFor(seriesNumber),
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'kg',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: repsControllerFor(seriesNumber),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'reps',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.radio_button_unchecked,
                          color: Color(0xFFB8C0C6),
                        ),
                      ],
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
                backgroundColor: const Color(0xFFEDF9E8),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF59D52D),
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
                style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 210,
            child: ExerciseMotionPreview(exerciseName: exercise.name),
          ),
          const SizedBox(height: 8),
          Text(
            'Objetivo: ${exercise.reps}',
            style: const TextStyle(
              color: Color(0xFF616B76),
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
                    color: Color(0xFF616B76),
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
                    color: Color(0xFF616B76),
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
                    color: Color(0xFF616B76),
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
                        fillColor: const Color(0xFFF6F7F7),
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
                        fillColor: const Color(0xFFF6F7F7),
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
