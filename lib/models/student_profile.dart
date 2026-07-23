class StudentProfile {
  final String id;
  final String userId;
  final String name;
  final String rut;
  final String phone;
  final String plan;
  final String status;
  final String startDate;
  final String endDate;
  final int daysRemaining;
  final int weeklyAttendanceCompleted;
  final int weeklyAttendanceTarget;
  final int monthlyAttendanceCompleted;
  final int monthlyAttendanceTarget;
  final int bodyScore;
  final String currentWeekLabel;
  final String currentWeekDates;

  const StudentProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.rut,
    required this.phone,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.daysRemaining,
    required this.weeklyAttendanceCompleted,
    required this.weeklyAttendanceTarget,
    required this.monthlyAttendanceCompleted,
    required this.monthlyAttendanceTarget,
    required this.bodyScore,
    required this.currentWeekLabel,
    required this.currentWeekDates,
  });

  StudentProfile copyWith({
    String? id,
    String? userId,
    String? name,
    String? rut,
    String? phone,
    String? plan,
    String? status,
    String? startDate,
    String? endDate,
    int? daysRemaining,
    int? weeklyAttendanceCompleted,
    int? weeklyAttendanceTarget,
    int? monthlyAttendanceCompleted,
    int? monthlyAttendanceTarget,
    int? bodyScore,
    String? currentWeekLabel,
    String? currentWeekDates,
  }) {
    return StudentProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      rut: rut ?? this.rut,
      phone: phone ?? this.phone,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      weeklyAttendanceCompleted:
          weeklyAttendanceCompleted ?? this.weeklyAttendanceCompleted,
      weeklyAttendanceTarget:
          weeklyAttendanceTarget ?? this.weeklyAttendanceTarget,
      monthlyAttendanceCompleted:
          monthlyAttendanceCompleted ?? this.monthlyAttendanceCompleted,
      monthlyAttendanceTarget:
          monthlyAttendanceTarget ?? this.monthlyAttendanceTarget,
      bodyScore: bodyScore ?? this.bodyScore,
      currentWeekLabel: currentWeekLabel ?? this.currentWeekLabel,
      currentWeekDates: currentWeekDates ?? this.currentWeekDates,
    );
  }

  String get weeklyAttendanceText =>
      '$weeklyAttendanceCompleted/$weeklyAttendanceTarget';

  String get monthlyAttendanceText =>
      '$monthlyAttendanceCompleted/$monthlyAttendanceTarget';

  int get weeklyAttendancePercent {
    if (weeklyAttendanceTarget == 0) return 0;
    return ((weeklyAttendanceCompleted / weeklyAttendanceTarget) * 100).round();
  }

  int get monthlyAttendancePercent {
    if (monthlyAttendanceTarget == 0) return 0;
    return ((monthlyAttendanceCompleted / monthlyAttendanceTarget) * 100)
        .round();
  }
}
