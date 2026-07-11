import '../models/app_user.dart';

class SessionStore {
  static AppUser? currentUser;

  static bool get isLoggedIn => currentUser != null;
  static bool get isStudent => currentUser?.role == UserRole.student;
  static bool get isAdmin => currentUser?.role == UserRole.admin;

  static void signIn(AppUser user) {
    currentUser = user;
  }

  static void signOut() {
    currentUser = null;
  }
}
