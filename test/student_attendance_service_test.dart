import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/routine_models.dart';
import 'package:gym_app/models/workout_log.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/imported_routine_store.dart';
import 'package:gym_app/services/student_attendance_service.dart';
import 'package:gym_app/services/student_workout_progress_store.dart';
import 'package:gym_app/services/workout_history_store.dart';

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001');

  setUp(() {
    ImportedRoutineStore.save(
      selectedPlan: 'Plan 4 sesiones',
      importedSessions: List.generate(
        4,
        (index) => DemoRoutineSession(
          session: 'Semana 2',
          title: 'Sesión ${index + 1}',
          exercises: [
            DemoRoutineExercise(name: 'Ejercicio', series: 1, reps: '10'),
          ],
        ),
      ),
    );
    StudentWorkoutProgressStore.resetProgress(profile);
    WorkoutHistoryStore.clearAll();
  });

  tearDown(() {
    ImportedRoutineStore.clear();
    StudentWorkoutProgressStore.resetProgress(profile);
    WorkoutHistoryStore.clearAll();
  });

  test('starts with real zero attendance and four pending sessions', () {
    final summary = StudentAttendanceService.getSummary(profile);

    expect(summary.weeklyText, '0/4');
    expect(summary.monthlyText, '0/16');
    expect(summary.weeklyCompleted, 0);
    expect(summary.weeklySkipped, 0);
    expect(summary.pendingSessions, 4);
    expect(summary.daysRemaining, 18);
  });

  test('completed adds attendance while skipped only advances', () {
    StudentWorkoutProgressStore.completeCurrentSession(profile, 4);
    WorkoutHistoryStore.add(
      WorkoutLog(
        id: 'completed',
        userId: 'student_001',
        studentProfileId: 'student_profile_001',
        studentName: 'Felipe Durán',
        plan: 'Plan 4 sesiones',
        weekLabel: 'Semana 2',
        sessionLabel: 'Semana 2',
        sessionTitle: 'Sesión 1',
        createdAt: DateTime(2026, 7, 22),
        status: WorkoutLogStatus.completed,
        exercises: const [],
      ),
    );
    StudentWorkoutProgressStore.skipCurrentSession(profile, 4);

    final summary = StudentAttendanceService.getSummary(profile);

    expect(summary.weeklyText, '1/4');
    expect(summary.weeklyPercent, 25);
    expect(summary.monthlyText, '1/16');
    expect(summary.monthlyPercent, 6);
    expect(summary.weeklyCompleted, 1);
    expect(summary.weeklySkipped, 1);
    expect(summary.weeklyAdvanced, 2);
    expect(summary.pendingSessions, 2);
  });

  test('returns an empty summary without a profile', () {
    final summary = StudentAttendanceService.getSummary(null);

    expect(summary.weeklyText, '0/0');
    expect(summary.monthlyText, '0/0');
    expect(summary.pendingSessions, 0);
  });
}
