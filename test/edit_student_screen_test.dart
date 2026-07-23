import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/teacher/screens/edit_student_screen.dart';
import 'package:gym_app/features/teacher/screens/students_list_screen.dart';
import 'package:gym_app/models/student_profile.dart';
import 'package:gym_app/services/demo_auth_service.dart';
import 'package:gym_app/services/student_profile_store.dart';

void main() {
  setUp(() {
    StudentProfileStore.resetToDemo();
    DemoAuthService.resetToDemo();
  });

  tearDown(() {
    StudentProfileStore.resetToDemo();
    DemoAuthService.resetToDemo();
  });

  testWidgets('edits profile and login credentials without changing userId', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final original = StudentProfileStore.getById('student_profile_001')!;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (_) => EditStudentScreen(profile: original),
                ),
              ),
              child: const Text('Abrir edición'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir edición'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Felipe Actualizado');
    await tester.enterText(fields.at(1), '12.345.678-5');
    await tester.enterText(fields.at(2), '+569 9999 8888');
    await tester.enterText(fields.at(3), '22-07-2026');
    await tester.enterText(fields.at(4), '22-08-2026');

    final planDropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.tap(planDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 3 sesiones').last);
    await tester.pumpAndSettle();

    final saveButton = find.text('Guardar cambios');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final updated = StudentProfileStore.getById(original.id)!;
    expect(updated.userId, original.userId);
    expect(updated.name, 'Felipe Actualizado');
    expect(updated.rut, '123456785');
    expect(updated.phone, '+569 9999 8888');
    expect(updated.plan, 'Plan 3 sesiones');
    expect(updated.weeklyAttendanceTarget, 3);
    expect(updated.monthlyAttendanceTarget, 12);
    expect(updated.startDate, '22-07-2026');
    expect(updated.endDate, '22-08-2026');

    final loginFuture = DemoAuthService.login(
      rut: '12.345.678-5',
      password: '1234',
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect((await loginFuture).name, 'Felipe Actualizado');

    final oldLoginExpectation = expectLater(
      DemoAuthService.login(rut: '11.111.111-1', password: '1234'),
      throwsA(isA<AuthException>()),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await oldLoginExpectation;
  });

  testWidgets('rejects a RUT used by another student', (tester) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const anotherProfile = StudentProfile(
      id: 'student_profile_002',
      userId: 'student_002',
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
    StudentProfileStore.add(anotherProfile);
    final felipe = StudentProfileStore.getById('student_profile_001')!;

    await tester.pumpWidget(
      MaterialApp(home: EditStudentScreen(profile: felipe)),
    );
    await tester.enterText(find.byType(TextField).at(1), '12.345.678-5');
    final saveButton = find.text('Guardar cambios');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pump();

    expect(find.text('Ya existe otro alumno con ese RUT'), findsOneWidget);
    expect(StudentProfileStore.getById(felipe.id)?.rut, felipe.rut);
  });

  testWidgets('detail and list refresh after editing the selected student', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: StudentsListScreen()));
    await tester.tap(find.text('Felipe Durán'));
    await tester.pumpAndSettle();

    final editAction = find.text('Editar datos del alumno');
    await tester.scrollUntilVisible(
      editAction,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(editAction);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Felipe Lista');
    final saveButton = find.text('Guardar cambios');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Felipe Lista'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Felipe Lista'), findsOneWidget);
    expect(find.text('Felipe Durán'), findsNothing);
  });
}
