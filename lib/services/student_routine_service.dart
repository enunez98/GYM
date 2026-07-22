import '../models/routine_models.dart';
import '../models/student_profile.dart';
import 'routine_assignment_store.dart';
import 'student_workout_progress_store.dart';

class StudentRoutineService {
  static DemoRoutineSession? getCurrentSession(StudentProfile? profile) {
    final sessions = getCurrentWeekSessions(profile);

    if (sessions.isEmpty) return null;

    final currentIndex = StudentWorkoutProgressStore.getCurrentSessionIndex(
      profile,
      sessions.length,
    );

    if (currentIndex == -1) return null;

    return sessions[currentIndex];
  }

  static int getCurrentSessionNumber(StudentProfile? profile) {
    final sessions = getCurrentWeekSessions(profile);
    if (sessions.isEmpty) return 0;

    final currentIndex = StudentWorkoutProgressStore.getCurrentSessionIndex(
      profile,
      sessions.length,
    );

    if (currentIndex == -1) return sessions.length;
    return currentIndex + 1;
  }

  static int getTotalSessionsForCurrentWeek(StudentProfile? profile) {
    return getCurrentWeekSessions(profile).length;
  }

  static bool isCurrentWeekFinished(StudentProfile? profile) {
    final sessions = getCurrentWeekSessions(profile);
    if (sessions.isEmpty) return false;

    return StudentWorkoutProgressStore.isWeekFinished(profile, sessions.length);
  }

  static List<DemoRoutineSession> getCurrentWeekSessions(
    StudentProfile? profile,
  ) {
    if (profile == null) return [];
    final assignment = RoutineAssignmentStore.getByUserId(profile.userId);
    if (assignment == null) return [];
    if (!_samePlan(profile.plan, assignment.plan)) return [];

    final currentWeekNumber = _extractWeekNumber(profile.currentWeekLabel);

    if (currentWeekNumber == 0) return assignment.sessions;

    final sessions = assignment.sessions.where((session) {
      final sessionWeekNumber = _extractWeekNumber(session.session);
      return sessionWeekNumber == currentWeekNumber;
    }).toList();

    if (sessions.isEmpty) return assignment.sessions;

    return sessions;
  }

  static bool hasRoutineAssigned(StudentProfile? profile) {
    return getCurrentSession(profile) != null;
  }

  static bool _samePlan(String profilePlan, String importedPlan) {
    return _normalize(profilePlan) == _normalize(importedPlan);
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(' ', '')
        .trim();
  }

  static int _extractWeekNumber(String value) {
    final match = RegExp(r'\d+').firstMatch(value);

    if (match == null) return 0;

    return int.tryParse(match.group(0) ?? '0') ?? 0;
  }
}
