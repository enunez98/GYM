class StudentProfile {
  final String id;
  final String userId;
  final String name;
  final String rut;
  final String phone;
  final String email;
  final String plan;
  final String contractPeriod;
  final String paymentMethod;
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
  final int createdAtEpoch;

  const StudentProfile({
    required this.id,
    required this.userId,
    required this.name,
    required this.rut,
    required this.phone,
    this.email = '',
    required this.plan,
    this.contractPeriod = 'Mensual',
    this.paymentMethod = '',
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
    this.createdAtEpoch = 0,
  });

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

  Map<String, Object?> toFirestore() => {
    'userId': userId,
    'name': name,
    'rut': rut,
    'phone': phone,
    'email': email,
    'plan': plan,
    'contractPeriod': contractPeriod,
    'paymentMethod': paymentMethod,
    'status': status,
    'startDate': startDate,
    'endDate': endDate,
    'daysRemaining': daysRemaining,
    'weeklyAttendanceCompleted': weeklyAttendanceCompleted,
    'weeklyAttendanceTarget': weeklyAttendanceTarget,
    'monthlyAttendanceCompleted': monthlyAttendanceCompleted,
    'monthlyAttendanceTarget': monthlyAttendanceTarget,
    'bodyScore': bodyScore,
    'currentWeekLabel': currentWeekLabel,
    'currentWeekDates': currentWeekDates,
    'createdAtEpoch': createdAtEpoch,
  };

  factory StudentProfile.fromFirestore(String id, Map<String, dynamic> data) {
    int number(String key) => (data[key] as num?)?.toInt() ?? 0;
    String text(String key) => data[key] as String? ?? '';

    return StudentProfile(
      id: id,
      userId: text('userId'),
      name: text('name'),
      rut: text('rut'),
      phone: text('phone'),
      email: text('email'),
      plan: text('plan'),
      contractPeriod: text('contractPeriod'),
      paymentMethod: text('paymentMethod'),
      status: text('status'),
      startDate: text('startDate'),
      endDate: text('endDate'),
      daysRemaining: number('daysRemaining'),
      weeklyAttendanceCompleted: number('weeklyAttendanceCompleted'),
      weeklyAttendanceTarget: number('weeklyAttendanceTarget'),
      monthlyAttendanceCompleted: number('monthlyAttendanceCompleted'),
      monthlyAttendanceTarget: number('monthlyAttendanceTarget'),
      bodyScore: number('bodyScore'),
      currentWeekLabel: text('currentWeekLabel'),
      currentWeekDates: text('currentWeekDates'),
      createdAtEpoch: number('createdAtEpoch'),
    );
  }
}
