import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/exercise_motion_preview.dart';
import '../../../models/routine_assignment.dart';
import '../../../models/routine_models.dart';
import '../../../services/routine_assignment_store.dart';
import 'weekly_routine_screen.dart';

class StudentRoutineEditorScreen extends StatefulWidget {
  final RoutineAssignment assignment;
  final bool embedded;
  final VoidCallback? onClose;
  final VoidCallback? onSaved;

  const StudentRoutineEditorScreen({
    super.key,
    required this.assignment,
    this.embedded = false,
    this.onClose,
    this.onSaved,
  });

  @override
  State<StudentRoutineEditorScreen> createState() =>
      _StudentRoutineEditorScreenState();
}

class _StudentRoutineEditorScreenState
    extends State<StudentRoutineEditorScreen> {
  late final List<DemoRoutineSession> _sessions;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _sessions = widget.assignment.sessions
        .map(
          (session) => DemoRoutineSession(
            session: session.session,
            title: session.title,
            exercises: session.exercises
                .map(
                  (exercise) => DemoRoutineExercise(
                    name: exercise.name,
                    series: exercise.series,
                    reps: exercise.reps,
                    rest: exercise.rest,
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  Future<void> _addExercise(DemoRoutineSession session) async {
    final exercise = await showDialog<DemoRoutineExercise>(
      context: context,
      builder: (_) => RoutineExerciseDialog(sessionLabel: session.title),
    );
    if (exercise == null || !mounted) return;
    if (session.exercises.any(
      (item) => item.name.toLowerCase() == exercise.name.toLowerCase(),
    )) {
      _showMessage('Ese ejercicio ya está en la sesión');
      return;
    }
    setState(() {
      session.exercises.add(exercise);
      _hasChanges = true;
    });
  }

  Future<void> _editExercise(DemoRoutineSession session, int index) async {
    final exercise = await showDialog<DemoRoutineExercise>(
      context: context,
      builder: (_) => RoutineExerciseDialog(
        sessionLabel: session.title,
        initialExercise: session.exercises[index],
      ),
    );
    if (exercise == null || !mounted) return;
    if (session.exercises.asMap().entries.any(
      (entry) =>
          entry.key != index &&
          entry.value.name.toLowerCase() == exercise.name.toLowerCase(),
    )) {
      _showMessage('Ese ejercicio ya está en la sesión');
      return;
    }
    setState(() {
      session.exercises[index] = exercise;
      _hasChanges = true;
    });
  }

  Future<void> _deleteExercise(DemoRoutineSession session, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ejercicio'),
        content: Text(
          '¿Eliminar ${session.exercises[index].name} solo de la rutina de ${widget.assignment.studentName}?',
        ),
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
      _hasChanges = true;
    });
  }

  Future<void> _save() async {
    if (_isSaving || !_hasChanges) return;
    if (_sessions.any((session) => session.exercises.isEmpty)) {
      _showMessage('Cada sesión debe tener al menos un ejercicio');
      return;
    }
    final updated = widget.assignment.withStudentSessions(_sessions);
    setState(() => _isSaving = true);
    try {
      if (Firebase.apps.isEmpty) {
        RoutineAssignmentStore.assign(updated);
      } else {
        await RoutineAssignmentStore.assignToFirestore(updated);
      }
      if (!mounted) return;
      if (widget.embedded) {
        widget.onSaved?.call();
      } else {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage('No se pudo guardar la rutina del alumno');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(wide ? 24 : 16),
                children: [
                  if (widget.embedded) ...[
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Volver a la ficha'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Rutina de ${widget.assignment.studentName}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rutina individual',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Los cambios se aplicarán solo a ${widget.assignment.studentName}. La rutina general y los demás alumnos conservarán sus ejercicios.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final session in _sessions) ...[
                    AppCard(
                      child: Material(
                        color: Colors.transparent,
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          tilePadding: EdgeInsets.zero,
                          title: Text('${session.session} · ${session.title}'),
                          subtitle: Text(
                            '${session.exercises.length} ejercicios',
                          ),
                          children: [
                            for (
                              var index = 0;
                              index < session.exercises.length;
                              index++
                            )
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: ExerciseMotionPreview(
                                    exerciseName: session.exercises[index].name,
                                    animate: false,
                                    showPhaseLabel: false,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                title: Text(session.exercises[index].name),
                                subtitle: Text(
                                  '${session.exercises[index].series} series · ${session.exercises[index].reps}${session.exercises[index].rest.isEmpty ? '' : ' · ${session.exercises[index].rest} de descanso'}',
                                ),
                                trailing: Wrap(
                                  spacing: 0,
                                  children: [
                                    IconButton(
                                      tooltip: 'Editar ejercicio',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _editExercise(session, index),
                                    ),
                                    IconButton(
                                      tooltip: 'Eliminar ejercicio',
                                      icon: const Icon(Icons.delete_outline),
                                      onPressed: () =>
                                          _deleteExercise(session, index),
                                    ),
                                  ],
                                ),
                              ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: () => _addExercise(session),
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar ejercicio'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: wide ? 360 : double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    key: const Key('save_student_routine_button'),
                    onPressed: _hasChanges && !_isSaving ? _save : null,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Guardar rutina del alumno',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (widget.embedded) {
      return ColoredBox(color: const Color(0xFFF6F7F7), child: content);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Rutina de ${widget.assignment.studentName}')),
      body: content,
    );
  }
}
