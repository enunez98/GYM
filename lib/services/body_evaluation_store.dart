import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/body_evaluation.dart';

class BodyEvaluationStore {
  static final List<BodyEvaluation> _evaluations = [];

  static List<BodyEvaluation> get all => List.unmodifiable(_evaluations);

  static void add(BodyEvaluation evaluation) {
    _evaluations.add(evaluation);
  }

  static Future<void> addToFirestore(BodyEvaluation evaluation) async {
    await FirebaseFirestore.instance
        .collection('evaluations')
        .doc(evaluation.id)
        .set(evaluation.toFirestore());
    _evaluations.add(evaluation);
  }

  static Future<void> loadForUser(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('evaluations')
        .where('userId', isEqualTo: userId)
        .get();
    final items =
        snapshot.docs
            .map(
              (document) =>
                  BodyEvaluation.fromFirestore(document.id, document.data()),
            )
            .toList()
          ..sort(
            (first, second) => first.createdAt.compareTo(second.createdAt),
          );
    _evaluations
      ..removeWhere((item) => item.userId == userId)
      ..addAll(items);
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
