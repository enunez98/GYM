class DemoExercise {
  final String name;
  final String muscleGroup;
  final List<DemoSet> series;

  DemoExercise({
    required this.name,
    required this.muscleGroup,
    required this.series,
  });
}

class DemoSet {
  final int serie;
  final int kg;
  final int reps;

  DemoSet({required this.serie, required this.kg, required this.reps});
}
