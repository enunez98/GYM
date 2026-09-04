import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../models/app_user.dart';
import '../../../models/student_profile.dart';
import '../../../services/demo_auth_service.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../services/routine_persistence_service.dart';
import '../../../services/student_profile_store.dart';

class RegisterStudentScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onClose;

  const RegisterStudentScreen({super.key, this.embedded = false, this.onClose});

  @override
  State<RegisterStudentScreen> createState() => _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final rutController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(text: '+569');
  final startDateController = TextEditingController(text: '04-07-2026');
  final endDateController = TextEditingController();

  String? selectedPlan;
  String? selectedContractPeriod;
  String? selectedPaymentMethod;
  bool webDatesInitialized = false;
  bool isSaving = false;

  String get selectedPlanPrice {
    final plan = selectedPlan;
    if (plan == null) return '—';
    if (plan.contains('2')) return '\$30.000';
    if (plan.contains('4')) return '\$55.000';
    return '\$45.000';
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    rutController.dispose();
    emailController.dispose();
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

  DateTime parseFormDate(String value) {
    final parts = value.trim().split('-');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.now();
  }

  int get contractMonths {
    return switch (selectedContractPeriod) {
      'Trimestral' => 3,
      'Semestral' => 6,
      'Anual' => 12,
      'Mensual' => 1,
      _ => 0,
    };
  }

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  DateTime addMonths(DateTime date, int months) {
    final targetMonth = date.month + months;
    final targetYear = date.year + (targetMonth - 1) ~/ 12;
    final normalizedMonth = (targetMonth - 1) % 12 + 1;
    final lastDay = DateTime(targetYear, normalizedMonth + 1, 0).day;
    final targetDay = date.day > lastDay ? lastDay : date.day;
    return DateTime(targetYear, normalizedMonth, targetDay);
  }

  void updateEndDateFromDuration() {
    if (selectedContractPeriod == null) {
      endDateController.clear();
      return;
    }
    final startDate = parseFormDate(startDateController.text);
    endDateController.text = formatDate(addMonths(startDate, contractMonths));
  }

  void initializeWebDates() {
    if (webDatesInitialized) return;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    startDateController.text = formatDate(today);
    updateEndDateFromDuration();
    webDatesInitialized = true;
  }

  Future<void> selectDate(
    TextEditingController controller, {
    required bool isWebLayout,
    bool updateCalculatedEndDate = false,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: parseFormDate(controller.text),
      firstDate: isWebLayout ? today : DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Seleccionar fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (selectedDate == null || !mounted) return;
    controller.text = formatDate(selectedDate);
    if (updateCalculatedEndDate) updateEndDateFromDuration();
    setState(() {});
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void closeScreen() {
    if (widget.embedded) {
      widget.onClose?.call();
      return;
    }
    Navigator.pop(context);
  }

  Future<void> showRegistrationResult({required bool success, String? detail}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          success ? Icons.check_circle_outline : Icons.error_outline,
          color: success
              ? const Color(0xFF59D52D)
              : Theme.of(context).colorScheme.error,
          size: 52,
        ),
        title: Text(
          success ? 'Alumno registrado' : 'No se pudo registrar el alumno',
          textAlign: TextAlign.center,
        ),
        content: Text(
          success
              ? 'El alumno se ha registrado correctamente.'
              : 'No se ha podido registrar el alumno.${detail == null ? ' Inténtalo nuevamente.' : '\n\n$detail'}',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> saveStudent() async {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim().toLowerCase();
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
    if (!email.contains('@') || !email.contains('.')) {
      showMessage('Ingresa un correo válido');
      return;
    }
    final plan = selectedPlan;
    final contractPeriod = selectedContractPeriod;
    final paymentMethod = selectedPaymentMethod;
    if (plan == null ||
        contractPeriod == null ||
        paymentMethod == null ||
        startDate.isEmpty ||
        endDate.isEmpty) {
      showMessage(
        'Selecciona plan, duración y método de pago, y completa sus fechas',
      );
      return;
    }

    final normalizedRut = DemoAuthService.normalizeRut(rutController.text);
    if (!DemoAuthService.isValidRut(normalizedRut)) {
      showMessage('El RUT ingresado no es válido');
      return;
    }
    if (StudentProfileStore.existsByRut(normalizedRut)) {
      await showRegistrationResult(
        success: false,
        detail: 'Ya existe un alumno con ese RUT',
      );
      return;
    }

    final fullName = '$name $lastName'.trim();
    setState(() => isSaving = true);

    late final AppUser user;
    try {
      if (Firebase.apps.isEmpty) {
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        user = AppUser(
          id: 'student_$timestamp',
          rut: normalizedRut,
          name: fullName,
          role: UserRole.student,
        );
        DemoAuthService.registerUser(user: user, password: '1234');
      } else {
        user = await FirebaseAuthService.registerStudent(
          rut: normalizedRut,
          email: email,
          name: fullName,
          password: '123456',
        );
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => isSaving = false);
      await showRegistrationResult(success: false, detail: error.message);
      return;
    } catch (error) {
      debugPrint('Error al crear la cuenta del alumno: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      await showRegistrationResult(success: false);
      return;
    }

    final weeklyTarget = weeklyTargetFromPlan(plan);
    try {
      final profile = StudentProfile(
        id: user.id,
        userId: user.id,
        name: fullName,
        rut: normalizedRut,
        phone: phone,
        email: email,
        plan: plan,
        contractPeriod: contractPeriod,
        paymentMethod: paymentMethod,
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
        createdAtEpoch: DateTime.now().millisecondsSinceEpoch,
      );
      if (Firebase.apps.isEmpty) {
        StudentProfileStore.add(profile);
        RoutinePersistenceService.assignActiveRoutineLocally(profile);
      } else {
        await StudentProfileStore.addToFirestore(profile);
        await RoutinePersistenceService.assignActiveRoutineToStudent(profile);
      }
    } catch (error) {
      debugPrint('Error al guardar la ficha del alumno: $error');
      if (!mounted) return;
      setState(() => isSaving = false);
      await showRegistrationResult(
        success: false,
        detail: 'La cuenta fue creada, pero no se pudo guardar la ficha.',
      );
      return;
    }

    if (!mounted) return;
    setState(() => isSaving = false);
    await showRegistrationResult(success: true);
    if (!mounted) return;
    closeScreen();
  }

  Widget buildPlanField() {
    return ResponsiveFormField(
      child: AppSelectField(
        value: selectedPlan,
        hint: 'Seleccionar plan',
        decoration: InputDecoration(
          labelText: 'Plan',
          prefixIcon: const Icon(Icons.fitness_center),
          filled: true,
          fillColor: const Color(0xFFF6F7F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        options: const [
          'Plan 2 sesiones',
          'Plan 3 sesiones',
          'Plan 4 sesiones',
        ],
        onChanged: (value) {
          setState(() => selectedPlan = value);
        },
      ),
    );
  }

  Widget buildContractPeriodField() {
    return ResponsiveFormField(
      child: AppSelectField(
        value: selectedContractPeriod,
        hint: 'Seleccionar duración',
        decoration: InputDecoration(
          labelText: 'Duración',
          prefixIcon: const Icon(Icons.date_range_outlined),
          filled: true,
          fillColor: const Color(0xFFF6F7F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        options: const ['Mensual', 'Trimestral', 'Semestral', 'Anual'],
        onChanged: (value) {
          setState(() {
            selectedContractPeriod = value;
            updateEndDateFromDuration();
          });
        },
      ),
    );
  }

  Widget buildPaymentMethodField() {
    return ResponsiveFormField(
      child: AppSelectField(
        value: selectedPaymentMethod,
        hint: 'Seleccionar método de pago',
        decoration: InputDecoration(
          labelText: 'Método de pago',
          prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
          filled: true,
          fillColor: const Color(0xFFF6F7F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        options: const [
          'Efectivo',
          'Transferencia',
          'Tarjeta débito/crédito',
          'Webpay',
          'Otro',
        ],
        onChanged: (value) {
          setState(() => selectedPaymentMethod = value);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWebLayout = MediaQuery.sizeOf(context).width >= 900;
    if (isWebLayout) initializeWebDates();

    return Scaffold(
      backgroundColor: widget.embedded
          ? const Color(0xFFF6F7F7)
          : const Color(0xFF111214),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.embedded)
              FormHeader(
                title: 'Registrar alumno',
                subtitle: 'Crear ficha inicial del alumno',
                icon: Icons.person_add_alt,
                onBack: closeScreen,
              ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F7F7),
                  borderRadius: widget.embedded
                      ? BorderRadius.zero
                      : const BorderRadius.vertical(top: Radius.circular(28)),
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
                          _ResponsiveFieldGroup(
                            isWebLayout: isWebLayout,
                            first: AppTextField(
                              controller: nameController,
                              label: 'Nombre',
                              icon: Icons.person_outline,
                              hint: 'Ej: Felipe',
                            ),
                            second: AppTextField(
                              controller: lastNameController,
                              label: 'Apellido',
                              icon: Icons.person_outline,
                              hint: 'Ej: Durán',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _ResponsiveFieldGroup(
                            isWebLayout: isWebLayout,
                            first: AppTextField(
                              controller: rutController,
                              label: 'RUT',
                              icon: Icons.badge_outlined,
                              hint: 'Ej: 12.345.678-5',
                            ),
                            second: AppTextField(
                              controller: phoneController,
                              label: 'Teléfono',
                              icon: Icons.phone_outlined,
                              hint: '+569XXXXXXXX',
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppTextField(
                            controller: emailController,
                            label: 'Correo electrónico',
                            icon: Icons.email_outlined,
                            hint: 'nombre@correo.cl',
                            keyboardType: TextInputType.emailAddress,
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
                          if (isWebLayout) ...[
                            _ResponsiveFieldGroup(
                              isWebLayout: true,
                              first: buildPlanField(),
                              second: buildContractPeriodField(),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveFieldGroup(
                              isWebLayout: true,
                              first: _PlanPriceField(value: selectedPlanPrice),
                              second: buildPaymentMethodField(),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveFieldGroup(
                              isWebLayout: true,
                              first: AppTextField(
                                controller: startDateController,
                                label: 'Fecha de inicio',
                                icon: Icons.calendar_month,
                                hint: 'dd-mm-aaaa',
                                readOnly: true,
                                onTap: () => selectDate(
                                  startDateController,
                                  isWebLayout: true,
                                  updateCalculatedEndDate: true,
                                ),
                              ),
                              second: AppTextField(
                                controller: endDateController,
                                label: 'Fecha de vencimiento',
                                icon: Icons.event_available,
                                hint: 'dd-mm-aaaa',
                                readOnly: true,
                                onTap: () => selectDate(
                                  endDateController,
                                  isWebLayout: true,
                                ),
                              ),
                            ),
                          ] else ...[
                            _ResponsiveFieldGroup(
                              isWebLayout: false,
                              first: buildPlanField(),
                              second: _PlanPriceField(value: selectedPlanPrice),
                            ),
                            const SizedBox(height: 12),
                            _ResponsiveFieldGroup(
                              isWebLayout: false,
                              first: AppTextField(
                                controller: startDateController,
                                label: 'Fecha de inicio',
                                icon: Icons.calendar_month,
                                hint: 'dd-mm-aaaa',
                                readOnly: true,
                                onTap: () => selectDate(
                                  startDateController,
                                  isWebLayout: false,
                                ),
                              ),
                              second: AppTextField(
                                controller: endDateController,
                                label: 'Fecha de vencimiento',
                                icon: Icons.event_available,
                                hint: 'dd-mm-aaaa',
                                readOnly: true,
                                onTap: () => selectDate(
                                  endDateController,
                                  isWebLayout: false,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            buildPaymentMethodField(),
                          ],
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
                    _ResponsiveButtonGroup(
                      isWebLayout: isWebLayout,
                      primary: ResponsiveActionButton(
                        child: SizedBox(
                          height: 54,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF59D52D),
                              foregroundColor: const Color(0xFF111214),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isSaving ? null : saveStudent,
                            icon: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              isSaving
                                  ? 'Guardando alumno...'
                                  : 'Guardar alumno',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      secondary: ResponsiveActionButton(
                        child: SizedBox(
                          height: 54,
                          child: isWebLayout
                              ? OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF111214),
                                    side: const BorderSide(
                                      color: Color(0xFFC9CED2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: isSaving ? null : closeScreen,
                                  icon: const Icon(Icons.close),
                                  label: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF111214),
                                    side: const BorderSide(
                                      color: Color(0xFFC9CED2),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  onPressed: isSaving ? null : closeScreen,
                                  child: const Text(
                                    'Cancelar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

class _ResponsiveButtonGroup extends StatelessWidget {
  final bool isWebLayout;
  final Widget primary;
  final Widget secondary;

  const _ResponsiveButtonGroup({
    required this.isWebLayout,
    required this.primary,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWebLayout) {
      return Column(children: [primary, const SizedBox(height: 10), secondary]);
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 200, child: secondary),
          const SizedBox(width: 12),
          SizedBox(width: 260, child: primary),
        ],
      ),
    );
  }
}

class _ResponsiveFieldGroup extends StatelessWidget {
  final bool isWebLayout;
  final Widget first;
  final Widget? second;

  const _ResponsiveFieldGroup({
    required this.isWebLayout,
    required this.first,
    this.second,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWebLayout || second == null) {
      return Column(
        children: [
          first,
          if (second != null) ...[const SizedBox(height: 12), second!],
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1052),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: first),
          const SizedBox(width: 12),
          Expanded(child: second!),
        ],
      ),
    );
  }
}

class _PlanPriceField extends StatelessWidget {
  final String value;

  const _PlanPriceField({required this.value});

  @override
  Widget build(BuildContext context) {
    return ResponsiveFormField(
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Valor',
          prefixIcon: const Icon(Icons.attach_money),
          filled: true,
          fillColor: const Color(0xFFF6F7F7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(value),
      ),
    );
  }
}
