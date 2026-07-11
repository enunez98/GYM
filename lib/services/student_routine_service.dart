import '../models/routine_models.dart';
import '../models/student_profile.dart';
import 'imported_routine_store.dart';

class StudentRoutineService {
  static DemoRoutineSession? getCurrentSession(StudentProfile? profile) {
    final sessions = getCurrentWeekSessions(profile);

    if (sessions.isEmpty) return null;

    return sessions.first;
  }

  static List<DemoRoutineSession> getCurrentWeekSessions(
    StudentProfile? profile,
  ) {
    if (profile == null) return [];
    if (!ImportedRoutineStore.hasData) return [];
    if (!_samePlan(profile.plan, ImportedRoutineStore.plan)) return [];

    final currentWeekNumber = _extractWeekNumber(profile.currentWeekLabel);

    if (currentWeekNumber == 0) return ImportedRoutineStore.sessions;

    final sessions = ImportedRoutineStore.sessions.where((session) {
      final sessionWeekNumber = _extractWeekNumber(session.session);
      return sessionWeekNumber == currentWeekNumber;
    }).toList();

    if (sessions.isEmpty) return ImportedRoutineStore.sessions;

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
