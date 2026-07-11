import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';

void main() {
  test('returns the profile associated with the demo student', () {
    final profile = DemoStudentProfileService.getByUserId('student_001');

    expect(profile, isNotNull);
    expect(profile!.name, 'Felipe Durán');
    expect(profile.plan, 'Plan 3 sesiones');
    expect(profile.weeklyAttendanceText, '1/3');
    expect(profile.weeklyAttendancePercent, 33);
    expect(profile.monthlyAttendanceText, '5/12');
    expect(profile.monthlyAttendancePercent, 42);
  });

  test('returns null when the user has no student profile', () {
    expect(DemoStudentProfileService.getByUserId('admin_001'), isNull);
    expect(DemoStudentProfileService.getByUserId(null), isNull);
  });
}
