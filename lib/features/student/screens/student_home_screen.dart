import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../services/demo_student_profile_service.dart';
import '../../../services/session_store.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_routine_service.dart';

class StudentHomeScreen extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const StudentHomeScreen({super.key, required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF00111F),
      child: SafeArea(
        child: Column(
          children: [
            const _Header(),
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
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final userName = profile?.name ?? user?.name ?? 'Alumno';
    final plan = profile?.plan ?? 'Plan no asignado';
    final status = profile?.status ?? 'Activo';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF59D52D),
            child: Icon(Icons.person, color: Color(0xFF111214)),
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
                Text(
                  'Plan: $plan',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          StatusChip(
            text: status,
            background: const Color(0xFF00563F),
            textColor: const Color(0xFFD8FFE6),
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
    final user = SessionStore.currentUser;
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final weekLabel = profile?.currentWeekLabel ?? 'Semana actual';
    final weekDates = profile?.currentWeekDates ?? '-';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semana actual',
            style: TextStyle(color: Color(0xFF616B76)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  weekLabel,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusChip(
                text: 'CARGA',
                background: const Color(0xFFEDF9E8),
                textColor: const Color(0xFF59D52D),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 17,
                color: Color(0xFF616B76),
              ),
              const SizedBox(width: 6),
              Text(weekDates, style: const TextStyle(color: Color(0xFF616B76))),
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
    final user = SessionStore.currentUser;
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final attendance = StudentAttendanceService.getSummary(profile);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Asistencia semanal',
                value: attendance.weeklyText,
                subtitle: '${attendance.weeklyPercent}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                title: 'Asistencia mensual',
                value: attendance.monthlyText,
                subtitle: '${attendance.monthlyPercent}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                title: 'Días restantes',
                value: '${attendance.daysRemaining}',
                subtitle: 'días',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AppCard(
          child: Row(
            children: [
              Expanded(
                child: _AttendanceMiniItem(
                  icon: Icons.check_circle_outline,
                  label: 'Completadas',
                  value: '${attendance.weeklyCompleted}',
                ),
              ),
              Expanded(
                child: _AttendanceMiniItem(
                  icon: Icons.skip_next_outlined,
                  label: 'Omitidas',
                  value: '${attendance.weeklySkipped}',
                ),
              ),
              Expanded(
                child: _AttendanceMiniItem(
                  icon: Icons.pending_actions_outlined,
                  label: 'Pendientes',
                  value: '${attendance.pendingSessions}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceMiniItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AttendanceMiniItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF59D52D), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
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
    final user = SessionStore.currentUser;
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final assignedSession = StudentRoutineService.getCurrentSession(profile);
    final totalSessions = StudentRoutineService.getTotalSessionsForCurrentWeek(
      profile,
    );
    final currentSessionNumber = StudentRoutineService.getCurrentSessionNumber(
      profile,
    );
    final weekFinished = StudentRoutineService.isCurrentWeekFinished(profile);
    final hasAssignedRoutine = assignedSession != null;
    final sessionTitle = weekFinished
        ? 'Semana completada'
        : hasAssignedRoutine
        ? assignedSession.title
        : 'Sesión pendiente';
    final sessionSubtitle = weekFinished
        ? 'Ya completaste u omitiste todas las sesiones de esta semana'
        : hasAssignedRoutine
        ? 'Sesión $currentSessionNumber de $totalSessions · ${assignedSession.exercises.length} ejercicios'
        : 'Aún no hay rutina asignada para este plan';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próxima clase',
            style: TextStyle(color: Color(0xFF616B76)),
          ),
          const SizedBox(height: 6),
          Text(
            sessionTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 17,
                color: Color(0xFF616B76),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sessionSubtitle,
                  style: const TextStyle(color: Color(0xFF616B76)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StatusChip(
            text: weekFinished
                ? 'Semana lista'
                : hasAssignedRoutine
                ? 'Rutina asignada'
                : 'Sin rutina',
            background: weekFinished || hasAssignedRoutine
                ? const Color(0xFFEDF9E8)
                : const Color(0xFFFFF2D9),
            textColor: weekFinished || hasAssignedRoutine
                ? const Color(0xFF59D52D)
                : const Color(0xFFD98200),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59D52D),
                foregroundColor: const Color(0xFF111214),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: hasAssignedRoutine ? onStartWorkout : null,
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
