import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/session_store.dart';

class BodyEvaluationScreen extends StatelessWidget {
  const BodyEvaluationScreen({super.key});

  String _number(double value) {
    if (value % 1 == 0) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }

  String _signed(double value) {
    final prefix = value > 0 ? '+' : '';
    return '$prefix${_number(value)}';
  }

  String _date(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final evaluation = BodyEvaluationStore.getLastByUserId(user?.id);

    return Container(
      color: const Color(0xFF00111F),
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Evaluación corporal',
              subtitle: 'Body Go Pro / Fitdays',
              icon: Icons.monitor_weight,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: evaluation == null
                    ? ListView(
                        children: const [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sin evaluación corporal',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Aún no tienes una evaluación corporal registrada.',
                                  style: TextStyle(color: Color(0xFF616B76)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Última evaluación',
                                  style: TextStyle(color: Color(0xFF616B76)),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _date(evaluation.createdAt),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    StatusChip(
                                      text: 'Registrada',
                                      background: const Color(0xFFEDF9E8),
                                      textColor: const Color(0xFF59D52D),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${evaluation.bodyScore}',
                                      style: const TextStyle(
                                        fontSize: 54,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF59D52D),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Padding(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text(
                                        '/100 puntos',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF616B76),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value:
                                        evaluation.bodyScore.clamp(0, 100) /
                                        100,
                                    minHeight: 12,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    color: const Color(0xFF59D52D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _BodyMetricTile(
                                  icon: Icons.monitor_weight,
                                  title: 'Peso',
                                  value: _number(evaluation.weightKg),
                                  unit: 'kg',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BodyMetricTile(
                                  icon: Icons.percent,
                                  title: 'Grasa',
                                  value: _number(evaluation.bodyFatPercent),
                                  unit: '%',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _BodyMetricTile(
                                  icon: Icons.accessibility_new,
                                  title: 'Masa muscular',
                                  value: _number(evaluation.muscleMassKg),
                                  unit: 'kg',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BodyMetricTile(
                                  icon: Icons.water_drop_outlined,
                                  title: 'Agua corporal',
                                  value: _number(evaluation.bodyWaterPercent),
                                  unit: '%',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _BodyMetricTile(
                                  icon: Icons.health_and_safety_outlined,
                                  title: 'IMC',
                                  value: _number(evaluation.bmi),
                                  unit: '',
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _BodyMetricTile(
                                  icon: Icons.local_fire_department_outlined,
                                  title: 'Metabolismo',
                                  value: '${evaluation.basalMetabolicRate}',
                                  unit: 'kcal',
                                ),
                              ),
                            ],
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
                                _BodyControlRow(
                                  label: 'Peso objetivo',
                                  value:
                                      '${_number(evaluation.targetWeightKg)} kg',
                                ),
                                _BodyControlRow(
                                  label: 'Control de peso',
                                  value:
                                      '${_signed(evaluation.weightControlKg)} kg',
                                ),
                                _BodyControlRow(
                                  label: 'Control de grasa',
                                  value:
                                      '${_signed(evaluation.fatControlKg)} kg',
                                ),
                                _BodyControlRow(
                                  label: 'Control muscular',
                                  value:
                                      '${_signed(evaluation.muscleControlKg)} kg',
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
                                  'Indicadores principales',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _BodyProgressRow(
                                  label: 'IMC',
                                  value: _number(evaluation.bmi),
                                  progress: (evaluation.bmi / 40).clamp(0, 1),
                                  status: 'Registrado',
                                ),
                                _BodyProgressRow(
                                  label: 'Grasa corporal',
                                  value:
                                      '${_number(evaluation.bodyFatPercent)}%',
                                  progress: (evaluation.bodyFatPercent / 50)
                                      .clamp(0, 1),
                                  status: 'Registrado',
                                ),
                                _BodyProgressRow(
                                  label: 'Masa muscular',
                                  value:
                                      '${_number(evaluation.muscleMassKg)} kg',
                                  progress: (evaluation.muscleMassKg / 80)
                                      .clamp(0, 1),
                                  status: 'Registrado',
                                ),
                                _BodyProgressRow(
                                  label: 'Agua corporal',
                                  value:
                                      '${_number(evaluation.bodyWaterPercent)}%',
                                  progress: (evaluation.bodyWaterPercent / 100)
                                      .clamp(0, 1),
                                  status: 'Registrado',
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
                                  'Otros indicadores',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                InfoRow(
                                  icon: Icons.scale,
                                  label: 'Grasa corporal',
                                  value: '${_number(evaluation.bodyFatKg)} kg',
                                ),
                                InfoRow(
                                  icon: Icons.fitness_center,
                                  label: 'Músculo esquelético',
                                  value:
                                      '${_number(evaluation.skeletalMuscleKg)} kg',
                                ),
                                InfoRow(
                                  icon: Icons.water_drop,
                                  label: 'Agua corporal',
                                  value:
                                      '${_number(evaluation.bodyWaterKg)} kg',
                                ),
                                InfoRow(
                                  icon: Icons.scale_outlined,
                                  label: 'Peso sin grasa',
                                  value:
                                      '${_number(evaluation.fatFreeMassKg)} kg',
                                ),
                                InfoRow(
                                  icon: Icons.bloodtype_outlined,
                                  label: 'Grasa visceral',
                                  value: '${evaluation.visceralFat}',
                                ),
                                InfoRow(
                                  icon: Icons.cake_outlined,
                                  label: 'Edad corporal',
                                  value: evaluation.bodyAge == 0
                                      ? '-'
                                      : '${evaluation.bodyAge}',
                                ),
                                InfoRow(
                                  icon: Icons.straighten,
                                  label: 'WHR',
                                  value: evaluation.whr == 0
                                      ? '-'
                                      : _number(evaluation.whr),
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

class _BodyMetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const _BodyMetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF59D52D), size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyControlRow extends StatelessWidget {
  final String label;
  final String value;

  const _BodyControlRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isPositive = value.startsWith('+');
    final isNegative = value.startsWith('-');

    Color color = const Color(0xFFF6F7F7);
    if (isPositive) color = const Color(0xFF59D52D);
    if (isNegative) color = const Color(0xFFD98200);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _BodyProgressRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final String status;

  const _BodyProgressRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFF59D52D),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF59D52D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
