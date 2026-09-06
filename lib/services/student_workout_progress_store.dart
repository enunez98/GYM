import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, Object?> toFirestore(StudentProfile profile) => {
    'userId': profile.userId,
    'studentProfileId': profile.id,
    'weekLabel': profile.currentWeekLabel,
    'currentSessionIndex': currentSessionIndex,
    'completedSessionIndexes': completedSessionIndexes.toList()..sort(),
    'skippedSessionIndexes': skippedSessionIndexes.toList()..sort(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  factory StudentWorkoutProgress.fromFirestore(Map<String, dynamic> data) {
    Set<int> indexes(String key) => (data[key] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((value) => value.toInt())
        .where((value) => value >= 0)
        .toSet();
    return StudentWorkoutProgress(
      currentSessionIndex: (data['currentSessionIndex'] as num?)?.toInt() ?? 0,
      completedSessionIndexes: indexes('completedSessionIndexes'),
      skippedSessionIndexes: indexes('skippedSessionIndexes'),
    );
  }
}

class StudentWorkoutProgressStore {
  static final Map<String, StudentWorkoutProgress> _progressByStudentWeek = {};

  static String _key(StudentProfile profile) {
    return '${profile.userId}_${profile.currentWeekLabel}';
  }

  static String firestoreDocumentId(StudentProfile profile) =>
      Uri.encodeComponent(_key(profile));

  static StudentWorkoutProgress snapshot(StudentProfile profile) {
    final progress = getProgress(profile) ?? StudentWorkoutProgress();
    return progress.copyWith(
      completedSessionIndexes: {...progress.completedSessionIndexes},
      skippedSessionIndexes: {...progress.skippedSessionIndexes},
    );
  }

  static void restore(StudentProfile profile, StudentWorkoutProgress progress) {
    _progressByStudentWeek[_key(profile)] = progress;
  }

  static Future<void> loadForProfile(StudentProfile? profile) async {
    if (profile == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('workoutProgress')
        .doc(firestoreDocumentId(profile))
        .get();
    if (snapshot.data() case final data?) {
      _progressByStudentWeek[_key(profile)] =
          StudentWorkoutProgress.fromFirestore(data);
    }
  }

  static Future<void> _persist(StudentProfile profile) async {
    final progress = getProgress(profile);
    if (progress == null) return;
    await FirebaseFirestore.instance
        .collection('workoutProgress')
        .doc(firestoreDocumentId(profile))
        .set(progress.toFirestore(profile));
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

  static Future<void> completeCurrentSessionPersisted(
    StudentProfile? profile,
    int totalSessions,
  ) async {
    if (profile == null) return;
    completeCurrentSession(profile, totalSessions);
    await _persist(profile);
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

  static Future<void> skipCurrentSessionPersisted(
    StudentProfile? profile,
    int totalSessions,
  ) async {
    if (profile == null) return;
    skipCurrentSession(profile, totalSessions);
    await _persist(profile);
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
