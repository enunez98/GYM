import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/routine_models.dart';
import '../../../services/imported_routine_store.dart';

class WeeklyRoutineScreen extends StatefulWidget {
  const WeeklyRoutineScreen({super.key});

  @override
  State<WeeklyRoutineScreen> createState() => _WeeklyRoutineScreenState();
}

class _WeeklyRoutineScreenState extends State<WeeklyRoutineScreen> {
  String selectedPlan = ImportedRoutineStore.hasData
      ? ImportedRoutineStore.plan
      : 'Plan 3 sesiones';

  String selectedWeek = 'Semana 1';

  final routines = {
    'Plan 2 sesiones': [
      DemoRoutineSession(
        session: 'Sesión 1',
        title: 'Full body A',
        exercises: [
          DemoRoutineExercise(name: 'Sentadilla', series: 4, reps: '10-12'),
          DemoRoutineExercise(name: 'Press banca', series: 4, reps: '8-10'),
          DemoRoutineExercise(name: 'Remo sentado', series: 4, reps: '10-12'),
          DemoRoutineExercise(name: 'Plancha', series: 3, reps: '30 seg'),
        ],
      ),
      DemoRoutineSession(
        session: 'Sesión 2',
        title: 'Full body B',
        exercises: [
          DemoRoutineExercise(
            name: 'Peso muerto rumano',
            series: 4,
            reps: '10',
          ),
          DemoRoutineExercise(name: 'Press militar', series: 4, reps: '8-10'),
          DemoRoutineExercise(name: 'Jalón al pecho', series: 4, reps: '10-12'),
          DemoRoutineExercise(name: 'Curl bíceps', series: 3, reps: '12'),
        ],
      ),
    ],
    'Plan 3 sesiones': [
      DemoRoutineSession(
        session: 'Sesión 1',
        title: 'Pecho - Tríceps',
        exercises: [
          DemoRoutineExercise(
            name: 'Press banca plano',
            series: 4,
            reps: '8-10',
          ),
          DemoRoutineExercise(
            name: 'Press inclinado mancuernas',
            series: 4,
            reps: '10-12',
          ),
          DemoRoutineExercise(
            name: 'Aperturas en máquina',
            series: 3,
            reps: '12-15',
          ),
          DemoRoutineExercise(
            name: 'Extensión de tríceps',
            series: 3,
            reps: '10-12',
          ),
        ],
      ),
      DemoRoutineSession(
        session: 'Sesión 2',
        title: 'Espalda - Bíceps',
        exercises: [
          DemoRoutineExercise(name: 'Jalón al pecho', series: 4, reps: '10-12'),
          DemoRoutineExercise(name: 'Remo con barra', series: 4, reps: '8-10'),
          DemoRoutineExercise(name: 'Remo sentado', series: 3, reps: '12'),
          DemoRoutineExercise(name: 'Curl bíceps', series: 3, reps: '10-12'),
        ],
      ),
      DemoRoutineSession(
        session: 'Sesión 3',
        title: 'Piernas - Hombros',
        exercises: [
          DemoRoutineExercise(name: 'Sentadilla', series: 4, reps: '8-10'),
          DemoRoutineExercise(name: 'Prensa', series: 4, reps: '10-12'),
          DemoRoutineExercise(
            name: 'Elevaciones laterales',
            series: 3,
            reps: '12-15',
          ),
          DemoRoutineExercise(name: 'Press hombro', series: 4, reps: '8-10'),
        ],
      ),
    ],
    'Plan 4 sesiones': [
      DemoRoutineSession(
        session: 'Sesión 1',
        title: 'Pecho',
        exercises: [
          DemoRoutineExercise(
            name: 'Press banca plano',
            series: 4,
            reps: '8-10',
          ),
          DemoRoutineExercise(name: 'Press inclinado', series: 4, reps: '10'),
          DemoRoutineExercise(name: 'Crossover', series: 3, reps: '12-15'),
        ],
      ),
      DemoRoutineSession(
        session: 'Sesión 2',
        title: 'Espalda',
        exercises: [
          DemoRoutineExercise(name: 'Jalón al pecho', series: 4, reps: '10-12'),
          DemoRoutineExercise(name: 'Remo barra', series: 4, reps: '8-10'),
          DemoRoutineExercise(name: 'Pullover polea', series: 3, reps: '12'),
        ],
      ),
      DemoRoutineSession(
        session: 'Sesión 3',
        title: 'Piernas',
        exercises: [
          DemoRoutineExercise(name: 'Sentadilla', series: 4, reps: '8-10'),
          DemoRoutineExercise(name: 'Prensa', series: 4, reps: '10-12'),
          DemoRoutineExercise(
            name: 'Extensión cuádriceps',
            series: 3,
            reps: '12-15',
          ),
        ],
      ),
      DemoRoutineSession(
        session: 'Sesión 4',
        title: 'Hombros - Brazos',
        exercises: [
          DemoRoutineExercise(name: 'Press hombro', series: 4, reps: '8-10'),
          DemoRoutineExercise(
            name: 'Elevaciones laterales',
            series: 3,
            reps: '12-15',
          ),
          DemoRoutineExercise(name: 'Curl bíceps', series: 3, reps: '10-12'),
          DemoRoutineExercise(name: 'Tríceps polea', series: 3, reps: '10-12'),
        ],
      ),
    ],
  };

