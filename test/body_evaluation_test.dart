import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/features/student/screens/body_evaluation_screen.dart';
import 'package:gym_app/features/teacher/screens/register_body_evaluation_screen.dart';
import 'package:gym_app/models/app_user.dart';
import 'package:gym_app/models/body_evaluation.dart';
import 'package:gym_app/services/body_evaluation_store.dart';
import 'package:gym_app/services/session_store.dart';

BodyEvaluation evaluation({
  required String id,
  String userId = 'student_001',
  DateTime? createdAt,
}) {
  return BodyEvaluation(
    id: id,
    userId: userId,
    studentProfileId: 'student_profile_001',
    studentName: 'Felipe Durán',
    createdAt: createdAt ?? DateTime(2026, 7, 22),
    bodyScore: 82,
    weightKg: 70,
    bodyFatKg: 14,
    bodyFatPercent: 20,
    muscleMassKg: 52,
    skeletalMuscleKg: 31,
    proteinKg: 0,
    bodyWaterKg: 40.6,
    bodyWaterPercent: 58,
    bmi: 22.9,
    fatFreeMassKg: 56,
    subcutaneousFatPercent: 0,
    visceralFat: 5,
    smi: 0,
    bodyAge: 0,
    whr: 0,
    basalMetabolicRate: 1553,
    targetWeightKg: 67.5,
    weightControlKg: -2.5,
    fatControlKg: -5,
    muscleControlKg: 2.5,
  );
}

void main() {
  setUp(() {
    BodyEvaluationStore.clearAll();
    SessionStore.signOut();
  });

  tearDown(() {
    BodyEvaluationStore.clearAll();
    SessionStore.signOut();
  });

  test('store filters evaluations and returns the last one per student', () {
    final first = evaluation(id: 'evaluation_1');
    final second = evaluation(
      id: 'evaluation_2',
      createdAt: DateTime(2026, 8, 22),
    );
    final anotherStudent = evaluation(
      id: 'evaluation_3',
      userId: 'student_002',
    );

    BodyEvaluationStore.add(first);
    BodyEvaluationStore.add(second);
    BodyEvaluationStore.add(anotherStudent);

    expect(BodyEvaluationStore.getByUserId('student_001'), [first, second]);
    expect(BodyEvaluationStore.getLastByUserId('student_001'), same(second));

    BodyEvaluationStore.clearByUserId('student_001');
    expect(BodyEvaluationStore.getByUserId('student_001'), isEmpty);
    expect(BodyEvaluationStore.all, [anotherStudent]);
  });

  testWidgets('student sees an empty state without evaluations', (
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

    await tester.pumpWidget(const MaterialApp(home: BodyEvaluationScreen()));

    expect(find.text('Sin evaluación corporal'), findsOneWidget);
    expect(
      find.text('Aún no tienes una evaluación corporal registrada.'),
      findsOneWidget,
    );
  });

  testWidgets('student sees the latest real body evaluation', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SessionStore.signIn(
      const AppUser(
        id: 'student_001',
        rut: '111111111',
        name: 'Felipe Durán',
        role: UserRole.student,
      ),
    );
    BodyEvaluationStore.add(evaluation(id: 'evaluation_1'));

    await tester.pumpWidget(const MaterialApp(home: BodyEvaluationScreen()));

    expect(find.text('22-07-2026'), findsOneWidget);
    expect(find.text('82'), findsOneWidget);
    expect(find.text('Peso'), findsOneWidget);
    expect(find.text('70'), findsWidgets);
    expect(find.text('Masa muscular'), findsWidgets);
    expect(find.text('52'), findsOneWidget);
  });

  testWidgets('admin form saves the demo student evaluation', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const RegisterBodyEvaluationScreen(),
                ),
              ),
              child: const Text('Abrir formulario'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir formulario'));
    await tester.pumpAndSettle();

    final saveButton = find.text('Guardar evaluación');
    await tester.scrollUntilVisible(
      saveButton,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    final saved = BodyEvaluationStore.getLastByUserId('student_001');
    expect(saved, isNotNull);
    expect(saved?.studentName, 'Felipe Durán');
    expect(saved?.createdAt, DateTime(2026, 5, 26));
    expect(saved?.bodyScore, 72);
    expect(saved?.weightKg, 70);
    expect(find.text('Abrir formulario'), findsOneWidget);
  });
}
