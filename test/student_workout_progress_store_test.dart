import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/student_workout_progress_store.dart';

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001');
  const totalSessions = 3;

  setUp(() => StudentWorkoutProgressStore.resetProgress(profile));
  tearDown(() => StudentWorkoutProgressStore.resetProgress(profile));

  test('completing advances and adds attendance', () {
    expect(
      StudentWorkoutProgressStore.getCurrentSessionIndex(
        profile,
        totalSessions,
      ),
      0,
    );

    StudentWorkoutProgressStore.completeCurrentSession(profile, totalSessions);

    final progress = StudentWorkoutProgressStore.getProgress(profile)!;
    expect(progress.completedSessionIndexes, {0});
    expect(progress.skippedSessionIndexes, isEmpty);
    expect(progress.attendanceCount, 1);
    expect(
      StudentWorkoutProgressStore.getCurrentSessionIndex(
        profile,
        totalSessions,
      ),
      1,
    );
  });

  test('skipping advances without adding attendance', () {
    StudentWorkoutProgressStore.skipCurrentSession(profile, totalSessions);

    final progress = StudentWorkoutProgressStore.getProgress(profile)!;
    expect(progress.completedSessionIndexes, isEmpty);
    expect(progress.skippedSessionIndexes, {0});
    expect(progress.attendanceCount, 0);
    expect(
      StudentWorkoutProgressStore.getCurrentSessionIndex(
        profile,
        totalSessions,
      ),
      1,
    );
  });

  test('finishes the week after all sessions are advanced', () {
    StudentWorkoutProgressStore.completeCurrentSession(profile, totalSessions);
    StudentWorkoutProgressStore.skipCurrentSession(profile, totalSessions);
    StudentWorkoutProgressStore.completeCurrentSession(profile, totalSessions);

    final progress = StudentWorkoutProgressStore.getProgress(profile)!;
    expect(progress.attendanceCount, 2);
    expect(progress.advancedCount, 3);
    expect(
      StudentWorkoutProgressStore.isWeekFinished(profile, totalSessions),
      isTrue,
    );
    expect(
      StudentWorkoutProgressStore.getCurrentSessionIndex(
        profile,
        totalSessions,
      ),
      -1,
    );
  });

  test('reset returns progress to the first session', () {
    StudentWorkoutProgressStore.completeCurrentSession(profile, totalSessions);
    StudentWorkoutProgressStore.resetProgress(profile);

    expect(
      StudentWorkoutProgressStore.getCurrentSessionIndex(
        profile,
        totalSessions,
      ),
      0,
    );
  });
}
