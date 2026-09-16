import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/info_row.dart';
import '../../../core/widgets/logout_option.dart';
import '../../../core/widgets/student_avatar.dart';
import '../../../services/demo_student_profile_service.dart';
import '../../../services/profile_photo_service.dart';
import '../../../services/session_store.dart';

import '../../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingPhoto = false;

  Future<void> _changePhoto() async {
    final user = SessionStore.currentUser;
    if (user == null || _uploadingPhoto) return;
    setState(() => _uploadingPhoto = true);
    try {
      final data = await ProfilePhotoService.pickAndSave(user);
      if (data == null || !mounted) return;
      SessionStore.updatePhotoData(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada')),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo subir la foto de perfil')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    await SessionStore.signOut();
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final profile = DemoStudentProfileService.getByUserId(user?.id);
    final userName = profile?.name ?? user?.name ?? 'Alumno';
    final userRut = profile?.rut ?? user?.rut ?? '-';
    final phone = profile?.phone ?? '-';
    final plan = profile?.plan ?? 'Plan no asignado';
    final endDate = profile?.endDate ?? '-';

    return Container(
      color: const Color(0xFF111214),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            StudentAvatar(radius: 44, fallbackName: userName),
            TextButton.icon(
              onPressed: _uploadingPhoto ? null : _changePhoto,
              icon: _uploadingPhoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _uploadingPhoto ? 'Subiendo foto...' : 'Cambiar foto',
              ),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF59D52D),
              ),
            ),
            const Text(
              'PNG o JPEG · máximo 2 MB',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$phone · RUT: $userRut',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
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
                            'Mi plan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Plan',
                            value: plan,
                          ),
                          InfoRow(
                            icon: Icons.event_available,
                            label: 'Vencimiento',
                            value: endDate,
                          ),
                          InfoRow(
                            icon: Icons.verified_user_outlined,
                            label: 'Estado',
                            value: profile?.status ?? 'Activo',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.person_outline,
                      title: 'Información personal',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.credit_card,
                      title: 'Plan y pagos',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.calendar_month,
                      title: 'Asistencia',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.monitor_weight,
                      title: 'Evaluación corporal',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.settings_outlined,
                      title: 'Configuración',
                    ),
                    const SizedBox(height: 10),
                    const _ProfileOption(
                      icon: Icons.help_outline,
                      title: 'Ayuda y soporte',
                    ),
                    const SizedBox(height: 16),
                    LogoutOption(onTap: () => _logout(context)),
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

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileOption({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF59D52D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF7A838C)),
        ],
      ),
    );
  }
}
