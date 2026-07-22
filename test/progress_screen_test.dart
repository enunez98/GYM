import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/progress_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/workout_log.dart';
import 'package:gym_app/services/session_store.dart';
import 'package:gym_app/services/workout_history_store.dart';

void main() {
  setUp(() {
    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );
    WorkoutHistoryStore.clearAll();
  });

  tearDown(() {
    SessionStore.signOut();
    WorkoutHistoryStore.clearAll();
  });

  testWidgets('shows an empty progress state without history', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProgressScreen())),
    );

    expect(find.text('Sin entrenamientos guardados'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(find.text('Todavía no hay series registradas.'), findsOneWidget);
  });

  testWidgets('shows progress calculated from saved history', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    WorkoutHistoryStore.add(
      WorkoutLog(
        id: 'workout_1',
        userId: 'student_001',
        studentProfileId: 'student_profile_001',
        studentName: 'Felipe Durán',
        plan: 'Plan 4 sesiones',
        weekLabel: 'Semana 2',
        sessionLabel: 'Semana 2',
        sessionTitle: 'Sesión real',
        createdAt: DateTime(2026, 7, 22),
        status: WorkoutLogStatus.completed,
        exercises: const [
          WorkoutExerciseLog(
            exerciseName: 'Press banca',
            plannedSeries: 1,
            targetReps: '5',
            sets: [WorkoutSetLog(setNumber: 1, kg: 60, reps: 5)],
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ProgressScreen())),
    );

    expect(find.text('Press banca'), findsWidgets);
    expect(find.text('Real'), findsOneWidget);
    expect(find.text('60x5'), findsOneWidget);
    expect(find.text('Sesión real'), findsOneWidget);
    expect(find.text('70'), findsWidgets);
  });
}
