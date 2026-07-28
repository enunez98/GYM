import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine_assignment.dart';
import '../models/routine_models.dart';
import '../models/student_profile.dart';
import 'routine_assignment_store.dart';
import 'imported_routine_store.dart';
import 'student_profile_store.dart';

class RoutinePersistenceResult {
  final int assignedStudents;

  const RoutinePersistenceResult({required this.assignedStudents});
}

class PersistedRoutine {
  final String id;
  final String plan;
  final String sourceFileName;
  final DateTime? updatedAt;
  final List<DemoRoutineSession> sessions;

  const PersistedRoutine({
    required this.id,
    required this.plan,
    required this.sourceFileName,
    required this.updatedAt,
    required this.sessions,
  });

  factory PersistedRoutine.fromFirestore(String id, Map<String, dynamic> data) {
    final rawSessions = data['sessions'] as List<dynamic>? ?? const [];
    final rawUpdatedAt = data['updatedAt'];

    return PersistedRoutine(
      id: id,
      plan: data['plan'] as String? ?? '',
      sourceFileName: data['sourceFileName'] as String? ?? '',
      updatedAt: rawUpdatedAt is Timestamp ? rawUpdatedAt.toDate() : null,
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

class RoutinePersistenceService {
  static String planDocumentId(String plan) {
    final sessions = RegExp(r'\d+').firstMatch(plan)?.group(0);
    if (sessions == null) {
      throw ArgumentError('El plan no contiene una cantidad de sesiones');
    }
    return 'plan_${sessions}_sessions';
  }

  static bool samePlan(String first, String second) {
    String normalize(String value) => value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll(' ', '')
        .trim();
    return normalize(first) == normalize(second);
  }

  static Future<List<PersistedRoutine>> loadRoutines() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('routines')
        .get();
    final routines = snapshot.docs
        .map(
          (document) =>
              PersistedRoutine.fromFirestore(document.id, document.data()),
        )
        .where((routine) => routine.plan.isNotEmpty)
        .toList();
    routines.sort((first, second) {
      final firstSessions =
          int.tryParse(RegExp(r'\d+').firstMatch(first.plan)?.group(0) ?? '') ??
          0;
      final secondSessions =
          int.tryParse(
            RegExp(r'\d+').firstMatch(second.plan)?.group(0) ?? '',
          ) ??
          0;
      return firstSessions.compareTo(secondSessions);
    });
    return routines;
  }

  static Future<RoutinePersistenceResult> replaceForPlan({
    required String plan,
    required String sourceFileName,
    required List<DemoRoutineSession> sessions,
  }) async {
    if (sessions.isEmpty) {
      throw ArgumentError('La rutina no contiene sesiones');
    }

    final firestore = FirebaseFirestore.instance;
    final planId = planDocumentId(plan);
    final studentsSnapshot = await firestore
        .collection('students')
        .where('plan', isEqualTo: plan)
        .get();
    final previousAssignments = await firestore
        .collection('routineAssignments')
        .where('plan', isEqualTo: plan)
        .get();
    final assignedAt = DateTime.now();
    final serializedSessions = sessions
        .map((session) => session.toFirestore())
        .toList();

    final writes = <void Function(WriteBatch)>[
      (batch) => batch.set(firestore.collection('routines').doc(planId), {
        'plan': plan,
        'sourceFileName': sourceFileName,
        'updatedAt': assignedAt,
        'sessions': serializedSessions,
      }),
      for (final previous in previousAssignments.docs)
        (batch) => batch.delete(previous.reference),
      for (final studentDocument in studentsSnapshot.docs)
        (batch) {
          final student = StudentProfile.fromFirestore(
            studentDocument.id,
            studentDocument.data(),
          );
          final assignment = _assignmentFor(
            student: student,
            planId: planId,
            plan: plan,
            sourceFileName: sourceFileName,
            assignedAt: assignedAt,
            sessions: sessions,
          );
          batch.set(
            firestore.collection('routineAssignments').doc(student.userId),
            assignment.toFirestore(),
          );
        },
    ];

    for (var start = 0; start < writes.length; start += 450) {
      final batch = firestore.batch();
      for (final write in writes.skip(start).take(450)) {
        write(batch);
      }
      await batch.commit();
    }

    _replaceLocalAssignments(
      plan: plan,
      planId: planId,
      sourceFileName: sourceFileName,
      assignedAt: assignedAt,
      sessions: sessions,
      students: studentsSnapshot.docs
          .map(
            (document) =>
                StudentProfile.fromFirestore(document.id, document.data()),
          )
          .toList(),
    );
    return RoutinePersistenceResult(
      assignedStudents: studentsSnapshot.docs.length,
    );
  }

  static Future<bool> assignActiveRoutineToStudent(
    StudentProfile student,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final planId = planDocumentId(student.plan);
    final snapshot = await firestore.collection('routines').doc(planId).get();
    final data = snapshot.data();
    if (data == null) return false;
    final rawSessions = data['sessions'] as List<dynamic>? ?? const [];
    final sessions = rawSessions
        .whereType<Map>()
        .map(
          (item) =>
              DemoRoutineSession.fromFirestore(Map<String, dynamic>.from(item)),
        )
        .toList();
    if (sessions.isEmpty) return false;

    final assignment = _assignmentFor(
      student: student,
      planId: planId,
      plan: student.plan,
      sourceFileName: data['sourceFileName'] as String? ?? '',
      assignedAt: DateTime.now(),
      sessions: sessions,
    );
    await firestore
        .collection('routineAssignments')
        .doc(student.userId)
        .set(assignment.toFirestore());
    RoutineAssignmentStore.assign(assignment);
    return true;
  }

  static bool assignActiveRoutineLocally(StudentProfile student) {
    if (!ImportedRoutineStore.hasData ||
        !samePlan(ImportedRoutineStore.plan, student.plan)) {
      return false;
    }
    RoutineAssignmentStore.assign(
      _assignmentFor(
        student: student,
        planId: planDocumentId(student.plan),
        plan: student.plan,
        sourceFileName: ImportedRoutineStore.fileName,
        assignedAt: DateTime.now(),
        sessions: ImportedRoutineStore.sessions,
      ),
    );
    return true;
  }

  static RoutinePersistenceResult replaceLocally({
    required String plan,
    required String sourceFileName,
    required List<DemoRoutineSession> sessions,
  }) {
    final students = StudentProfileStore.all
        .where((student) => samePlan(student.plan, plan))
        .toList();
    _replaceLocalAssignments(
      plan: plan,
      planId: planDocumentId(plan),
      sourceFileName: sourceFileName,
      assignedAt: DateTime.now(),
      sessions: sessions,
      students: students,
    );
    return RoutinePersistenceResult(assignedStudents: students.length);
  }

  static void _replaceLocalAssignments({
    required String plan,
    required String planId,
    required String sourceFileName,
    required DateTime assignedAt,
    required List<DemoRoutineSession> sessions,
    required List<StudentProfile> students,
  }) {
    for (final assignment
        in RoutineAssignmentStore.all
            .where((item) => samePlan(item.plan, plan))
            .toList()) {
      RoutineAssignmentStore.removeByUserId(assignment.userId);
    }
    for (final student in students) {
      RoutineAssignmentStore.assign(
        _assignmentFor(
          student: student,
          planId: planId,
          plan: plan,
          sourceFileName: sourceFileName,
          assignedAt: assignedAt,
          sessions: sessions,
        ),
      );
    }
  }

  static RoutineAssignment _assignmentFor({
    required StudentProfile student,
    required String planId,
    required String plan,
    required String sourceFileName,
    required DateTime assignedAt,
    required List<DemoRoutineSession> sessions,
  }) {
    return RoutineAssignment(
      id: '${planId}_${student.userId}',
      userId: student.userId,
      studentProfileId: student.id,
      studentName: student.name,
      plan: plan,
      routineName: 'Rutina $plan',
      sourceFileName: sourceFileName,
      assignedAt: assignedAt,
      sessions: List<DemoRoutineSession>.from(sessions),
    );
  }
}
