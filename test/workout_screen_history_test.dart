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

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001');

  setUp(() {
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

    expect(find.text('Sesión 1 importada'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), '50');
    await tester.enterText(find.byType(TextField).at(1), '10');

    final saveButton = find.text('Guardar entrenamiento');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();

    final completed = WorkoutHistoryStore.allLogs.single;
    expect(completed.isCompleted, isTrue);
    expect(completed.totalSets, 1);
    expect(completed.totalVolume, 500);
    expect(find.text('Sesión 2 importada'), findsOneWidget);

    final skipButton = find.text('Omitir sesión');
    await tester.ensureVisible(skipButton);
    await tester.tap(skipButton);
    await tester.pump();

    expect(WorkoutHistoryStore.allLogs, hasLength(2));
    expect(WorkoutHistoryStore.allLogs.last.isSkipped, isTrue);
    expect(StudentWorkoutProgressStore.isWeekFinished(profile, 2), isTrue);
    expect(find.text('Semana completada'), findsOneWidget);
  });
}
