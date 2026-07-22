import '../models/student_profile.dart';
import 'student_profile_store.dart';

class DemoStudentProfileService {
  static StudentProfile? getByUserId(String? userId) {
    return StudentProfileStore.getByUserId(userId);
  }

  static List<StudentProfile> get all => StudentProfileStore.all;
}
