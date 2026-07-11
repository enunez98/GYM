import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/profile_screen.dart';
import 'package:gym_app/features/student/screens/student_home_screen.dart';
import 'package:gym_app/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/services/session_store.dart';

void main() {
  tearDown(SessionStore.signOut);

  testWidgets('student home uses the logged-in user name', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: StudentHomeScreen(onStartWorkout: () {})),
    );

    expect(find.text('Hola, Felipe Durán 👋'), findsOneWidget);
  });

  testWidgets('student profile uses the logged-in name and RUT', (
    tester,
  ) async {
    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.text('Felipe Durán'), findsOneWidget);
    expect(find.text('RUT: 111111111'), findsOneWidget);
  });

  testWidgets('admin panel welcomes the logged-in administrator', (
    tester,
  ) async {
    SessionStore.signIn(
      const AppUser(
        id: 'admin_001',
        rut: '222222222',
        name: 'Administrador GYM',
        role: UserRole.admin,
      ),
    );

    await tester.pumpWidget(const MaterialApp(home: TeacherDashboardScreen()));

    expect(find.text('Panel Admin'), findsOneWidget);
    expect(find.text('Bienvenido, Administrador GYM'), findsOneWidget);
  });
}
