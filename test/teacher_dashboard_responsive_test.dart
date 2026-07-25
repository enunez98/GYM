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
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Alumnos'), findsOneWidget);
    expect(find.text('Evaluar'), findsOneWidget);
    expect(find.text('Rutinas'), findsOneWidget);
    expect(find.text('Importar'), findsOneWidget);

    await tester.tap(find.text('Alumnos'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Listado general del gimnasio'), findsOneWidget);

    await tester.tap(find.text('Felipe Durán'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Datos del alumno'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Listado general del gimnasio'), findsOneWidget);
  });

  testWidgets('muestra el dashboard web desde 900 px', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));

    expect(find.text('Inicio'), findsOneWidget);
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
    expect(find.text('Inicio'), findsOneWidget);
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
    await tester.tap(find.text('Alumnos'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar alumno'));
    await tester.pumpAndSettle();

    expect(
      tester
          .getSize(find.widgetWithText(ElevatedButton, 'Guardar alumno'))
          .width,
      lessThanOrEqualTo(360),
    );
    for (final element
        in find.byType(DropdownButtonFormField<String>).evaluate()) {
      expect(
        tester.getSize(find.byElementPredicate((e) => e == element)).width,
        lessThanOrEqualTo(520),
      );
    }
  });

  testWidgets('muestra la rutina web como tabla de ejercicios', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));
    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();

    expect(find.text('Semana 2 - Ordinario'), findsOneWidget);
    expect(find.text('Ver calendario'), findsOneWidget);
    expect(find.text('Ejercicio'), findsWidgets);
    expect(find.text('Series'), findsWidgets);
    expect(find.text('Repeticiones'), findsWidgets);
    expect(find.text('Descanso'), findsWidgets);
    expect(find.text('Agregar ejercicio'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.endsWith('bench_press.png'),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Agregar ejercicio').first);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    final modalFields = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(modalFields.at(0), 'Press francés');
    await tester.enterText(modalFields.at(1), '4');
    await tester.enterText(modalFields.at(2), '12');
    await tester.enterText(modalFields.at(3), '45 seg');
    await tester.tap(find.text('Guardar ejercicio'));
    await tester.pumpAndSettle();

    expect(find.text('Press francés'), findsOneWidget);
    expect(find.text('18 series'), findsOneWidget);

    await tester.tap(find.text('Plan 3 sesiones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 2 sesiones').last);
    await tester.pumpAndSettle();

    expect(find.text('Full body A'), findsOneWidget);
    expect(find.text('Pecho - Tríceps'), findsNothing);
  });

  testWidgets('mantiene el panel web al abrir y cerrar detalle de alumno', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));
    await tester.tap(find.text('Alumnos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Felipe Durán'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Alumnos'), findsWidgets);
    expect(find.text('Detalle del alumno'), findsOneWidget);
    expect(find.text('Volver al listado'), findsOneWidget);
    expect(find.text('Datos del alumno'), findsOneWidget);

    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();

    expect(find.text('Buscar alumno...'), findsOneWidget);
    expect(find.text('Felipe Durán'), findsOneWidget);
    expect(find.text('Detalle del alumno'), findsNothing);
  });

  testWidgets('abre registro desde alumnos sin perder el panel web', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(appAtSize(const Size(1440, 1000)));
    await tester.tap(find.text('Alumnos'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Registrar alumno'));
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Registrar alumno'), findsOneWidget);
    expect(find.text('Alumnos'), findsWidgets);
    expect(find.text('Volver al listado'), findsOneWidget);
    expect(find.text('Plan contratado'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);
  });
}
