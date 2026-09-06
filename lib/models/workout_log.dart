import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, Object?> toFirestore() => {
    'setNumber': setNumber,
    'kg': kg,
    'reps': reps,
  };

  factory WorkoutSetLog.fromFirestore(Map<String, dynamic> data) {
    return WorkoutSetLog(
      setNumber: (data['setNumber'] as num?)?.toInt() ?? 0,
      kg: (data['kg'] as num?)?.toDouble() ?? 0,
      reps: (data['reps'] as num?)?.toInt() ?? 0,
    );
  }
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

  Map<String, Object?> toFirestore() => {
    'exerciseName': exerciseName,
    'plannedSeries': plannedSeries,
    'targetReps': targetReps,
    'sets': sets.map((set) => set.toFirestore()).toList(),
  };

  factory WorkoutExerciseLog.fromFirestore(Map<String, dynamic> data) {
    final rawSets = data['sets'] as List<dynamic>? ?? const [];
    return WorkoutExerciseLog(
      exerciseName: data['exerciseName'] as String? ?? '',
      plannedSeries: (data['plannedSeries'] as num?)?.toInt() ?? 0,
      targetReps: data['targetReps'] as String? ?? '',
      sets: rawSets
          .whereType<Map>()
          .map(
            (set) =>
                WorkoutSetLog.fromFirestore(Map<String, dynamic>.from(set)),
          )
          .toList(),
    );
  }
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

  Map<String, Object?> toFirestore() => {
    'userId': userId,
    'studentProfileId': studentProfileId,
    'studentName': studentName,
    'plan': plan,
    'weekLabel': weekLabel,
    'sessionLabel': sessionLabel,
    'sessionTitle': sessionTitle,
    'createdAt': createdAt,
    'status': status.name,
    'exercises': exercises.map((exercise) => exercise.toFirestore()).toList(),
  };

  factory WorkoutLog.fromFirestore(String id, Map<String, dynamic> data) {
    final rawExercises = data['exercises'] as List<dynamic>? ?? const [];
    final rawDate = data['createdAt'];
    return WorkoutLog(
      id: id,
      userId: data['userId'] as String? ?? '',
      studentProfileId: data['studentProfileId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      plan: data['plan'] as String? ?? '',
      weekLabel: data['weekLabel'] as String? ?? '',
      sessionLabel: data['sessionLabel'] as String? ?? '',
      sessionTitle: data['sessionTitle'] as String? ?? '',
      createdAt: rawDate is Timestamp
          ? rawDate.toDate()
          : rawDate is DateTime
          ? rawDate
          : DateTime.fromMillisecondsSinceEpoch(0),
      status: data['status'] == WorkoutLogStatus.skipped.name
          ? WorkoutLogStatus.skipped
          : WorkoutLogStatus.completed,
      exercises: rawExercises
          .whereType<Map>()
          .map(
            (exercise) => WorkoutExerciseLog.fromFirestore(
              Map<String, dynamic>.from(exercise),
            ),
          )
          .toList(),
    );
  }
}
