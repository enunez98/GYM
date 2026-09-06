import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/widgets/app_select_field.dart';
import 'package:gym_app/core/widgets/exercise_motion_preview.dart';
import 'package:gym_app/features/teacher/screens/teacher_dashboard_screen.dart';
import 'package:gym_app/features/teacher/screens/students_list_screen.dart';
import 'package:gym_app/services/exercise_catalog_service.dart';

void main() {
  setUp(() {
    ExerciseCatalogService.testExerciseNames = const [
      'Press banca plano con barra',
    ];
  });

  tearDown(() {
    ExerciseCatalogService.testExerciseNames = null;
  });

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
    for (final element in find.byType(AppSelectField).evaluate()) {
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

    expect(find.text('Seleccionar plan'), findsWidgets);
    expect(find.text('Seleccionar semana'), findsWidgets);
    expect(find.text('Agregar ejercicio'), findsNothing);

    await tester.tap(find.text('Seleccionar plan').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 3 sesiones'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppSelectField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Semana 1'));
    await tester.pumpAndSettle();

    expect(find.text('Ver calendario'), findsOneWidget);
    expect(find.text('Agregar ejercicio'), findsNothing);

    await tester.tap(find.text('Sesión 1').first);
    await tester.pumpAndSettle();

    expect(find.text('Ejercicio'), findsWidgets);
    expect(find.text('Series'), findsWidgets);
    expect(find.text('Repeticiones'), findsWidgets);
    expect(find.text('Descanso'), findsWidgets);
    expect(find.text('Agregar ejercicio'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ExerciseMotionPreview &&
            widget.exerciseName == 'Press banca plano' &&
            !widget.animate,
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Agregar ejercicio').first);
    await tester.pumpAndSettle();
    expect(find.text('Cargando ejercicios...'), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);

    final nameField = find.byKey(const Key('exercise_search_field'));
    final seriesField = find.byKey(const Key('exercise_series_field'));
    final repsField = find.byKey(const Key('exercise_reps_field'));
    final restField = find.byKey(const Key('exercise_rest_field'));
    await tester.enterText(nameField, 'Ejercicio inexistente');
    await tester.enterText(seriesField, '');
    await tester.enterText(repsField, '');
    await tester.enterText(restField, '');
    await tester.tap(find.text('Guardar ejercicio'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona un ejercicio de la lista'), findsOneWidget);
    expect(find.text('Usa entre 1 y 20 series'), findsOneWidget);
    expect(find.text('Completa las repeticiones'), findsOneWidget);
    expect(find.text('Completa el descanso'), findsOneWidget);

    await tester.enterText(nameField, 'Press banca plano con barra');
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo cargar el catálogo de ejercicios'),
      findsNothing,
    );
    final catalogOption = find.widgetWithText(
      ListTile,
      'Press banca plano con barra',
    );
    expect(catalogOption, findsOneWidget);
    await tester.tap(catalogOption);
    await tester.pumpAndSettle();
    await tester.enterText(seriesField, '4');
    await tester.enterText(repsField, '12');
    await tester.enterText(restField, '45 seg');
    await tester.tap(find.text('Guardar ejercicio'));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona un ejercicio de la lista'), findsNothing);
    expect(find.text('Ingresa una cantidad válida'), findsNothing);
    expect(find.text('Completa las repeticiones'), findsNothing);
    expect(find.text('Completa el descanso'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Press banca plano con barra'), findsOneWidget);
    expect(find.text('18 series'), findsOneWidget);
    final saveRoutineButton = find.byKey(const Key('save_routine_button'));
    expect(
      tester.widget<ElevatedButton>(saveRoutineButton).onPressed,
      isNotNull,
    );

    await tester.ensureVisible(find.byTooltip('Acciones').last);
    await tester.tap(find.byTooltip('Acciones').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Editar ejercicio'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('exercise_series_field')), '5');
    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();
    expect(find.text('19 series'), findsOneWidget);

    tester.widget<ElevatedButton>(saveRoutineButton).onPressed!();
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Rutina guardada y actualizada'),
      findsOneWidget,
    );
    expect(tester.widget<ElevatedButton>(saveRoutineButton).onPressed, isNull);

    await tester.ensureVisible(find.byTooltip('Acciones').last);
    await tester.tap(find.byTooltip('Acciones').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('Eliminar ejercicio'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Eliminar'));
    await tester.pumpAndSettle();
    expect(find.text('Press banca plano con barra'), findsNothing);
    expect(
      tester.widget<ElevatedButton>(saveRoutineButton).onPressed,
      isNotNull,
    );

    await tester.fling(
      find.byType(ListView).first,
      const Offset(0, 2000),
      1000,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 3 sesiones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plan 2 sesiones').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppSelectField).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Semana 1'));
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
