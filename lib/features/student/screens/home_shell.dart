import 'package:flutter/material.dart';

import 'student_home_screen.dart';
import 'workout_screen.dart';
import 'progress_screen.dart';
import 'body_evaluation_screen.dart';
import 'profile_screen.dart';
import '../../../services/session_store.dart';
import '../../auth/login_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentHomeScreen(onStartWorkout: () => changeTab(1)),
      const WorkoutScreen(),
      const ProgressScreen(),
      const BodyEvaluationScreen(),
      const ProfileScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _StudentWebShell(
            currentIndex: currentIndex,
            onDestinationSelected: changeTab,
            child: IndexedStack(index: currentIndex, children: pages),
          );
        }

        return Scaffold(
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: changeTab,
            selectedItemColor: const Color(0xFF59D52D),
            unselectedItemColor: const Color(0xFF616B76),
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            items: _studentDestinations
                .map(
                  (destination) => BottomNavigationBarItem(
                    icon: Icon(destination.icon),
                    activeIcon: Icon(destination.selectedIcon),
                    label: destination.label,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

const _studentDestinations = [
  _StudentDestination(
    label: 'Inicio',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  _StudentDestination(
    label: 'Entreno',
    icon: Icons.fitness_center_outlined,
    selectedIcon: Icons.fitness_center,
  ),
  _StudentDestination(
    label: 'Progreso',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
  ),
  _StudentDestination(
    label: 'Corporal',
    icon: Icons.monitor_weight_outlined,
    selectedIcon: Icons.monitor_weight,
  ),
  _StudentDestination(
    label: 'Perfil',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
  ),
];

class _StudentDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _StudentDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _StudentWebShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget child;

  const _StudentWebShell({
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.child,
  });

  void _logout(BuildContext context) {
    SessionStore.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = SessionStore.currentUser?.name ?? 'Alumno';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F6),
      body: Row(
        children: [
          Container(
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
                for (
                  var index = 0;
                  index < _studentDestinations.length;
                  index++
                )
                  _StudentSidebarItem(
                    destination: _studentDestinations[index],
                    selected: currentIndex == index,
                    onTap: () => onDestinationSelected(index),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'Alumno',
                            style: TextStyle(
                              color: Color(0xFF9DA6AE),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar sesión',
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout, color: Color(0xFF9DA6AE)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: SizedBox.expand(child: child)),
        ],
      ),
    );
  }
}

class _StudentSidebarItem extends StatelessWidget {
  final _StudentDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _StudentSidebarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
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
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: foreground,
                  size: 21,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    destination.label,
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
