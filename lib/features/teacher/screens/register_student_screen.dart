import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../models/app_user.dart';
import '../../../models/student_profile.dart';
import '../../../services/demo_auth_service.dart';
import '../../../services/student_profile_store.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final rutController = TextEditingController();
  final phoneController = TextEditingController(text: '+569');
  final startDateController = TextEditingController(text: '04-07-2026');
  final endDateController = TextEditingController(text: '04-08-2026');

  String selectedPlan = 'Plan 3 sesiones';

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    rutController.dispose();
    phoneController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  int weeklyTargetFromPlan(String plan) {
    if (plan.contains('2')) return 2;
    if (plan.contains('4')) return 4;
    return 3;
  }

  int calculateDaysRemaining(String endDate) {
    try {
      final parts = endDate.trim().split('-');
      if (parts.length != 3) return 0;

      final parsed = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final difference = parsed.difference(today).inDays;
      return difference < 0 ? 0 : difference;
    } catch (_) {
      return 0;
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void saveStudent() {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final startDate = startDateController.text.trim();
    final endDate = endDateController.text.trim();

    if (name.isEmpty || lastName.isEmpty) {
      showMessage('Completa nombre y apellido');
      return;
    }
    if (phone.length < 9) {
      showMessage('Ingresa un teléfono válido');
      return;
    }
    if (selectedPlan.isEmpty || startDate.isEmpty || endDate.isEmpty) {
      showMessage('Completa el plan y sus fechas');
      return;
    }

    final normalizedRut = DemoAuthService.normalizeRut(rutController.text);
    if (!DemoAuthService.isValidRut(normalizedRut)) {
      showMessage('El RUT ingresado no es válido');
      return;
    }
    if (StudentProfileStore.existsByRut(normalizedRut)) {
      showMessage('Ya existe un alumno con ese RUT');
      return;
    }

    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final userId = 'student_$timestamp';
    final profileId = 'student_profile_$timestamp';
    final fullName = '$name $lastName'.trim();
    final user = AppUser(
      id: userId,
      rut: normalizedRut,
      name: fullName,
      role: UserRole.student,
    );

    try {
      DemoAuthService.registerUser(user: user, password: '1234');
    } on AuthException catch (error) {
      showMessage(error.message);
      return;
    }

    final weeklyTarget = weeklyTargetFromPlan(selectedPlan);
    StudentProfileStore.add(
      StudentProfile(
        id: profileId,
        userId: userId,
        name: fullName,
        rut: normalizedRut,
        phone: phone,
        plan: selectedPlan,
        status: 'Activo',
        startDate: startDate,
        endDate: endDate,
        daysRemaining: calculateDaysRemaining(endDate),
        weeklyAttendanceCompleted: 0,
        weeklyAttendanceTarget: weeklyTarget,
        monthlyAttendanceCompleted: 0,
        monthlyAttendanceTarget: weeklyTarget * 4,
        bodyScore: 0,
        currentWeekLabel: 'Semana 1 - Ordinario',
        currentWeekDates: '-',
      ),
    );

    showMessage('Alumno registrado. Contraseña temporal: 1234');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Registrar alumno',
              subtitle: 'Crear ficha inicial del alumno',
              icon: Icons.person_add_alt,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos personales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: nameController,
                            label: 'Nombre',
                            icon: Icons.person_outline,
                            hint: 'Ej: Felipe',
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: lastNameController,
                            label: 'Apellido',
                            icon: Icons.person_outline,
                            hint: 'Ej: Durán',
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: rutController,
                            label: 'RUT',
                            icon: Icons.badge_outlined,
                            hint: 'Ej: 12.345.678-5',
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: phoneController,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            hint: '+569XXXXXXXX',
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plan contratado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: selectedPlan,
                            decoration: InputDecoration(
                              labelText: 'Plan',
                              prefixIcon: const Icon(Icons.fitness_center),
                              filled: true,
                              fillColor: const Color(0xFFF6F7F7),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Plan 2 sesiones',
                                child: Text('Plan 2 sesiones'),
                              ),
                              DropdownMenuItem(
                                value: 'Plan 3 sesiones',
                                child: Text('Plan 3 sesiones'),
                              ),
                              DropdownMenuItem(
                                value: 'Plan 4 sesiones',
                                child: Text('Plan 4 sesiones'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedPlan = value ?? 'Plan 3 sesiones';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: startDateController,
                            label: 'Fecha de inicio',
                            icon: Icons.calendar_month,
                            hint: 'dd-mm-aaaa',
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: endDateController,
                            label: 'Fecha de vencimiento',
                            icon: Icons.event_available,
                            hint: 'dd-mm-aaaa',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Color(0xFF2563EB)),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cuando conectemos Firebase, esta ficha quedará guardada en la base de datos del gimnasio.',
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF59D52D),
                          foregroundColor: const Color(0xFF111214),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: saveStudent,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Guardar alumno',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111214),
                          side: const BorderSide(color: Color(0xFFC9CED2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
