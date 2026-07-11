import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';

class BodyEvaluationScreen extends StatelessWidget {
  const BodyEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
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
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Última evaluación',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '26 May 2026',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusChip(
                                text: 'Estándar',
                                background: const Color(0xFFDFF9EA),
                                textColor: const Color(0xFF12985C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '72',
                                style: TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF20B2AA),
                                ),
                              ),
                              SizedBox(width: 4),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '/100 puntos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              value: 0.72,
                              minHeight: 12,
                              backgroundColor: Color(0xFFE5E7EB),
                              color: Color(0xFF20B2AA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.monitor_weight,
                            title: 'Peso',
                            value: '70.0',
                            unit: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.percent,
                            title: 'Grasa',
                            value: '21.7',
                            unit: '%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.accessibility_new,
                            title: 'Masa muscular',
                            value: '51.2',
                            unit: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.water_drop_outlined,
                            title: 'Agua corporal',
                            value: '57.4',
                            unit: '%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.health_and_safety_outlined,
                            title: 'IMC',
                            value: '22.9',
                            unit: '',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.local_fire_department_outlined,
                            title: 'Metabolismo',
                            value: '1553',
                            unit: 'kcal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Control recomendado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _BodyControlRow(
                            label: 'Peso objetivo',
                            value: '67.5 kg',
                          ),
                          _BodyControlRow(
                            label: 'Control de peso',
                            value: '-2.5 kg',
                          ),
                          _BodyControlRow(
                            label: 'Control de grasa',
                            value: '-5.0 kg',
                          ),
                          _BodyControlRow(
                            label: 'Control muscular',
                            value: '+2.5 kg',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Indicadores principales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _BodyProgressRow(
                            label: 'IMC',
                            value: '22.9',
                            progress: 0.55,
                            status: 'Estándar',
                          ),
                          _BodyProgressRow(
                            label: 'Grasa corporal',
                            value: '21.7%',
                            progress: 0.62,
                            status: 'Estándar',
                          ),
                          _BodyProgressRow(
                            label: 'Masa muscular',
                            value: '51.2 kg',
                            progress: 0.73,
                            status: 'Estándar',
                          ),
                          _BodyProgressRow(
                            label: 'Agua corporal',
                            value: '57.4%',
                            progress: 0.70,
                            status: 'Estándar',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Otros indicadores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.bloodtype_outlined,
                            label: 'Grasa visceral',
                            value: '5',
                          ),
                          InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Músculo esquelético',
                            value: '30.9 kg',
                          ),
                          InfoRow(
                            icon: Icons.scale_outlined,
                            label: 'Peso sin grasa',
                            value: '54.9 kg',
                          ),
                          InfoRow(
                            icon: Icons.cake_outlined,
                            label: 'Edad corporal',
                            value: '31',
                          ),
                          InfoRow(
                            icon: Icons.straighten,
                            label: 'WHR',
                            value: '0.84',
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
          Icon(icon, color: const Color(0xFF20B2AA), size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
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
                      color: Colors.black54,
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

    Color color = Colors.black87;
    if (isPositive) color = const Color(0xFF12985C);
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
              color: const Color(0xFF20B2AA),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF12985C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
