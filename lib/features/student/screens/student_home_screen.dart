import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../services/imported_routine_store.dart';
import '../../../services/session_store.dart';

class StudentHomeScreen extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const StudentHomeScreen({super.key, required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _Header(),
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
                    const _WeekCard(),
                    const SizedBox(height: 14),
                    const _AttendanceCards(),
                    const SizedBox(height: 14),
                    _NextWorkoutCard(onStartWorkout: onStartWorkout),
                    const SizedBox(height: 14),
                    const _BodySummaryCard(),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final userName = user?.name ?? 'Alumno';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF20B2AA),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $userName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Plan: 3 sesiones por semana',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          StatusChip(
            text: 'Activo',
            background: Color(0xFF173D35),
            textColor: Color(0xFF7CFFC4),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Semana actual', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Semana 2 - Ordinario',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              StatusChip(
                text: 'CARGA',
                background: const Color(0xFFDFF9EA),
                textColor: const Color(0xFF12985C),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.calendar_month, size: 17, color: Colors.black45),
              SizedBox(width: 6),
              Text(
                '06 Jul - 12 Jul 2026',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceCards extends StatelessWidget {
  const _AttendanceCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: MetricCard(
            title: 'Asistencia semanal',
            value: '1/3',
            subtitle: '33%',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: MetricCard(
            title: 'Asistencia mensual',
            value: '5/12',
            subtitle: '42%',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: MetricCard(
            title: 'Días restantes',
            value: '18',
            subtitle: 'días',
          ),
        ),
      ],
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const _NextWorkoutCard({required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    final importedSession = ImportedRoutineStore.sessions.isNotEmpty
        ? ImportedRoutineStore.sessions.first
        : null;

    final sessionTitle = importedSession != null
        ? importedSession.title
        : 'Sesión 1';

    final sessionSubtitle = importedSession != null
        ? '${importedSession.session} · ${importedSession.exercises.length} ejercicios'
        : 'Pecho - Tríceps';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Próxima clase', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            sessionTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.fitness_center, size: 17, color: Colors.black45),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sessionSubtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
          if (importedSession != null) ...[
            const SizedBox(height: 10),
            StatusChip(
              text: 'Desde Excel',
              background: const Color(0xFFDFF9EA),
              textColor: const Color(0xFF12985C),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onStartWorkout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Comenzar entrenamiento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.play_arrow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodySummaryCard extends StatelessWidget {
  const _BodySummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen rápido',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          InfoRow(
            icon: Icons.score,
            label: 'Última evaluación',
            value: '72/100',
            chip: true,
          ),
          const InfoRow(
            icon: Icons.monitor_weight,
            label: 'Peso actual',
            value: '70.0 kg',
          ),
          const InfoRow(
            icon: Icons.percent,
            label: 'Grasa corporal',
            value: '21.7%',
          ),
          const InfoRow(
            icon: Icons.accessibility_new,
            label: 'Masa muscular',
            value: '51.2 kg',
          ),
        ],
      ),
    );
  }
}
