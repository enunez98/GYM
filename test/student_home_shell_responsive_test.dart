import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/home_shell.dart';
import 'package:gym_app/features/student/screens/student_home_screen.dart';

void main() {
  testWidgets('muestra navegación inferior del alumno en móvil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeShell()));

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });

  testWidgets('muestra panel lateral del alumno en web', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: HomeShell()));

    expect(find.byType(BottomNavigationBar), findsNothing);
    expect(find.text('NEXFIT'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Entreno'), findsOneWidget);
    expect(find.text('Alumno'), findsWidgets);
    expect(tester.getSize(find.byType(StudentHomeScreen)).width, 1180);
    expect(
      tester
          .getSize(
            find.widgetWithText(ElevatedButton, 'Comenzar entrenamiento'),
          )
          .width,
      lessThanOrEqualTo(360),
    );
  });
}
