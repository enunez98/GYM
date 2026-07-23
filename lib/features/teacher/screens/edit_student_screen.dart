import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../models/student_profile.dart';
import '../../../services/demo_auth_service.dart';
import '../../../services/student_profile_store.dart';

class EditStudentScreen extends StatefulWidget {
  final StudentProfile profile;

  const EditStudentScreen({super.key, required this.profile});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  late final TextEditingController nameController;
  late final TextEditingController rutController;
  late final TextEditingController phoneController;
  late final TextEditingController startDateController;
  late final TextEditingController endDateController;
  late String selectedPlan;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.profile.name);
    rutController = TextEditingController(text: widget.profile.rut);
    phoneController = TextEditingController(text: widget.profile.phone);
    startDateController = TextEditingController(text: widget.profile.startDate);
    endDateController = TextEditingController(text: widget.profile.endDate);
    selectedPlan = widget.profile.plan;
    selectedStatus = widget.profile.status;
  }

  @override
  void dispose() {
    nameController.dispose();
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

  DateTime? parseDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }
    return date;
  }

  int calculateDaysRemaining(String endDate) {
    final parsed = parseDate(endDate);
    if (parsed == null) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = parsed.difference(today).inDays;
    return difference < 0 ? 0 : difference;
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void saveStudent() {
    final name = nameController.text.trim();
    final normalizedRut = DemoAuthService.normalizeRut(rutController.text);
    final phone = phoneController.text.trim();
    final startDate = startDateController.text.trim();
    final endDate = endDateController.text.trim();

    if (name.isEmpty) {
      showError('Ingresa el nombre del alumno');
      return;
    }
    if (!DemoAuthService.isValidRut(normalizedRut)) {
      showError('El RUT ingresado no es válido');
      return;
    }
    if (StudentProfileStore.existsByRutExcludingProfile(
      rut: normalizedRut,
      profileId: widget.profile.id,
    )) {
      showError('Ya existe otro alumno con ese RUT');
      return;
    }
    if (DemoAuthService.existsByRutExcludingUser(
      rut: normalizedRut,
      userId: widget.profile.userId,
    )) {
      showError('Ya existe un usuario con ese RUT');
      return;
    }
    if (phone.isEmpty) {
      showError('Ingresa el teléfono del alumno');
      return;
    }
    if (selectedPlan.isEmpty || selectedStatus.isEmpty) {
      showError('Selecciona plan y estado');
      return;
    }
    if (parseDate(startDate) == null || parseDate(endDate) == null) {
      showError('Ingresa fechas válidas en formato dd-mm-aaaa');
      return;
    }

    final weeklyTarget = weeklyTargetFromPlan(selectedPlan);
    final updatedProfile = widget.profile.copyWith(
      name: name,
      rut: normalizedRut,
      phone: phone,
      plan: selectedPlan,
      status: selectedStatus,
      startDate: startDate,
      endDate: endDate,
      daysRemaining: calculateDaysRemaining(endDate),
      weeklyAttendanceTarget: weeklyTarget,
      monthlyAttendanceTarget: weeklyTarget * 4,
    );

    try {
      DemoAuthService.updateUser(
        userId: updatedProfile.userId,
        rut: updatedProfile.rut,
        name: updatedProfile.name,
        isActive: updatedProfile.status != 'Inactivo',
      );
    } on AuthException catch (error) {
      showError(error.message);
      return;
    }
    StudentProfileStore.update(updatedProfile);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alumno actualizado correctamente')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Editar alumno',
              subtitle: widget.profile.name,
              icon: Icons.edit_outlined,
              onBack: () => Navigator.pop(context, false),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
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
                            label: 'Nombre completo',
                            icon: Icons.person_outline,
                            hint: 'Ej: Felipe Durán',
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
                            'Plan y estado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: selectedPlan,
                            decoration: _dropdownDecoration(
                              label: 'Plan',
                              icon: Icons.fitness_center,
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
                                selectedPlan = value ?? selectedPlan;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedStatus,
                            decoration: _dropdownDecoration(
                              label: 'Estado',
                              icon: Icons.verified_user_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Activo',
                                child: Text('Activo'),
                              ),
                              DropdownMenuItem(
                                value: 'Por vencer',
                                child: Text('Por vencer'),
                              ),
                              DropdownMenuItem(
                                value: 'Vencido',
                                child: Text('Vencido'),
                              ),
                              DropdownMenuItem(
                                value: 'Inactivo',
                                child: Text('Inactivo'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value ?? selectedStatus;
                              });
                            },
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
                            'Vigencia del plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
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
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: saveStudent,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Guardar cambios',
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
                        onPressed: () => Navigator.pop(context, false),
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

  InputDecoration _dropdownDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF6F8FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
