import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chartValues = [70.0, 72.5, 75.0, 80.0, 82.5];

    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Progreso',
              subtitle: 'Cargas, volumen y rendimiento',
              icon: Icons.bar_chart,
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
                            'Ejercicio destacado',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Press Banca Plano',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusChip(
                                text: '+12.5 kg',
                                background: const Color(0xFFDFF9EA),
                                textColor: const Color(0xFF12985C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Evolución de 1RM estimado últimos 3 meses',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(
                          child: MetricCard(
                            title: '1RM estimado',
                            value: '82.5',
                            subtitle: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Volumen total',
                            value: '10.2K',
                            subtitle: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Mejor serie',
                            value: '80x5',
                            subtitle: 'kg x reps',
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
                            'Evolución 1RM estimado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 210,
                            child: CustomPaint(
                              painter: ProgressChartPainter(chartValues),
                              child: Container(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('15 Abr', style: TextStyle(fontSize: 12)),
                              Text('30 Abr', style: TextStyle(fontSize: 12)),
                              Text('15 May', style: TextStyle(fontSize: 12)),
                              Text('30 May', style: TextStyle(fontSize: 12)),
                              Text('15 Jun', style: TextStyle(fontSize: 12)),
                            ],
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
                            'Mejores series',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _BestSetRow(
                            position: 1,
                            exercise: 'Press Banca Plano',
                            result: '82.5 kg x 5 reps',
                            date: '15 Jun 2026',
                          ),
                          _BestSetRow(
                            position: 2,
                            exercise: 'Press Banca Plano',
                            result: '80 kg x 5 reps',
                            date: '30 May 2026',
                          ),
                          _BestSetRow(
                            position: 3,
                            exercise: 'Press Banca Plano',
                            result: '75 kg x 6 reps',
                            date: '15 May 2026',
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
                            'Resumen de progreso',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.trending_up,
                            label: 'Subida de carga',
                            value: '+17.8%',
                          ),
                          InfoRow(
                            icon: Icons.calendar_month,
                            label: 'Sesiones registradas',
                            value: '15',
                          ),
                          InfoRow(
                            icon: Icons.bolt,
                            label: 'Consistencia',
                            value: 'Buena',
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

class _BestSetRow extends StatelessWidget {
  final int position;
  final String exercise;
  final String result;
  final String date;

  const _BestSetRow({
    required this.position,
    required this.exercise,
    required this.result,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFFE9F8F7),
            child: Text(
              '$position',
              style: const TextStyle(
                color: Color(0xFF20B2AA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(result, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ProgressChartPainter extends CustomPainter {
  final List<double> values;

  ProgressChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final axisPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF20B2AA)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF20B2AA)
      ..style = PaintingStyle.fill;

    final gridTextPainter = TextPainter(textDirection: TextDirection.ltr);

    const leftPadding = 36.0;
    const topPadding = 10.0;
    const bottomPadding = 28.0;
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final minValue = 60.0;
    final maxValue = 90.0;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + chartHeight * i / 3;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        axisPaint,
      );

      final labelValue = (maxValue - ((maxValue - minValue) * i / 3)).round();
      gridTextPainter.text = TextSpan(
        text: '$labelValue',
        style: const TextStyle(color: Colors.black45, fontSize: 11),
      );
      gridTextPainter.layout();
      gridTextPainter.paint(canvas, Offset(0, y - 7));
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = leftPadding + chartWidth * i / (values.length - 1);
      final normalized = (values[i] - minValue) / (maxValue - minValue);
      final y = topPadding + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, pointPaint);

      final valueText = TextPainter(
        text: TextSpan(
          text: values[i].toStringAsFixed(values[i] % 1 == 0 ? 0 : 1),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      valueText.layout();
      valueText.paint(canvas, Offset(points[i].dx - 12, points[i].dy - 24));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
