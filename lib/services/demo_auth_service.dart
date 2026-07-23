import '../models/app_user.dart';

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

class DemoAuthService {
  static final List<_DemoCredential> _users = _demoUsers();

  static List<_DemoCredential> _demoUsers() => [
    _DemoCredential(
      user: const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
      password: '1234',
    ),
    _DemoCredential(
      user: const AppUser(
        id: 'admin_001',
        rut: '222222222',
        name: 'Administrador GYM',
        role: UserRole.admin,
      ),
      password: '1234',
    ),
  ];

  static void registerUser({required AppUser user, required String password}) {
    final normalizedRut = normalizeRut(user.rut);
    final exists = _users.any(
      (credential) => credential.user.rut == normalizedRut,
    );

    if (exists) {
      throw const AuthException('Ya existe un usuario con ese RUT');
    }

    _users.add(
      _DemoCredential(
        user: AppUser(
          id: user.id,
          rut: normalizedRut,
          name: user.name,
          role: user.role,
          isActive: user.isActive,
        ),
        password: password,
      ),
    );
  }

  static bool existsByRutExcludingUser({
    required String rut,
    required String userId,
  }) {
    final normalizedRut = normalizeRut(rut);
    return _users.any(
      (credential) =>
          credential.user.id != userId && credential.user.rut == normalizedRut,
    );
  }

  static void updateUser({
    required String userId,
    required String rut,
    required String name,
    bool isActive = true,
  }) {
    final normalizedRut = normalizeRut(rut);
    if (existsByRutExcludingUser(rut: normalizedRut, userId: userId)) {
      throw const AuthException('Ya existe un usuario con ese RUT');
    }

    final index = _users.indexWhere(
      (credential) => credential.user.id == userId,
    );
    if (index == -1) return;

    final oldCredential = _users[index];
    _users[index] = _DemoCredential(
      user: AppUser(
        id: oldCredential.user.id,
        rut: normalizedRut,
        name: name,
        role: oldCredential.user.role,
        isActive: isActive,
      ),
      password: oldCredential.password,
    );
  }

  static void resetToDemo() {
    _users
      ..clear()
      ..addAll(_demoUsers());
  }

  static Future<AppUser> login({
    required String rut,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final normalizedRut = normalizeRut(rut);
    final cleanPassword = password.trim();

    if (normalizedRut.isEmpty || cleanPassword.isEmpty) {
      throw const AuthException('Ingresa RUT y contraseña');
    }

    if (!isValidRut(normalizedRut)) {
      throw const AuthException('El RUT ingresado no es válido');
    }

    for (final credential in _users) {
      if (credential.user.rut == normalizedRut &&
          credential.password == cleanPassword) {
        if (!credential.user.isActive) {
          throw const AuthException('Usuario inactivo');
        }

        return credential.user;
      }
    }

    throw const AuthException('RUT o contraseña incorrectos');
  }

  static String normalizeRut(String rut) {
    return rut
        .replaceAll('.', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .toUpperCase()
        .trim();
  }

  static bool isValidRut(String rut) {
    final cleanRut = normalizeRut(rut);

    if (cleanRut.length < 2) return false;

    final body = cleanRut.substring(0, cleanRut.length - 1);
    final dv = cleanRut.substring(cleanRut.length - 1);

    if (int.tryParse(body) == null) return false;

    int sum = 0;
    int multiplier = 2;

    for (int i = body.length - 1; i >= 0; i--) {
      sum += int.parse(body[i]) * multiplier;
      multiplier++;

      if (multiplier > 7) multiplier = 2;
    }

    final result = 11 - (sum % 11);

    final String expectedDv;
    if (result == 11) {
      expectedDv = '0';
    } else if (result == 10) {
      expectedDv = 'K';
    } else {
      expectedDv = result.toString();
    }

    return dv == expectedDv;
  }
}

class _DemoCredential {
  final AppUser user;
  final String password;

  const _DemoCredential({required this.user, required this.password});
}
