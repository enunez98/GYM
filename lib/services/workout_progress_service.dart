import '../models/workout_log.dart';
import 'workout_history_store.dart';

class WorkoutProgressSummary {
  final int completedSessions;
  final int totalSets;
  final double totalVolume;
  final double bestEstimatedOneRm;
  final String bestExerciseName;
  final String bestSetText;
  final WorkoutLog? lastCompletedWorkout;
  final List<BestWorkoutSet> bestSets;
  final List<double> oneRmTrend;

  const WorkoutProgressSummary({
    required this.completedSessions,
    required this.totalSets,
    required this.totalVolume,
    required this.bestEstimatedOneRm,
    required this.bestExerciseName,
    required this.bestSetText,
    required this.lastCompletedWorkout,
    required this.bestSets,
    required this.oneRmTrend,
  });

  bool get hasData => completedSessions > 0;
}

class BestWorkoutSet {
  final String exerciseName;
  final double kg;
  final int reps;
  final double estimatedOneRm;
  final DateTime date;

  const BestWorkoutSet({
    required this.exerciseName,
    required this.kg,
    required this.reps,
    required this.estimatedOneRm,
    required this.date,
  });

  String get resultText {
    return '${WorkoutProgressService.formatKg(kg)} kg x $reps reps';
  }
}

class WorkoutProgressService {
  static WorkoutProgressSummary getSummaryByUserId(String? userId) {
    if (userId == null || userId.isEmpty) return _emptySummary();

    final completedLogs = WorkoutHistoryStore.getCompletedByUserId(userId);
    if (completedLogs.isEmpty) return _emptySummary();

    final bestSets = <BestWorkoutSet>[];
    final oneRmTrend = <double>[];

    for (final log in completedLogs) {
      double bestOneRmForWorkout = 0;

      for (final exercise in log.exercises) {
        for (final set in exercise.sets) {
          if (set.kg <= 0 || set.reps <= 0) continue;

          final estimatedOneRm = estimateOneRm(set.kg, set.reps);
          if (estimatedOneRm > bestOneRmForWorkout) {
            bestOneRmForWorkout = estimatedOneRm;
          }

          bestSets.add(
            BestWorkoutSet(
              exerciseName: exercise.exerciseName,
              kg: set.kg,
              reps: set.reps,
              estimatedOneRm: estimatedOneRm,
              date: log.createdAt,
            ),
          );
        }
      }

      if (bestOneRmForWorkout > 0) oneRmTrend.add(bestOneRmForWorkout);
    }

    bestSets.sort((a, b) => b.estimatedOneRm.compareTo(a.estimatedOneRm));
    final bestSet = bestSets.isNotEmpty ? bestSets.first : null;
    final totalVolume = completedLogs.fold<double>(
      0,
      (total, log) => total + log.totalVolume,
    );
    final totalSets = completedLogs.fold<int>(
      0,
      (total, log) => total + log.totalSets,
    );

    return WorkoutProgressSummary(
      completedSessions: completedLogs.length,
      totalSets: totalSets,
      totalVolume: totalVolume,
      bestEstimatedOneRm: bestSet?.estimatedOneRm ?? 0,
      bestExerciseName: bestSet?.exerciseName ?? '-',
      bestSetText: bestSet == null
          ? '-'
          : '${formatKg(bestSet.kg)}x${bestSet.reps}',
      lastCompletedWorkout: completedLogs.last,
      bestSets: bestSets,
      oneRmTrend: oneRmTrend,
    );
  }

  static double estimateOneRm(double kg, int reps) {
    if (kg <= 0 || reps <= 0) return 0;
    return kg * (1 + reps / 30);
  }

  static String formatKg(double value) {
    if (value == 0) return '0';
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  static String formatVolume(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toStringAsFixed(0);
  }

  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  static WorkoutProgressSummary _emptySummary() {
    return const WorkoutProgressSummary(
      completedSessions: 0,
      totalSets: 0,
      totalVolume: 0,
      bestEstimatedOneRm: 0,
      bestExerciseName: '-',
      bestSetText: '-',
      lastCompletedWorkout: null,
      bestSets: [],
      oneRmTrend: [],
    );
  }
}
