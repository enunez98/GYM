import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/app_user.dart';

class SessionStore {
  static AppUser? currentUser;

  static bool get isLoggedIn => currentUser != null;
  static bool get isStudent => currentUser?.role == UserRole.student;
  static bool get isAdmin => currentUser?.role == UserRole.admin;

  static void signIn(AppUser user) {
    currentUser = user;
  }

  static Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.signOut();
    }
    currentUser = null;
  }
}
