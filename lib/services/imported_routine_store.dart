import '../models/routine_models.dart';

class ImportedRoutineStore {
  static String plan = 'Plan 3 sesiones';
  static List<DemoRoutineSession> sessions = [];

  static bool get hasData => sessions.isNotEmpty;

  static void save({
    required String selectedPlan,
    required List<DemoRoutineSession> importedSessions,
  }) {
    plan = selectedPlan;
    sessions = List<DemoRoutineSession>.from(importedSessions);
  }

  static void clear() {
    plan = 'Plan 3 sesiones';
    sessions = [];
  }
}
