import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/widgets/app_select_field.dart';
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

String formattedDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-${date.year}';
}

DateTime dateAfterMonths(DateTime date, int months) {
  final month = date.month + months;
  final year = date.year + (month - 1) ~/ 12;
  final normalizedMonth = (month - 1) % 12 + 1;
  final lastDay = DateTime(year, normalizedMonth + 1, 0).day;
  return DateTime(year, normalizedMonth, math.min(date.day, lastDay));
}

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
    await tester.enterText(fields.at(4), 'camila@correo.cl');
    await tester.tap(find.text('Seleccionar plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 3 sesiones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar duración'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mensual'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Seleccionar método de pago'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(AppSelectField).at(2), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Efectivo'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Guardar alumno');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Alumno registrado'), findsOneWidget);
    expect(
      find.textContaining('El alumno se ha registrado correctamente.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();

    final profile = StudentProfileStore.all.last;
    expect(profile.name, 'Camila Rojas');
    expect(profile.rut, '123456785');
    expect(profile.contractPeriod, 'Mensual');
    expect(profile.paymentMethod, 'Efectivo');
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
    expect(find.text('+56998765432'), findsOneWidget);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(find.text(formattedDate(today)), findsOneWidget);
    expect(find.text(formattedDate(dateAfterMonths(today, 1))), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sin evaluación corporal registrada.'),
      500,
      scrollable: find.byType(Scrollable).last,
    );
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
    await tester.enterText(fields.at(4), 'felipe.duplicado@correo.cl');
    await tester.tap(find.text('Seleccionar plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 3 sesiones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seleccionar duración'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mensual'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Seleccionar método de pago'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(AppSelectField).at(2), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Efectivo'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Guardar alumno');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('No se pudo registrar el alumno'), findsOneWidget);
    expect(
      find.textContaining('No se ha podido registrar el alumno.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Ya existe un alumno con ese RUT'),
      findsOneWidget,
    );
    expect(StudentProfileStore.all, hasLength(1));
  });

  testWidgets('web registration shows paired fields and plan price', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RegisterStudentScreen()));

    final fields = find.byType(TextField);
    expect(
      tester.getTopLeft(fields.at(0)).dy,
      tester.getTopLeft(fields.at(1)).dy,
    );
    expect(
      tester.getTopLeft(fields.at(2)).dy,
      tester.getTopLeft(fields.at(3)).dy,
    );
    expect(tester.widget<TextField>(fields.at(5)).readOnly, isTrue);
    expect(tester.widget<TextField>(fields.at(6)).readOnly, isTrue);
    await tester.tap(fields.at(5));
    await tester.pumpAndSettle();
    final calendar = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    final current = DateTime.now();
    expect(
      calendar.firstDate,
      DateTime(current.year, current.month, current.day),
    );
    await tester.tap(find.text('Cancelar').last);
    await tester.pumpAndSettle();
    final contractFields = find.byType(AppSelectField);
    expect(
      tester.getTopLeft(contractFields.at(0)).dy,
      tester.getTopLeft(contractFields.at(1)).dy,
    );
    final saveButton = find.widgetWithText(ElevatedButton, 'Guardar alumno');
    final cancelButton = find.widgetWithText(OutlinedButton, 'Cancelar');
    expect(
      tester.getTopLeft(saveButton).dy,
      tester.getTopLeft(cancelButton).dy,
    );
    expect(
      tester.getTopLeft(cancelButton).dx,
      lessThan(tester.getTopLeft(saveButton).dx),
    );
    expect(
      tester.getTopLeft(contractFields.at(2)).dy,
      lessThan(tester.getTopLeft(fields.at(5)).dy),
    );
    expect(find.text('Seleccionar plan'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Seleccionar duración'), findsOneWidget);
    expect(find.text('Seleccionar método de pago'), findsOneWidget);
    await tester.tap(find.text('Seleccionar duración'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trimestral'));
    await tester.pumpAndSettle();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    expect(
      tester.widget<TextField>(fields.at(6)).controller?.text,
      formattedDate(dateAfterMonths(today, 3)),
    );
    await tester.scrollUntilVisible(
      find.text('Seleccionar método de pago'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(AppSelectField).at(2), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Transferencia'), findsOneWidget);
    expect(find.text('Tarjeta débito/crédito'), findsOneWidget);
    expect(find.text('Webpay'), findsOneWidget);
    expect(find.text('Otro'), findsOneWidget);
    await tester.tap(find.text('Transferencia'));
    await tester.pumpAndSettle();
    expect(find.text('Transferencia'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Seleccionar plan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(AppSelectField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 2 sesiones').last);
    await tester.pumpAndSettle();

    expect(find.text('\$30.000'), findsOneWidget);
  });

  testWidgets('mobile registration shows the selected plan price', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RegisterStudentScreen()));

    expect(find.text('Valor'), findsOneWidget);
    expect(find.text('Seleccionar plan'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Seleccionar método de pago'), findsOneWidget);
    final mobileFields = find.byType(TextField);
    expect(tester.widget<TextField>(mobileFields.at(5)).readOnly, isTrue);
    expect(tester.widget<TextField>(mobileFields.at(6)).readOnly, isTrue);

    await tester.tap(mobileFields.at(5));
    await tester.pumpAndSettle();
    expect(find.text('Seleccionar fecha'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Aceptar'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Seleccionar plan'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byType(AppSelectField).first, warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 4 sesiones').last);
    await tester.pumpAndSettle();

    expect(find.text('\$55.000'), findsOneWidget);
  });

  testWidgets('web students list sorts, searches and filters by status', (
    tester,
  ) async {
    StudentProfileStore.add(newProfile);
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: StudentsListScreen()));

    expect(find.text('Nombre A-Z'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Camila Rojas')).dy,
      lessThan(tester.getTopLeft(find.text('Felipe Durán')).dy),
    );

    await tester.enterText(find.byType(TextField), 'Felipe');
    await tester.pump();
    expect(find.text('Felipe Durán'), findsOneWidget);
    expect(find.text('Camila Rojas'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.text('Todos los estados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Vencido').last);
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron alumnos'), findsOneWidget);
  });

  testWidgets('web students list paginates every 10 students', (tester) async {
    for (var index = 1; index <= 11; index++) {
      final number = index.toString().padLeft(2, '0');
      StudentProfileStore.add(
        StudentProfile(
          id: 'profile_$number',
          userId: 'user_$number',
          name: 'Alumno $number',
          rut: '1000000$number',
          phone: '+569 0000 00$number',
          plan: 'Plan 3 sesiones',
          status: 'Activo',
          startDate: '01-07-2026',
          endDate: '01-08-2026',
          daysRemaining: 30,
          weeklyAttendanceCompleted: 0,
          weeklyAttendanceTarget: 3,
          monthlyAttendanceCompleted: 0,
          monthlyAttendanceTarget: 12,
          bodyScore: 0,
          currentWeekLabel: 'Semana 1',
          currentWeekDates: '-',
        ),
      );
    }

    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: StudentsListScreen()));

    expect(find.text('Alumno 01'), findsOneWidget);
    expect(find.text('Alumno 11'), findsNothing);
    expect(find.text('Felipe Durán'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Alumno 10'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Alumno 10'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    expect(find.text('Alumno 01'), findsNothing);
    expect(find.text('Alumno 11'), findsOneWidget);
    expect(find.text('Felipe Durán'), findsOneWidget);
  });
}
