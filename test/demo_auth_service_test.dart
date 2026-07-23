import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/services/demo_auth_service.dart';

void main() {
  setUp(DemoAuthService.resetToDemo);
  tearDown(DemoAuthService.resetToDemo);

  test('normalizes and validates demo RUT values', () {
    expect(DemoAuthService.normalizeRut('11.111.111-1'), '111111111');
    expect(DemoAuthService.isValidRut('11.111.111-1'), isTrue);
    expect(DemoAuthService.isValidRut('22.222.222-2'), isTrue);
    expect(DemoAuthService.isValidRut('11.111.111-2'), isFalse);
  });

  test('logs in the demo student', () async {
    final user = await DemoAuthService.login(
      rut: '11.111.111-1',
      password: '1234',
    );

    expect(user.role, UserRole.student);
    expect(user.name, 'Felipe Durán');
  });

  test('logs in the demo admin', () async {
    final user = await DemoAuthService.login(
      rut: '22.222.222-2',
      password: '1234',
    );

    expect(user.role, UserRole.admin);
  });

  test('rejects an incorrect password', () async {
    expect(
      () => DemoAuthService.login(rut: '11.111.111-1', password: 'incorrecta'),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'RUT o contraseña incorrectos',
        ),
      ),
    );
  });

  test('updates student name and RUT while preserving the password', () async {
    DemoAuthService.updateUser(
      userId: 'student_001',
      rut: '12.345.678-5',
      name: 'Felipe Actualizado',
    );

    final updated = await DemoAuthService.login(
      rut: '12.345.678-5',
      password: '1234',
    );
    expect(updated.name, 'Felipe Actualizado');
    expect(updated.id, 'student_001');
    expect(
      () => DemoAuthService.login(rut: '11.111.111-1', password: '1234'),
      throwsA(isA<AuthException>()),
    );
  });

  test('does not allow changing a student to another credential RUT', () {
    expect(
      () => DemoAuthService.updateUser(
        userId: 'student_001',
        rut: '22.222.222-2',
        name: 'Felipe Durán',
      ),
      throwsA(
        isA<AuthException>().having(
          (error) => error.message,
          'message',
          'Ya existe un usuario con ese RUT',
        ),
      ),
    );
  });
}
