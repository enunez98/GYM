import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/teacher/screens/student_detail_screen.dart';
import 'package:gym_app/features/teacher/screens/student_workout_history_screen.dart';
import 'package:gym_app/models/workout_log.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/workout_history_store.dart';

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001')!;

  setUp(WorkoutHistoryStore.clearAll);
  tearDown(WorkoutHistoryStore.clearAll);

  testWidgets('shows an empty state for a student without history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: StudentWorkoutHistoryScreen(profile: profile)),
    );

    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Felipe Durán'), findsOneWidget);
    expect(find.text('Sin historial'), findsOneWidget);
    expect(
      find.text(
        'Este alumno todavía no tiene entrenamientos guardados ni sesiones omitidas.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows completed and skipped sessions with sets and volume', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    WorkoutHistoryStore.add(
      WorkoutLog(
        id: 'completed_1',
        userId: profile.userId,
        studentProfileId: profile.id,
        studentName: profile.name,
        plan: profile.plan,
        weekLabel: 'Semana 2 - Ordinario',
        sessionLabel: 'Semana 2',
        sessionTitle: 'Sesión completada',
        createdAt: DateTime(2026, 7, 21),
        status: WorkoutLogStatus.completed,
        exercises: const [
          WorkoutExerciseLog(
            exerciseName: 'Press banca',
            plannedSeries: 3,
            targetReps: '8-10',
            sets: [
              WorkoutSetLog(setNumber: 1, kg: 40, reps: 10),
              WorkoutSetLog(setNumber: 2, kg: 45, reps: 8),
            ],
          ),
        ],
      ),
    );
    WorkoutHistoryStore.add(
      WorkoutLog(
        id: 'skipped_1',
        userId: profile.userId,
        studentProfileId: profile.id,
        studentName: profile.name,
        plan: profile.plan,
        weekLabel: 'Semana 2 - Ordinario',
        sessionLabel: 'Semana 2',
        sessionTitle: 'Sesión omitida',
        createdAt: DateTime(2026, 7, 22),
        status: WorkoutLogStatus.skipped,
        exercises: const [],
      ),
    );
    WorkoutHistoryStore.add(
      WorkoutLog(
        id: 'other_student',
        userId: 'student_002',
        studentProfileId: 'student_profile_002',
        studentName: 'Otro alumno',
        plan: 'Plan 3 sesiones',
        weekLabel: 'Semana 1',
        sessionLabel: 'Semana 1',
        sessionTitle: 'No mostrar',
        createdAt: DateTime(2026, 7, 23),
        status: WorkoutLogStatus.completed,
        exercises: const [],
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: StudentWorkoutHistoryScreen(profile: profile)),
    );

    expect(find.text('Completados'), findsOneWidget);
    expect(find.text('Omitidos'), findsOneWidget);
    expect(find.text('760'), findsWidgets);
    expect(find.text('Sesión omitida'), findsOneWidget);
    expect(find.text('Omitido'), findsOneWidget);
    expect(find.text('22-07-2026'), findsOneWidget);
    expect(
      find.text(
        'Esta sesión fue omitida, por eso no suma asistencia ni progreso.',
      ),
      findsOneWidget,
    );
    expect(find.text('No mostrar'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Sesión omitida')).dy,
      lessThan(tester.getTopLeft(find.text('Sesión completada')).dy),
    );

    final exerciseName = find.text('Press banca');
    await tester.scrollUntilVisible(
      exerciseName,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(exerciseName, findsOneWidget);
    expect(
      find.text('Objetivo: 8-10 · 2/3 series · Volumen 760 kg'),
      findsOneWidget,
    );
    expect(find.text('40 kg x 10 reps'), findsOneWidget);
    expect(find.text('45 kg x 8 reps'), findsOneWidget);
  });

  testWidgets('student detail opens history for the selected profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: profile)),
    );

    final historyAction = find.text('Ver historial de entrenamientos');
    await tester.scrollUntilVisible(
      historyAction,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(historyAction);
    await tester.pumpAndSettle();

    expect(find.text('Historial'), findsOneWidget);
    expect(find.text(profile.name), findsOneWidget);
    expect(find.text('Sin historial'), findsOneWidget);
  });
}
