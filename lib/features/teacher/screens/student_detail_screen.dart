import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/teacher_action_row.dart';
import '../../../models/body_evaluation.dart';
import '../../../models/routine_assignment.dart';
import '../../../models/student_profile.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/imported_routine_store.dart';
import '../../../services/routine_assignment_store.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_workout_progress_store.dart';

class StudentDetailScreen extends StatefulWidget {
  final StudentProfile student;
  final bool embedded;

  const StudentDetailScreen({
    super.key,
    required this.student,
    this.embedded = false,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  StreamSubscription<List<BodyEvaluation>>? _evaluationSubscription;
  List<BodyEvaluation> _firestoreEvaluations = const [];
  Object? _evaluationError;
  bool _loadingEvaluations = false;

  StudentProfile get student => widget.student;

  bool get _usesFirestore => Firebase.apps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _listenToEvaluations();
  }

  @override
  void didUpdateWidget(covariant StudentDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.userId != widget.student.userId) {
      _listenToEvaluations();
    }
  }

  void _listenToEvaluations() {
    _evaluationSubscription?.cancel();
    _firestoreEvaluations = const [];
    _evaluationError = null;
    _loadingEvaluations = _usesFirestore;
    if (!_usesFirestore) return;

    _evaluationSubscription = BodyEvaluationStore.watchForUser(student.userId)
        .listen(
          (evaluations) {
            if (!mounted) return;
            setState(() {
              _firestoreEvaluations = evaluations;
              _loadingEvaluations = false;
              _evaluationError = null;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            setState(() {
              _loadingEvaluations = false;
              _evaluationError = error;
            });
          },
        );
  }

  @override
  void dispose() {
    _evaluationSubscription?.cancel();
    super.dispose();
  }

  bool samePlan(String first, String second) {
    String normalize(String value) {
      return value
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll(' ', '')
          .trim();
    }

    return normalize(first) == normalize(second);
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  Future<void> assignImportedRoutine() async {
    if (!ImportedRoutineStore.hasData) {
      showMessage('Primero carga una rutina desde Excel');
      return;
    }
    if (!samePlan(student.plan, ImportedRoutineStore.plan)) {
      showMessage('La rutina importada no corresponde al plan del alumno');
      return;
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final assignment = RoutineAssignment(
      id: 'assignment_$timestamp',
      userId: student.userId,
      studentProfileId: student.id,
      studentName: student.name,
      plan: student.plan,
      routineName: 'Rutina importada',
      sourceFileName: ImportedRoutineStore.fileName,
      assignedAt: DateTime.now(),
      sessions: List.from(ImportedRoutineStore.sessions),
    );
    if (Firebase.apps.isEmpty) {
      RoutineAssignmentStore.assign(assignment);
    } else {
      await RoutineAssignmentStore.assignToFirestore(assignment);
    }
    StudentWorkoutProgressStore.resetProgress(student);
    setState(() {});
    showMessage('Rutina asignada a ${student.name}');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.sizeOf(context).width >= 900;
    final attendance = StudentAttendanceService.getSummary(student);
    final evaluations = _usesFirestore
        ? _firestoreEvaluations
        : BodyEvaluationStore.getByUserId(student.userId).reversed.toList();
    final evaluation = evaluations.isEmpty ? null : evaluations.first;
    final bodyScore = evaluation?.bodyScore ?? student.bodyScore;
    final assignment = RoutineAssignmentStore.getByUserId(student.userId);
    final importedRoutineAvailable = ImportedRoutineStore.hasData;
    final importedPlanMatches =
        importedRoutineAvailable &&
        samePlan(student.plan, ImportedRoutineStore.plan);
    final assignmentHelpText = !importedRoutineAvailable
        ? 'Primero carga una rutina desde Excel'
        : !importedPlanMatches
        ? 'La rutina importada no corresponde al plan del alumno'
        : 'La rutina importada está disponible para este alumno';

    return Scaffold(
      backgroundColor: widget.embedded
          ? const Color(0xFFF6F7F7)
          : const Color(0xFF111214),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.embedded)
              FormHeader(
                title: student.name,
                subtitle: student.plan,
                icon: Icons.person,
                onBack: () => Navigator.pop(context),
              ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWeb ? 28 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F7),
                  borderRadius: widget.embedded
                      ? BorderRadius.zero
                      : const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(3000),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: isWeb
                              ? _StudentMetricCard(
                                  icon: Icons.calendar_today_outlined,
                                  title: 'Asistencia',
                                  value: attendance.monthlyText,
                                  subtitle: 'mensual',
                                )
                              : MetricCard(
                                  title: 'Asistencia',
                                  value: attendance.monthlyText,
                                  subtitle: 'mensual',
                                ),
                        ),
                        SizedBox(width: isWeb ? 24 : 10),
                        Expanded(
                          child: isWeb
                              ? _StudentMetricCard(
                                  icon: Icons.fitness_center_rounded,
                                  title: 'Evaluación',
                                  value: '$bodyScore/100',
                                  subtitle: 'corporal',
                                )
                              : MetricCard(
                                  title: 'Evaluación',
                                  value: '$bodyScore/100',
                                  subtitle: 'corporal',
                                ),
                        ),
                        SizedBox(width: isWeb ? 24 : 10),
                        Expanded(
                          child: isWeb
                              ? _StudentMetricCard(
                                  icon: Icons.verified_user_outlined,
                                  title: 'Estado',
                                  value: student.status,
                                  subtitle: 'plan',
                                )
                              : MetricCard(
                                  title: 'Estado',
                                  value: student.status,
                                  subtitle: 'plan',
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: isWeb ? 28 : 14),
                    AppCard(
                      padding: EdgeInsets.all(isWeb ? 32 : 16),
                      webContentMaxWidth: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isWeb) ...[
                                const Icon(
                                  Icons.fitness_center_rounded,
                                  color: Color(0xFF59D52D),
                                  size: 25,
                                ),
                                const SizedBox(width: 18),
                              ],
                              const Text(
                                'Rutina asignada',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isWeb ? 24 : 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (assignment == null)
                                      const Text(
                                        'Este alumno aún no tiene rutina asignada.',
                                        style: TextStyle(
                                          color: Color(0xFF616B76),
                                          fontSize: 16,
                                        ),
                                      )
                                    else ...[
                                      InfoRow(
                                        icon: Icons.description_outlined,
                                        label: 'Rutina',
                                        value: assignment.routineName,
                                      ),
                                      InfoRow(
                                        icon: Icons.file_present_outlined,
                                        label: 'Archivo',
                                        value: assignment.sourceFileName.isEmpty
                                            ? 'Rutina importada'
                                            : assignment.sourceFileName,
                                      ),
                                      InfoRow(
                                        icon: Icons.fitness_center,
                                        label: 'Plan',
                                        value: assignment.plan,
                                      ),
                                      InfoRow(
                                        icon: Icons.calendar_view_week_outlined,
                                        label: 'Contenido',
                                        value:
                                            '${assignment.totalWeeks} semanas · ${assignment.totalSessions} sesiones · ${assignment.totalExercises} ejercicios',
                                      ),
                                      InfoRow(
                                        icon: Icons.schedule,
                                        label: 'Asignada',
                                        value: formatDate(
                                          assignment.assignedAt,
                                        ),
                                      ),
                                    ],
                                    if (assignment == null ||
                                        importedRoutineAvailable) ...[
                                      const SizedBox(height: 14),
                                      Text(
                                        assignmentHelpText,
                                        style: TextStyle(
                                          color: importedPlanMatches
                                              ? const Color(0xFF59D52D)
                                              : const Color(0xFFFF5B13),
                                          fontSize: isWeb ? 15 : 13,
                                          fontWeight: isWeb
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      ResponsiveActionButton(
                                        webMaxWidth: isWeb ? 470 : 360,
                                        child: ElevatedButton.icon(
                                          onPressed: importedPlanMatches
                                              ? assignImportedRoutine
                                              : null,
                                          style: isWeb
                                              ? ElevatedButton.styleFrom(
                                                  elevation: 0,
                                                  backgroundColor: Colors.white,
                                                  foregroundColor: const Color(
                                                    0xFF4AC51F,
                                                  ),
                                                  disabledBackgroundColor:
                                                      Colors.white,
                                                  side: const BorderSide(
                                                    color: Color(0xFFCFE9C5),
                                                  ),
                                                )
                                              : null,
                                          icon: const Icon(
                                            Icons.assignment_add,
                                          ),
                                          label: Text(
                                            assignment == null
                                                ? 'Asignar rutina importada'
                                                : 'Reasignar rutina importada',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isWeb) ...[
                                const SizedBox(width: 40),
                                const _RoutineIllustration(),
                                const SizedBox(width: 42),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isWeb ? 28 : 14),
                    AppCard(
                      padding: EdgeInsets.all(isWeb ? 32 : 16),
                      webContentMaxWidth: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (isWeb) ...[
                                const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF59D52D),
                                  size: 25,
                                ),
                                const SizedBox(width: 18),
                              ],
                              const Text(
                                'Datos del alumno',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isWeb ? 24 : 14),
                          for (final item in [
                            (Icons.phone_outlined, 'Teléfono', student.phone),
                            (Icons.badge_outlined, 'RUT', student.rut),
                            (Icons.local_mall_outlined, 'Plan', student.plan),
                            (
                              Icons.calendar_today_outlined,
                              'Fecha de inicio',
                              student.startDate,
                            ),
                            (
                              Icons.event_available,
                              'Vencimiento',
                              student.endDate,
                            ),
                            (
                              Icons.hourglass_bottom,
                              'Días restantes',
                              '${student.daysRemaining}',
                            ),
                            (
                              Icons.verified_user_outlined,
                              'Estado',
                              student.status,
                            ),
                          ])
                            isWeb
                                ? _WebStudentInfoRow(
                                    icon: item.$1,
                                    label: item.$2,
                                    value: item.$3,
                                    highlight: item.$2 == 'Estado',
                                  )
                                : InfoRow(
                                    icon: item.$1,
                                    label: item.$2,
                                    value: item.$3,
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
                            'Acciones del profesor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const TeacherActionRow(
                            icon: Icons.fitness_center,
                            title: 'Ver rutina actual',
                            subtitle: 'Semana y sesión pendiente',
                          ),
                          const TeacherActionRow(
                            icon: Icons.monitor_weight,
                            title: 'Registrar nueva evaluación',
                            subtitle: 'Body Go Pro / Fitdays',
                          ),
                          TeacherActionRow(
                            icon: Icons.calendar_month,
                            title: 'Ver asistencia',
                            subtitle:
                                '${attendance.weeklyText} semanal · ${attendance.monthlyText} mensual',
                          ),
                          const TeacherActionRow(
                            icon: Icons.edit_outlined,
                            title: 'Editar datos del alumno',
                            subtitle: 'Plan, teléfono o vencimiento',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      webContentMaxWidth: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.monitor_weight_outlined,
                                color: Color(0xFF59D52D),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Evaluación corporal',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (evaluations.isNotEmpty)
                                Text(
                                  '${evaluations.length} ${evaluations.length == 1 ? 'evaluación' : 'evaluaciones'}',
                                  style: const TextStyle(
                                    color: Color(0xFF616B76),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          if (_loadingEvaluations)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 28),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_evaluationError != null)
                            _EvaluationLoadError(onRetry: _listenToEvaluations)
                          else if (evaluations.isEmpty)
                            const Text(
                              'Sin evaluación corporal registrada.',
                              style: TextStyle(color: Color(0xFF616B76)),
                            )
                          else
                            Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < evaluations.length;
                                  index++
                                ) ...[
                                  _EvaluationHistoryCard(
                                    evaluation: evaluations[index],
                                    initiallyExpanded: index == 0,
                                  ),
                                  if (index < evaluations.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              ],
                            ),
                        ],
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

class _StudentMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StudentMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 152),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAEC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xFFEDF9E8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: const Color(0xFF4AC51F)),
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF616B76),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF07111D),
                      fontSize: 31,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF4AC51F),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebStudentInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _WebStudentInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE7EAEC))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF4AC51F)),
          const SizedBox(width: 20),
          SizedBox(
            width: 340,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF616B76), fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: highlight
                    ? const Color(0xFF4AC51F)
                    : const Color(0xFF07111D),
                fontSize: 16,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineIllustration extends StatelessWidget {
  const _RoutineIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 175,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 14,
            bottom: 12,
            child: Container(
              width: 210,
              height: 130,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F4),
                borderRadius: BorderRadius.circular(70),
              ),
            ),
          ),
          Positioned(
            right: 56,
            top: 4,
            child: Container(
              width: 116,
              height: 148,
              padding: const EdgeInsets.fromLTRB(18, 27, 18, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF9EA4A9), width: 8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  4,
                  (index) => const Row(
                    children: [
                      Icon(
                        Icons.check_box_rounded,
                        color: Color(0xFFD5D8DA),
                        size: 16,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Divider(color: Color(0xFFD5D8DA), thickness: 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 84,
            top: 0,
            child: Container(
              width: 58,
              height: 25,
              decoration: BoxDecoration(
                color: const Color(0xFF70777E),
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          const Positioned(
            right: 4,
            bottom: 8,
            child: Icon(
              Icons.fitness_center_rounded,
              size: 86,
              color: Color(0xFF666D74),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvaluationLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _EvaluationLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4EF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: Color(0xFFFF5B13)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No fue posible obtener las evaluaciones desde Firebase.',
              style: TextStyle(color: Color(0xFF616B76)),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EvaluationHistoryCard extends StatelessWidget {
  final BodyEvaluation evaluation;
  final bool initiallyExpanded;

  const _EvaluationHistoryCard({
    required this.evaluation,
    required this.initiallyExpanded,
  });

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  String _number(num value, {String suffix = ''}) {
    final decimal = value.toDouble();
    final text = decimal == decimal.roundToDouble()
        ? decimal.toInt().toString()
        : decimal.toStringAsFixed(1);
    return '$text$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final metrics = <(IconData, String, String)>[
      (
        Icons.monitor_weight_outlined,
        'Peso actual',
        _number(evaluation.weightKg, suffix: ' kg'),
      ),
      (Icons.height, 'Estatura', _number(evaluation.heightCm, suffix: ' cm')),
      (Icons.speed, 'IMC', _number(evaluation.bmi)),
      (
        Icons.percent,
        'Grasa corporal',
        _number(evaluation.bodyFatPercent, suffix: '%'),
      ),
      (
        Icons.scale_outlined,
        'Grasa corporal',
        _number(evaluation.bodyFatKg, suffix: ' kg'),
      ),
      (
        Icons.accessibility_new,
        'Masa muscular',
        _number(evaluation.muscleMassKg, suffix: ' kg'),
      ),
      (
        Icons.fitness_center,
        'Músculo esquelético',
        _number(evaluation.skeletalMuscleKg, suffix: ' kg'),
      ),
      (
        Icons.water_drop_outlined,
        'Agua corporal',
        _number(evaluation.bodyWaterPercent, suffix: '%'),
      ),
      (
        Icons.water_outlined,
        'Agua corporal',
        _number(evaluation.bodyWaterKg, suffix: ' kg'),
      ),
      (
        Icons.balance_outlined,
        'Masa libre de grasa',
        _number(evaluation.fatFreeMassKg, suffix: ' kg'),
      ),
      (
        Icons.science_outlined,
        'Proteína',
        _number(evaluation.proteinKg, suffix: ' kg'),
      ),
      (
        Icons.percent,
        'Grasa subcutánea',
        _number(evaluation.subcutaneousFatPercent, suffix: '%'),
      ),
      (
        Icons.warning_amber_rounded,
        'Grasa visceral',
        _number(evaluation.visceralFat),
      ),
      (Icons.straighten, 'SMI', _number(evaluation.smi)),
      (Icons.swap_horiz, 'Relación cintura/cadera', _number(evaluation.whr)),
      (
        Icons.local_fire_department_outlined,
        'Metabolismo basal',
        _number(evaluation.basalMetabolicRate, suffix: ' kcal'),
      ),
      (
        Icons.cake_outlined,
        'Edad corporal',
        _number(evaluation.bodyAge, suffix: ' años'),
      ),
      (
        Icons.track_changes_outlined,
        'Peso objetivo',
        _number(evaluation.targetWeightKg, suffix: ' kg'),
      ),
      (
        Icons.tune,
        'Control de peso',
        _number(evaluation.weightControlKg, suffix: ' kg'),
      ),
      (
        Icons.tune,
        'Control de grasa',
        _number(evaluation.fatControlKg, suffix: ' kg'),
      ),
      (
        Icons.tune,
        'Control muscular',
        _number(evaluation.muscleControlKg, suffix: ' kg'),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFB),
        border: Border.all(color: const Color(0xFFE7EAEC)),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFEDF9E8),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${evaluation.bodyScore}',
            style: const TextStyle(
              color: Color(0xFF3FB52A),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        title: Text(
          'Evaluación del ${_date(evaluation.createdAt)}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          'Puntaje corporal ${evaluation.bodyScore}/100',
          style: const TextStyle(color: Color(0xFF616B76)),
        ),
        children: [
          const Divider(),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 900
                  ? 4
                  : constraints.maxWidth >= 560
                  ? 2
                  : 1;
              final itemWidth =
                  (constraints.maxWidth - ((columns - 1) * 12)) / columns;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final metric in metrics)
                    _EvaluationMetric(
                      width: itemWidth,
                      icon: metric.$1,
                      label: metric.$2,
                      value: metric.$3,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EvaluationMetric extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;

  const _EvaluationMetric({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE7EAEC)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF59D52D), size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF07111D),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
