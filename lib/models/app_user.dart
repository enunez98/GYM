enum UserRole { student, admin }

extension UserRoleExtension on UserRole {
  bool get isStudent => this == UserRole.student;
  bool get isAdmin => this == UserRole.admin;

  String get label {
    switch (this) {
      case UserRole.student:
        return 'Alumno';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class AppUser {
  final String id;
  final String rut;
  final String name;
  final UserRole role;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.rut,
    required this.name,
    required this.role,
    this.isActive = true,
  });
}
