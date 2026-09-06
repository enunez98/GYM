import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ExerciseCatalogService {
  ExerciseCatalogService._();

  static List<Map<String, dynamic>>? _cachedItems;

  @visibleForTesting
  static List<String>? testExerciseNames;

  static Future<List<String>> loadNames({bool requireImages = false}) async {
    final testNames = testExerciseNames;
    if (testNames != null) return List.unmodifiable(testNames);

    final items = await _loadItems();
    final names =
        items
            .where((item) {
              if (!requireImages) return true;
              final images = item['imagenes'];
              return images is Map &&
                  images.values.whereType<String>().any(
                    (image) => image.isNotEmpty,
                  );
            })
            .map(
              (item) =>
                  (item['nombre'] as String? ?? item['name'] as String? ?? '')
                      .trim(),
            )
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return List.unmodifiable(names);
  }

  static Future<List<Map<String, dynamic>>> _loadItems() async {
    final cachedItems = _cachedItems;
    if (cachedItems != null) return cachedItems;

    final source = await rootBundle.loadString('assets/data/exercises.json');
    final decoded = jsonDecode(source) as List<dynamic>;
    final items = decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
    _cachedItems = items;
    return items;
  }
}
