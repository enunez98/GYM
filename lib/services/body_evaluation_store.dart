import '../models/body_evaluation.dart';

class BodyEvaluationStore {
  static final List<BodyEvaluation> _evaluations = [];

  static List<BodyEvaluation> get all => List.unmodifiable(_evaluations);

  static void add(BodyEvaluation evaluation) {
    _evaluations.add(evaluation);
  }

  static List<BodyEvaluation> getByUserId(String userId) {
    return List.unmodifiable(
      _evaluations.where((item) => item.userId == userId).toList(),
    );
  }

  static BodyEvaluation? getLastByUserId(String? userId) {
    if (userId == null || userId.isEmpty) return null;

    final items = getByUserId(userId);
    if (items.isEmpty) return null;
    return items.last;
  }

  static void clearByUserId(String userId) {
    _evaluations.removeWhere((item) => item.userId == userId);
  }

  static void clearAll() {
    _evaluations.clear();
  }
}