  int getWeekNumber(String value) {
    final match = RegExp(r'\d+').firstMatch(value);
    if (match == null) return 0;
    return int.tryParse(match.group(0) ?? '0') ?? 0;
  }

  List<String> get importedWeeks {
    final weeks = ImportedRoutineStore.sessions
        .map((session) => session.session)
        .toSet()
        .toList();

    weeks.sort((a, b) => getWeekNumber(a).compareTo(getWeekNumber(b)));

    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    final hasImportedRoutine = ImportedRoutineStore.hasData;
    final weeks = importedWeeks;

    if (hasImportedRoutine &&
        weeks.isNotEmpty &&
        !weeks.contains(selectedWeek)) {
      selectedWeek = weeks.first;
    }

    final selectedSessions = hasImportedRoutine
        ? ImportedRoutineStore.sessions
              .where((session) => session.session == selectedWeek)
              .toList()
        : routines[selectedPlan] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Rutina semanal',
              subtitle: 'Planificación de ejercicios',
              icon: Icons.fitness_center,
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
                    if (hasImportedRoutine) ...[
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rutina importada desde Excel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${ImportedRoutineStore.plan} · ${ImportedRoutineStore.sessions.length} sesiones',
                              style: const TextStyle(color: Color(0xFF616B76)),
                            ),
                          ],
                        ),
                      ),
                      if (weeks.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Seleccionar semana',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ResponsiveFormField(
                                child: DropdownButtonFormField<String>(
                                  value: selectedWeek,
                                  decoration: InputDecoration(
                                    labelText: 'Semana',
                                    prefixIcon: const Icon(
                                      Icons.calendar_month,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF6F7F7),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  items: weeks
                                      .map(
                                        (week) => DropdownMenuItem(
                                          value: week,
                                          child: Text(week),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedWeek = value ?? weeks.first;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                    ],
                    if (!hasImportedRoutine)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seleccionar plan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ResponsiveFormField(
                              child: DropdownButtonFormField<String>(
                                value: selectedPlan,
                                decoration: InputDecoration(
                                  labelText: 'Plan',
                                  prefixIcon: const Icon(Icons.assignment),
                                  filled: true,
                                  fillColor: const Color(0xFFF6F7F7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Plan 2 sesiones',
                                    child: Text('Plan 2 sesiones'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Plan 3 sesiones',
                                    child: Text('Plan 3 sesiones'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Plan 4 sesiones',
                                    child: Text('Plan 4 sesiones'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedPlan = value ?? 'Plan 3 sesiones';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (!hasImportedRoutine) const SizedBox(height: 14),
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasImportedRoutine
                                      ? selectedWeek
                                      : 'Semana 2 - Ordinario',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  hasImportedRoutine
                                      ? 'Mostrando sesiones importadas para esta semana'
                                      : '06 Jul - 12 Jul 2026',
                                  style: const TextStyle(
                                    color: Color(0xFF616B76),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusChip(
                            text: 'CARGA',
                            background: const Color(0xFFEDF9E8),
                            textColor: const Color(0xFF59D52D),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final session in selectedSessions) ...[
                      _RoutineSessionCard(session: session),
                      const SizedBox(height: 14),
                    ],
                    if (hasImportedRoutine) ...[
                      const SizedBox(height: 4),
                      ResponsiveActionButton(
                        child: SizedBox(
                          height: 54,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                ImportedRoutineStore.clear();
                                selectedPlan = 'Plan 3 sesiones';
                                selectedWeek = 'Semana 1';
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Rutina importada eliminada'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text(
                              'Limpiar rutina importada',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
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

class _RoutineSessionCard extends StatelessWidget {
  final DemoRoutineSession session;

  const _RoutineSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.session,
            style: const TextStyle(color: Color(0xFF616B76)),
          ),
          const SizedBox(height: 4),
          Text(
            session.title,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < session.exercises.length; i++) ...[
            _RoutineExerciseRow(number: i + 1, exercise: session.exercises[i]),
            if (i < session.exercises.length - 1) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _RoutineExerciseRow extends StatelessWidget {
  final int number;
  final DemoRoutineExercise exercise;

  const _RoutineExerciseRow({required this.number, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
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
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${exercise.series} series',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              exercise.reps,
              style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
