import 'package:flutter/material.dart';

void main() {
  runApp(const GymApp());
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYM Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF20B2AA),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _goTo(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Color(0xFF20B2AA),
                  child: Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'GYM Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gestión de alumnos, rutinas y progreso',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 34),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecciona un perfil',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Entrada de prueba antes de conectar Firebase.',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _RoleButton(
                        icon: Icons.person,
                        title: 'Entrar como Alumno',
                        subtitle: 'Dashboard, entrenamiento, progreso y corporal',
                        color: const Color(0xFF20B2AA),
                        onTap: () => _goTo(context, const HomeShell()),
                      ),
                      const SizedBox(height: 12),
                      _RoleButton(
                        icon: Icons.sports,
                        title: 'Entrar como Profesor',
                        subtitle: 'Alumnos, rutinas, pesajes y asistencia',
                        color: const Color(0xFF2563EB),
                        onTap: () => _goTo(
                          context,
                          const TeacherDashboardScreen(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RoleButton(
                        icon: Icons.admin_panel_settings,
                        title: 'Entrar como Admin / Dueño',
                        subtitle: 'Panel general del gimnasio',
                        color: const Color(0xFF7C3AED),
                        onTap: () => _goTo(
                          context,
                          const AdminDashboardScreen(),
                        ),
                      ),
                    ],
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

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF6F8FA),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}

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
      StudentHomeScreen(
        onStartWorkout: () => changeTab(1),
      ),
      const WorkoutScreen(),
      const ProgressScreen(),
      const BodyEvaluationScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changeTab,
        selectedItemColor: const Color(0xFF20B2AA),
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Entreno',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_weight_outlined),
            activeIcon: Icon(Icons.monitor_weight),
            label: 'Corporal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class StudentHomeScreen extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const StudentHomeScreen({
    super.key,
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _Header(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
                    const _WeekCard(),
                    const SizedBox(height: 14),
                    const _AttendanceCards(),
                    const SizedBox(height: 14),
                    _NextWorkoutCard(
                      onStartWorkout: onStartWorkout,
                    ),
                    const SizedBox(height: 14),
                    const _BodySummaryCard(),
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

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      DemoExercise(
        name: 'Press Banca Plano',
        muscleGroup: 'Pecho',
        series: [
          DemoSet(serie: 1, kg: 60, reps: 10),
          DemoSet(serie: 2, kg: 65, reps: 10),
          DemoSet(serie: 3, kg: 65, reps: 8),
          DemoSet(serie: 4, kg: 60, reps: 10),
        ],
      ),
      DemoExercise(
        name: 'Press Inclinado Mancuernas',
        muscleGroup: 'Pecho',
        series: [
          DemoSet(serie: 1, kg: 28, reps: 12),
          DemoSet(serie: 2, kg: 30, reps: 10),
          DemoSet(serie: 3, kg: 30, reps: 10),
          DemoSet(serie: 4, kg: 28, reps: 12),
        ],
      ),
      DemoExercise(
        name: 'Extensión de Tríceps',
        muscleGroup: 'Tríceps',
        series: [
          DemoSet(serie: 1, kg: 25, reps: 12),
          DemoSet(serie: 2, kg: 30, reps: 10),
          DemoSet(serie: 3, kg: 30, reps: 10),
        ],
      ),
    ];

    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _ScreenHeader(
              title: 'Entrenamiento',
              subtitle: 'Sesión actual del alumno',
              icon: Icons.fitness_center,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Semana 2 - Ordinario',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Sesión 1',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _StatusChip(
                                text: 'Pendiente',
                                background: const Color(0xFFFFF2D9),
                                textColor: const Color(0xFFD98200),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Pecho - Tríceps',
                            style: TextStyle(color: Colors.black54),
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
                              'Debes completar esta sesión para avanzar a la siguiente clase.',
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (int i = 0; i < exercises.length; i++) ...[
                      _ExerciseCard(
                        number: i + 1,
                        exercise: exercises[i],
                      ),
                      const SizedBox(height: 14),
                    ],
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20B2AA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Entrenamiento guardado correctamente',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Guardar entrenamiento',
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sesión omitida'),
                            ),
                          );
                        },
                        child: const Text(
                          'Omitir sesión',
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

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chartValues = [70.0, 72.5, 75.0, 80.0, 82.5];

    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _ScreenHeader(
              title: 'Progreso',
              subtitle: 'Cargas, volumen y rendimiento',
              icon: Icons.bar_chart,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ejercicio destacado',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Press Banca Plano',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _StatusChip(
                                text: '+12.5 kg',
                                background: const Color(0xFFDFF9EA),
                                textColor: const Color(0xFF12985C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Evolución de 1RM estimado últimos 3 meses',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(
                          child: _MetricCard(
                            title: '1RM estimado',
                            value: '82.5',
                            subtitle: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'Volumen total',
                            value: '10.2K',
                            subtitle: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'Mejor serie',
                            value: '80x5',
                            subtitle: 'kg x reps',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evolución 1RM estimado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 210,
                            child: CustomPaint(
                              painter: ProgressChartPainter(chartValues),
                              child: Container(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('15 Abr', style: TextStyle(fontSize: 12)),
                              Text('30 Abr', style: TextStyle(fontSize: 12)),
                              Text('15 May', style: TextStyle(fontSize: 12)),
                              Text('30 May', style: TextStyle(fontSize: 12)),
                              Text('15 Jun', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Mejores series',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _BestSetRow(
                            position: 1,
                            exercise: 'Press Banca Plano',
                            result: '82.5 kg x 5 reps',
                            date: '15 Jun 2026',
                          ),
                          _BestSetRow(
                            position: 2,
                            exercise: 'Press Banca Plano',
                            result: '80 kg x 5 reps',
                            date: '30 May 2026',
                          ),
                          _BestSetRow(
                            position: 3,
                            exercise: 'Press Banca Plano',
                            result: '75 kg x 6 reps',
                            date: '15 May 2026',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Resumen de progreso',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.trending_up,
                            label: 'Subida de carga',
                            value: '+17.8%',
                          ),
                          _InfoRow(
                            icon: Icons.calendar_month,
                            label: 'Sesiones registradas',
                            value: '15',
                          ),
                          _InfoRow(
                            icon: Icons.bolt,
                            label: 'Consistencia',
                            value: 'Buena',
                          ),
                        ],
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

class BodyEvaluationScreen extends StatelessWidget {
  const BodyEvaluationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _ScreenHeader(
              title: 'Evaluación corporal',
              subtitle: 'Body Go Pro / Fitdays',
              icon: Icons.monitor_weight,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Última evaluación',
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '26 May 2026',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              _StatusChip(
                                text: 'Estándar',
                                background: const Color(0xFFDFF9EA),
                                textColor: const Color(0xFF12985C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '72',
                                style: TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF20B2AA),
                                ),
                              ),
                              SizedBox(width: 4),
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '/100 puntos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: const LinearProgressIndicator(
                              value: 0.72,
                              minHeight: 12,
                              backgroundColor: Color(0xFFE5E7EB),
                              color: Color(0xFF20B2AA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: const [
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.monitor_weight,
                            title: 'Peso',
                            value: '70.0',
                            unit: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.percent,
                            title: 'Grasa',
                            value: '21.7',
                            unit: '%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.accessibility_new,
                            title: 'Masa muscular',
                            value: '51.2',
                            unit: 'kg',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.water_drop_outlined,
                            title: 'Agua corporal',
                            value: '57.4',
                            unit: '%',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.health_and_safety_outlined,
                            title: 'IMC',
                            value: '22.9',
                            unit: '',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _BodyMetricTile(
                            icon: Icons.local_fire_department_outlined,
                            title: 'Metabolismo',
                            value: '1553',
                            unit: 'kcal',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Control recomendado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _BodyControlRow(
                            label: 'Peso objetivo',
                            value: '67.5 kg',
                          ),
                          _BodyControlRow(
                            label: 'Control de peso',
                            value: '-2.5 kg',
                          ),
                          _BodyControlRow(
                            label: 'Control de grasa',
                            value: '-5.0 kg',
                          ),
                          _BodyControlRow(
                            label: 'Control muscular',
                            value: '+2.5 kg',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Indicadores principales',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _BodyProgressRow(
                            label: 'IMC',
                            value: '22.9',
                            progress: 0.55,
                            status: 'Estándar',
                          ),
                          _BodyProgressRow(
                            label: 'Grasa corporal',
                            value: '21.7%',
                            progress: 0.62,
                            status: 'Estándar',
                          ),
                          _BodyProgressRow(
                            label: 'Masa muscular',
                            value: '51.2 kg',
                            progress: 0.73,
                            status: 'Estándar',
                          ),
                          _BodyProgressRow(
                            label: 'Agua corporal',
                            value: '57.4%',
                            progress: 0.70,
                            status: 'Estándar',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Otros indicadores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _InfoRow(
                            icon: Icons.bloodtype_outlined,
                            label: 'Grasa visceral',
                            value: '5',
                          ),
                          _InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Músculo esquelético',
                            value: '30.9 kg',
                          ),
                          _InfoRow(
                            icon: Icons.scale_outlined,
                            label: 'Peso sin grasa',
                            value: '54.9 kg',
                          ),
                          _InfoRow(
                            icon: Icons.cake_outlined,
                            label: 'Edad corporal',
                            value: '31',
                          ),
                          _InfoRow(
                            icon: Icons.straighten,
                            label: 'WHR',
                            value: '0.84',
                          ),
                        ],
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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF20B2AA),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Felipe Durán',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '+569 1234 5678',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
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
                    _LogoutOption(
                      onTap: () => _logout(context),
                    ),
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

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _ScreenHeader(
              title: 'Panel Profesor',
              subtitle: 'Gestión diaria de alumnos',
              icon: Icons.sports,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: _MetricCard(
                            title: 'Alumnos activos',
                            value: '42',
                            subtitle: 'activos',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'Clases hoy',
                            value: '18',
                            subtitle: 'agendadas',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'Pesajes',
                            value: '6',
                            subtitle: 'semana',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Acciones rápidas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _TeacherActionRow(
                            icon: Icons.person_add_alt,
                            title: 'Registrar alumno',
                            subtitle: 'Nombre, teléfono, plan y vencimiento',
                          ),
                          _TeacherActionRow(
                            icon: Icons.monitor_weight,
                            title: 'Registrar evaluación corporal',
                            subtitle: 'Datos de Body Go Pro / Fitdays',
                          ),
                          _TeacherActionRow(
                            icon: Icons.fitness_center,
                            title: 'Ver rutina semanal',
                            subtitle: 'Plan 2, 3 o 4 sesiones',
                          ),
                          _TeacherActionRow(
                            icon: Icons.upload_file,
                            title: 'Cargar rutinas desde Excel',
                            subtitle: 'Importar planificación del gimnasio',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
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
                    _LogoutOption(
                      onTap: () => _logout(context),
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

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF06111F),
      child: SafeArea(
        child: Column(
          children: [
            const _ScreenHeader(
              title: 'Panel Admin',
              subtitle: 'Resumen general del gimnasio',
              icon: Icons.admin_panel_settings,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F8FA),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: ListView(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                          child: _MetricCard(
                            title: 'Alumnos',
                            value: '128',
                            subtitle: 'activos',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'Vencen pronto',
                            value: '9',
                            subtitle: 'planes',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: _MetricCard(
                            title: 'Asistencia',
                            value: '76%',
                            subtitle: 'mes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Gestión del gimnasio',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _TeacherActionRow(
                            icon: Icons.groups,
                            title: 'Usuarios registrados',
                            subtitle: 'Alumnos, profesores y administradores',
                          ),
                          _TeacherActionRow(
                            icon: Icons.calendar_month,
                            title: 'Planes y vencimientos',
                            subtitle: '2, 3 o 4 sesiones por semana',
                          ),
                          _TeacherActionRow(
                            icon: Icons.insert_chart_outlined,
                            title: 'Reporte de asistencia',
                            subtitle: 'Cumplimiento por alumno y plan',
                          ),
                          _TeacherActionRow(
                            icon: Icons.upload_file,
                            title: 'Importar planificación',
                            subtitle: 'Cargar Excel de rutinas',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Alertas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _AdminAlertRow(
                            icon: Icons.warning_amber,
                            title: '9 alumnos con plan por vencer',
                            subtitle: 'Revisar renovaciones esta semana',
                          ),
                          _AdminAlertRow(
                            icon: Icons.trending_down,
                            title: '12 alumnos con baja asistencia',
                            subtitle: 'Menos del 50% de cumplimiento mensual',
                          ),
                          _AdminAlertRow(
                            icon: Icons.monitor_weight,
                            title: '6 evaluaciones corporales pendientes',
                            subtitle: 'Alumnos sin pesaje actualizado',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LogoutOption(
                      onTap: () => _logout(context),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFF20B2AA),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, Felipe 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Plan: 3 sesiones por semana',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(
            text: 'Activo',
            background: Color(0xFF173D35),
            textColor: Color(0xFF7CFFC4),
          ),
        ],
      ),
    );
  }
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ScreenHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF20B2AA),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Semana actual',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Semana 2 - Ordinario',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _StatusChip(
                text: 'CARGA',
                background: const Color(0xFFDFF9EA),
                textColor: const Color(0xFF12985C),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.calendar_month, size: 17, color: Colors.black45),
              SizedBox(width: 6),
              Text(
                '06 Jul - 12 Jul 2026',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceCards extends StatelessWidget {
  const _AttendanceCards();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetricCard(
            title: 'Asistencia semanal',
            value: '1/3',
            subtitle: '33%',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'Asistencia mensual',
            value: '5/12',
            subtitle: '42%',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'Días restantes',
            value: '18',
            subtitle: 'días',
          ),
        ),
      ],
    );
  }
}

class _NextWorkoutCard extends StatelessWidget {
  final VoidCallback onStartWorkout;

  const _NextWorkoutCard({
    required this.onStartWorkout,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próxima clase',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sesión 1',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.fitness_center, size: 17, color: Colors.black45),
              SizedBox(width: 6),
              Text(
                'Pecho - Tríceps',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF20B2AA),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onStartWorkout,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Comenzar entrenamiento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.play_arrow),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodySummaryCard extends StatelessWidget {
  const _BodySummaryCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen rápido',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.score,
            label: 'Última evaluación',
            value: '72/100',
            chip: true,
          ),
          const _InfoRow(
            icon: Icons.monitor_weight,
            label: 'Peso actual',
            value: '70.0 kg',
          ),
          const _InfoRow(
            icon: Icons.percent,
            label: 'Grasa corporal',
            value: '21.7%',
          ),
          const _InfoRow(
            icon: Icons.accessibility_new,
            label: 'Masa muscular',
            value: '51.2 kg',
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final int number;
  final DemoExercise exercise;

  const _ExerciseCard({
    required this.number,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE9F8F7),
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: Color(0xFF20B2AA),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  exercise.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${exercise.series.length} series',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            exercise.muscleGroup,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Serie',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: 76,
                child: Text(
                  'kg',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8),
              SizedBox(
                width: 76,
                child: Text(
                  'reps',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in exercise.series)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Serie ${item.serie}'),
                  ),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '${item.kg}',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 76,
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '${item.reps}',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BestSetRow extends StatelessWidget {
  final int position;
  final String exercise;
  final String result;
  final String date;

  const _BestSetRow({
    required this.position,
    required this.exercise,
    required this.result,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFFE9F8F7),
            child: Text(
              '$position',
              style: const TextStyle(
                color: Color(0xFF20B2AA),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  result,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyMetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const _BodyMetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFF20B2AA),
            size: 22,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyControlRow extends StatelessWidget {
  final String label;
  final String value;

  const _BodyControlRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = value.startsWith('+');
    final isNegative = value.startsWith('-');

    Color color = Colors.black87;
    if (isPositive) color = const Color(0xFF12985C);
    if (isNegative) color = const Color(0xFFD98200);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyProgressRow extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final String status;

  const _BodyProgressRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE5E7EB),
              color: const Color(0xFF20B2AA),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            status,
            style: const TextStyle(
              color: Color(0xFF12985C),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TeacherActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE9F8F7),
            child: Icon(
              icon,
              color: const Color(0xFF20B2AA),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
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
            backgroundColor: Color(0xFF20B2AA),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  plan,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _StatusChip(
            text: status,
            background:
                isWarning ? const Color(0xFFFFF2D9) : const Color(0xFFDFF9EA),
            textColor:
                isWarning ? const Color(0xFFD98200) : const Color(0xFF12985C),
          ),
        ],
      ),
    );
  }
}

class _AdminAlertRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminAlertRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFFF2D9),
            child: Icon(
              icon,
              color: const Color(0xFFD98200),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;

  const _ProfileOption({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF20B2AA)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38),
        ],
      ),
    );
  }
}

class _LogoutOption extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutOption({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF20B2AA),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool chip;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.chip = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = chip
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFDFF9EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF12985C),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 19, color: const Color(0xFF20B2AA)),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          valueWidget,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;

  const _StatusChip({
    required this.text,
    required this.background,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProgressChartPainter extends CustomPainter {
  final List<double> values;

  ProgressChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final axisPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF20B2AA)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF20B2AA)
      ..style = PaintingStyle.fill;

    final gridTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const leftPadding = 36.0;
    const topPadding = 10.0;
    const bottomPadding = 28.0;
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final minValue = 60.0;
    final maxValue = 90.0;

    for (int i = 0; i <= 3; i++) {
      final y = topPadding + chartHeight * i / 3;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        axisPaint,
      );

      final labelValue = (maxValue - ((maxValue - minValue) * i / 3)).round();
      gridTextPainter.text = TextSpan(
        text: '$labelValue',
        style: const TextStyle(
          color: Colors.black45,
          fontSize: 11,
        ),
      );
      gridTextPainter.layout();
      gridTextPainter.paint(
        canvas,
        Offset(0, y - 7),
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = leftPadding + chartWidth * i / (values.length - 1);
      final normalized = (values[i] - minValue) / (maxValue - minValue);
      final y = topPadding + chartHeight * (1 - normalized);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 5, pointPaint);

      final valueText = TextPainter(
        text: TextSpan(
          text: values[i].toStringAsFixed(values[i] % 1 == 0 ? 0 : 1),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      valueText.layout();
      valueText.paint(
        canvas,
        Offset(points[i].dx - 12, points[i].dy - 24),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DemoExercise {
  final String name;
  final String muscleGroup;
  final List<DemoSet> series;

  DemoExercise({
    required this.name,
    required this.muscleGroup,
    required this.series,
  });
}

class DemoSet {
  final int serie;
  final int kg;
  final int reps;

  DemoSet({
    required this.serie,
    required this.kg,
    required this.reps,
  });
}