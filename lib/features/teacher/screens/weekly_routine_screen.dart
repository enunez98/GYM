import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/routine_models.dart';
import '../../../services/imported_routine_store.dart';
import '../../../services/routine_persistence_service.dart';

class WeeklyRoutineScreen extends StatefulWidget {
  const WeeklyRoutineScreen({super.key});

  @override
  State<WeeklyRoutineScreen> createState() => _WeeklyRoutineScreenState();
}

class _WeeklyRoutineScreenState extends State<WeeklyRoutineScreen> {
  String? selectedPlan;
  String? selectedWeek;
  List<PersistedRoutine> persistedRoutines = const [];
  bool isLoadingRoutines = false;
  String? routineLoadError;

  @override
  void initState() {
    super.initState();
    _loadFirebaseRoutines();
  }

  Future<void> _loadFirebaseRoutines() async {
    if (Firebase.apps.isEmpty) return;

    setState(() {
      isLoadingRoutines = true;
      routineLoadError = null;
    });
    try {
      final loadedRoutines = await RoutinePersistenceService.loadRoutines();
      if (!mounted) return;
      setState(() {
        persistedRoutines = loadedRoutines;
        isLoadingRoutines = false;
      });
    } catch (error) {
      debugPrint('Error al cargar rutinas desde Firebase: $error');
      if (!mounted) return;
      setState(() {
        isLoadingRoutines = false;
        routineLoadError = 'No se pudieron cargar las rutinas desde Firebase.';
      });
    }
  }

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
    final weeks = activeSessions
        .map((session) => session.session)
        .toSet()
        .toList();
    if (weeks.isEmpty && Firebase.apps.isEmpty && selectedPlan != null) {
      return const ['Semana 1'];
    }

    weeks.sort((a, b) => getWeekNumber(a).compareTo(getWeekNumber(b)));

