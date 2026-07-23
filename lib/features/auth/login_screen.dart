import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../services/demo_auth_service.dart';
import '../../services/session_store.dart';
import '../student/screens/home_shell.dart';
import '../teacher/screens/teacher_dashboard_screen.dart';

const _energyGreen = Color(0xFFA6FF00);
const _strengthGreen = Color(0xFF74B800);
const _carbonBlack = Color(0xFF111214);
const _deepGray = Color(0xFF1E1F23);
const _steelGray = Color(0xFF6B6F76);
const _boneWhite = Color(0xFFF2F2F4);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final rutController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    rutController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final rut = rutController.text.trim();
    final password = passwordController.text.trim();

    if (rut.isEmpty || password.isEmpty) {
      _showMessage('Ingresa RUT y contraseña');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await DemoAuthService.login(rut: rut, password: password);
      SessionStore.signIn(user);

      if (!mounted) return;

      final Widget destination = user.role == UserRole.student
          ? const HomeShell()
          : const TeacherDashboardScreen();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('No se pudo iniciar sesión');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _deepGray,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void fillStudentDemo() {
    setState(() {
      rutController.text = '11.111.111-1';
      passwordController.text = '1234';
    });
  }

  void fillAdminDemo() {
    setState(() {
      rutController.text = '22.222.222-2';
      passwordController.text = '1234';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            return Stack(
              children: [
                const Positioned.fill(child: _AmbientBackground()),
                Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : 520,
                      maxHeight: isDesktop ? 790 : double.infinity,
                    ),
                    margin: EdgeInsets.all(isDesktop ? 20 : 0),
                    decoration: isDesktop
                        ? BoxDecoration(
                            color: _carbonBlack,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: _steelGray.withValues(alpha: .38),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 50,
                                offset: Offset(0, 24),
                              ),
                            ],
                          )
                        : const BoxDecoration(),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        if (isDesktop) const _DesktopHeader(),
                        Expanded(
                          child: Row(
                            children: [
                              if (isDesktop)
                                const Expanded(flex: 11, child: _VisualPanel()),
                              Expanded(
                                flex: 10,
                                child: _LoginPanel(
                                  isDesktop: isDesktop,
                                  rutController: rutController,
                                  passwordController: passwordController,
                                  isLoading: isLoading,
                                  obscurePassword: obscurePassword,
                                  rememberMe: rememberMe,
                                  onLogin: login,
                                  onTogglePassword: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                  onRememberChanged: (value) => setState(
                                    () => rememberMe = value ?? false,
                                  ),
                                  onStudentDemo: fillStudentDemo,
                                  onAdminDemo: fillAdminDemo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isDesktop) const _DesktopFooter(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -.35),
          radius: 1.15,
          colors: [_deepGray, Color(0xFF08090B), Color(0xFF050608)],
        ),
      ),
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 38),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C0E),
        border: Border(
          bottom: BorderSide(color: _steelGray.withValues(alpha: .26)),
        ),
      ),
      child: Row(
        children: [
          const _BrandLogo(compact: true),
          const Spacer(),
          Text(
            '¿Necesitas ayuda?',
            style: TextStyle(
              color: _boneWhite.withValues(alpha: .68),
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 26),
          OutlinedButton(
            onPressed: () => _comingSoon(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _boneWhite,
              side: const BorderSide(color: _energyGreen),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 17),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Regístrate',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualPanel extends StatelessWidget {
  const _VisualPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/nexfit_gym_background.png',
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Color(0x33000000), Color(0xCC000000)],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 110),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [_BrandLogo()],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(28, 24, 28, 35),
            child: _Benefits(),
          ),
        ),
        const Positioned(
          left: 0,
          bottom: 0,
          child: ClipPath(
            clipper: _CornerAccentClipper(),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [_energyGreen, Color(0xFFC8FF22)],
                ),
              ),
              child: SizedBox(width: 112, height: 88),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.isDesktop,
    required this.rutController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onLogin,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onStudentDemo,
    required this.onAdminDemo,
  });

  final bool isDesktop;
  final TextEditingController rutController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onLogin;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onStudentDemo;
  final VoidCallback onAdminDemo;

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: isDesktop
          ? const NeverScrollableScrollPhysics()
          : const ClampingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 48 : 24,
        isDesktop ? 32 : 28,
        isDesktop ? 48 : 24,
        isDesktop ? 20 : 28,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isDesktop) ...[
                  const Center(child: _BrandLogo()),
                  const SizedBox(height: 28),
                ],
                const _LoginTitle(),
                SizedBox(height: isDesktop ? 24 : 34),
                _DarkTextField(
                  controller: rutController,
                  label: 'RUT',
                  hint: 'Ej: 11.111.111-1',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 13),
                _DarkTextField(
                  controller: passwordController,
                  label: 'Contraseña',
                  hint: 'Ingresa tu contraseña',
                  icon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => onLogin(),
                  suffixIcon: IconButton(
                    tooltip: obscurePassword
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _boneWhite,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: _energyGreen,
                        checkColor: _carbonBlack,
                        side: const BorderSide(color: _energyGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: onRememberChanged,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Text(
                      'Recordarme',
                      style: TextStyle(color: _boneWhite, fontSize: 13),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _comingSoon(context),
                          style: TextButton.styleFrom(
                            foregroundColor: _energyGreen,
                            padding: EdgeInsets.zero,
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isDesktop ? 15 : 22),
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _energyGreen,
                      disabledBackgroundColor: _strengthGreen.withValues(
                        alpha: .55,
                      ),
                      foregroundColor: _carbonBlack,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _carbonBlack,
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: isDesktop ? 18 : 25),
                const _DividerLabel(),
                SizedBox(height: isDesktop ? 14 : 20),
                _SocialButton(
                  label: 'Continuar con Google',
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: _energyGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const _SocialButton(
                  label: 'Continuar con Apple',
                  child: Icon(Icons.apple, color: _boneWhite, size: 24),
                ),
                SizedBox(height: isDesktop ? 14 : 22),
                _DemoAccess(onStudent: onStudentDemo, onAdmin: onAdminDemo),
                if (!isDesktop) ...[
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿No tienes cuenta? ',
                        style: TextStyle(color: _boneWhite, fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () => _comingSoon(context),
                        child: const Text(
                          'Regístrate',
                          style: TextStyle(
                            color: _energyGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Container(
      color: _carbonBlack.withValues(alpha: isDesktop ? .98 : .88),
      child: isDesktop
          ? LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 620,
                    child: content,
                  ),
                );
              },
            )
          : content,
    );
  }
}

class _LoginTitle extends StatelessWidget {
  const _LoginTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Inicia '),
              TextSpan(
                text: 'sesión',
                style: TextStyle(color: _energyGreen),
              ),
            ],
          ),
          style: TextStyle(
            color: _boneWhite,
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bienvenido de vuelta a tu mejor versión.',
          style: TextStyle(
            color: _boneWhite.withValues(alpha: .62),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.textInputAction,
    required this.autofillHints,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String> autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onSubmitted: onSubmitted,
      cursorColor: _energyGreen,
      style: const TextStyle(color: _boneWhite, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: _boneWhite.withValues(alpha: .65)),
        hintStyle: TextStyle(
          color: _steelGray.withValues(alpha: .85),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: _boneWhite, size: 21),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _deepGray.withValues(alpha: .55),
        contentPadding: const EdgeInsets.symmetric(vertical: 19),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _steelGray.withValues(alpha: .45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _energyGreen, width: 1.4),
        ),
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: _steelGray.withValues(alpha: .8))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'o continúa con',
            style: TextStyle(
              color: _boneWhite.withValues(alpha: .65),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: _steelGray.withValues(alpha: .8))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: () => _comingSoon(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: _boneWhite,
          side: BorderSide(color: _steelGray.withValues(alpha: .65)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: child),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _DemoAccess extends StatelessWidget {
  const _DemoAccess({required this.onStudent, required this.onAdmin});

  final VoidCallback onStudent;
  final VoidCallback onAdmin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _deepGray.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _steelGray.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Text(
            'Acceso demo',
            style: TextStyle(
              color: _boneWhite.withValues(alpha: .65),
              fontSize: 11,
            ),
          ),
          const Spacer(),
          _DemoButton(label: 'Alumno', onPressed: onStudent),
          const SizedBox(width: 8),
          _DemoButton(label: 'Admin', onPressed: onAdmin),
        ],
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: const TextStyle(
            color: _energyGreen,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      compact
          ? 'assets/images/nexfit_logo_compact.png'
          : 'assets/images/nexfit_logo.png',
      width: compact ? 150 : 300,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: compact
          ? 'NexFit'
          : 'NexFit — Tu fuerza. Tu mejor versión.',
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.bolt_outlined, 'Energía'),
      (Icons.trending_up_rounded, 'Progreso'),
      (Icons.fitness_center_rounded, 'Movimiento\ny superación'),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        for (final item in items)
          SizedBox(
            width: 92,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.$1, color: _energyGreen, size: 25),
                const SizedBox(height: 9),
                SizedBox(
                  height: 30,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _boneWhite,
                        fontSize: 11,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _CornerAccentClipper extends CustomClipper<Path> {
  const _CornerAccentClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * .68)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * .28, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DesktopFooter extends StatelessWidget {
  const _DesktopFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0C0E),
        border: Border(
          top: BorderSide(color: _steelGray.withValues(alpha: .22)),
        ),
      ),
      child: Text(
        '© 2026 NexFit. Todos los derechos reservados.',
        style: TextStyle(
          color: _boneWhite.withValues(alpha: .42),
          fontSize: 11,
        ),
      ),
    );
  }
}

void _comingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Esta función estará disponible próximamente'),
      backgroundColor: _deepGray,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
