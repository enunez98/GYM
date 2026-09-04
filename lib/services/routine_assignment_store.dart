import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/routine_assignment.dart';

class RoutineAssignmentStore {
  static final Map<String, RoutineAssignment> _assignmentsByUserId = {};

  static List<RoutineAssignment> get all {
    return List.unmodifiable(_assignmentsByUserId.values);
  }

  static RoutineAssignment? getByUserId(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    return _assignmentsByUserId[userId];
  }

  static bool hasAssignment(String? userId) {
    return getByUserId(userId) != null;
  }

  static void assign(RoutineAssignment assignment) {
    _assignmentsByUserId[assignment.userId] = assignment;
  }

  static Future<void> assignToFirestore(RoutineAssignment assignment) async {
    await FirebaseFirestore.instance
        .collection('routineAssignments')
        .doc(assignment.userId)
        .set(assignment.toFirestore());
    assign(assignment);
  }

  static Future<void> loadForUser(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('routineAssignments')
        .doc(userId)
        .get();
    _assignmentsByUserId.remove(userId);
    final data = snapshot.data();
    if (data != null) {
      assign(RoutineAssignment.fromFirestore(snapshot.id, data));
    }
  }

  static Future<void> loadAllFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('routineAssignments')
        .get();
    _assignmentsByUserId
      ..clear()
      ..addEntries(
        snapshot.docs.map((document) {
          final assignment = RoutineAssignment.fromFirestore(
            document.id,
            document.data(),
          );
          return MapEntry(assignment.userId, assignment);
        }),
      );
  }

  static void removeByUserId(String userId) {
    _assignmentsByUserId.remove(userId);
  }

  static Future<void> removeFromFirestore(String userId) async {
    await FirebaseFirestore.instance
        .collection('routineAssignments')
        .doc(userId)
        .delete();
    removeByUserId(userId);
  }

  static void clearAll() {
    _assignmentsByUserId.clear();
  }
}
