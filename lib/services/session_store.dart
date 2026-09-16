import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'body_evaluation_store.dart';
import 'firebase_auth_service.dart';
import 'routine_assignment_store.dart';
import 'student_profile_store.dart';
import 'student_workout_progress_store.dart';
import 'workout_history_store.dart';

class SessionStore {
  static AppUser? currentUser;
  static final ValueNotifier<AppUser?> userNotifier = ValueNotifier(null);

  static bool get isLoggedIn => currentUser != null;
  static bool get isStudent => currentUser?.role == UserRole.student;
  static bool get isAdmin => currentUser?.role == UserRole.admin;

  static void signIn(AppUser user) {
    currentUser = user;
    userNotifier.value = user;
  }

  static void updatePhotoData(String data) {
    final user = currentUser;
    if (user == null) return;
    signIn(user.withPhotoData(data));
  }

  static Future<AppUser?> restore() async {
    if (Firebase.apps.isEmpty) return currentUser;
    final user = await FirebaseAuthService.restoreCurrentUser();
    if (user == null) {
      currentUser = null;
      userNotifier.value = null;
      return null;
    }
    await loadDataFor(user);
    signIn(user);
    return user;
  }

  static Future<void> loadDataFor(AppUser user) async {
    if (user.role == UserRole.admin) {
      await StudentProfileStore.loadFromFirestore();
      await RoutineAssignmentStore.loadAllFromFirestore();
      await WorkoutHistoryStore.loadAllFromFirestore();
    } else {
      await StudentProfileStore.loadForUser(user.id);
      final profile = StudentProfileStore.getByUserId(user.id);
      await Future.wait([
        BodyEvaluationStore.loadForUser(user.id),
        RoutineAssignmentStore.loadForUser(user.id),
        WorkoutHistoryStore.loadForUser(user.id),
        StudentWorkoutProgressStore.loadForProfile(profile),
      ]);
    }
  }

  static Future<void> signOut() async {
    if (Firebase.apps.isNotEmpty) {
      await FirebaseAuth.instance.signOut();
    }
    currentUser = null;
    userNotifier.value = null;
  }
}
