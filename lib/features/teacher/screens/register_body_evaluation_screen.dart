import 'dart:math' as math;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../models/body_evaluation.dart';
import '../../../models/student_profile.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/student_profile_store.dart';

class RegisterBodyEvaluationScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const RegisterBodyEvaluationScreen({super.key, this.onClose});

  @override
  State<RegisterBodyEvaluationScreen> createState() =>
      _RegisterBodyEvaluationScreenState();
}

class _RegisterBodyEvaluationScreenState
    extends State<RegisterBodyEvaluationScreen> {
  final dateController = TextEditingController();
  final scoreController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final bodyFatController = TextEditingController();
  final fatKgController = TextEditingController();
  final muscleMassController = TextEditingController();
  final skeletalMuscleController = TextEditingController();
  final waterController = TextEditingController();
  final imcController = TextEditingController();
  final visceralFatController = TextEditingController();
  final metabolismController = TextEditingController();
  final targetWeightController = TextEditingController();
  final targetFatController = TextEditingController();
  final targetMuscleController = TextEditingController();
  final weightControlController = TextEditingController();
  final fatControlController = TextEditingController();
  final muscleControlController = TextEditingController();

  String? selectedStudentId;
  bool isSaving = false;

  List<StudentProfile> get students => StudentProfileStore.all;

  StudentProfile? get selectedStudent {
    final id = selectedStudentId;
    if (id == null) return null;
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    weightController.addListener(recalculateFromWeightAndHeight);
    heightController.addListener(recalculateFromWeightAndHeight);
    bodyFatController.addListener(recalculateScore);
    muscleMassController.addListener(recalculateScore);
    waterController.addListener(recalculateScore);
    visceralFatController.addListener(recalculateScore);
    metabolismController.addListener(refreshRangeLabels);
    recalculateFromWeightAndHeight();
  }

  void refreshRangeLabels() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    dateController.dispose();
    scoreController.dispose();
    weightController.dispose();
    heightController.dispose();
    bodyFatController.dispose();
    fatKgController.dispose();
    muscleMassController.dispose();
    skeletalMuscleController.dispose();
    waterController.dispose();
    imcController.dispose();
    visceralFatController.dispose();
    metabolismController.dispose();
    targetWeightController.dispose();
    targetFatController.dispose();
    targetMuscleController.dispose();
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

  void recalculateFromWeightAndHeight() {
    final weight = parseDouble(weightController.text);
    final heightMeters = parseDouble(heightController.text) / 100;
    if (weight > 0 && heightMeters > 0) {
      final bmi = weight / (heightMeters * heightMeters);
      imcController.text = bmi.toStringAsFixed(1);
      final targetWeight = 22 * heightMeters * heightMeters;
      targetWeightController.text = targetWeight.toStringAsFixed(1);
      targetFatController.text = (targetWeight * .18).toStringAsFixed(1);
      targetMuscleController.text = (targetWeight * .45).toStringAsFixed(1);
      weightControlController.text = (targetWeight - weight).toStringAsFixed(1);
    } else {
      imcController.clear();
      targetWeightController.clear();
      targetFatController.clear();
      targetMuscleController.clear();
      weightControlController.clear();
    }
    recalculateScore();
  }

  void recalculateScore() {
    final bmi = parseDouble(imcController.text);
    final bodyFat = parseDouble(bodyFatController.text);
    final water = parseDouble(waterController.text);
    final visceral = parseInt(visceralFatController.text);
    final weight = parseDouble(weightController.text);
    final muscle = parseDouble(muscleMassController.text);
    final musclePercent = weight <= 0 ? 0 : muscle / weight * 100;
    final currentFatKg = weight * bodyFat / 100;
    final targetWeight = parseDouble(targetWeightController.text);
    final targetFatKg = targetWeight * .18;
    final targetMuscleKg = targetWeight * .45;

    if (weight > 0 && bodyFat > 0) {
      fatKgController.text = currentFatKg.toStringAsFixed(1);
    } else {
      fatKgController.clear();
    }
    if (targetWeight > 0 && currentFatKg > 0) {
      fatControlController.text = (targetFatKg - currentFatKg).toStringAsFixed(
        1,
      );
    } else {
      fatControlController.clear();
    }
    if (targetWeight > 0 && muscle > 0) {
      muscleControlController.text = (targetMuscleKg - muscle).toStringAsFixed(
        1,
      );
    } else {
      muscleControlController.clear();
    }

    final hasCompleteScoreData =
        bmi > 0 &&
        bodyFat > 0 &&
        water > 0 &&
        visceral > 0 &&
        weight > 0 &&
        muscle > 0;
    if (!hasCompleteScoreData) {
      scoreController.clear();
      if (mounted) setState(() {});
      return;
    }

    var score = 100.0;
    score -= (bmi - 22).abs() * 3;
    if (bodyFat < 10) score -= (10 - bodyFat) * 1.5;
    if (bodyFat > 24) score -= (bodyFat - 24) * 1.5;
    if (water < 50) score -= (50 - water);
    if (water > 65) score -= (water - 65);
    if (visceral > 9) score -= (visceral - 9) * 2;
    if (musclePercent < 40) score -= (40 - musclePercent);
    scoreController.text = score.clamp(0, 100).round().toString();
    if (mounted) setState(() {});
  }

  String scoreRange(int score) {
    if (score >= 90) return 'Excelente';
    if (score >= 80) return 'Óptimo';
    if (score >= 70) return 'Bueno';
    if (score >= 60) return 'Regular';
    return 'Bajo';
  }

  String bmiRange(double bmi) {
    if (bmi < 18.5) return 'Bajo';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Elevado';
    return 'Alto';
  }

  String bodyFatRange(double value) {
    if (value < 10) return 'Bajo';
    if (value <= 24) return 'Normal';
    if (value <= 30) return 'Elevado';
    return 'Alto';
  }

  String muscleRange() {
    final weight = parseDouble(weightController.text);
    final muscle = parseDouble(muscleMassController.text);
    final ratio = weight <= 0 ? 0 : muscle / weight;
    if (ratio >= .55) return 'Excelente';
    if (ratio >= .45) return 'Óptimo';
    if (ratio >= .35) return 'Bueno';
    return 'Bajo';
  }

  String waterRange(double value) {
    if (value >= 55 && value <= 65) return 'Óptimo';
    if (value >= 50 && value <= 70) return 'Bueno';
    return 'Bajo';
  }

  String visceralRange(int value) {
    if (value <= 5) return 'Óptimo';
    if (value <= 9) return 'Normal';
    if (value <= 14) return 'Elevado';
    return 'Alto';
  }

  String metabolismRange(int value) {
    if (value < 1200) return 'Bajo';
    if (value <= 2500) return 'Normal';
    return 'Alto';
  }

  void closeScreen() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> showSaveResult({
    required bool success,
    String? technicalMessage,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_outline : Icons.error_outline,
          color: success
              ? const Color(0xFF59D52D)
              : Theme.of(context).colorScheme.error,
          size: 52,
        ),
        title: Text(
          success
              ? 'Evaluación registrada'
              : 'No se pudo registrar la evaluación',
          textAlign: TextAlign.center,
        ),
        content: Text(
          success
              ? 'La evaluación fue registrada exitosamente.'
              : 'No se ha podido registrar la evaluación. Revisa tu conexión e inténtalo nuevamente.${technicalMessage == null ? '' : '\n\n$technicalMessage'}',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> saveEvaluation() async {
    if (isSaving) return;
    final weight = parseDouble(weightController.text);
    final height = parseDouble(heightController.text);
    final bodyFatPercent = parseDouble(bodyFatController.text);
    final muscleMass = parseDouble(muscleMassController.text);
    final bodyScore = parseInt(scoreController.text);

    if (selectedStudent == null ||
        dateController.text.trim().isEmpty ||
        weight <= 0 ||
        height <= 0 ||
        bodyFatPercent <= 0 ||
        muscleMass <= 0 ||
        bodyScore <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa alumno, fecha, peso, estatura, grasa, músculo y los indicadores',
          ),
        ),
      );
      return;
    }

    final student = selectedStudent;
    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay alumnos registrados')),
      );
      return;
    }
    final bodyFatKg = parseDouble(fatKgController.text);
    final waterPercent = parseDouble(waterController.text);
    final evaluation = BodyEvaluation(
      id: 'body_${DateTime.now().microsecondsSinceEpoch}',
      userId: student.userId,
      studentProfileId: student.id,
      studentName: student.name,
      createdAt: parseDate(dateController.text),
      bodyScore: bodyScore,
      weightKg: weight,
      heightCm: parseDouble(heightController.text),
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

    setState(() => isSaving = true);
    try {
      if (Firebase.apps.isEmpty) {
        BodyEvaluationStore.add(evaluation);
      } else {
        await BodyEvaluationStore.addToFirestore(evaluation);
      }

      if (!mounted) return;
      setState(() => isSaving = false);
      await showSaveResult(success: true);
      if (!mounted) return;
      closeScreen();
    } catch (error) {
      debugPrint('Error al registrar evaluación corporal: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      await showSaveResult(success: false);
    }
  }

  Widget _buildWebEvaluationPanels() {
    final bodyFat = parseDouble(bodyFatController.text);
    final muscleMass = parseDouble(muscleMassController.text);
    final weight = parseDouble(weightController.text);
    final bmi = parseDouble(imcController.text);
    final water = parseDouble(waterController.text);
    final visceralFat = parseInt(visceralFatController.text);
    final score = parseInt(scoreController.text);
    final hasDistribution = bodyFat > 0 && muscleMass > 0;

    return Column(
      children: [
        AppCard(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
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
                      _ResponsiveEvaluationRow(
                        isWebLayout: true,
                        first: AppTextField(
                          controller: weightController,
                          label: 'Peso kg',
                          icon: Icons.monitor_weight,
                          hint: 'Ej: 70.0',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        second: AppTextField(
                          controller: heightController,
                          label: 'Estatura cm',
                          icon: Icons.height,
                          hint: 'Ej: 175',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ResponsiveEvaluationRow(
                        isWebLayout: true,
                        first: AppTextField(
                          controller: bodyFatController,
                          label: 'Grasa corporal %',
                          icon: Icons.percent,
                          hint: 'Ej: 21.7',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffix: bodyFat > 0
                              ? _RangeLabel(label: bodyFatRange(bodyFat))
                              : null,
                        ),
                        second: AppTextField(
                          controller: fatKgController,
                          label: 'Masa grasa kg',
                          icon: Icons.scale,
                          hint: 'Se calcula automáticamente',
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ResponsiveEvaluationRow(
                        isWebLayout: true,
                        first: AppTextField(
                          controller: muscleMassController,
                          label: 'Masa muscular kg',
                          icon: Icons.accessibility_new,
                          hint: 'Ej: 51.2',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffix: weight > 0 && muscleMass > 0
                              ? _RangeLabel(label: muscleRange())
                              : null,
                        ),
                        second: AppTextField(
                          controller: skeletalMuscleController,
                          label: 'Músculo esquelético kg',
                          icon: Icons.fitness_center,
                          hint: 'Ej: 30.9',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const VerticalDivider(width: 1, color: Color(0xFFE1E5E8)),
                const SizedBox(width: 24),
                Expanded(
                  child: _DistributionContent(
                    hasData: hasDistribution,
                    muscleRange: hasDistribution ? muscleRange() : '',
                    bodyFatRange: hasDistribution ? bodyFatRange(bodyFat) : '',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
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
                      _ResponsiveEvaluationRow(
                        isWebLayout: true,
                        first: AppTextField(
                          controller: imcController,
                          label: 'IMC',
                          icon: Icons.health_and_safety_outlined,
                          hint: 'Se calcula automáticamente',
                          readOnly: true,
                          suffix: bmi > 0
                              ? _RangeLabel(label: bmiRange(bmi))
                              : null,
                        ),
                        second: AppTextField(
                          controller: waterController,
                          label: 'Agua corporal %',
                          icon: Icons.water_drop_outlined,
                          hint: 'Ej: 57.4',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          suffix: water > 0
                              ? _RangeLabel(label: waterRange(water))
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ResponsiveEvaluationRow(
                        isWebLayout: true,
                        first: AppTextField(
                          controller: visceralFatController,
                          label: 'Grasa visceral',
                          icon: Icons.bloodtype_outlined,
                          hint: 'Ej: 5',
                          keyboardType: TextInputType.number,
                          suffix: visceralFat > 0
                              ? _RangeLabel(label: visceralRange(visceralFat))
                              : null,
                        ),
                        second: AppTextField(
                          controller: metabolismController,
                          label: 'Metabolismo basal kcal',
                          icon: Icons.local_fire_department_outlined,
                          hint: 'Ej: 1553',
                          keyboardType: TextInputType.number,
                          suffix: parseInt(metabolismController.text) > 0
                              ? _RangeLabel(
                                  label: metabolismRange(
                                    parseInt(metabolismController.text),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const VerticalDivider(width: 1, color: Color(0xFFE1E5E8)),
                const SizedBox(width: 24),
                Expanded(
                  child: _GeneralSummaryContent(
                    score: score,
                    range: score > 0 ? scoreRange(score) : '',
                    bmi: bmi,
                    bmiRange: bmi > 0 ? bmiRange(bmi) : '',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Control recomendado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: targetWeightController,
                      label: 'Peso objetivo kg',
                      icon: Icons.monitor_weight,
                      hint: 'Se calcula automáticamente',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: targetFatController,
                      label: 'Grasa objetivo kg',
                      icon: Icons.percent,
                      hint: 'Se calcula automáticamente',
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: targetMuscleController,
                      label: 'Masa muscular objetivo kg',
                      icon: Icons.accessibility_new,
                      hint: 'Se calcula automáticamente',
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Estos valores son referenciales. Ajusta según el objetivo del alumno.',
                style: TextStyle(color: Color(0xFF616B76), fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Evaluación corporal',
              subtitle: 'Registrar datos Body Go Pro / Fitdays',
              icon: Icons.monitor_weight,
              onBack: closeScreen,
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
                          _ResponsiveEvaluationRow(
                            isWebLayout: isWebLayout,
                            first: ResponsiveFormField(
                              child: AppSelectField(
                                value: selectedStudent?.name,
                                decoration: InputDecoration(
                                  labelText: 'Alumno',
                                  prefixIcon: const Icon(Icons.person),
                                  filled: true,
                                  fillColor: const Color(0xFFF6F7F7),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                hint: students.isEmpty
                                    ? 'No hay alumnos registrados'
                                    : 'Seleccionar alumno',
                                options: [
                                  for (final student in students) student.name,
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedStudentId = students
                                        .where(
                                          (student) => student.name == value,
                                        )
                                        .firstOrNull
                                        ?.id;
                                  });
                                },
                              ),
                            ),
                            second: AppTextField(
                              controller: dateController,
                              label: 'Fecha evaluación',
                              icon: Icons.calendar_month,
                              hint: 'dd-mm-aaaa',
                              readOnly: false,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: scoreController,
                            label: 'Puntuación corporal',
                            icon: Icons.score,
                            hint: 'Ej: 72',
                            keyboardType: TextInputType.number,
                            readOnly: false,
                            suffix:
                                isWebLayout &&
                                    parseInt(scoreController.text) > 0
                                ? _RangeLabel(
                                    label: scoreRange(
                                      parseInt(scoreController.text),
                                    ),
                                  )
                                : null,
                          ),
                          if (!isWebLayout &&
                              parseInt(scoreController.text) > 0) ...[
                            const SizedBox(height: 8),
                            _RangeLabel(
                              label: scoreRange(parseInt(scoreController.text)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (isWebLayout) _buildWebEvaluationPanels(),
                    if (!isWebLayout)
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
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: weightController,
                                label: 'Peso kg',
                                icon: Icons.monitor_weight,
                                hint: 'Ej: 70.0',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              second: AppTextField(
                                controller: heightController,
                                label: 'Estatura cm',
                                icon: Icons.height,
                                hint: 'Ej: 175',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: bodyFatController,
                                label: 'Grasa corporal %',
                                icon: Icons.percent,
                                hint: 'Ej: 21.7',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              second: AppTextField(
                                controller: fatKgController,
                                label: 'Masa grasa kg',
                                icon: Icons.scale,
                                hint: 'Ej: 15.2',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: muscleMassController,
                                label: 'Masa muscular kg',
                                icon: Icons.accessibility_new,
                                hint: 'Ej: 51.2',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              second: AppTextField(
                                controller: skeletalMuscleController,
                                label: 'Músculo esquelético kg',
                                icon: Icons.fitness_center,
                                hint: 'Ej: 30.9',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                            if (parseDouble(bodyFatController.text) > 0 ||
                                (parseDouble(weightController.text) > 0 &&
                                    parseDouble(muscleMassController.text) >
                                        0)) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (parseDouble(bodyFatController.text) > 0)
                                    _RangeLabel(
                                      label:
                                          'Grasa: ${bodyFatRange(parseDouble(bodyFatController.text))}',
                                    ),
                                  if (parseDouble(weightController.text) > 0 &&
                                      parseDouble(muscleMassController.text) >
                                          0)
                                    _RangeLabel(
                                      label: 'Músculo: ${muscleRange()}',
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (!isWebLayout) const SizedBox(height: 14),
                    if (!isWebLayout)
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
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: imcController,
                                label: 'IMC',
                                icon: Icons.health_and_safety_outlined,
                                hint: 'Ej: 22.9',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                readOnly: true,
                              ),
                              second: AppTextField(
                                controller: waterController,
                                label: 'Agua corporal %',
                                icon: Icons.water_drop_outlined,
                                hint: 'Ej: 57.4',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: visceralFatController,
                                label: 'Grasa visceral',
                                icon: Icons.bloodtype_outlined,
                                hint: 'Ej: 5',
                                keyboardType: TextInputType.number,
                              ),
                              second: AppTextField(
                                controller: metabolismController,
                                label: 'Metabolismo basal kcal',
                                icon: Icons.local_fire_department_outlined,
                                hint: 'Ej: 1553',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            if (parseDouble(imcController.text) > 0 ||
                                parseDouble(waterController.text) > 0 ||
                                parseInt(visceralFatController.text) > 0) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (parseDouble(imcController.text) > 0)
                                    _RangeLabel(
                                      label:
                                          'IMC: ${bmiRange(parseDouble(imcController.text))}',
                                    ),
                                  if (parseDouble(waterController.text) > 0)
                                    _RangeLabel(
                                      label:
                                          'Agua: ${waterRange(parseDouble(waterController.text))}',
                                    ),
                                  if (parseInt(visceralFatController.text) > 0)
                                    _RangeLabel(
                                      label:
                                          'Grasa visceral: ${visceralRange(parseInt(visceralFatController.text))}',
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (!isWebLayout) const SizedBox(height: 14),
                    if (!isWebLayout)
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
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: targetWeightController,
                                label: 'Peso objetivo kg',
                                icon: Icons.flag_outlined,
                                hint: 'Ej: 67.5',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                readOnly: true,
                              ),
                              second: AppTextField(
                                controller: weightControlController,
                                label: 'Control de peso kg',
                                icon: Icons.trending_down,
                                hint: 'Ej: -2.5',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveEvaluationRow(
                              isWebLayout: isWebLayout,
                              first: AppTextField(
                                controller: fatControlController,
                                label: 'Control de grasa kg',
                                icon: Icons.percent,
                                hint: 'Ej: -5.0',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                readOnly: true,
                              ),
                              second: AppTextField(
                                controller: muscleControlController,
                                label: 'Control muscular kg',
                                icon: Icons.trending_up,
                                hint: 'Ej: +2.5',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                      signed: true,
                                    ),
                                readOnly: true,
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
                              'Los rangos son referenciales generales. La interpretación clínica puede variar según edad, sexo y condición de salud.',
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
                    _ResponsiveEvaluationButtonGroup(
                      isWebLayout: isWebLayout,
                      primary: ResponsiveActionButton(
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
                            onPressed: isSaving ? null : saveEvaluation,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              isSaving
                                  ? 'Guardando evaluación...'
                                  : 'Guardar evaluación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      secondary: ResponsiveActionButton(
                        child: SizedBox(
                          height: 54,
                          child: isWebLayout
                              ? OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF111214),
                                    side: const BorderSide(
                                      color: Color(0xFFC9CED2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: isSaving ? null : closeScreen,
                                  icon: const Icon(Icons.close),
                                  label: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF111214),
                                    side: const BorderSide(
                                      color: Color(0xFFC9CED2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: isSaving ? null : closeScreen,
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

class _RangeLabel extends StatelessWidget {
  final String label;

  const _RangeLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF3B9E1E),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _DistributionLegend extends StatelessWidget {
  final Color color;
  final String label;

  const _DistributionLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 9),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _DistributionContent extends StatelessWidget {
  final bool hasData;
  final String muscleRange;
  final String bodyFatRange;

  const _DistributionContent({
    required this.hasData,
    required this.muscleRange,
    required this.bodyFatRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribución',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 235,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: SizedBox(
                    height: 220,
                    child: Image.asset(
                      'assets/images/body_composition/muscle_distribution.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      semanticLabel: 'Distribución anatómica de masa muscular',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: hasData
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DistributionLegend(
                            color: const Color(0xFF59D52D),
                            label: 'Músculo $muscleRange',
                          ),
                          const SizedBox(height: 12),
                          _DistributionLegend(
                            color: const Color(0xFF9ADF83),
                            label: 'Grasa $bodyFatRange',
                          ),
                          const SizedBox(height: 12),
                          const _DistributionLegend(
                            color: Color(0xFFD9F1D1),
                            label: 'Valor referencial',
                          ),
                        ],
                      )
                    : const Text(
                        'Completa grasa corporal y masa muscular para ver la clasificación.',
                        style: TextStyle(
                          color: Color(0xFF616B76),
                          fontSize: 12,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneralSummaryContent extends StatelessWidget {
  final int score;
  final String range;
  final double bmi;
  final String bmiRange;

  const _GeneralSummaryContent({
    required this.score,
    required this.range,
    required this.bmi,
    required this.bmiRange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen general',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: score > 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 190,
                      height: 112,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ScoreGaugePainter(
                                progress: score.clamp(0, 100) / 100,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$score',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '/100',
                                    style: TextStyle(
                                      color: Color(0xFF616B76),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'Puntuación corporal',
                      style: TextStyle(color: Color(0xFF616B76), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    _RangeLabel(label: range),
                    if (bmi > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'IMC ${bmi.toStringAsFixed(1)} · $bmiRange',
                        style: const TextStyle(
                          color: Color(0xFF616B76),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                )
              : const Center(
                  child: Text(
                    'Completa los indicadores para generar la puntuación corporal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF616B76), fontSize: 12),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  final double progress;

  const _ScoreGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 13.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      (size.height - strokeWidth) * 2,
    );
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE7E9EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF39A918), Color(0xFF74DF32)],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, backgroundPaint);
    canvas.drawArc(
      rect,
      math.pi,
      math.pi * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ResponsiveEvaluationButtonGroup extends StatelessWidget {
  final bool isWebLayout;
  final Widget primary;
  final Widget secondary;

  const _ResponsiveEvaluationButtonGroup({
    required this.isWebLayout,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWebLayout) {
      return Column(children: [primary, const SizedBox(height: 10), secondary]);
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 200, child: secondary),
          const SizedBox(width: 12),
          SizedBox(width: 260, child: primary),
        ],
      ),
    );
  }
}

class _ResponsiveEvaluationRow extends StatelessWidget {
  final bool isWebLayout;
  final Widget first;
  final Widget second;

  const _ResponsiveEvaluationRow({
    required this.isWebLayout,
    required this.first,
    required this.second,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWebLayout) {
      return Column(children: [first, const SizedBox(height: 12), second]);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1052),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second),
        ],
      ),
    );
  }
}
