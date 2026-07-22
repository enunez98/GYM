import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/student_home_screen.dart';
import 'package:gym_app/features/student/screens/workout_screen.dart';
import 'package:gym_app/features/teacher/screens/student_detail_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/routine_assignment.dart';
import 'package:gym_app/models/routine_models.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/imported_routine_store.dart';
import 'package:gym_app/services/routine_assignment_store.dart';
import 'package:gym_app/services/session_store.dart';
import 'package:gym_app/services/student_workout_progress_store.dart';

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001')!;
  final sessions = [
    DemoRoutineSession(
      session: 'Semana 2',
      title: 'Sesión 1 importada',
      exercises: [
        DemoRoutineExercise(name: 'Sentadilla', series: 4, reps: '10'),
        DemoRoutineExercise(name: 'Press banca', series: 3, reps: '8'),
      ],
    ),
    DemoRoutineSession(
      session: 'Semana 2',
      title: 'Sesión 2 importada',
      exercises: [DemoRoutineExercise(name: 'Remo', series: 3, reps: '12')],
    ),
  ];

  setUp(() {
    ImportedRoutineStore.clear();
    RoutineAssignmentStore.clearAll();
    StudentWorkoutProgressStore.resetProgress(profile);
    SessionStore.signOut();
  });

  tearDown(() {
    ImportedRoutineStore.clear();
    RoutineAssignmentStore.clearAll();
    StudentWorkoutProgressStore.resetProgress(profile);
    SessionStore.signOut();
  });

  test('assignment store replaces and removes routines by user', () {
    final first = RoutineAssignment(
      id: 'assignment_1',
      userId: profile.userId,
      studentProfileId: profile.id,
      studentName: profile.name,
      plan: profile.plan,
      routineName: 'Rutina inicial',
      sourceFileName: 'inicial.xlsx',
      assignedAt: DateTime(2026, 7, 22),
      sessions: sessions,
    );
    final replacement = RoutineAssignment(
      id: 'assignment_2',
      userId: profile.userId,
      studentProfileId: profile.id,
      studentName: profile.name,
      plan: profile.plan,
      routineName: 'Rutina nueva',
      sourceFileName: 'nueva.xlsx',
      assignedAt: DateTime(2026, 7, 23),
      sessions: [sessions.first],
    );

    RoutineAssignmentStore.assign(first);
    expect(RoutineAssignmentStore.hasAssignment(profile.userId), isTrue);
    expect(RoutineAssignmentStore.getByUserId(profile.userId), same(first));
    expect(first.totalWeeks, 1);
    expect(first.totalSessions, 2);
    expect(first.totalExercises, 3);

    RoutineAssignmentStore.assign(replacement);
    expect(RoutineAssignmentStore.all, [replacement]);

    RoutineAssignmentStore.removeByUserId(profile.userId);
    expect(RoutineAssignmentStore.hasAssignment(profile.userId), isFalse);
  });

  testWidgets('admin assigns and removes the imported routine from detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ImportedRoutineStore.save(
      selectedPlan: 'Plan 4 sesiones',
      importedSessions: sessions,
      sourceFileName: 'plan_felipe.xlsx',
    );

    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: profile)),
    );
    final assignButton = find.text('Asignar rutina importada');
    await tester.scrollUntilVisible(
      assignButton,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(assignButton);
    await tester.pump();

    final assignment = RoutineAssignmentStore.getByUserId(profile.userId);
    expect(assignment, isNotNull);
    expect(assignment?.sourceFileName, 'plan_felipe.xlsx');
    expect(assignment?.sessions, sessions);
    expect(find.text('Rutina asignada a Felipe Durán'), findsOneWidget);
    expect(find.text('plan_felipe.xlsx'), findsOneWidget);

    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: StudentHomeScreen(onStartWorkout: () {})),
    );
    expect(find.text('Sesión 1 importada'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: profile)),
    );
    final removeButton = find.text('Quitar rutina asignada');
    await tester.scrollUntilVisible(
      removeButton,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(removeButton);
    await tester.pump();

    expect(RoutineAssignmentStore.hasAssignment(profile.userId), isFalse);
    expect(
      find.text('Este alumno aún no tiene rutina asignada.'),
      findsOneWidget,
    );
  });

  testWidgets('detail blocks an imported routine from another plan', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    ImportedRoutineStore.save(
      selectedPlan: 'Plan 3 sesiones',
      importedSessions: sessions,
      sourceFileName: 'plan3.xlsx',
    );
    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: profile)),
    );

    final helpText = find.text(
      'La rutina importada no corresponde al plan del alumno',
    );
    await tester.scrollUntilVisible(
      helpText,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Asignar rutina importada'),
    );
    expect(helpText, findsOneWidget);
    expect(button.onPressed, isNull);
    expect(RoutineAssignmentStore.all, isEmpty);
  });

  testWidgets('workout is empty and disabled without an assignment', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WorkoutScreen())),
    );

    expect(find.text('Sin rutina asignada'), findsOneWidget);
    expect(
      find.text('Aún no tienes ejercicios asignados para esta semana.'),
      findsOneWidget,
    );
    final saveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Guardar entrenamiento'),
    );
    final skipButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Omitir sesión'),
    );
    expect(saveButton.onPressed, isNull);
    expect(skipButton.onPressed, isNull);
  });
}
