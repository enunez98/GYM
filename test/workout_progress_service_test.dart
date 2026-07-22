import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/workout_log.dart';
import 'package:gym_app/services/workout_history_store.dart';
import 'package:gym_app/services/workout_progress_service.dart';

void main() {
  WorkoutLog log({
    required String id,
    required DateTime date,
    required String exercise,
    required double kg,
    required int reps,
    WorkoutLogStatus status = WorkoutLogStatus.completed,
  }) {
    return WorkoutLog(
      id: id,
      userId: 'student_001',
      studentProfileId: 'student_profile_001',
      studentName: 'Felipe Durán',
      plan: 'Plan 4 sesiones',
      weekLabel: 'Semana 2',
      sessionLabel: 'Semana 2',
      sessionTitle: id,
      createdAt: date,
      status: status,
      exercises: status == WorkoutLogStatus.skipped
          ? const []
          : [
              WorkoutExerciseLog(
                exerciseName: exercise,
                plannedSeries: 1,
                targetReps: '$reps',
                sets: [WorkoutSetLog(setNumber: 1, kg: kg, reps: reps)],
              ),
            ],
    );
  }

  setUp(WorkoutHistoryStore.clearAll);
  tearDown(WorkoutHistoryStore.clearAll);

  test('returns an empty summary without completed workouts', () {
    final summary = WorkoutProgressService.getSummaryByUserId('student_001');

    expect(summary.hasData, isFalse);
    expect(summary.completedSessions, 0);
    expect(summary.bestExerciseName, '-');
    expect(summary.oneRmTrend, isEmpty);
  });

  test('calculates real metrics and ignores skipped workouts', () {
    WorkoutHistoryStore.add(
      log(
        id: 'Sesión 1',
        date: DateTime(2026, 7, 20),
        exercise: 'Sentadilla',
        kg: 50,
        reps: 10,
      ),
    );
    WorkoutHistoryStore.add(
      log(
        id: 'Sesión omitida',
        date: DateTime(2026, 7, 21),
        exercise: '-',
        kg: 0,
        reps: 0,
        status: WorkoutLogStatus.skipped,
      ),
    );
    WorkoutHistoryStore.add(
      log(
        id: 'Sesión 3',
        date: DateTime(2026, 7, 22),
        exercise: 'Press banca',
        kg: 60,
        reps: 5,
      ),
    );

    final summary = WorkoutProgressService.getSummaryByUserId('student_001');

    expect(summary.completedSessions, 2);
    expect(summary.totalSets, 2);
    expect(summary.totalVolume, 800);
    expect(summary.bestEstimatedOneRm, 70);
    expect(summary.bestExerciseName, 'Press banca');
    expect(summary.bestSetText, '60x5');
    expect(summary.lastCompletedWorkout?.sessionTitle, 'Sesión 3');
    expect(summary.bestSets.first.exerciseName, 'Press banca');
    expect(summary.oneRmTrend, hasLength(2));
    expect(summary.oneRmTrend.first, closeTo(66.67, 0.01));
    expect(summary.oneRmTrend.last, 70);
  });

  test('formats values for presentation', () {
    expect(WorkoutProgressService.formatKg(70), '70');
    expect(WorkoutProgressService.formatKg(66.666), '66.7');
    expect(WorkoutProgressService.formatVolume(800), '800');
    expect(WorkoutProgressService.formatVolume(1250), '1.3K');
    expect(
      WorkoutProgressService.formatDate(DateTime(2026, 7, 2)),
      '02-07-2026',
    );
  });
}
