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

  static void removeByUserId(String userId) {
    _assignmentsByUserId.remove(userId);
  }

  static void clearAll() {
    _assignmentsByUserId.clear();
  }
}
