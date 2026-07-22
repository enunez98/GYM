class BodyEvaluation {
  final String id;
  final String userId;
  final String studentProfileId;
  final String studentName;
  final DateTime createdAt;
  final int bodyScore;
  final double weightKg;
  final double bodyFatKg;
  final double bodyFatPercent;
  final double muscleMassKg;
  final double skeletalMuscleKg;
  final double proteinKg;
  final double bodyWaterKg;
  final double bodyWaterPercent;
  final double bmi;
  final double fatFreeMassKg;
  final double subcutaneousFatPercent;
  final int visceralFat;
  final double smi;
  final int bodyAge;
  final double whr;
  final int basalMetabolicRate;
  final double targetWeightKg;
  final double weightControlKg;
  final double fatControlKg;
  final double muscleControlKg;

  const BodyEvaluation({
    required this.id,
    required this.userId,
    required this.studentProfileId,
    required this.studentName,
    required this.createdAt,
    required this.bodyScore,
    required this.weightKg,
    required this.bodyFatKg,
    required this.bodyFatPercent,
    required this.muscleMassKg,
    required this.skeletalMuscleKg,
    required this.proteinKg,
    required this.bodyWaterKg,
    required this.bodyWaterPercent,
    required this.bmi,
    required this.fatFreeMassKg,
    required this.subcutaneousFatPercent,
    required this.visceralFat,
    required this.smi,
    required this.bodyAge,
    required this.whr,
    required this.basalMetabolicRate,
    required this.targetWeightKg,
    required this.weightControlKg,
    required this.fatControlKg,
    required this.muscleControlKg,
  });
}
