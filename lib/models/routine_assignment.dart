import 'routine_models.dart';

class RoutineAssignment {
  final String id;
  final String userId;
  final String studentProfileId;
  final String studentName;
  final String plan;
  final String routineName;
  final String sourceFileName;
  final DateTime assignedAt;
  final List<DemoRoutineSession> sessions;

  const RoutineAssignment({
    required this.id,
    required this.userId,
    required this.studentProfileId,
    required this.studentName,
    required this.plan,
    required this.routineName,
    required this.sourceFileName,
    required this.assignedAt,
    required this.sessions,
  });

  int get totalWeeks {
    return sessions.map((session) => session.session).toSet().length;
  }

  int get totalSessions => sessions.length;

  int get totalExercises {
    return sessions.fold<int>(
      0,
      (total, session) => total + session.exercises.length,
    );
  }
}
