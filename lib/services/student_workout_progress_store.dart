import '../models/student_profile.dart';

class StudentWorkoutProgress {
  final int currentSessionIndex;
  final Set<int> completedSessionIndexes;
  final Set<int> skippedSessionIndexes;

  StudentWorkoutProgress({
    this.currentSessionIndex = 0,
    Set<int>? completedSessionIndexes,
    Set<int>? skippedSessionIndexes,
  }) : completedSessionIndexes = completedSessionIndexes ?? <int>{},
       skippedSessionIndexes = skippedSessionIndexes ?? <int>{};

  int get attendanceCount => completedSessionIndexes.length;

  int get advancedCount =>
      {...completedSessionIndexes, ...skippedSessionIndexes}.length;

  bool isAdvanced(int index) {
    return completedSessionIndexes.contains(index) ||
        skippedSessionIndexes.contains(index);
  }

  bool isWeekFinished(int totalSessions) {
    if (totalSessions <= 0) return false;
    return advancedCount >= totalSessions;
  }

  StudentWorkoutProgress copyWith({
    int? currentSessionIndex,
    Set<int>? completedSessionIndexes,
    Set<int>? skippedSessionIndexes,
  }) {
    return StudentWorkoutProgress(
      currentSessionIndex: currentSessionIndex ?? this.currentSessionIndex,
      completedSessionIndexes:
          completedSessionIndexes ?? this.completedSessionIndexes,
      skippedSessionIndexes:
          skippedSessionIndexes ?? this.skippedSessionIndexes,
    );
  }
}

class StudentWorkoutProgressStore {
  static final Map<String, StudentWorkoutProgress> _progressByStudentWeek = {};

  static String _key(StudentProfile profile) {
    return '${profile.userId}_${profile.currentWeekLabel}';
  }

  static StudentWorkoutProgress? getProgress(StudentProfile? profile) {
    if (profile == null) return null;

    final key = _key(profile);
    _progressByStudentWeek.putIfAbsent(key, StudentWorkoutProgress.new);
    return _progressByStudentWeek[key];
  }

  static int getCurrentSessionIndex(
    StudentProfile? profile,
    int totalSessions,
  ) {
    if (profile == null || totalSessions <= 0) return -1;

    final progress = getProgress(profile);
    if (progress == null || progress.isWeekFinished(totalSessions)) return -1;

    final currentIndex = progress.currentSessionIndex;
    if (currentIndex >= 0 &&
        currentIndex < totalSessions &&
        !progress.isAdvanced(currentIndex)) {
      return currentIndex;
    }

    return _findNextPending(
      totalSessions: totalSessions,
      completed: progress.completedSessionIndexes,
      skipped: progress.skippedSessionIndexes,
    );
  }

  static void completeCurrentSession(
    StudentProfile? profile,
    int totalSessions,
  ) {
    if (profile == null || totalSessions <= 0) return;

    final progress = getProgress(profile);
    if (progress == null) return;

    final currentIndex = getCurrentSessionIndex(profile, totalSessions);
    if (currentIndex == -1) return;

    final completed = {...progress.completedSessionIndexes, currentIndex};
    final skipped = {...progress.skippedSessionIndexes};
    final nextIndex = _findNextPending(
      totalSessions: totalSessions,
      completed: completed,
      skipped: skipped,
    );

    _progressByStudentWeek[_key(profile)] = progress.copyWith(
      currentSessionIndex: nextIndex == -1 ? totalSessions : nextIndex,
      completedSessionIndexes: completed,
      skippedSessionIndexes: skipped,
    );
  }

  static void skipCurrentSession(StudentProfile? profile, int totalSessions) {
    if (profile == null || totalSessions <= 0) return;

    final progress = getProgress(profile);
    if (progress == null) return;

    final currentIndex = getCurrentSessionIndex(profile, totalSessions);
    if (currentIndex == -1) return;

    final completed = {...progress.completedSessionIndexes};
    final skipped = {...progress.skippedSessionIndexes, currentIndex};
    final nextIndex = _findNextPending(
      totalSessions: totalSessions,
      completed: completed,
      skipped: skipped,
    );

    _progressByStudentWeek[_key(profile)] = progress.copyWith(
      currentSessionIndex: nextIndex == -1 ? totalSessions : nextIndex,
      completedSessionIndexes: completed,
      skippedSessionIndexes: skipped,
    );
  }

  static bool isWeekFinished(StudentProfile? profile, int totalSessions) {
    final progress = getProgress(profile);
    if (progress == null) return false;
    return progress.isWeekFinished(totalSessions);
  }

  static void resetProgress(StudentProfile? profile) {
    if (profile == null) return;
    _progressByStudentWeek.remove(_key(profile));
  }

  static int _findNextPending({
    required int totalSessions,
    required Set<int> completed,
    required Set<int> skipped,
  }) {
    for (int i = 0; i < totalSessions; i++) {
      if (!completed.contains(i) && !skipped.contains(i)) return i;
    }
    return -1;
  }
}
