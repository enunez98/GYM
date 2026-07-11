import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/demo_exercise.dart';
import '../../../models/routine_models.dart';
import '../../../services/imported_routine_store.dart';

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final importedSession = ImportedRoutineStore.sessions.isNotEmpty
        ? ImportedRoutineStore.sessions.first
        : null;

    final hasImportedWorkout = importedSession != null;

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
                            hasImportedWorkout
                                ? importedSession.session
                                : 'Semana 2 - Ordinario',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  hasImportedWorkout
                                      ? importedSession.title
                                      : 'Sesión 1',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusChip(
                                text: hasImportedWorkout
                                    ? 'Excel'
                                    : 'Pendiente',
                                background: hasImportedWorkout
                                    ? const Color(0xFFDFF9EA)
                                    : const Color(0xFFFFF2D9),
                                textColor: hasImportedWorkout
                                    ? const Color(0xFF12985C)
                                    : const Color(0xFFD98200),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasImportedWorkout
                                ? '${importedSession.exercises.length} ejercicios importados'
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
                              hasImportedWorkout
                                  ? 'Esta clase viene desde la planificación Excel cargada por el profesor.'
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
                    if (hasImportedWorkout)
                      for (
                        int i = 0;
                        i < importedSession.exercises.length;
                        i++
                      ) ...[
                        _ImportedWorkoutExerciseCard(
                          number: i + 1,
                          exercise: importedSession.exercises[i],
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Entrenamiento guardado correctamente',
                              ),
                            ),
                          );
                        },
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sesión omitida')),
                          );
                        },
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
  final DemoRoutineExercise exercise;

  const _ImportedWorkoutExerciseCard({
    required this.number,
    required this.exercise,
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
          for (int i = 1; i <= totalSeries; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('Serie $i')),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
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
