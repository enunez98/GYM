import '../models/workout_log.dart';

class WorkoutHistoryStore {
  static final List<WorkoutLog> _logs = [];

  static List<WorkoutLog> get allLogs => List.unmodifiable(_logs);

  static void add(WorkoutLog log) {
    _logs.add(log);
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
