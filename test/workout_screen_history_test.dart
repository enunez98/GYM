import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/workout_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/routine_assignment.dart';
import 'package:gym_app/models/routine_models.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/routine_assignment_store.dart';
import 'package:gym_app/services/session_store.dart';
import 'package:gym_app/services/student_workout_progress_store.dart';
import 'package:gym_app/services/workout_history_store.dart';
import 'package:gym_app/services/workout_exercise_draft_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001');

  Future<void> pumpLocalStorage(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }

  final greyOverlay = find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.decoration is BoxDecoration &&
        (widget.decoration! as BoxDecoration).color == const Color(0xC0A9B1BC),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WorkoutExerciseDraftStore.resetForTesting();
    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );
    RoutineAssignmentStore.assign(
      RoutineAssignment(
        id: 'assignment_1',
        userId: 'student_001',
        studentProfileId: 'student_profile_001',
        studentName: 'Felipe Durán',
        plan: 'Plan 4 sesiones',
        routineName: 'Rutina importada',
        sourceFileName: 'plan4.xlsx',
        assignedAt: DateTime(2026, 7, 22),
        sessions: [
          DemoRoutineSession(
            session: 'Semana 2',
            title: 'Sesión 1 importada',
            exercises: [
              DemoRoutineExercise(name: 'Sentadilla', series: 1, reps: '10'),
            ],
          ),
          DemoRoutineSession(
            session: 'Semana 2',
            title: 'Sesión 2 importada',
            exercises: [
              DemoRoutineExercise(name: 'Remo', series: 1, reps: '12'),
            ],
          ),
        ],
      ),
    );
    StudentWorkoutProgressStore.resetProgress(profile);
    WorkoutHistoryStore.clearAll();
  });

  tearDown(() {
    SessionStore.signOut();
    RoutineAssignmentStore.clearAll();
    StudentWorkoutProgressStore.resetProgress(profile);
    WorkoutHistoryStore.clearAll();
  });

  testWidgets('saves entered sets and logs a skipped session', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WorkoutScreen())),
    );
    await pumpLocalStorage(tester);

    expect(find.text('Sesión 1 importada'), findsWidgets);
    await tester.enterText(find.byType(TextField).at(0), '50');
    await tester.enterText(find.byType(TextField).at(1), '10');
    await tester.pump();
    await tester.tap(find.text('Guardar ejercicio'));
    await pumpLocalStorage(tester);
    expect(find.text('COMPLETADO'), findsOneWidget);
    expect(greyOverlay, findsOneWidget);

    final saveButton = find.text('Guardar entrenamiento');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await pumpLocalStorage(tester);
    await pumpLocalStorage(tester);

    final completed = WorkoutHistoryStore.allLogs.single;
    expect(completed.isCompleted, isTrue);
    expect(completed.totalSets, 1);
    expect(completed.totalVolume, 500);
    expect(find.text('Sesión 2 importada'), findsWidgets);

    final skipButton = find.text('Omitir sesión');
    await tester.ensureVisible(skipButton);
    await tester.tap(skipButton);
    await pumpLocalStorage(tester);
    await pumpLocalStorage(tester);

    expect(WorkoutHistoryStore.allLogs, hasLength(2));
    expect(WorkoutHistoryStore.allLogs.last.isSkipped, isTrue);
    expect(StudentWorkoutProgressStore.isWeekFinished(profile, 2), isTrue);
    expect(find.text('Semana completada'), findsOneWidget);
  });

  testWidgets('allows zero kg when repetitions are valid', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WorkoutScreen())),
    );
    await pumpLocalStorage(tester);
    await tester.enterText(find.byType(TextField).at(0), '0');
    await tester.enterText(find.byType(TextField).at(1), '12');
    await tester.pump();
    await tester.tap(find.text('Guardar ejercicio'));
    await pumpLocalStorage(tester);
    final saveButton = find.text('Guardar entrenamiento');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await pumpLocalStorage(tester);

    expect(WorkoutHistoryStore.allLogs, hasLength(1));
    expect(WorkoutHistoryStore.allLogs.single.totalSets, 1);
    expect(WorkoutHistoryStore.allLogs.single.totalVolume, 0);
  });

  testWidgets('rejects a set with weight but no repetitions', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WorkoutScreen())),
    );
    await pumpLocalStorage(tester);
    await tester.enterText(find.byType(TextField).at(0), '50');
    expect(
      find.widgetWithText(ElevatedButton, 'Guardar ejercicio'),
      findsOneWidget,
    );
    final saveButton = find.text('Guardar entrenamiento');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    expect(WorkoutHistoryStore.allLogs, isEmpty);
    expect(find.textContaining('Guarda cada ejercicio'), findsOneWidget);
  });

  testWidgets(
    'exige completar todas las series antes de guardar el ejercicio',
    (tester) async {
      RoutineAssignmentStore.assign(
        RoutineAssignment(
          id: 'assignment_2',
          userId: 'student_001',
          studentProfileId: 'student_profile_001',
          studentName: 'Felipe Durán',
          plan: 'Plan 4 sesiones',
          routineName: 'Rutina de dos series',
          sourceFileName: 'plan4.xlsx',
          assignedAt: DateTime(2026, 7, 22),
          sessions: [
            DemoRoutineSession(
              session: 'Semana 2',
              title: 'Sesión dos series',
              exercises: [
                DemoRoutineExercise(name: 'Sentadilla', series: 2, reps: '10'),
              ],
            ),
          ],
        ),
      );
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WorkoutScreen())),
      );
      await pumpLocalStorage(tester);
      await tester.enterText(find.byType(TextField).at(1), '10');
      await tester.pump();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Guardar ejercicio'),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField).at(3), '10');
      await tester.pump();
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Guardar ejercicio'),
            )
            .onPressed,
        isNotNull,
      );
    },
  );

  testWidgets('restaura un ejercicio guardado y permite corregirlo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget screen() => const MaterialApp(home: Scaffold(body: WorkoutScreen()));
    await tester.pumpWidget(screen());
    await pumpLocalStorage(tester);
    await tester.enterText(find.byType(TextField).at(0), '55');
    await tester.enterText(find.byType(TextField).at(1), '10');
    await tester.pump();
    tester.testTextInput.hide();
    await tester.pump();
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    await tester.ensureVisible(find.text('Guardar ejercicio'));
    await tester.tap(find.text('Guardar ejercicio'));
    await pumpLocalStorage(tester);
    expect(find.text('COMPLETADO'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).enabled,
      isFalse,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(screen());
    await pumpLocalStorage(tester);
    expect(find.text('COMPLETADO'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '55',
    );

    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    await tester.ensureVisible(find.text('Cancelar completado'));
    await tester.tap(find.text('Cancelar completado'));
    await pumpLocalStorage(tester);
    expect(find.text('COMPLETADO'), findsNothing);
    expect(greyOverlay, findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).enabled,
      isTrue,
    );
    await tester.enterText(find.byType(TextField).first, '60');
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      '60',
    );
  });
}
