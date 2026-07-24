import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/logout_option.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/teacher_action_row.dart';
import '../../../services/session_store.dart';

import '../../auth/login_screen.dart';
import 'import_routines_screen.dart';
import 'register_body_evaluation_screen.dart';
import 'register_student_screen.dart';
import 'students_list_screen.dart';
import 'weekly_routine_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _webSectionIndex = 0;

  void _selectWebSection(int index) {
    setState(() => _webSectionIndex = index);
  }

  void _logout(BuildContext context) {
    SessionStore.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openRegisterStudent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterStudentScreen()),
    );
  }

  void _openRegisterBodyEvaluation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterBodyEvaluationScreen()),
    );
  }

  void _openStudentsList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const StudentsListScreen()),
    );
  }

  void _openWeeklyRoutine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WeeklyRoutineScreen()),
    );
  }

  void _openImportRoutines(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportRoutinesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionStore.currentUser;
    final userName = user?.name ?? 'Admin';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildWebDashboard(context, userName, constraints.maxWidth);
        }

        return _buildMobileDashboard(context, userName);
      },
    );
  }

  Widget _buildMobileDashboard(BuildContext context, String userName) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Panel Admin',
              subtitle: 'Bienvenido, $userName',
              icon: Icons.sports,
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
                    Row(
                      children: const [
                        Expanded(
                          child: MetricCard(
                            title: 'Alumnos activos',
                            value: '42',
                            subtitle: 'activos',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Clases hoy',
                            value: '18',
                            subtitle: 'agendadas',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Pesajes',
                            value: '6',
                            subtitle: 'semana',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Acciones rápidas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TeacherActionRow(
                            icon: Icons.person_add_alt,
                            title: 'Registrar alumno',
                            subtitle: 'Nombre, teléfono, plan y vencimiento',
                            onTap: () => _openRegisterStudent(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.groups,
                            title: 'Ver alumnos',
                            subtitle:
                                'Listado, estado, plan y ficha del alumno',
                            onTap: () => _openStudentsList(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.monitor_weight,
                            title: 'Registrar evaluación corporal',
                            subtitle: 'Datos de Body Go Pro / Fitdays',
                            onTap: () => _openRegisterBodyEvaluation(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.fitness_center,
                            title: 'Ver rutina semanal',
                            subtitle: 'Plan 2, 3 o 4 sesiones',
                            onTap: () => _openWeeklyRoutine(context),
                          ),
                          TeacherActionRow(
                            icon: Icons.upload_file,
                            title: 'Cargar rutinas desde Excel',
                            subtitle: 'Importar planificación del gimnasio',
                            onTap: () => _openImportRoutines(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Alumnos recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _StudentMiniRow(
                            name: 'Felipe Durán',
                            plan: 'Plan 3 sesiones',
                            status: 'Activo',
                          ),
                          _StudentMiniRow(
                            name: 'Camila Rojas',
                            plan: 'Plan 2 sesiones',
                            status: 'Activo',
                          ),
                          _StudentMiniRow(
                            name: 'Matías Soto',
                            plan: 'Plan 4 sesiones',
                            status: 'Por vencer',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    LogoutOption(onTap: () => _logout(context)),
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

  Widget _buildWebDashboard(
    BuildContext context,
    String userName,
    double viewportWidth,
  ) {
    if (_webSectionIndex != 0) {
      final pages = <Widget>[
        const SizedBox.shrink(),
        const StudentsListScreen(),
        const RegisterStudentScreen(),
        const RegisterBodyEvaluationScreen(),
        const WeeklyRoutineScreen(),
        const ImportRoutinesScreen(),
      ];

      return _buildWebSectionShell(context, userName, pages[_webSectionIndex]);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F6),
      body: Row(
        children: [
          _WebSidebar(
            userName: userName,
            selectedIndex: _webSectionIndex,
            onDashboard: () => _selectWebSection(0),
            onRegisterStudent: () => _selectWebSection(2),
            onStudents: () => _selectWebSection(1),
            onEvaluation: () => _selectWebSection(3),
            onRoutine: () => _selectWebSection(4),
            onImport: () => _selectWebSection(5),
            onLogout: () => _logout(context),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFF00111F),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                      child: _AdminDashboardHeader(userName: userName),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3F5F6),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumen general',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF07111D),
                                    ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Revisa la actividad de tu gimnasio y gestiona a tus alumnos.',
                                style: TextStyle(
                                  color: Color(0xFF616B76),
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Row(
                                children: [
                                  Expanded(
                                    child: _WebMetricCard(
                                      icon: Icons.groups_rounded,
                                      title: 'Alumnos activos',
                                      value: '42',
                                      detail: '+8% este mes',
                                    ),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child: _WebMetricCard(
                                      icon: Icons.calendar_today_rounded,
                                      title: 'Clases hoy',
                                      value: '18',
                                      detail: '12 completadas',
                                    ),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child: _WebMetricCard(
                                      icon: Icons.monitor_weight_rounded,
                                      title: 'Evaluaciones',
                                      value: '6',
                                      detail: 'Esta semana',
                                    ),
                                  ),
                                  SizedBox(width: 18),
                                  Expanded(
                                    child: _WebMetricCard(
                                      icon: Icons.trending_up_rounded,
                                      title: 'Asistencia',
                                      value: '87%',
                                      detail: '+4% vs. mes anterior',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _WebSection(
                                      title: 'Acciones rápidas',
                                      subtitle: 'Tareas frecuentes',
                                      child: GridView.count(
                                        crossAxisCount: viewportWidth >= 1200
                                            ? 2
                                            : 1,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: viewportWidth >= 1200
                                            ? 4.8
                                            : 6.5,
                                        children: [
                                          _WebActionTile(
                                            icon:
                                                Icons.person_add_alt_1_rounded,
                                            title: 'Registrar alumno',
                                            onTap: () => _selectWebSection(2),
                                          ),
                                          _WebActionTile(
                                            icon: Icons.groups_2_rounded,
                                            title: 'Ver alumnos',
                                            onTap: () => _selectWebSection(1),
                                          ),
                                          _WebActionTile(
                                            icon: Icons.monitor_weight_rounded,
                                            title: 'Nueva evaluación',
                                            onTap: () => _selectWebSection(3),
                                          ),
                                          _WebActionTile(
                                            icon: Icons.fitness_center_rounded,
                                            title: 'Rutina semanal',
                                            onTap: () => _selectWebSection(4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  const Expanded(
                                    flex: 2,
                                    child: _WebSection(
                                      title: 'Alumnos recientes',
                                      subtitle: 'Últimos registros',
                                      child: Column(
                                        children: [
                                          _StudentMiniRow(
                                            name: 'Felipe Durán',
                                            plan: 'Plan 3 sesiones',
                                            status: 'Activo',
                                          ),
                                          _StudentMiniRow(
                                            name: 'Camila Rojas',
                                            plan: 'Plan 2 sesiones',
                                            status: 'Activo',
                                          ),
                                          _StudentMiniRow(
                                            name: 'Matías Soto',
                                            plan: 'Plan 4 sesiones',
                                            status: 'Por vencer',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSectionShell(
    BuildContext context,
    String userName,
    Widget page,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F6),
      body: Row(
        children: [
          _WebSidebar(
            userName: userName,
            selectedIndex: _webSectionIndex,
            onDashboard: () => _selectWebSection(0),
            onStudents: () => _selectWebSection(1),
            onRegisterStudent: () => _selectWebSection(2),
            onEvaluation: () => _selectWebSection(3),
            onRoutine: () => _selectWebSection(4),
            onImport: () => _selectWebSection(5),
            onLogout: () => _logout(context),
          ),
          Expanded(child: SizedBox.expand(child: page)),
        ],
      ),
    );
  }
}

class _WebSidebar extends StatelessWidget {
  final String userName;
  final int selectedIndex;
  final VoidCallback onDashboard;
  final VoidCallback onRegisterStudent;
  final VoidCallback onStudents;
  final VoidCallback onEvaluation;
  final VoidCallback onRoutine;
  final VoidCallback onImport;
  final VoidCallback onLogout;

  const _WebSidebar({
    required this.userName,
    required this.selectedIndex,
    required this.onDashboard,
    required this.onRegisterStudent,
    required this.onStudents,
    required this.onEvaluation,
    required this.onRoutine,
    required this.onImport,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: const Color(0xFF07111D),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/images/nexfit_logo_compact.png',
              width: 170,
              height: 56,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
          ),
          const SizedBox(height: 38),
          _SidebarItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            selected: selectedIndex == 0,
            onTap: onDashboard,
          ),
          _SidebarItem(
            icon: Icons.groups_2_rounded,
            label: 'Alumnos',
            selected: selectedIndex == 1,
            onTap: onStudents,
          ),
          _SidebarItem(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Registrar alumno',
            selected: selectedIndex == 2,
            onTap: onRegisterStudent,
          ),
          _SidebarItem(
            icon: Icons.monitor_weight_rounded,
            label: 'Evaluaciones',
            selected: selectedIndex == 3,
            onTap: onEvaluation,
          ),
          _SidebarItem(
            icon: Icons.fitness_center_rounded,
            label: 'Rutinas',
            selected: selectedIndex == 4,
            onTap: onRoutine,
          ),
          _SidebarItem(
            icon: Icons.upload_file_rounded,
            label: 'Importar rutinas',
            selected: selectedIndex == 5,
            onTap: onImport,
          ),
          const Spacer(),
          const Divider(color: Color(0xFF25303A)),
          const SizedBox(height: 10),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF59D52D),
                child: Icon(Icons.person, color: Color(0xFF07111D)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'Administrador',
                      style: TextStyle(color: Color(0xFF9DA6AE), fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: onLogout,
                icon: const Icon(Icons.logout, color: Color(0xFF9DA6AE)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? const Color(0xFF07111D) : Colors.white70;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Material(
        color: selected ? const Color(0xFF59D52D) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: foreground, size: 21),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminDashboardHeader extends StatelessWidget {
  final String userName;

  const _AdminDashboardHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 24,
          backgroundColor: Color(0xFF59D52D),
          child: Icon(Icons.admin_panel_settings, color: Color(0xFF07111D)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $userName 👋',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Panel administrativo del gimnasio',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF00563F),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Administrador',
            style: TextStyle(
              color: Color(0xFFD8FFE6),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String detail;

  const _WebMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF9E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF3FB52A), size: 20),
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: Color(0xFF9DA6AE)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF616B76), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          Text(
            detail,
            style: const TextStyle(
              color: Color(0xFF3FB52A),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _WebSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _WebSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _WebActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _WebActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F7F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF07111D),
                child: Icon(icon, color: const Color(0xFF59D52D), size: 20),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 19,
                color: Color(0xFF616B76),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentMiniRow extends StatelessWidget {
  final String name;
  final String plan;
  final String status;

  const _StudentMiniRow({
    required this.name,
    required this.plan,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isWarning = status == 'Por vencer';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 21,
            backgroundColor: Color(0xFF59D52D),
            child: Icon(Icons.person, color: Color(0xFF111214)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  plan,
                  style: const TextStyle(
                    color: Color(0xFF616B76),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            text: status,
            background: isWarning
                ? const Color(0xFFFFF2D9)
                : const Color(0xFFEDF9E8),
            textColor: isWarning
                ? const Color(0xFFD98200)
                : const Color(0xFF59D52D),
          ),
        ],
      ),
    );
  }
}
