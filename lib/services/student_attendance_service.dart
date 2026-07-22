import '../models/student_profile.dart';
import 'student_routine_service.dart';
import 'student_workout_progress_store.dart';
import 'workout_history_store.dart';

class StudentAttendanceSummary {
  final int weeklyCompleted;
  final int weeklyTarget;
  final int monthlyCompleted;
  final int monthlyTarget;
  final int weeklySkipped;
  final int weeklyAdvanced;
  final int daysRemaining;

  const StudentAttendanceSummary({
    required this.weeklyCompleted,
    required this.weeklyTarget,
    required this.monthlyCompleted,
    required this.monthlyTarget,
    required this.weeklySkipped,
    required this.weeklyAdvanced,
    required this.daysRemaining,
  });

  String get weeklyText => '$weeklyCompleted/$weeklyTarget';
  String get monthlyText => '$monthlyCompleted/$monthlyTarget';

  int get weeklyPercent {
    if (weeklyTarget <= 0) return 0;
    return ((weeklyCompleted / weeklyTarget) * 100).round();
  }

  int get monthlyPercent {
    if (monthlyTarget <= 0) return 0;
    return ((monthlyCompleted / monthlyTarget) * 100).round();
  }

  int get pendingSessions {
    final pending = weeklyTarget - weeklyAdvanced;
    return pending < 0 ? 0 : pending;
  }
}

class StudentAttendanceService {
  static StudentAttendanceSummary getSummary(StudentProfile? profile) {
    if (profile == null) {
      return const StudentAttendanceSummary(
        weeklyCompleted: 0,
        weeklyTarget: 0,
        monthlyCompleted: 0,
        monthlyTarget: 0,
        weeklySkipped: 0,
        weeklyAdvanced: 0,
        daysRemaining: 0,
      );
    }

    final weekSessions = StudentRoutineService.getCurrentWeekSessions(profile);
    final weeklyTarget = weekSessions.isNotEmpty
        ? weekSessions.length
        : profile.weeklyAttendanceTarget;
    final progress = StudentWorkoutProgressStore.getProgress(profile);
    final weeklyCompleted = progress?.completedSessionIndexes.length ?? 0;
    final weeklySkipped = progress?.skippedSessionIndexes.length ?? 0;
    final weeklyAdvanced = progress?.advancedCount ?? 0;
    final monthlyCompleted = WorkoutHistoryStore.getCompletedSessionsCount(
      profile.userId,
    );

    return StudentAttendanceSummary(
      weeklyCompleted: weeklyCompleted,
      weeklyTarget: weeklyTarget,
      monthlyCompleted: monthlyCompleted,
      monthlyTarget: profile.monthlyAttendanceTarget,
      weeklySkipped: weeklySkipped,
      weeklyAdvanced: weeklyAdvanced,
      daysRemaining: profile.daysRemaining,
    );
  }
}
