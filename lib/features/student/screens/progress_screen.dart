import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../services/session_store.dart';
import '../../../services/workout_progress_service.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final summary = WorkoutProgressService.getSummaryByUserId(user?.id);
    final hasProgress = summary.hasData;
    final chartValues = summary.oneRmTrend;

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
                              Expanded(
                                child: Text(
                                  hasProgress
                                      ? summary.bestExerciseName
                                      : 'Sin entrenamientos guardados',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              StatusChip(
                                text: hasProgress ? 'Real' : 'Pendiente',
                                background: hasProgress
                                    ? const Color(0xFFDFF9EA)
                                    : const Color(0xFFFFF2D9),
                                textColor: hasProgress
                                    ? const Color(0xFF12985C)
                                    : const Color(0xFFD98200),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            hasProgress
                                ? 'Calculado desde tus entrenamientos guardados'
                                : 'Guarda un entrenamiento para generar progreso',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: '1RM estimado',
                            value: hasProgress
                                ? WorkoutProgressService.formatKg(
                                    summary.bestEstimatedOneRm,
                                  )
                                : '-',
                            subtitle: 'kg',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Volumen total',
                            value: WorkoutProgressService.formatVolume(
                              summary.totalVolume,
                            ),
                            subtitle: 'kg',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Mejor serie',
                            value: summary.bestSetText,
                            subtitle: 'kg x reps',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (chartValues.isNotEmpty)
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
                            const Text(
                              'Cada punto representa el mejor 1RM estimado de un entrenamiento guardado.',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Evolución 1RM estimado',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Aún no hay datos suficientes para mostrar el gráfico.',
                              style: TextStyle(color: Colors.black54),
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
                            'Mejores series',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (summary.bestSets.isEmpty)
                            const Text(
                              'Todavía no hay series registradas.',
                              style: TextStyle(color: Colors.black54),
                            )
                          else
                            for (
                              int i = 0;
                              i < summary.bestSets.take(5).length;
                              i++
                            )
                              _BestSetRow(
                                position: i + 1,
                                exercise: summary.bestSets[i].exerciseName,
                                result:
                                    '${summary.bestSets[i].resultText} · 1RM ${WorkoutProgressService.formatKg(summary.bestSets[i].estimatedOneRm)} kg',
                                date: WorkoutProgressService.formatDate(
                                  summary.bestSets[i].date,
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
                            'Resumen de progreso',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.calendar_month,
                            label: 'Sesiones completadas',
                            value: '${summary.completedSessions}',
                          ),
                          InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Series registradas',
                            value: '${summary.totalSets}',
                          ),
                          InfoRow(
                            icon: Icons.bolt,
                            label: 'Volumen acumulado',
                            value:
                                '${WorkoutProgressService.formatVolume(summary.totalVolume)} kg',
                          ),
                          InfoRow(
                            icon: Icons.history,
                            label: 'Último entrenamiento',
                            value: summary.lastCompletedWorkout == null
                                ? '-'
                                : summary.lastCompletedWorkout!.sessionTitle,
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

    const leftPadding = 42.0;
    const topPadding = 18.0;
    const bottomPadding = 28.0;
    const rightPadding = 14.0;
    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    final minRaw = values.reduce(math.min);
    final maxRaw = values.reduce(math.max);
    final rawRange = (maxRaw - minRaw).abs();
    final range = rawRange < 1 ? 10.0 : rawRange;
    final minValue = math.max(0, minRaw - range * 0.20);
    final maxValue = maxRaw + range * 0.20;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + chartHeight * i / 3;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        axisPaint,
      );
      final labelValue = maxValue - ((maxValue - minValue) * i / 3);
      gridTextPainter.text = TextSpan(
        text: WorkoutProgressService.formatKg(labelValue),
        style: const TextStyle(color: Colors.black45, fontSize: 11),
      );
      gridTextPainter.layout();
      gridTextPainter.paint(canvas, Offset(0, y - 7));
    }

    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + chartWidth * i / (values.length - 1);
      final normalized = (values[i] - minValue) / (maxValue - minValue);
      final y = topPadding + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, pointPaint);
      final valueText = TextPainter(
        text: TextSpan(
          text: WorkoutProgressService.formatKg(values[i]),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valueText.layout();
      valueText.paint(canvas, Offset(points[i].dx - 14, points[i].dy - 24));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
