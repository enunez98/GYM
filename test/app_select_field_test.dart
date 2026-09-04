import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/widgets/app_select_field.dart';

void main() {
  testWidgets('web select opens below using the complete field width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: 520,
                child: AppSelectField(
                  value: null,
                  options: const ['Alumno uno', 'Alumno dos'],
                  onChanged: (_) {},
                  hint: 'Seleccionar alumno',
                  decoration: const InputDecoration(
                    labelText: 'Alumno',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final select = find.byType(AppSelectField);
    expect(find.text('Seleccionar alumno'), findsOneWidget);
    await tester.tap(select);
    await tester.pumpAndSettle();

    expect(find.text('Seleccionar alumno'), findsOneWidget);
    expect(find.text('Alumno uno'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(MenuItemButton, 'Alumno uno')).width,
      tester.getSize(select).width,
    );
    expect(
      tester.getTopLeft(find.widgetWithText(MenuItemButton, 'Alumno uno')).dy,
      greaterThan(tester.getBottomLeft(select).dy),
    );
  });
}
