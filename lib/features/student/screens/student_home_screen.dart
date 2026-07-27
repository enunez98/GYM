import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../services/demo_student_profile_service.dart';
import '../../../services/session_store.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_routine_service.dart';

class StudentHomeScreen extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const StudentHomeScreen({super.key, required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 900) {
      return _WebStudentHome(onStartWorkout: onStartWorkout);
    }

    return Container(
      color: const Color(0xFF111214),
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

class _WebStudentHome extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const _WebStudentHome({required this.onStartWorkout});

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final attendance = StudentAttendanceService.getSummary(profile);
    final assignedSession = StudentRoutineService.getCurrentSession(profile);
    final totalSessions = StudentRoutineService.getTotalSessionsForCurrentWeek(
      profile,
    );
    final currentSessionNumber = StudentRoutineService.getCurrentSessionNumber(
      profile,
    );
    final weekFinished = StudentRoutineService.isCurrentWeekFinished(profile);
    final hasAssignedRoutine = assignedSession != null;
    final userName = profile?.name ?? user?.name ?? 'Alumno';
    final plan = profile?.plan ?? 'Plan no asignado';
    final sessionTitle = weekFinished
        ? 'Semana completada'
        : hasAssignedRoutine
        ? assignedSession.title
        : 'Sesión pendiente';
    final sessionSubtitle = weekFinished
        ? 'Todas las sesiones de esta semana fueron completadas'
        : hasAssignedRoutine
        ? 'Sesión $currentSessionNumber de $totalSessions · ${assignedSession.exercises.length} ejercicios'
        : 'Aún no hay rutina asignada para este plan';

    return ColoredBox(
      color: const Color(0xFF111214),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF59D52D),
                    child: Icon(Icons.person, color: Color(0xFF07111D)),
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
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    text: profile?.status ?? 'Activo',
                    background: const Color(0xFF16422A),
                    textColor: const Color(0xFFD8FFE6),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F5F6),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _WebAttendanceMetric(
                            icon: Icons.fitness_center_rounded,
                            title: 'Asistencia semanal',
                            value: attendance.weeklyText,
                            percent: attendance.weeklyPercent,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _WebAttendanceMetric(
                            icon: Icons.fitness_center_rounded,
                            title: 'Asistencia mensual',
                            value: attendance.monthlyText,
                            percent: attendance.monthlyPercent,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: _WebAttendanceMetric(
                            icon: Icons.event_available_outlined,
                            title: 'Días restantes',
                            value: '${attendance.daysRemaining}',
                            suffix: 'días',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 22,
                      ),
                      webContentMaxWidth: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            child: _WebAttendanceStatus(
                              icon: Icons.check_circle_outline,
                              value: attendance.weeklyCompleted,
                              label: 'Completadas',
                            ),
                          ),
                          const _WebVerticalDivider(),
                          Expanded(
                            child: _WebAttendanceStatus(
                              icon: Icons.skip_next_outlined,
                              value: attendance.weeklySkipped,
                              label: 'Omitidas',
                            ),
                          ),
                          const _WebVerticalDivider(),
                          Expanded(
                            child: _WebAttendanceStatus(
                              icon: Icons.pending_actions_outlined,
                              value: attendance.pendingSessions,
                              label: 'Pendientes',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
                      webContentMaxWidth: double.infinity,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PRÓXIMA CLASE',
                                  style: TextStyle(
                                    color: Color(0xFF25303A),
                                    fontSize: 13,
                                    letterSpacing: .8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  sessionTitle,
                                  style: const TextStyle(
                                    color: Color(0xFF07111D),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.call_made_rounded,
                                      color: Color(0xFF616B76),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        sessionSubtitle,
                                        style: const TextStyle(
                                          color: Color(0xFF616B76),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
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
                                      ? const Color(0xFF4AC51F)
                                      : const Color(0xFFD98200),
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: 360,
                                  height: 56,
                                  child: ElevatedButton.icon(
                                    onPressed: hasAssignedRoutine
                                        ? onStartWorkout
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF71E000),
                                      foregroundColor: const Color(0xFF07111D),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                    ),
                                    iconAlignment: IconAlignment.end,
                                    icon: const Icon(Icons.play_arrow_rounded),
                                    label: const Text(
                                      'Comenzar entrenamiento',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 28),
                          const Expanded(
                            flex: 2,
                            child: _WorkoutIllustration(),
                          ),
                        ],
                      ),
                    ),
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

class _WebAttendanceMetric extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final int? percent;
  final String? suffix;

  const _WebAttendanceMetric({
    required this.icon,
    required this.title,
    required this.value,
    this.percent,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 158),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAEC)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF9E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF4AC51F), size: 29),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF616B76),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF07111D),
                    fontSize: 30,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (percent != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percent!.clamp(0, 100) / 100,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFF0F2F3),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFF59D52D),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Color(0xFF4AC51F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 13),
                  Text(
                    suffix ?? '',
                    style: const TextStyle(
                      color: Color(0xFF4AC51F),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebAttendanceStatus extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _WebAttendanceStatus({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF9E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF4AC51F), size: 27),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF3FB52A),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF616B76), fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}

class _WebVerticalDivider extends StatelessWidget {
  const _WebVerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 76, color: const Color(0xFFE7EAEC));
  }
}

class _WorkoutIllustration extends StatelessWidget {
  const _WorkoutIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Image.asset(
        'assets/images/student_home_workout.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel:
            'Ilustración de implementos y planificación de entrenamiento',
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
          ResponsiveActionButton(
            child: SizedBox(
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
                    Flexible(
                      child: Text(
                        'Comenzar entrenamiento',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.play_arrow),
                  ],
                ),
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
