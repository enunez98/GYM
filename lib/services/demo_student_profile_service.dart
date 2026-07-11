import '../models/student_profile.dart';

class DemoStudentProfileService {
  static const List<StudentProfile> _profiles = [
    StudentProfile(
      id: 'student_profile_001',
      userId: 'student_001',
      name: 'Felipe Durán',
      rut: '111111111',
      phone: '+569 1234 5678',
      plan: 'Plan 4 sesiones',
      status: 'Activo',
      startDate: '04-07-2026',
      endDate: '04-08-2026',
      daysRemaining: 18,
      weeklyAttendanceCompleted: 1,
      weeklyAttendanceTarget: 4,
      monthlyAttendanceCompleted: 5,
      monthlyAttendanceTarget: 16,
      bodyScore: 72,
      currentWeekLabel: 'Semana 2 - Ordinario',
      currentWeekDates: '06 Jul - 12 Jul 2026',
    ),
  ];

  static StudentProfile? getByUserId(String? userId) {
    if (userId == null) return null;

    for (final profile in _profiles) {
      if (profile.userId == userId) return profile;
    }

    return null;
  }
}
