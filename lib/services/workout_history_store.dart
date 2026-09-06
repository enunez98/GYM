import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/student_profile.dart';
import '../models/workout_log.dart';
import 'student_workout_progress_store.dart';

class WorkoutHistoryStore {
  static final List<WorkoutLog> _logs = [];

  static List<WorkoutLog> get allLogs => List.unmodifiable(_logs);

  static void add(WorkoutLog log) {
    _logs.add(log);
  }

  static Future<void> addToFirestore(WorkoutLog log) async {
    await FirebaseFirestore.instance
        .collection('workouts')
        .doc(log.id)
        .set(log.toFirestore());
    add(log);
  }

  static Future<void> addAndAdvance({
    required WorkoutLog log,
    required StudentProfile profile,
    required int totalSessions,
    required bool completed,
  }) async {
    final previousProgress = StudentWorkoutProgressStore.snapshot(profile);
    if (completed) {
      StudentWorkoutProgressStore.completeCurrentSession(
        profile,
        totalSessions,
      );
    } else {
      StudentWorkoutProgressStore.skipCurrentSession(profile, totalSessions);
    }
    final updatedProgress = StudentWorkoutProgressStore.snapshot(profile);
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    batch.set(firestore.collection('workouts').doc(log.id), log.toFirestore());
    batch.set(
      firestore
          .collection('workoutProgress')
          .doc(StudentWorkoutProgressStore.firestoreDocumentId(profile)),
      updatedProgress.toFirestore(profile),
    );
    try {
      await batch.commit();
      add(log);
    } catch (_) {
      StudentWorkoutProgressStore.restore(profile, previousProgress);
      rethrow;
    }
  }

  static Future<void> loadForUser(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .get();
    final items =
        snapshot.docs
            .map((doc) => WorkoutLog.fromFirestore(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _logs
      ..removeWhere((log) => log.userId == userId)
      ..addAll(items);
  }

  static Future<void> loadAllFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('workouts')
        .get();
    final items =
        snapshot.docs
            .map((doc) => WorkoutLog.fromFirestore(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _logs
      ..clear()
      ..addAll(items);
  }

  static List<WorkoutLog> getByUserId(String userId) {
    return List.unmodifiable(
      _logs.where((log) => log.userId == userId).toList(),
    );
  }

  static List<WorkoutLog> getCompletedByUserId(String userId) {
    return List.unmodifiable(
      _logs
          .where(
            (log) =>
                log.userId == userId &&
                log.status == WorkoutLogStatus.completed,
          )
          .toList(),
    );
  }

  static WorkoutLog? getLastCompletedByUserId(String userId) {
    final completed = getCompletedByUserId(userId);
    if (completed.isEmpty) return null;
    return completed.last;
  }

  static double getTotalVolumeByUserId(String userId) {
    final completed = getCompletedByUserId(userId);
    return completed.fold<double>(0, (total, log) => total + log.totalVolume);
  }

  static int getCompletedSessionsCount(String userId) {
    return getCompletedByUserId(userId).length;
  }

  static void clearByUserId(String userId) {
    _logs.removeWhere((log) => log.userId == userId);
  }

  static void clearAll() {
    _logs.clear();
  }
}
