import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/widgets/student_avatar.dart';
import 'package:gym_app/features/student/screens/home_shell.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/services/profile_photo_service.dart';
import 'package:gym_app/services/session_store.dart';

void main() {
  tearDown(SessionStore.signOut);

  test('usa primer nombre y primer apellido para las iniciales', () {
    expect(studentInitials('Felipe Durán'), 'FD');
    expect(studentInitials('Juan Carlos Pérez González'), 'JP');
    expect(studentInitials('  Ana   Soto  '), 'AS');
  });

  test('acepta solo firmas PNG y JPEG dentro del límite', () {
    expect(
      ProfilePhotoService.imageContentType(
        Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
      ),
      'image/png',
    );
    expect(
      ProfilePhotoService.imageContentType(
        Uint8List.fromList([0xFF, 0xD8, 0xFF]),
      ),
      'image/jpeg',
    );
    expect(
      ProfilePhotoService.imageContentType(Uint8List.fromList([1, 2, 3])),
      isNull,
    );
    expect(
      ProfilePhotoService.imageContentType(
        Uint8List(ProfilePhotoService.maxBytes + 1),
      ),
      isNull,
    );
  });

  testWidgets('reduce una foto a una miniatura ligera', (tester) async {
    final thumbnail = await tester.runAsync(() async {
      final asset = await rootBundle.load(
        'assets/images/student_home_workout.png',
      );
      final bytes = asset.buffer.asUint8List(
        asset.offsetInBytes,
        asset.lengthInBytes,
      );
      return ProfilePhotoService.makeThumbnail(bytes);
    });
    expect(thumbnail, isNotNull);
    expect(
      thumbnail!.length,
      lessThanOrEqualTo(ProfilePhotoService.maxStoredBytes),
    );
    expect(ProfilePhotoService.imageContentType(thumbnail), 'image/png');
  });

  testWidgets('muestra iniciales en perfil y navegación sin foto', (
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
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeShell()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perfil').last);
    await tester.pumpAndSettle();

    expect(find.text('Cambiar foto'), findsOneWidget);
    expect(find.text('PNG o JPEG · máximo 2 MB'), findsOneWidget);
    expect(find.text('FD'), findsWidgets);
    expect(find.byType(StudentAvatar), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
