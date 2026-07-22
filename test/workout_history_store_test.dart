import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/workout_log.dart';
import 'package:gym_app/services/workout_history_store.dart';

void main() {
  WorkoutLog completedLog({
    required String id,
    required String userId,
    double kg = 50,
    int reps = 10,
  }) {
    return WorkoutLog(
      id: id,
      userId: userId,
      studentProfileId: 'profile_$userId',
      studentName: 'Alumno',
      plan: 'Plan 4 sesiones',
      weekLabel: 'Semana 2',
      sessionLabel: 'Semana 2',
      sessionTitle: 'Sesión 1',
      createdAt: DateTime(2026, 7, 22),
      status: WorkoutLogStatus.completed,
      exercises: [
        WorkoutExerciseLog(
          exerciseName: 'Sentadilla',
          plannedSeries: 4,
          targetReps: '10',
          sets: [
            WorkoutSetLog(setNumber: 1, kg: kg, reps: reps),
            WorkoutSetLog(setNumber: 2, kg: kg, reps: reps),
          ],
        ),
      ],
    );
  }

  WorkoutLog skippedLog(String userId) {
    return WorkoutLog(
      id: 'skipped',
      userId: userId,
      studentProfileId: 'profile_$userId',
      studentName: 'Alumno',
      plan: 'Plan 4 sesiones',
      weekLabel: 'Semana 2',
      sessionLabel: 'Semana 2',
      sessionTitle: 'Sesión 2',
      createdAt: DateTime(2026, 7, 22),
      status: WorkoutLogStatus.skipped,
      exercises: const [],
    );
  }

  setUp(WorkoutHistoryStore.clearAll);
  tearDown(WorkoutHistoryStore.clearAll);

  test('calculates sets and volume from completed workout data', () {
    final log = completedLog(id: 'completed_1', userId: 'student_001');

    expect(log.totalSets, 2);
    expect(log.totalVolume, 1000);
    expect(log.exercises.single.totalVolume, 1000);
    expect(log.isCompleted, isTrue);
  });

  test('stores completed and skipped sessions separately', () {
    final completed = completedLog(id: 'completed_1', userId: 'student_001');
    final skipped = skippedLog('student_001');
    WorkoutHistoryStore.add(completed);
    WorkoutHistoryStore.add(skipped);

    expect(WorkoutHistoryStore.getByUserId('student_001'), [
      completed,
      skipped,
    ]);
    expect(WorkoutHistoryStore.getCompletedByUserId('student_001'), [
      completed,
    ]);
    expect(
      WorkoutHistoryStore.getLastCompletedByUserId('student_001'),
      completed,
    );
    expect(WorkoutHistoryStore.getCompletedSessionsCount('student_001'), 1);
    expect(WorkoutHistoryStore.getTotalVolumeByUserId('student_001'), 1000);
  });

  test('filters and clears history by user', () {
    WorkoutHistoryStore.add(
      completedLog(id: 'student_log', userId: 'student_001'),
    );
    WorkoutHistoryStore.add(
      completedLog(id: 'other_log', userId: 'student_002'),
    );

    WorkoutHistoryStore.clearByUserId('student_001');

    expect(WorkoutHistoryStore.getByUserId('student_001'), isEmpty);
    expect(WorkoutHistoryStore.getByUserId('student_002'), hasLength(1));
  });
}
