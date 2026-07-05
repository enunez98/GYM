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
      home: const StudentHomeScreen(),
    );
  }
}

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111F),
      body: SafeArea(
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
                  children: const [
                    _WeekCard(),
                    SizedBox(height: 14),
                    _AttendanceCards(),
                    SizedBox(height: 14),
                    _NextWorkoutCard(),
                    SizedBox(height: 14),
                    _BodySummaryCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF173D35),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Activo',
              style: TextStyle(
                color: Color(0xFF7CFFC4),
                fontWeight: FontWeight.w600,
              ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF9EA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'CARGA',
                  style: TextStyle(
                    color: Color(0xFF12985C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
  const _NextWorkoutCard();

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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WorkoutScreen(),
                  ),
                );
              },
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

class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exercises = [
      DemoExercise(
        name: 'Press Banca Plano',
        series: [
          DemoSet(serie: 1, kg: 60, reps: 10),
          DemoSet(serie: 2, kg: 65, reps: 10),
          DemoSet(serie: 3, kg: 65, reps: 8),
          DemoSet(serie: 4, kg: 60, reps: 10),
        ],
      ),
      DemoExercise(
        name: 'Press Inclinado Mancuernas',
        series: [
          DemoSet(serie: 1, kg: 28, reps: 12),
          DemoSet(serie: 2, kg: 30, reps: 10),
          DemoSet(serie: 3, kg: 30, reps: 10),
          DemoSet(serie: 4, kg: 28, reps: 12),
        ],
      ),
      DemoExercise(
        name: 'Extensión de Tríceps',
        series: [
          DemoSet(serie: 1, kg: 25, reps: 12),
          DemoSet(serie: 2, kg: 30, reps: 10),
          DemoSet(serie: 3, kg: 30, reps: 10),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06111F),
        foregroundColor: Colors.white,
        title: const Text('Entrenamiento'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2D9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Pendiente',
                        style: TextStyle(
                          color: Color(0xFFD98200),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    content: Text('Entrenamiento guardado correctamente'),
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
              const Text(
                '4 series',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
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

class DemoExercise {
  final String name;
  final List<DemoSet> series;

  DemoExercise({
    required this.name,
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
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
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
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}