import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutExerciseDraft {
  final Map<String, String> inputs;
  final Set<int> completedExercises;

  const WorkoutExerciseDraft({
    required this.inputs,
    required this.completedExercises,
  });

  Map<String, Object> toJson() => {
    'inputs': inputs,
    'completedExercises': completedExercises.toList()..sort(),
  };

  factory WorkoutExerciseDraft.fromJson(Map<String, dynamic> json) {
    final rawInputs = json['inputs'];
    final rawCompleted = json['completedExercises'];
    return WorkoutExerciseDraft(
      inputs: rawInputs is Map
          ? rawInputs.map((key, value) => MapEntry('$key', '$value'))
          : {},
      completedExercises: rawCompleted is List
          ? rawCompleted.whereType<num>().map((value) => value.toInt()).toSet()
          : {},
    );
  }
}

class WorkoutExerciseDraftStore {
  static const _prefix = 'workout_exercise_draft_v1_';
  static Future<void> _pendingWrite = Future.value();

  @visibleForTesting
  static void resetForTesting() {
    _pendingWrite = Future.value();
  }

  static String key({
    required String userId,
    required String week,
    required String session,
    required String routineSignature,
  }) =>
      '$_prefix${Uri.encodeComponent('$userId|$week|$session|$routineSignature')}';

  static Future<WorkoutExerciseDraft?> load(String key) async {
    await _pendingWrite;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return WorkoutExerciseDraft.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(String key, WorkoutExerciseDraft draft) {
    _pendingWrite = _pendingWrite.catchError((Object _) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.setString(key, jsonEncode(draft.toJson()))) {
        throw StateError('No se pudo guardar el avance local');
      }
    });
    return _pendingWrite;
  }

  static Future<void> clear(String key) {
    _pendingWrite = _pendingWrite.catchError((Object _) {}).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      if (!await prefs.remove(key)) {
        throw StateError('No se pudo borrar el avance local');
      }
    });
    return _pendingWrite;
  }
}
