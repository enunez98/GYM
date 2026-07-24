import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../models/body_evaluation.dart';
import '../../../services/body_evaluation_store.dart';

class RegisterBodyEvaluationScreen extends StatefulWidget {
  const RegisterBodyEvaluationScreen({super.key});

  @override
  State<RegisterBodyEvaluationScreen> createState() =>
      _RegisterBodyEvaluationScreenState();
}

class _RegisterBodyEvaluationScreenState
    extends State<RegisterBodyEvaluationScreen> {
  final dateController = TextEditingController(text: '26-05-2026');
  final scoreController = TextEditingController(text: '72');
  final weightController = TextEditingController(text: '70.0');
  final bodyFatController = TextEditingController(text: '21.7');
  final fatKgController = TextEditingController(text: '15.2');
  final muscleMassController = TextEditingController(text: '51.2');
  final skeletalMuscleController = TextEditingController(text: '30.9');
  final waterController = TextEditingController(text: '57.4');
  final imcController = TextEditingController(text: '22.9');
  final visceralFatController = TextEditingController(text: '5');
  final metabolismController = TextEditingController(text: '1553');
  final targetWeightController = TextEditingController(text: '67.5');
  final weightControlController = TextEditingController(text: '-2.5');
  final fatControlController = TextEditingController(text: '-5.0');
  final muscleControlController = TextEditingController(text: '+2.5');

  String selectedStudent = 'Felipe Durán';

  @override
  void dispose() {
    dateController.dispose();
    scoreController.dispose();
    weightController.dispose();
    bodyFatController.dispose();
    fatKgController.dispose();
    muscleMassController.dispose();
    skeletalMuscleController.dispose();
    waterController.dispose();
    imcController.dispose();
    visceralFatController.dispose();
    metabolismController.dispose();
    targetWeightController.dispose();
    weightControlController.dispose();
    fatControlController.dispose();
    muscleControlController.dispose();
    super.dispose();
  }

  double parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.').trim()) ?? 0;
  }

  int parseInt(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  DateTime parseDate(String value) {
    final parts = value.trim().split(RegExp(r'[-/]'));
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.now();
  }

  ({String userId, String profileId}) studentIds(String name) {
    return switch (name) {
      'Camila Rojas' => (
        userId: 'student_002',
        profileId: 'student_profile_002',
      ),
      'Matías Soto' => (
        userId: 'student_003',
        profileId: 'student_profile_003',
      ),
      _ => (userId: 'student_001', profileId: 'student_profile_001'),
    };
  }

  void saveEvaluation() {
    final weight = parseDouble(weightController.text);
    final bodyFatPercent = parseDouble(bodyFatController.text);
    final muscleMass = parseDouble(muscleMassController.text);
    final bodyScore = parseInt(scoreController.text);

    if (weight <= 0 ||
        bodyFatPercent <= 0 ||
        muscleMass <= 0 ||
        bodyScore <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa peso, grasa corporal, masa muscular y puntuación',
          ),
        ),
      );
      return;
    }

    final ids = studentIds(selectedStudent);
    final bodyFatKg = parseDouble(fatKgController.text);
    final waterPercent = parseDouble(waterController.text);
    final evaluation = BodyEvaluation(
      id: 'body_${DateTime.now().microsecondsSinceEpoch}',
      userId: ids.userId,
      studentProfileId: ids.profileId,
      studentName: selectedStudent,
      createdAt: parseDate(dateController.text),
      bodyScore: bodyScore,
      weightKg: weight,
      bodyFatKg: bodyFatKg,
      bodyFatPercent: bodyFatPercent,
      muscleMassKg: muscleMass,
      skeletalMuscleKg: parseDouble(skeletalMuscleController.text),
      proteinKg: 0,
      bodyWaterKg: weight * waterPercent / 100,
      bodyWaterPercent: waterPercent,
      bmi: parseDouble(imcController.text),
      fatFreeMassKg: weight - bodyFatKg,
      subcutaneousFatPercent: 0,
      visceralFat: parseInt(visceralFatController.text),
      smi: 0,
      bodyAge: 0,
      whr: 0,
      basalMetabolicRate: parseInt(metabolismController.text),
      targetWeightKg: parseDouble(targetWeightController.text),
      weightControlKg: parseDouble(weightControlController.text),
      fatControlKg: parseDouble(fatControlController.text),
      muscleControlKg: parseDouble(muscleControlController.text),
    );

    BodyEvaluationStore.add(evaluation);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evaluación corporal guardada')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Evaluación corporal',
              subtitle: 'Registrar datos Body Go Pro / Fitdays',
              icon: Icons.monitor_weight,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alumno y fecha',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ResponsiveFormField(
                            child: DropdownButtonFormField<String>(
                              value: selectedStudent,
                              decoration: InputDecoration(
                                labelText: 'Alumno',
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor: const Color(0xFFF6F7F7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Felipe Durán',
                                  child: Text('Felipe Durán'),
                                ),
                                DropdownMenuItem(
                                  value: 'Camila Rojas',
                                  child: Text('Camila Rojas'),
                                ),
                                DropdownMenuItem(
                                  value: 'Matías Soto',
                                  child: Text('Matías Soto'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedStudent = value ?? 'Felipe Durán';
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: dateController,
                            label: 'Fecha evaluación',
                            icon: Icons.calendar_month,
                            hint: 'dd-mm-aaaa',
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: scoreController,
                            label: 'Puntuación corporal',
                            icon: Icons.score,
                            hint: 'Ej: 72',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Composición corporal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: weightController,
                            label: 'Peso kg',
                            icon: Icons.monitor_weight,
                            hint: 'Ej: 70.0',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: bodyFatController,
                            label: 'Grasa corporal %',
                            icon: Icons.percent,
                            hint: 'Ej: 21.7',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: fatKgController,
                            label: 'Masa grasa kg',
                            icon: Icons.scale,
                            hint: 'Ej: 15.2',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: muscleMassController,
                            label: 'Masa muscular kg',
                            icon: Icons.accessibility_new,
                            hint: 'Ej: 51.2',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: skeletalMuscleController,
                            label: 'Músculo esquelético kg',
                            icon: Icons.fitness_center,
                            hint: 'Ej: 30.9',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Indicadores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: imcController,
                            label: 'IMC',
                            icon: Icons.health_and_safety_outlined,
                            hint: 'Ej: 22.9',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: waterController,
                            label: 'Agua corporal %',
                            icon: Icons.water_drop_outlined,
                            hint: 'Ej: 57.4',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: visceralFatController,
                            label: 'Grasa visceral',
                            icon: Icons.bloodtype_outlined,
                            hint: 'Ej: 5',
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: metabolismController,
                            label: 'Metabolismo basal kcal',
                            icon: Icons.local_fire_department_outlined,
                            hint: 'Ej: 1553',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Control recomendado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: targetWeightController,
                            label: 'Peso objetivo kg',
                            icon: Icons.flag_outlined,
                            hint: 'Ej: 67.5',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: weightControlController,
                            label: 'Control de peso kg',
                            icon: Icons.trending_down,
                            hint: 'Ej: -2.5',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: fatControlController,
                            label: 'Control de grasa kg',
                            icon: Icons.percent,
                            hint: 'Ej: -5.0',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: muscleControlController,
                            label: 'Control muscular kg',
                            icon: Icons.trending_up,
                            hint: 'Ej: +2.5',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Estos datos alimentarán el dashboard corporal del alumno y los gráficos de evolución.',
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ResponsiveActionButton(
                      child: SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF59D52D),
                            foregroundColor: const Color(0xFF111214),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: saveEvaluation,
                          icon: const Icon(Icons.save),
                          label: const Text(
                            'Guardar evaluación',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ResponsiveActionButton(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111214),
                            side: const BorderSide(color: Color(0xFFC9CED2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
