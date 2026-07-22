import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/teacher/screens/register_student_screen.dart';
import 'package:gym_app/features/teacher/screens/students_list_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/student_profile.dart';
import 'package:gym_app/services/demo_auth_service.dart';
import 'package:gym_app/services/student_profile_store.dart';

const newProfile = StudentProfile(
  id: 'student_profile_test',
  userId: 'student_test',
  name: 'Camila Rojas',
  rut: '123456785',
  phone: '+569 9876 5432',
  plan: 'Plan 3 sesiones',
  status: 'Activo',
  startDate: '22-07-2026',
  endDate: '22-08-2026',
  daysRemaining: 31,
  weeklyAttendanceCompleted: 0,
  weeklyAttendanceTarget: 3,
  monthlyAttendanceCompleted: 0,
  monthlyAttendanceTarget: 12,
  bodyScore: 0,
  currentWeekLabel: 'Semana 1 - Ordinario',
  currentWeekDates: '-',
);

void main() {
  setUp(() {
    StudentProfileStore.resetToDemo();
    DemoAuthService.resetToDemo();
  });

  tearDown(() {
    StudentProfileStore.resetToDemo();
    DemoAuthService.resetToDemo();
  });

  test('profile store keeps demo and registered students', () {
    expect(StudentProfileStore.all, hasLength(1));
    expect(
      StudentProfileStore.getByUserId('student_001')?.name,
      'Felipe Durán',
    );

    StudentProfileStore.add(newProfile);

    expect(StudentProfileStore.all, hasLength(2));
    expect(StudentProfileStore.getById(newProfile.id), same(newProfile));
    expect(
      StudentProfileStore.getByUserId(newProfile.userId),
      same(newProfile),
    );
    expect(StudentProfileStore.existsByRut('12.345.678-5'), isTrue);
  });

  test('registered credential can log in and rejects duplicate RUT', () async {
    const user = AppUser(
      id: 'student_test',
      rut: '12.345.678-5',
      name: 'Camila Rojas',
      role: UserRole.student,
    );
    DemoAuthService.registerUser(user: user, password: '1234');

    final loggedIn = await DemoAuthService.login(
      rut: '12.345.678-5',
      password: '1234',
    );
    expect(loggedIn.name, 'Camila Rojas');
    expect(loggedIn.rut, '123456785');
    expect(loggedIn.role, UserRole.student);
    expect(
      () => DemoAuthService.registerUser(user: user, password: '1234'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Ya existe un usuario con ese RUT',
        ),
      ),
    );
  });

  testWidgets('admin registers student and opens their real detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const RegisterStudentScreen(),
                ),
              ),
              child: const Text('Registrar'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Camila');
    await tester.enterText(fields.at(1), 'Rojas');
    await tester.enterText(fields.at(2), '12.345.678-5');
    await tester.enterText(fields.at(3), '+569 9876 5432');
    await tester.enterText(fields.at(4), '22-07-2026');
    await tester.enterText(fields.at(5), '22-08-2026');

    final saveButton = find.text('Guardar alumno');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final profile = StudentProfileStore.all.last;
    expect(profile.name, 'Camila Rojas');
    expect(profile.rut, '123456785');
    expect(profile.weeklyAttendanceTarget, 3);
    expect(profile.monthlyAttendanceTarget, 12);
    final loginFuture = DemoAuthService.login(
      rut: profile.rut,
      password: '1234',
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect((await loginFuture).name, 'Camila Rojas');

    await tester.pumpWidget(const MaterialApp(home: StudentsListScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Felipe Durán'), findsOneWidget);
    expect(find.text('Camila Rojas'), findsOneWidget);

    await tester.tap(find.text('Camila Rojas'));
    await tester.pumpAndSettle();
    expect(find.text('12.345.678-5'), findsNothing);
    expect(find.text('123456785'), findsOneWidget);
    expect(find.text('+569 9876 5432'), findsOneWidget);
    expect(find.text('22-07-2026'), findsOneWidget);
    expect(find.text('22-08-2026'), findsOneWidget);
    expect(find.text('Sin evaluación corporal registrada.'), findsOneWidget);
  });

  testWidgets('registration rejects a duplicated student RUT', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RegisterStudentScreen()));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Felipe');
    await tester.enterText(fields.at(1), 'Duplicado');
    await tester.enterText(fields.at(2), '11.111.111-1');
    await tester.enterText(fields.at(3), '+569 1111 2222');

    final saveButton = find.text('Guardar alumno');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Ya existe un alumno con ese RUT'), findsOneWidget);
    expect(StudentProfileStore.all, hasLength(1));
  });
}
