// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_app/app.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/services/session_store.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GymApp());
    await tester.pumpAndSettle();

    expect(
      find.bySemanticsLabel('NexFit — Tu fuerza. Tu mejor versión.'),
      findsOneWidget,
    );
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });

  testWidgets('restores an active user and returns to login after sign out', (
    WidgetTester tester,
  ) async {
    SessionStore.signIn(
      const AppUser(
        id: 'admin_test',
        rut: '',
        name: 'Administrador de prueba',
        role: UserRole.admin,
      ),
    );
    addTearDown(SessionStore.signOut);

    await tester.pumpWidget(const GymApp());
    await tester.pumpAndSettle();
    expect(find.text('Panel Admin'), findsOneWidget);

    await SessionStore.signOut();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const GymApp());
    await tester.pumpAndSettle();
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });

  testWidgets('desktop login fits without scrolling', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GymApp());
    await tester.pump();

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );

    expect(scrollView.physics, isA<NeverScrollableScrollPhysics>());
    expect(find.text('Inicial de Nex'), findsNothing);
    expect(find.text('Movimiento\ny superación'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile login fits on phone sizes without scrolling', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final size in const [
      Size(320, 568),
      Size(360, 640),
      Size(400, 631),
      Size(430, 932),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const GymApp());
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Regístrate'), findsOneWidget);
      expect(
        tester.getBottomLeft(find.text('Regístrate')).dy,
        lessThan(size.height),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('el teclado no reduce el tamaño del login móvil', (tester) async {
    tester.view.physicalSize = const Size(400, 631);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const GymApp());
    await tester.pumpAndSettle();
    final logo = find.bySemanticsLabel('NexFit — Tu fuerza. Tu mejor versión.');
    final originalLogoRect = tester.getRect(logo);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.getRect(logo).size, originalLogoRect.size);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    final password = find.widgetWithText(TextField, 'Contraseña');
    await tester.enterText(password, 'clave-segura');
    await tester.pumpAndSettle();
    expect(tester.getRect(password).bottom, lessThanOrEqualTo(331));
    expect(tester.takeException(), isNull);
  });
}
