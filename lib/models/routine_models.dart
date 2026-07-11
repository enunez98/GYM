class DemoRoutineSession {
  final String session;
  final String title;
  final List<DemoRoutineExercise> exercises;

  DemoRoutineSession({
    required this.session,
    required this.title,
    required this.exercises,
  });
}

class DemoRoutineExercise {
  final String name;
  final int series;
  final String reps;

  DemoRoutineExercise({
    required this.name,
    required this.series,
    required this.reps,
  });
}
