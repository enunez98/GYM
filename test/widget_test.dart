// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:gym_app/app.dart';

void main() {
  testWidgets('shows the login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GymApp());

    expect(find.text('GYM Pro'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('RUT'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Demo alumno'), findsOneWidget);
    expect(find.text('Demo admin'), findsOneWidget);
  });
}
