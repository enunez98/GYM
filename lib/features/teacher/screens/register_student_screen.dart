import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_header.dart';

class RegisterStudentScreen extends StatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController(text: '+569');
  final startDateController = TextEditingController(text: '04-07-2026');
  final endDateController = TextEditingController(text: '04-08-2026');

  String selectedPlan = 'Plan 3 sesiones';

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  void saveStudent() {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || lastName.isEmpty || phone.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa nombre, apellido y teléfono válido'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alumno $name $lastName registrado con $selectedPlan'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
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
                              fillColor: const Color(0xFFF6F8FA),
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
                          backgroundColor: const Color(0xFF20B2AA),
                          foregroundColor: Colors.white,
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
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black26),
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
