enum WorkoutLogStatus { completed, skipped }

extension WorkoutLogStatusExtension on WorkoutLogStatus {
  String get label {
    switch (this) {
      case WorkoutLogStatus.completed:
        return 'Completado';
      case WorkoutLogStatus.skipped:
        return 'Omitido';
    }
  }
}

class WorkoutSetLog {
  final int setNumber;
  final double kg;
  final int reps;

  const WorkoutSetLog({
    required this.setNumber,
    required this.kg,
    required this.reps,
  });

  double get volume => kg * reps;
}

class WorkoutExerciseLog {
  final String exerciseName;
  final int plannedSeries;
  final String targetReps;
  final List<WorkoutSetLog> sets;

  const WorkoutExerciseLog({
    required this.exerciseName,
    required this.plannedSeries,
    required this.targetReps,
    required this.sets,
  });

  double get totalVolume {
    return sets.fold<double>(0, (total, item) => total + item.volume);
  }

  int get completedSets => sets.length;
}

class WorkoutLog {
  final String id;
  final String userId;
  final String studentProfileId;
  final String studentName;
  final String plan;
  final String weekLabel;
  final String sessionLabel;
  final String sessionTitle;
  final DateTime createdAt;
  final WorkoutLogStatus status;
  final List<WorkoutExerciseLog> exercises;

  const WorkoutLog({
    required this.id,
    required this.userId,
    required this.studentProfileId,
    required this.studentName,
    required this.plan,
    required this.weekLabel,
    required this.sessionLabel,
    required this.sessionTitle,
    required this.createdAt,
    required this.status,
    required this.exercises,
  });

  bool get isCompleted => status == WorkoutLogStatus.completed;
  bool get isSkipped => status == WorkoutLogStatus.skipped;

  double get totalVolume {
    return exercises.fold<double>(0, (total, item) => total + item.totalVolume);
  }

  int get totalSets {
    return exercises.fold<int>(0, (total, item) => total + item.completedSets);
  }
}
