import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/routine_assignment.dart';
import 'package:gym_app/models/routine_models.dart';
import 'package:gym_app/services/demo_student_profile_service.dart';
import 'package:gym_app/services/routine_assignment_store.dart';
import 'package:gym_app/services/student_routine_service.dart';
import 'package:gym_app/services/student_workout_progress_store.dart';

void main() {
  final profile = DemoStudentProfileService.getByUserId('student_001');
  final weekOne = DemoRoutineSession(
    session: 'Semana 1',
    title: 'Sesión semana uno',
    exercises: [DemoRoutineExercise(name: 'Sentadilla', series: 4, reps: '10')],
  );
  final weekTwoFirst = DemoRoutineSession(
    session: 'Semana 2',
    title: 'Sesión 1 importada',
    exercises: [DemoRoutineExercise(name: 'Press banca', series: 4, reps: '8')],
  );
  final weekTwoSecond = DemoRoutineSession(
    session: 'Semana 2',
    title: 'Sesión 2 importada',
    exercises: [DemoRoutineExercise(name: 'Remo', series: 3, reps: '12')],
  );

  tearDown(() {
    RoutineAssignmentStore.clearAll();
    StudentWorkoutProgressStore.resetProgress(profile);
  });

  test('assigns sessions matching the student plan and current week', () {
    RoutineAssignmentStore.assign(
      RoutineAssignment(
        id: 'assignment_1',
        userId: 'student_001',
        studentProfileId: 'student_profile_001',
        studentName: 'Felipe Durán',
        plan: 'Plan 4 sesiones',
        routineName: 'Rutina importada',
        sourceFileName: 'plan4.xlsx',
        assignedAt: DateTime(2026, 7, 22),
        sessions: [weekOne, weekTwoFirst, weekTwoSecond],
      ),
    );

    final sessions = StudentRoutineService.getCurrentWeekSessions(profile);

    expect(sessions, [weekTwoFirst, weekTwoSecond]);
    expect(StudentRoutineService.getCurrentSession(profile), weekTwoFirst);
    expect(StudentRoutineService.getCurrentSessionNumber(profile), 1);
    expect(StudentRoutineService.getTotalSessionsForCurrentWeek(profile), 2);
    expect(StudentRoutineService.isCurrentWeekFinished(profile), isFalse);
    expect(StudentRoutineService.hasRoutineAssigned(profile), isTrue);
  });

  test('does not assign a routine from a different plan', () {
    RoutineAssignmentStore.assign(
      RoutineAssignment(
        id: 'assignment_2',
        userId: 'student_001',
        studentProfileId: 'student_profile_001',
        studentName: 'Felipe Durán',
        plan: 'Plan 3 sesiones',
        routineName: 'Rutina importada',
        sourceFileName: 'plan3.xlsx',
        assignedAt: DateTime(2026, 7, 22),
        sessions: [weekTwoFirst],
      ),
    );

    expect(StudentRoutineService.getCurrentWeekSessions(profile), isEmpty);
    expect(StudentRoutineService.hasRoutineAssigned(profile), isFalse);
  });

  test('does not return a global routine without an assignment', () {
    expect(StudentRoutineService.getCurrentSession(profile), isNull);
  });
}
