import 'package:cloud_firestore/cloud_firestore.dart';

class BodyEvaluation {
  final String id;
  final String userId;
  final String studentProfileId;
  final String studentName;
  final DateTime createdAt;
  final int bodyScore;
  final double weightKg;
  final double heightCm;
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
    this.heightCm = 0,
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

  Map<String, Object?> toFirestore() => {
    'userId': userId,
    'studentProfileId': studentProfileId,
    'studentName': studentName,
    'createdAt': createdAt,
    'bodyScore': bodyScore,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'bodyFatKg': bodyFatKg,
    'bodyFatPercent': bodyFatPercent,
    'muscleMassKg': muscleMassKg,
    'skeletalMuscleKg': skeletalMuscleKg,
    'proteinKg': proteinKg,
    'bodyWaterKg': bodyWaterKg,
    'bodyWaterPercent': bodyWaterPercent,
    'bmi': bmi,
    'fatFreeMassKg': fatFreeMassKg,
    'subcutaneousFatPercent': subcutaneousFatPercent,
    'visceralFat': visceralFat,
    'smi': smi,
    'bodyAge': bodyAge,
    'whr': whr,
    'basalMetabolicRate': basalMetabolicRate,
    'targetWeightKg': targetWeightKg,
    'weightControlKg': weightControlKg,
    'fatControlKg': fatControlKg,
    'muscleControlKg': muscleControlKg,
  };

  factory BodyEvaluation.fromFirestore(String id, Map<String, dynamic> data) {
    double decimal(String key) => (data[key] as num?)?.toDouble() ?? 0;
    int integer(String key) => (data[key] as num?)?.toInt() ?? 0;
    String text(String key) => data[key] as String? ?? '';
    final rawDate = data['createdAt'];

    return BodyEvaluation(
      id: id,
      userId: text('userId'),
      studentProfileId: text('studentProfileId'),
      studentName: text('studentName'),
      createdAt: rawDate is Timestamp
          ? rawDate.toDate()
          : rawDate is DateTime
          ? rawDate
          : DateTime.now(),
      bodyScore: integer('bodyScore'),
      weightKg: decimal('weightKg'),
      heightCm: decimal('heightCm'),
      bodyFatKg: decimal('bodyFatKg'),
      bodyFatPercent: decimal('bodyFatPercent'),
      muscleMassKg: decimal('muscleMassKg'),
      skeletalMuscleKg: decimal('skeletalMuscleKg'),
      proteinKg: decimal('proteinKg'),
      bodyWaterKg: decimal('bodyWaterKg'),
      bodyWaterPercent: decimal('bodyWaterPercent'),
      bmi: decimal('bmi'),
      fatFreeMassKg: decimal('fatFreeMassKg'),
      subcutaneousFatPercent: decimal('subcutaneousFatPercent'),
      visceralFat: integer('visceralFat'),
      smi: decimal('smi'),
      bodyAge: integer('bodyAge'),
      whr: decimal('whr'),
      basalMetabolicRate: integer('basalMetabolicRate'),
      targetWeightKg: decimal('targetWeightKg'),
      weightControlKg: decimal('weightControlKg'),
      fatControlKg: decimal('fatControlKg'),
      muscleControlKg: decimal('muscleControlKg'),
    );
  }
}
