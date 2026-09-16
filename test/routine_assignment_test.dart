import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/student_home_screen.dart';
import 'package:gym_app/features/student/screens/workout_screen.dart';
import 'package:gym_app/features/teacher/screens/student_detail_screen.dart';
import 'package:gym_app/features/teacher/screens/student_routine_editor_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/routine_assignment.dart';
import 'package:gym_app/models/routine_models.dart';
import 'package:gym_app/models/student_profile.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/exercise_catalog_service.dart';
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

  test('la carga general conserva asignaciones personalizadas', () {
    final otherStudent = StudentProfile(
      id: 'other_profile',
      userId: 'other_student',
      name: 'Otro alumno',
      rut: '222222222',
      phone: '+56922222222',
      email: 'otro@test.cl',
      plan: profile.plan,
      status: 'Activo',
      startDate: profile.startDate,
      endDate: profile.endDate,
      daysRemaining: 30,
      weeklyAttendanceCompleted: 0,
      weeklyAttendanceTarget: 4,
      monthlyAttendanceCompleted: 0,
      monthlyAttendanceTarget: 16,
      bodyScore: 0,
      currentWeekLabel: profile.currentWeekLabel,
      currentWeekDates: profile.currentWeekDates,
    );
    StudentProfileStore.clearAll();
    StudentProfileStore.add(profile);
    StudentProfileStore.add(otherStudent);
    addTearDown(StudentProfileStore.resetToDemo);

    RoutinePersistenceService.replaceLocally(
      plan: profile.plan,
      sourceFileName: 'general_v1.xlsx',
      sessions: sessions,
    );
    final original = RoutineAssignmentStore.getByUserId(profile.userId)!;
    final personalizedSessions = [
      DemoRoutineSession(
        session: sessions.first.session,
        title: sessions.first.title,
        exercises: [sessions.first.exercises.first],
      ),
      sessions.last,
    ];
    RoutineAssignmentStore.assign(
      original.withStudentSessions(personalizedSessions),
    );

    RoutinePersistenceService.replaceLocally(
      plan: profile.plan,
      sourceFileName: 'general_v2.xlsx',
      sessions: [sessions.last],
    );

    final customized = RoutineAssignmentStore.getByUserId(profile.userId)!;
    final other = RoutineAssignmentStore.getByUserId(otherStudent.userId)!;
    expect(customized.isCustomized, isTrue);
    expect(customized.sessions.first.exercises, hasLength(1));
    expect(customized.sourceFileName, 'general_v1.xlsx');
    expect(other.isCustomized, isFalse);
    expect(other.sourceFileName, 'general_v2.xlsx');
    expect(other.sessions, hasLength(1));
  });

  testWidgets('editar la rutina de un alumno no cambia otra asignación', (
    tester,
  ) async {
    ExerciseCatalogService.testExerciseNames = const ['Remo', 'Press banca'];
    addTearDown(() => ExerciseCatalogService.testExerciseNames = null);
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final first = RoutineAssignment(
      id: 'first',
      userId: profile.userId,
      studentProfileId: profile.id,
      studentName: profile.name,
      plan: profile.plan,
      routineName: 'Rutina importada',
      sourceFileName: 'general.xlsx',
      assignedAt: DateTime(2026, 7, 22),
      sessions: sessions,
    );
    final second = RoutineAssignment(
      id: 'second',
      userId: 'other_student',
      studentProfileId: 'other_profile',
      studentName: 'Otro alumno',
      plan: profile.plan,
      routineName: 'Rutina importada',
      sourceFileName: 'general.xlsx',
      assignedAt: DateTime(2026, 7, 22),
      sessions: sessions,
    );
    RoutineAssignmentStore.assign(first);
    RoutineAssignmentStore.assign(second);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentRoutineEditorScreen(assignment: first),
              ),
            ),
            child: const Text('Abrir editor'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir editor'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Eliminar ejercicio').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar ejercicio').first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('exercise_search_field')),
      'Remo',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar ejercicio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar ejercicio').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('exercise_series_field')), '5');
    await tester.tap(find.text('Guardar cambios').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save_student_routine_button')));
    await tester.pumpAndSettle();

    expect(
      RoutineAssignmentStore.getByUserId(profile.userId)!.isCustomized,
      isTrue,
    );
    final personalExercises = RoutineAssignmentStore.getByUserId(
      profile.userId,
    )!.sessions.first.exercises;
    expect(personalExercises, hasLength(2));
    expect(personalExercises.map((item) => item.name), contains('Remo'));
    expect(personalExercises.first.series, 5);
    expect(
      RoutineAssignmentStore.getByUserId(
        second.userId,
      )!.sessions.first.exercises,
      hasLength(2),
    );
    expect(sessions.first.exercises, hasLength(2));
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
    expect(find.text('Modificar rutina del alumno'), findsOneWidget);

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
