import '../models/student_profile.dart';

class StudentProfileStore {
  static const StudentProfile _demoProfile = StudentProfile(
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
  );

  static final List<StudentProfile> _profiles = [_demoProfile];

  static List<StudentProfile> get all => List.unmodifiable(_profiles);

  static StudentProfile? getByUserId(String? userId) {
    if (userId == null || userId.isEmpty) return null;

    for (final profile in _profiles) {
      if (profile.userId == userId) return profile;
    }
    return null;
  }

  static StudentProfile? getById(String? id) {
    if (id == null || id.isEmpty) return null;

    for (final profile in _profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  static bool existsByRut(String rut) {
    final normalizedRut = _normalizeRut(rut);
    return _profiles.any(
      (profile) => _normalizeRut(profile.rut) == normalizedRut,
    );
  }

  static void add(StudentProfile profile) {
    _profiles.add(profile);
  }

  static void clearAll() {
    _profiles.clear();
  }

  static void resetToDemo() {
    _profiles
      ..clear()
      ..add(_demoProfile);
  }

  static String _normalizeRut(String rut) {
    return rut
        .replaceAll('.', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toUpperCase()
        .trim();
  }
}
