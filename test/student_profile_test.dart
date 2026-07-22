import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/student_profile_store.dart';

void main() {
  setUp(StudentProfileStore.resetToDemo);
  tearDown(StudentProfileStore.resetToDemo);

  test('returns the profile associated with the demo student', () {
    final profile = DemoStudentProfileService.getByUserId('student_001');

    expect(profile, isNotNull);
    expect(profile!.name, 'Felipe Durán');
    expect(profile.plan, 'Plan 4 sesiones');
    expect(profile.weeklyAttendanceText, '1/4');
    expect(profile.weeklyAttendancePercent, 25);
    expect(profile.monthlyAttendanceText, '5/16');
    expect(profile.monthlyAttendancePercent, 31);
  });

  test('returns null when the user has no student profile', () {
    expect(DemoStudentProfileService.getByUserId('admin_001'), isNull);
    expect(DemoStudentProfileService.getByUserId(null), isNull);
  });
}