    return weeks;
  }

  PersistedRoutine? get selectedPersistedRoutine {
    for (final routine in persistedRoutines) {
      if (routine.plan == selectedPlan) return routine;
    }
    return null;
  }

  bool get isUsingLocalImport =>
      selectedPlan != null &&
      ImportedRoutineStore.hasData &&
      selectedPlan == ImportedRoutineStore.plan;

  bool get isUsingFirebaseRoutine =>
      !isUsingLocalImport && selectedPersistedRoutine != null;

  bool get hasRealRoutine => isUsingFirebaseRoutine || isUsingLocalImport;

  List<DemoRoutineSession> get activeSessions {
    if (isUsingFirebaseRoutine) return selectedPersistedRoutine!.sessions;
    if (isUsingLocalImport) return ImportedRoutineStore.sessions;
    return const [];
  }

  String get activeSourceFileName {
    if (isUsingFirebaseRoutine) {
      return selectedPersistedRoutine!.sourceFileName;
    }
    if (isUsingLocalImport) return ImportedRoutineStore.fileName;
    return '';
  }

  List<String> get availablePlans {
    final plans = persistedRoutines.map((routine) => routine.plan).toList();
    if (ImportedRoutineStore.hasData &&
        !plans.contains(ImportedRoutineStore.plan)) {
      plans.add(ImportedRoutineStore.plan);
    }
    return plans.isEmpty
        ? const ['Plan 2 sesiones', 'Plan 3 sesiones', 'Plan 4 sesiones']
        : plans;
  }

  @override
  Widget build(BuildContext context) {
    final hasImportedRoutine = hasRealRoutine;
    final isUsingDemoRoutine = Firebase.apps.isEmpty && !hasImportedRoutine;
    final weeks = importedWeeks;

    final selectedSessions = hasImportedRoutine && selectedWeek != null
        ? activeSessions
              .where((session) => session.session == selectedWeek)
              .toList()
        : isUsingDemoRoutine && selectedPlan != null && selectedWeek != null
        ? routines[selectedPlan] ?? []
        : <DemoRoutineSession>[];

    if (MediaQuery.sizeOf(context).width >= 900) {
      return _buildWebRoutine(
        context,
        selectedSessions: selectedSessions,
        hasImportedRoutine: hasImportedRoutine,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111214),
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
                              '$selectedPlan · ${activeSessions.length} sesiones'
                              '${activeSourceFileName.isEmpty ? '' : ' · $activeSourceFileName'}',
                              style: const TextStyle(color: Color(0xFF616B76)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
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
                            child: AppSelectField(
                              value: selectedPlan,
                              hint: 'Seleccionar plan',
                              decoration: InputDecoration(
                                labelText: 'Plan',
                                prefixIcon: const Icon(Icons.assignment),
                                filled: true,
                                fillColor: const Color(0xFFF6F7F7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              options: availablePlans,
                              onChanged: (value) {
                                setState(() {
                                  selectedPlan = value;
                                  selectedWeek = null;
                                });
                              },
                            ),
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
                            'Seleccionar semana',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ResponsiveFormField(
                            child: AppSelectField(
                              value: selectedWeek,
                              hint: 'Seleccionar semana',
                              decoration: InputDecoration(
                                labelText: 'Semana',
                                prefixIcon: const Icon(Icons.calendar_month),
                                filled: true,
                                fillColor: const Color(0xFFF6F7F7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              options: selectedPlan == null ? const [] : weeks,
                              onChanged: selectedPlan == null
                                  ? null
                                  : (value) {
                                      setState(() => selectedWeek = value);
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isLoadingRoutines) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 14),
                    ],
                    if (routineLoadError != null) ...[
                      AppCard(
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(child: Text(routineLoadError!)),
                            TextButton(
                              onPressed: _loadFirebaseRoutines,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (selectedPlan != null && selectedWeek != null)
                      AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hasImportedRoutine
                                        ? selectedWeek!
                                        : !isUsingDemoRoutine
                                        ? 'Sin rutina cargada'
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
                                        : !isUsingDemoRoutine
                                        ? 'Importa una planificación para $selectedPlan'
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
                    if (selectedPlan != null && selectedWeek != null)
                      const SizedBox(height: 14),
                    for (final session in selectedSessions) ...[
                      _RoutineSessionCard(session: session),
                      const SizedBox(height: 14),
                    ],
                    if (isUsingLocalImport && Firebase.apps.isEmpty) ...[
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
                                selectedPlan = null;
                                selectedWeek = null;
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

  Widget _buildWebRoutine(
    BuildContext context, {
    required List<DemoRoutineSession> selectedSessions,
    required bool hasImportedRoutine,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFF111214),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Plan',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'La rutina cambia según la cantidad de sesiones',
                                        style: TextStyle(
                                          color: Color(0xFF616B76),
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: AppSelectField(
                                    value: selectedPlan,
                                    hint: 'Seleccionar plan',
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.assignment),
                                      filled: true,
                                      fillColor: const Color(0xFFFAFBFB),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    options: availablePlans,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedPlan = value;
                                        selectedWeek = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: AppCard(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Semana',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Elige la semana que deseas planificar o revisar',
                                        style: TextStyle(
                                          color: Color(0xFF616B76),
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: AppSelectField(
                                    value: selectedWeek,
                                    hint: 'Seleccionar semana',
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                        Icons.calendar_month,
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFFAFBFB),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    options: selectedPlan == null
                                        ? const []
                                        : importedWeeks,
                                    onChanged: selectedPlan == null
                                        ? null
                                        : (value) {
                                            setState(
                                              () => selectedWeek = value,
                                            );
                                          },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (isLoadingRoutines) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 14),
                    ],
                    if (routineLoadError != null) ...[
                      AppCard(
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(child: Text(routineLoadError!)),
                            TextButton(
                              onPressed: _loadFirebaseRoutines,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (selectedPlan != null && selectedWeek != null)
                      Container(
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.fromLTRB(28, 16, 24, 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              left: -28,
                              top: -16,
                              bottom: -16,
                              child: Container(
                                width: 4,
                                color: const Color(0xFF59D52D),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEDF9E8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month,
                                    color: Color(0xFF3BAF19),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hasImportedRoutine
                                            ? selectedWeek!
                                            : Firebase.apps.isNotEmpty
                                            ? 'Sin rutina cargada'
                                            : selectedWeek!,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: hasImportedRoutine
                                                  ? 'Rutina importada'
                                                  : 'Planificación semanal',
                                            ),
                                            const TextSpan(
                                              text: '  •  ',
                                              style: TextStyle(
                                                color: Color(0xFF59D52D),
                                              ),
                                            ),
                                            TextSpan(text: selectedPlan),
                                          ],
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF616B76),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const StatusChip(
                                      text: 'CARGA',
                                      background: Color(0xFFEDF9E8),
                                      textColor: Color(0xFF3BAF19),
                                    ),
                                    const SizedBox(height: 10),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(
                                          0xFF3BAF19,
                                        ),
                                        side: const BorderSide(
                                          color: Color(0xFF59D52D),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 14,
                                        ),
                                        shape: const StadiumBorder(),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Calendario semanal seleccionado',
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                      ),
                                      label: const Text(
                                        'Ver calendario',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (selectedPlan != null && selectedWeek != null)
                      const SizedBox(height: 14),
                    for (final session in selectedSessions) ...[
                      _WebRoutineSessionCard(
                        session: session,
                        onAddExercise: () => _showAddExerciseDialog(session),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (selectedSessions.isEmpty)
                      const AppCard(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No hay sesiones disponibles para esta semana.',
                              style: TextStyle(color: Color(0xFF616B76)),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddExerciseDialog(DemoRoutineSession session) async {
    final exercise = await showDialog<DemoRoutineExercise>(
      context: context,
      builder: (_) => _AddExerciseDialog(sessionLabel: session.session),
    );

    if (exercise == null || !mounted) return;
    setState(() => session.exercises.add(exercise));
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final String sessionLabel;

  const _AddExerciseDialog({required this.sessionLabel});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final nameController = TextEditingController();
  final seriesController = TextEditingController(text: '3');
  final repsController = TextEditingController(text: '10 - 12');
  final restController = TextEditingController(text: '60 - 90 seg');
  String? errorText;

  @override
  void dispose() {
    nameController.dispose();
    seriesController.dispose();
    repsController.dispose();
    restController.dispose();
    super.dispose();
  }

  void _save() {
    final name = nameController.text.trim();
    final series = int.tryParse(seriesController.text.trim()) ?? 0;
    final reps = repsController.text.trim();
    final rest = restController.text.trim();

    if (name.isEmpty || series <= 0 || reps.isEmpty || rest.isEmpty) {
      setState(() => errorText = 'Completa todos los datos del ejercicio');
      return;
    }

    Navigator.pop(
      context,
      DemoRoutineExercise(name: name, series: series, reps: reps, rest: rest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar ejercicio · ${widget.sessionLabel}'),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Ejercicio',
                hintText: 'Ej: Press francés',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: seriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Series',
                      hintText: 'Ej: 3',
                      prefixIcon: Icon(Icons.numbers),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    decoration: const InputDecoration(
                      labelText: 'Repeticiones',
                      hintText: 'Ej: 10 - 12',
                      prefixIcon: Icon(Icons.repeat),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: restController,
              decoration: const InputDecoration(
                labelText: 'Descanso',
                hintText: 'Ej: 60 - 90 seg',
                prefixIcon: Icon(Icons.timer_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.add),
          label: const Text('Guardar ejercicio'),
        ),
      ],
    );
  }
}

class _WebRoutineSessionCard extends StatelessWidget {
  final DemoRoutineSession session;
  final VoidCallback onAddExercise;

  const _WebRoutineSessionCard({
    required this.session,
    required this.onAddExercise,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeries = session.exercises.fold<int>(
      0,
      (total, exercise) => total + exercise.series,
    );
    final estimatedMinutes = ((totalSeries * 3) / 5).ceil() * 5;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
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
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 19),
                      const SizedBox(width: 8),
                      Text(
                        '$totalSeries series',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Duración estimada: $estimatedMinutes min',
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _WebRoutineTableHeader(),
          const SizedBox(height: 8),
          for (int index = 0; index < session.exercises.length; index++) ...[
            _WebRoutineExerciseRow(
              number: index + 1,
              exercise: session.exercises[index],
            ),
            if (index < session.exercises.length - 1) const SizedBox(height: 6),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3BAF19),
              side: const BorderSide(color: Color(0xFF59D52D)),
            ),
            onPressed: onAddExercise,
            icon: const Icon(Icons.add, size: 18),
            label: const Text(
              'Agregar ejercicio',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebRoutineTableHeader extends StatelessWidget {
  const _WebRoutineTableHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 34,
      child: Row(
        children: [
          SizedBox(width: 48, child: Center(child: Text('#'))),
          Expanded(flex: 5, child: Text('Ejercicio')),
          Expanded(flex: 2, child: Text('Series')),
          Expanded(flex: 2, child: Text('Repeticiones')),
          Expanded(flex: 2, child: Text('Descanso')),
          SizedBox(width: 68, child: Center(child: Text('Acción'))),
        ],
      ),
    );
  }
}

class _WebRoutineExerciseRow extends StatelessWidget {
  final int number;
  final DemoRoutineExercise exercise;

  const _WebRoutineExerciseRow({required this.number, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final rest = exercise.rest.isNotEmpty
        ? exercise.rest
        : number <= 2
        ? '60 - 90 seg'
        : '45 - 60 seg';

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE2E5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Center(
              child: CircleAvatar(
                radius: 15,
                backgroundColor: const Color(0xFFEDF9E8),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF3BAF19),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F7),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Image.asset(
                      _exerciseImagePath(exercise.name),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.sports_gymnastics,
                        color: Color(0xFF3BAF19),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    exercise.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Text('${exercise.series} series')),
          Expanded(flex: 2, child: Text('${exercise.reps} reps')),
          Expanded(flex: 2, child: Text(rest)),
          SizedBox(
            width: 68,
            child: PopupMenuButton<String>(
              tooltip: 'Acciones',
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _exerciseImagePath(String exerciseName) {
  final name = exerciseName
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  String asset;
  if (name.contains('sentadilla')) {
    asset = 'squat';
  } else if (name.contains('inclinado')) {
    asset = 'incline_press';
  } else if (name.contains('press banca')) {
    asset = 'bench_press';
  } else if (name.contains('remo sentado')) {
    asset = 'seated_row';
  } else if (name.contains('remo')) {
    asset = 'barbell_row';
  } else if (name.contains('plancha')) {
    asset = 'plank';
  } else if (name.contains('peso muerto')) {
    asset = 'romanian_deadlift';
  } else if (name.contains('press militar')) {
    asset = 'military_press';
  } else if (name.contains('jalon')) {
    asset = 'lat_pulldown';
  } else if (name.contains('curl')) {
    asset = 'biceps_curl';
  } else if (name.contains('apertura')) {
    asset = 'pec_deck';
  } else if (name.contains('extension cuadriceps')) {
    asset = 'leg_extension';
  } else if (name.contains('extension') && name.contains('triceps')) {
    asset = 'triceps_extension';
  } else if (name.contains('triceps')) {
    asset = 'triceps_rope';
  } else if (name.contains('prensa')) {
    asset = 'leg_press';
  } else if (name.contains('elevacion')) {
    asset = 'lateral_raise';
  } else if (name.contains('press hombro')) {
    asset = 'shoulder_press';
  } else if (name.contains('crossover')) {
    asset = 'cable_crossover';
  } else if (name.contains('pullover')) {
    asset = 'cable_pullover';
  } else {
    asset = 'generic_dumbbell';
  }

  return 'assets/images/exercises/$asset.png';
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
