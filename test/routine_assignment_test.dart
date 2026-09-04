import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/student_home_screen.dart';
import 'package:gym_app/features/student/screens/workout_screen.dart';
import 'package:gym_app/features/teacher/screens/student_detail_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/routine_assignment.dart';
import 'package:gym_app/models/routine_models.dart';
import 'package:gym_app/models/student_profile.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/imported_routine_store.dart';
import 'package:gym_app/services/routine_assignment_store.dart';
import 'package:gym_app/services/routine_persistence_service.dart';
import 'package:gym_app/services/session_store.dart';
import 'package:gym_app/services/student_workout_progress_store.dart';
import 'package:gym_app/services/student_profile_store.dart';

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

  test('routine replacement automatically updates students from that plan', () {
    const plan3Student = StudentProfile(
      id: 'profile_plan_3',
      userId: 'user_plan_3',
      name: 'Alumno Plan 3',
      rut: '123456785',
      phone: '+56911111111',
      email: 'plan3@test.cl',
      plan: 'Plan 3 sesiones',
      status: 'Activo',
      startDate: '01-07-2026',
      endDate: '01-08-2026',
      daysRemaining: 30,
      weeklyAttendanceCompleted: 0,
      weeklyAttendanceTarget: 3,
      monthlyAttendanceCompleted: 0,
      monthlyAttendanceTarget: 12,
      bodyScore: 0,
      currentWeekLabel: 'Semana 1',
      currentWeekDates: '-',
    );
    const plan4Student = StudentProfile(
      id: 'profile_plan_4',
      userId: 'user_plan_4',
      name: 'Alumno Plan 4',
      rut: '111111111',
      phone: '+56922222222',
      email: 'plan4@test.cl',
      plan: 'Plan 4 sesiones',
      status: 'Activo',
      startDate: '01-07-2026',
      endDate: '01-08-2026',
      daysRemaining: 30,
      weeklyAttendanceCompleted: 0,
      weeklyAttendanceTarget: 4,
      monthlyAttendanceCompleted: 0,
      monthlyAttendanceTarget: 16,
      bodyScore: 0,
      currentWeekLabel: 'Semana 1',
      currentWeekDates: '-',
    );

    StudentProfileStore.clearAll();
    StudentProfileStore.add(plan3Student);
    StudentProfileStore.add(plan4Student);
    addTearDown(StudentProfileStore.resetToDemo);

    final firstResult = RoutinePersistenceService.replaceLocally(
      plan: 'Plan 3 sesiones',
      sourceFileName: 'plan3_v1.xlsx',
      sessions: sessions,
    );
    expect(firstResult.assignedStudents, 1);
    expect(
      RoutineAssignmentStore.getByUserId(plan3Student.userId)?.sourceFileName,
      'plan3_v1.xlsx',
    );
    expect(RoutineAssignmentStore.getByUserId(plan4Student.userId), isNull);

    RoutinePersistenceService.replaceLocally(
      plan: 'Plan 3 sesiones',
      sourceFileName: 'plan3_v2.xlsx',
      sessions: [sessions.first],
    );
    final replacement = RoutineAssignmentStore.getByUserId(plan3Student.userId);
    expect(replacement?.sourceFileName, 'plan3_v2.xlsx');
    expect(replacement?.sessions, hasLength(1));
    expect(RoutineAssignmentStore.all, hasLength(1));
  });

  testWidgets('admin assigns and keeps the imported routine in detail', (
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

    ImportedRoutineStore.clear();
    await tester.pumpWidget(
      MaterialApp(home: StudentDetailScreen(student: profile)),
    );

    expect(RoutineAssignmentStore.hasAssignment(profile.userId), isTrue);
    expect(find.text('plan_felipe.xlsx'), findsOneWidget);
    expect(find.text('Primero carga una rutina desde Excel'), findsNothing);
    expect(find.text('Quitar rutina asignada'), findsNothing);
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
