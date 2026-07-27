import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, Object?> toFirestore() => {
    'userId': userId,
    'studentProfileId': studentProfileId,
    'studentName': studentName,
    'plan': plan,
    'routineName': routineName,
    'sourceFileName': sourceFileName,
    'assignedAt': assignedAt,
    'sessions': sessions.map((session) => session.toFirestore()).toList(),
  };

  factory RoutineAssignment.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawDate = data['assignedAt'];
    final rawSessions = data['sessions'] as List<dynamic>? ?? const [];
    return RoutineAssignment(
      id: id,
      userId: data['userId'] as String? ?? id,
      studentProfileId: data['studentProfileId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      plan: data['plan'] as String? ?? '',
      routineName: data['routineName'] as String? ?? 'Rutina asignada',
      sourceFileName: data['sourceFileName'] as String? ?? '',
      assignedAt: rawDate is Timestamp
          ? rawDate.toDate()
          : rawDate is DateTime
          ? rawDate
          : DateTime.now(),
      sessions: rawSessions
          .whereType<Map>()
          .map(
            (item) => DemoRoutineSession.fromFirestore(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}
