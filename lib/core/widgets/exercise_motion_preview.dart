import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExerciseMotionPreview extends StatefulWidget {
  final String exerciseName;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final bool animate;
  final bool showPhaseLabel;

  const ExerciseMotionPreview({
    super.key,
    required this.exerciseName,
    this.fit = BoxFit.contain,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.animate = true,
    this.showPhaseLabel = true,
  });

  @override
  State<ExerciseMotionPreview> createState() => _ExerciseMotionPreviewState();
}

class _ExerciseMotionPreviewState extends State<ExerciseMotionPreview>
    with SingleTickerProviderStateMixin {
  static final Future<Map<String, List<String>>> _catalog = _loadCatalog();
  static const _fallback = 'assets/images/exercises/generic_dumbbell.png';

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static String _normalize(String value) {
    const accented = 'áéíóúüñ';
    const plain = 'aeiouun';
    var result = value.toLowerCase().trim();
    for (var index = 0; index < accented.length; index++) {
      result = result.replaceAll(accented[index], plain[index]);
    }
    return result
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Future<Map<String, List<String>>> _loadCatalog() async {
    final source = await rootBundle.loadString('assets/data/exercises.json');
    final items = jsonDecode(source) as List<dynamic>;
    final result = <String, List<String>>{};

    for (final rawItem in items.whereType<Map>()) {
      final item = Map<String, dynamic>.from(rawItem);
      final images = item['imagenes'];
      if (images is! Map) continue;
      final imageMap = Map<String, dynamic>.from(images);
      final frames = <String>[
        for (final phase in const ['inicio', 'bajada', 'subida'])
          if ((imageMap[phase] as String?)?.isNotEmpty ?? false)
            'assets/images/exercises_3d/${imageMap[phase]}',
      ];
      if (frames.isEmpty) continue;

      final names = <String>{
        if (item['nombre'] is String) item['nombre'] as String,
        if (item['name'] is String) item['name'] as String,
        if (item['aliases'] is List)
          ...(item['aliases'] as List).whereType<String>(),
      };
      for (final name in names) {
        result[_normalize(name)] = frames;
      }
    }
    return result;
  }

  static List<String>? _findFrames(
    Map<String, List<String>> catalog,
    String exerciseName,
  ) {
    final query = _normalize(exerciseName);
    final exact = catalog[query];
    if (exact != null) return exact;

    // Imported spreadsheets sometimes append a technique or equipment note.
    final candidates = catalog.entries.where((entry) {
      final key = entry.key;
      return key.length >= 6 && (query.contains(key) || key.contains(query));
    }).toList()..sort((a, b) => b.key.length.compareTo(a.key.length));
    if (candidates.isNotEmpty) return candidates.first.value;

    final queryWords = query
        .split(' ')
        .where((word) => word.length >= 4)
        .toSet();
    if (queryWords.isEmpty) return null;
    final ranked =
        catalog.entries
            .map((entry) {
              final words = entry.key.split(' ').toSet();
              return (
                entry: entry,
                matches: queryWords.intersection(words).length,
              );
            })
            .where((candidate) => candidate.matches > 0)
            .toList()
          ..sort((a, b) => b.matches.compareTo(a.matches));
    return ranked.isEmpty ? null : ranked.first.entry.value;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: ColoredBox(
        color: const Color(0xFFF5F6F6),
        child: FutureBuilder<Map<String, List<String>>>(
          future: _catalog,
          builder: (context, snapshot) {
            final frames = snapshot.hasData
                ? _findFrames(snapshot.data!, widget.exerciseName)
                : null;
            if (frames == null || frames.isEmpty) {
              return Image.asset(_fallback, fit: widget.fit);
            }

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final sequence = frames.length >= 3
                    ? const [0, 1, 2, 1]
                    : List<int>.generate(frames.length, (index) => index);
                final step =
                    (_controller.value * sequence.length).floor() %
                    sequence.length;
                final frameIndex = sequence[step];
                final asset = frames[frameIndex];
                final phase = switch (frameIndex) {
                  1 => 'BAJADA',
                  2 => 'SUBIDA',
                  _ => 'INICIO',
                };
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.97,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: Image.asset(
                        asset,
                        key: ValueKey(asset),
                        fit: widget.fit,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(_fallback, fit: widget.fit),
                      ),
                    ),
                    if (widget.showPhaseLabel)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xD9111214),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF59D52D),
                                  size: 15,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  phase,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
