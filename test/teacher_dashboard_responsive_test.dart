import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:gym_app/features/teacher/screens/students_list_screen.dart';

void main() {
  Widget appAtSize(Size size) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(home: TeacherDashboardScreen()),
    );
  }

  testWidgets('mantiene el dashboard móvil bajo 900 px', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(430, 900)));

    expect(find.text('Panel Admin'), findsOneWidget);
    expect(find.text('Acciones rápidas'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
  });

  testWidgets('muestra el dashboard web desde 900 px', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Resumen general'), findsOneWidget);
    expect(find.text('Importar rutinas'), findsOneWidget);
  });

  testWidgets('mantiene el panel web al cambiar de sección admin', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));
    await tester.tap(find.text('Alumnos'));
    await tester.pumpAndSettle();

    expect(find.text('NEXFIT'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Listado general del gimnasio'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
    expect(tester.getSize(find.byType(StudentsListScreen)).width, 1180);
  });

  testWidgets('limita el ancho de botones administrativos en web', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));
    await tester.tap(find.text('Registrar alumno').first);
    await tester.pumpAndSettle();

    expect(
      tester
          .getSize(find.widgetWithText(ElevatedButton, 'Guardar alumno'))
          .width,
      lessThanOrEqualTo(360),
    );
    expect(
      tester.getSize(find.byType(DropdownButtonFormField<String>)).width,
      lessThanOrEqualTo(520),
    );
  });
}
