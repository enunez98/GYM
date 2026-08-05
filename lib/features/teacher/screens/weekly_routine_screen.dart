import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/exercise_motion_preview.dart';
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
  bool hasUnsavedChanges = false;
  bool isSavingRoutine = false;

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
                        onEditExercise: (index) =>
                            _showEditExerciseDialog(session, index),
                        onDeleteExercise: (index) =>
                            _deleteExercise(session, index),
                        onSave: _saveRoutineChanges,
                        hasUnsavedChanges: hasUnsavedChanges,
                        isSaving: isSavingRoutine,
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
    setState(() {
      session.exercises.add(exercise);
      hasUnsavedChanges = true;
    });
  }

  Future<void> _showEditExerciseDialog(
    DemoRoutineSession session,
    int index,
  ) async {
    final exercise = await showDialog<DemoRoutineExercise>(
      context: context,
      builder: (_) => _AddExerciseDialog(
        sessionLabel: session.session,
        initialExercise: session.exercises[index],
      ),
    );
    if (exercise == null || !mounted) return;
    setState(() {
      session.exercises[index] = exercise;
      hasUnsavedChanges = true;
    });
  }

  Future<void> _deleteExercise(DemoRoutineSession session, int index) async {
    final exercise = session.exercises[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: Text('¿Quieres eliminar "${exercise.name}" de la rutina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      session.exercises.removeAt(index);
      hasUnsavedChanges = true;
    });
  }

  Future<void> _saveRoutineChanges() async {
    final plan = selectedPlan;
    final sessions = activeSessions.isNotEmpty
        ? activeSessions
        : routines[plan] ?? const <DemoRoutineSession>[];
    if (plan == null || sessions.isEmpty || isSavingRoutine) return;

    setState(() => isSavingRoutine = true);
    try {
      final sourceFileName = activeSourceFileName.isEmpty
          ? 'Edición manual'
          : activeSourceFileName;
      final result = Firebase.apps.isEmpty
          ? RoutinePersistenceService.replaceLocally(
              plan: plan,
              sourceFileName: sourceFileName,
              sessions: sessions,
            )
          : await RoutinePersistenceService.replaceForPlan(
              plan: plan,
              sourceFileName: sourceFileName,
              sessions: sessions,
            );
      if (!mounted) return;
      setState(() {
        hasUnsavedChanges = false;
        isSavingRoutine = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rutina guardada y actualizada para ${result.assignedStudents} alumnos',
          ),
        ),
      );
    } catch (error) {
      debugPrint('Error al guardar la rutina: $error');
      if (!mounted) return;
      setState(() => isSavingRoutine = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la rutina. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final String sessionLabel;
  final DemoRoutineExercise? initialExercise;

  const _AddExerciseDialog({required this.sessionLabel, this.initialExercise});

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  final nameFocusNode = FocusNode();
  late final TextEditingController seriesController;
  late final TextEditingController repsController;
  late final TextEditingController restController;
  List<String> catalogExerciseNames = const [];
  String? selectedExerciseName;
  bool isLoadingCatalog = true;
  bool showSearchResults = false;

  @override
  void initState() {
    super.initState();
    final exercise = widget.initialExercise;
    nameController = TextEditingController(text: exercise?.name ?? '');
    seriesController = TextEditingController(
      text: exercise?.series.toString() ?? '3',
    );
    repsController = TextEditingController(text: exercise?.reps ?? '10 - 12');
    restController = TextEditingController(
      text: exercise?.rest.isNotEmpty == true ? exercise!.rest : '60 - 90 seg',
    );
    selectedExerciseName = exercise?.name;
    _loadExerciseCatalog();
  }

  Future<void> _loadExerciseCatalog() async {
    final source = await rootBundle.loadString('assets/data/exercises.json');
    final items = jsonDecode(source) as List<dynamic>;
    final names =
        items
            .whereType<Map>()
            .where((rawItem) {
              final images = rawItem['imagenes'];
              return images is Map &&
                  images.values.whereType<String>().any(
                    (image) => image.isNotEmpty,
                  );
            })
            .map((rawItem) {
              final item = Map<String, dynamic>.from(rawItem);
              return (item['nombre'] as String? ??
                      item['name'] as String? ??
                      '')
                  .trim();
            })
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    if (!mounted) return;
    setState(() {
      catalogExerciseNames = names;
      selectedExerciseName = _catalogMatch();
      isLoadingCatalog = false;
    });
  }

  String _normalize(String value) {
    const accented = 'áéíóúüñ';
    const plain = 'aeiouun';
    var result = value.toLowerCase().trim();
    for (var index = 0; index < accented.length; index++) {
      result = result.replaceAll(accented[index], plain[index]);
    }
    return result;
  }

  String? _catalogMatch() {
    final query = _normalize(nameController.text);
    for (final name in catalogExerciseNames) {
      if (_normalize(name) == query) return name;
    }
    return null;
  }

  List<String> get _searchResults {
    final query = _normalize(nameController.text);
    if (query.isEmpty || !showSearchResults) return const [];
    return catalogExerciseNames
        .where((name) => _normalize(name).contains(query))
        .take(5)
        .toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    nameFocusNode.dispose();
    seriesController.dispose();
    repsController.dispose();
    restController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final name = _catalogMatch()!;
    final series = int.tryParse(seriesController.text.trim()) ?? 0;
    final reps = repsController.text.trim();
    final rest = restController.text.trim();

    Navigator.pop(
      context,
      DemoRoutineExercise(name: name, series: series, reps: reps, rest: rest),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${widget.initialExercise == null ? 'Agregar' : 'Editar'} ejercicio · ${widget.sessionLabel}',
      ),
      content: SizedBox(
        width: 560,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('exercise_search_field'),
                controller: nameController,
                focusNode: nameFocusNode,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    showSearchResults = value.trim().isNotEmpty;
                    if (value != selectedExerciseName) {
                      selectedExerciseName = null;
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Buscar ejercicio',
                  hintText: isLoadingCatalog
                      ? 'Cargando ejercicios...'
                      : 'Escribe para buscar en el catálogo',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: selectedExerciseName == null
                      ? null
                      : const Icon(
                          Icons.check_circle,
                          color: Color(0xFF3BAF19),
                        ),
                  border: const OutlineInputBorder(),
                ),
                validator: (_) => _catalogMatch() == null
                    ? 'Selecciona un ejercicio de la lista'
                    : null,
              ),
              if (!isLoadingCatalog && catalogExerciseNames.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No se pudo cargar el catálogo de ejercicios',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 6),
                Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Color(0xFFDDE2E5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 290),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final name = _searchResults[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 48,
                            height: 48,
                            child: ExerciseMotionPreview(
                              exerciseName: name,
                              borderRadius: BorderRadius.circular(8),
                              animate: false,
                              showPhaseLabel: false,
                            ),
                          ),
                          title: Text(name),
                          onTap: () {
                            setState(() {
                              selectedExerciseName = name;
                              showSearchResults = false;
                              nameController.text = name;
                            });
                            nameFocusNode.unfocus();
                            formKey.currentState?.validate();
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: const Key('exercise_series_field'),
                      controller: seriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Series',
                        hintText: 'Ej: 3',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final series = int.tryParse(value?.trim() ?? '');
                        return series == null || series <= 0
                            ? 'Ingresa una cantidad válida'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      key: const Key('exercise_reps_field'),
                      controller: repsController,
                      decoration: const InputDecoration(
                        labelText: 'Repeticiones',
                        hintText: 'Ej: 10 - 12',
                        prefixIcon: Icon(Icons.repeat),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true)
                          ? 'Completa las repeticiones'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                key: const Key('exercise_rest_field'),
                controller: restController,
                decoration: const InputDecoration(
                  labelText: 'Descanso',
                  hintText: 'Ej: 60 - 90 seg',
                  prefixIcon: Icon(Icons.timer_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Completa el descanso'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: Icon(widget.initialExercise == null ? Icons.add : Icons.save),
          label: Text(
            widget.initialExercise == null
                ? 'Guardar ejercicio'
                : 'Guardar cambios',
          ),
        ),
      ],
    );
  }
}

class _WebRoutineSessionCard extends StatefulWidget {
  final DemoRoutineSession session;
  final VoidCallback onAddExercise;
  final ValueChanged<int> onEditExercise;
  final ValueChanged<int> onDeleteExercise;
  final VoidCallback onSave;
  final bool hasUnsavedChanges;
  final bool isSaving;

  const _WebRoutineSessionCard({
    required this.session,
    required this.onAddExercise,
    required this.onEditExercise,
    required this.onDeleteExercise,
    required this.onSave,
    required this.hasUnsavedChanges,
    required this.isSaving,
  });

  @override
  State<_WebRoutineSessionCard> createState() => _WebRoutineSessionCardState();
}

class _WebRoutineSessionCardState extends State<_WebRoutineSessionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final totalSeries = session.exercises.fold<int>(
      0,
      (total, exercise) => total + exercise.series,
    );
    final estimatedMinutes = ((totalSeries * 3) / 5).ceil() * 5;

    return AppCard(
      webContentMaxWidth: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
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
                          const SizedBox(width: 14),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            child: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isExpanded
                            ? 'Ocultar ejercicios'
                            : '${session.exercises.length} ejercicios · Ver detalle',
                        style: const TextStyle(
                          color: Color(0xFF616B76),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: !_isExpanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Duración estimada: $estimatedMinutes min',
                          style: const TextStyle(
                            color: Color(0xFF616B76),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const _WebRoutineTableHeader(),
                      const SizedBox(height: 8),
                      for (
                        int index = 0;
                        index < session.exercises.length;
                        index++
                      ) ...[
                        _WebRoutineExerciseRow(
                          number: index + 1,
                          exercise: session.exercises[index],
                          onEdit: () => widget.onEditExercise(index),
                          onDelete: () => widget.onDeleteExercise(index),
                        ),
                        if (index < session.exercises.length - 1)
                          const SizedBox(height: 6),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF3BAF19),
                              side: const BorderSide(color: Color(0xFF59D52D)),
                            ),
                            onPressed: widget.onAddExercise,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text(
                              'Agregar ejercicio',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            key: const Key('save_routine_button'),
                            onPressed:
                                widget.hasUnsavedChanges && !widget.isSaving
                                ? widget.onSave
                                : null,
                            icon: widget.isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              widget.isSaving ? 'Guardando...' : 'Guardar',
                            ),
                          ),
                        ],
                      ),
                    ],
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _WebRoutineExerciseRow({
    required this.number,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

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
                  child: ExerciseMotionPreview(
                    exerciseName: exercise.name,
                    borderRadius: BorderRadius.circular(9),
                    animate: false,
                    showPhaseLabel: false,
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
              onSelected: (action) {
                if (action == 'edit') onEdit();
                if (action == 'delete') onDelete();
              },
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

class _RoutineSessionCard extends StatefulWidget {
  final DemoRoutineSession session;

  const _RoutineSessionCard({required this.session});

  @override
  State<_RoutineSessionCard> createState() => _RoutineSessionCardState();
}

class _RoutineSessionCardState extends State<_RoutineSessionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
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
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.exercises.length} ejercicios',
                        style: const TextStyle(
                          color: Color(0xFF616B76),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            child: !_isExpanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    children: [
                      const SizedBox(height: 14),
                      for (int i = 0; i < session.exercises.length; i++) ...[
                        _RoutineExerciseRow(
                          number: i + 1,
                          exercise: session.exercises[i],
                        ),
                        if (i < session.exercises.length - 1)
                          const Divider(height: 18),
                      ],
                    ],
                  ),
          ),
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
        SizedBox(
          width: 46,
          height: 46,
          child: ExerciseMotionPreview(
            exerciseName: exercise.name,
            borderRadius: BorderRadius.circular(9),
            animate: false,
            showPhaseLabel: false,
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
