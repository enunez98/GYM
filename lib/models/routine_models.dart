class DemoRoutineSession {
  final String session;
  final String title;
  final List<DemoRoutineExercise> exercises;

  DemoRoutineSession({
    required this.session,
    required this.title,
    required this.exercises,
  });

  Map<String, Object?> toFirestore() => {
    'session': session,
    'title': title,
    'exercises': exercises.map((exercise) => exercise.toFirestore()).toList(),
  };

  factory DemoRoutineSession.fromFirestore(Map<String, dynamic> data) {
    final rawExercises = data['exercises'] as List<dynamic>? ?? const [];
    return DemoRoutineSession(
      session: data['session'] as String? ?? '',
      title: data['title'] as String? ?? '',
      exercises: rawExercises
          .whereType<Map>()
          .map(
            (item) => DemoRoutineExercise.fromFirestore(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class DemoRoutineExercise {
  final String name;
  final int series;
  final String reps;
  final String rest;

  DemoRoutineExercise({
    required this.name,
    required this.series,
    required this.reps,
    this.rest = '',
  });

  Map<String, Object?> toFirestore() => {
    'name': name,
    'series': series,
    'reps': reps,
    'rest': rest,
  };

  factory DemoRoutineExercise.fromFirestore(Map<String, dynamic> data) {
    return DemoRoutineExercise(
      name: data['name'] as String? ?? '',
      series: (data['series'] as num?)?.toInt() ?? 1,
      reps: data['reps'] as String? ?? '',
      rest: data['rest'] as String? ?? '',
    );
  }
}
