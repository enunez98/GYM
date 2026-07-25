import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../models/student_profile.dart';
import '../../../services/body_evaluation_store.dart';
import '../../../services/student_attendance_service.dart';
import '../../../services/student_profile_store.dart';
import 'register_student_screen.dart';
import 'student_detail_screen.dart';

class StudentsListScreen extends StatefulWidget {
  final bool initiallyShowRegisterStudent;

  const StudentsListScreen({
    super.key,
    this.initiallyShowRegisterStudent = false,
  });

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'Todos los estados';
  String _selectedOrder = 'Nombre A-Z';
  int _currentPage = 0;
  StudentProfile? _selectedStudent;
  bool _showRegisterStudent = false;

  static const int _studentsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _showRegisterStudent = widget.initiallyShowRegisterStudent;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StudentProfile> get _visibleStudents {
    final query = _searchController.text.trim().toLowerCase();
    final students = StudentProfileStore.all.where((student) {
      final matchesStatus =
          _selectedStatus == 'Todos los estados' ||
          student.status == _selectedStatus;
      final matchesSearch =
          query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.rut.toLowerCase().contains(query) ||
          student.phone.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();

    students.sort(
      (a, b) => _selectedOrder == 'Nombre Z-A'
          ? b.name.toLowerCase().compareTo(a.name.toLowerCase())
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return students;
  }

  Future<void> _openRegisterStudent() async {
    if (MediaQuery.sizeOf(context).width >= 900) {
      setState(() {
        _selectedStudent = null;
        _showRegisterStudent = true;
      });
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const RegisterStudentScreen()),
    );
    if (mounted) setState(() => _currentPage = 0);
  }

  void _openStudent(StudentProfile student) {
    setState(() => _selectedStudent = student);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 900) {
      return _buildWeb(context);
    }
    return _buildMobile(context);
  }

  Widget _buildWeb(BuildContext context) {
    final students = StudentProfileStore.all;
    final visibleStudents = _visibleStudents;
    final totalPages = visibleStudents.isEmpty
        ? 1
        : (visibleStudents.length / _studentsPerPage).ceil();
    final safeCurrentPage = math.min(_currentPage, totalPages - 1);
    final pageStart = safeCurrentPage * _studentsPerPage;
    final pageStudents = visibleStudents
        .skip(pageStart)
        .take(_studentsPerPage)
        .toList();
    final activeCount = _countStatus(students, 'Activo');
    final expiringCount = _countStatus(students, 'Por vencer');
    final expiredCount = _countStatus(students, 'Vencido');
    final inactiveCount = _countStatus(students, 'Inactivo');

    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Alumnos',
              subtitle: 'Listado general del gimnasio',
              icon: Icons.groups,
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: _showRegisterStudent
                    ? _buildWebRegisterStudent()
                    : _selectedStudent != null
                    ? _buildWebStudentDetail(_selectedStudent!)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (_) {
                                    setState(() => _currentPage = 0);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Buscar alumno...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE1E5E8),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE1E5E8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _openRegisterStudent,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF59D52D),
                                    foregroundColor: const Color(0xFF111214),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text(
                                    'Registrar alumno',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: MetricCard(
                                  title: 'Activos',
                                  value: '$activeCount',
                                  subtitle: 'alumnos',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MetricCard(
                                  title: 'Por vencer',
                                  value: '$expiringCount',
                                  subtitle: 'planes',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MetricCard(
                                  title: 'Vencidos',
                                  value: '$expiredCount',
                                  subtitle: 'planes',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MetricCard(
                                  title: 'Inactivos',
                                  value: '$inactiveCount',
                                  subtitle: 'alumnos',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              SizedBox(
                                width: 210,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedStatus,
                                  isExpanded: true,
                                  decoration: _filterDecoration(),
                                  items:
                                      const [
                                            'Todos los estados',
                                            'Activo',
                                            'Por vencer',
                                            'Vencido',
                                            'Inactivo',
                                          ]
                                          .map(
                                            (status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedStatus =
                                          value ?? 'Todos los estados';
                                      _currentPage = 0;
                                    });
                                  },
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 205,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _selectedOrder,
                                  isExpanded: true,
                                  decoration: _filterDecoration(
                                    label: 'Ordenar por',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Nombre A-Z',
                                      child: Text('Nombre A-Z'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Nombre Z-A',
                                      child: Text('Nombre Z-A'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedOrder = value ?? 'Nombre A-Z';
                                      _currentPage = 0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton.filledTonal(
                                tooltip: 'Filtros',
                                onPressed: () {},
                                icon: const Icon(Icons.filter_list),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: _StudentsWebTable(
                              students: pageStudents,
                              currentPage: safeCurrentPage,
                              totalPages: totalPages,
                              onPageChanged: (page) {
                                setState(() => _currentPage = page);
                              },
                              onStudentTap: _openStudent,
                            ),
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

  Widget _buildWebStudentDetail(StudentProfile student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _selectedStudent = null),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al listado'),
            ),
            const SizedBox(width: 12),
            const Text(
              'Alumnos',
              style: TextStyle(
                color: Color(0xFF3BAF19),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF7A838C),
              ),
            ),
            const Text(
              'Detalle del alumno',
              style: TextStyle(color: Color(0xFF616B76)),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF7A838C),
              ),
            ),
            Expanded(
              child: Text(
                student.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(child: StudentDetailScreen(student: student, embedded: true)),
      ],
    );
  }

  Widget _buildWebRegisterStudent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _showRegisterStudent = false),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al listado'),
            ),
            const SizedBox(width: 12),
            const Text(
              'Alumnos',
              style: TextStyle(
                color: Color(0xFF3BAF19),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: Color(0xFF7A838C),
              ),
            ),
            const Text(
              'Registrar alumno',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: RegisterStudentScreen(
            embedded: true,
            onClose: () {
              setState(() {
                _showRegisterStudent = false;
                _currentPage = 0;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    if (_selectedStudent != null) {
      return _buildMobileStudentDetail(_selectedStudent!);
    }

    final students = StudentProfileStore.all;
    final activeCount = _countStatus(students, 'Activo');
    final expiringCount = _countStatus(students, 'Por vencer');
    final expiredCount = _countStatus(students, 'Vencido');

    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Alumnos',
              subtitle: 'Listado general del gimnasio',
              icon: Icons.groups,
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
                      child: ResponsiveFormField(
                        webMaxWidth: 620,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Buscar alumno...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xFFF6F7F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Activos',
                            value: '$activeCount',
                            subtitle: 'alumnos',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Por vencer',
                            value: '$expiringCount',
                            subtitle: 'planes',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: MetricCard(
                            title: 'Vencidos',
                            value: '$expiredCount',
                            subtitle: 'planes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final student in students) ...[
                      _StudentListCard(
                        student: student,
                        onTap: () => _openStudent(student),
                      ),
                      const SizedBox(height: 12),
                    ],
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

  Widget _buildMobileStudentDetail(StudentProfile student) {
    return Scaffold(
      backgroundColor: const Color(0xFF00111F),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: student.name,
              subtitle: student.plan,
              icon: Icons.person,
              onBack: () => setState(() => _selectedStudent = null),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F7F7),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: StudentDetailScreen(student: student, embedded: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countStatus(List<StudentProfile> students, String status) {
    return students.where((student) => student.status == status).length;
  }

  InputDecoration _filterDecoration({String? label}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE1E5E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE1E5E8)),
      ),
    );
  }
}

class _StudentsWebTable extends StatelessWidget {
  final List<StudentProfile> students;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<StudentProfile> onStudentTap;

  const _StudentsWebTable({
    required this.students,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    required this.onStudentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E5E8)),
      ),
      child: Column(
        children: [
          const _StudentsTableHeader(),
          const Divider(height: 1),
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron alumnos',
                      style: TextStyle(color: Color(0xFF616B76)),
                    ),
                  )
                : ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _StudentsTableRow(
                        student: student,
                        onTap: () => onStudentTap(student),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 52,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Página anterior',
                  onPressed: currentPage > 0
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                ..._pageButtons(),
                IconButton(
                  tooltip: 'Página siguiente',
                  onPressed: currentPage < totalPages - 1
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _pageButtons() {
    final visibleCount = math.min(totalPages, 5);
    final maxStart = math.max(0, totalPages - visibleCount);
    final start = math.min(math.max(0, currentPage - 2), maxStart);

    return [
      for (int page = start; page < start + visibleCount; page++) ...[
        if (page > start) const SizedBox(width: 8),
        _PageNumber(
          text: '${page + 1}',
          selected: page == currentPage,
          onTap: () => onPageChanged(page),
        ),
      ],
    ];
  }
}

class _StudentsTableHeader extends StatelessWidget {
  const _StudentsTableHeader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(width: 18),
          Expanded(flex: 3, child: Text('Alumno')),
          Expanded(flex: 3, child: Text('Contacto')),
          Expanded(flex: 2, child: Text('Plan')),
          Expanded(flex: 2, child: Text('Estado')),
          Expanded(flex: 2, child: Text('Vencimiento')),
          SizedBox(width: 58),
        ],
      ),
    );
  }
}

class _StudentsTableRow extends StatelessWidget {
  final StudentProfile student;
  final VoidCallback onTap;

  const _StudentsTableRow({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final statusColors = _statusColors(student.status);
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            const SizedBox(width: 18),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: const Color(0xFFDCF8D3),
                    child: Text(
                      _initials(student.name),
                      style: const TextStyle(
                        color: Color(0xFF236D0B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'RUT: ${_formatRut(student.rut)}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7A838C),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.phone, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    student.email.isEmpty
                        ? 'Sin correo registrado'
                        : student.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7A838C),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.plan, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  const Text(
                    '1 mes',
                    style: TextStyle(color: Color(0xFF7A838C), fontSize: 12),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  text: student.status,
                  background: statusColors.$1,
                  textColor: statusColors.$2,
                ),
              ),
            ),
            Expanded(flex: 2, child: Text(student.endDate)),
            SizedBox(
              width: 58,
              child: IconButton(
                tooltip: 'Ver ficha',
                onPressed: onTap,
                icon: const Icon(Icons.more_horiz),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _PageNumber({
    required this.text,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFBFF5AD) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(text),
      ),
    );
  }
}

class _StudentListCard extends StatelessWidget {
  final StudentProfile student;
  final VoidCallback onTap;

  const _StudentListCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final attendance = StudentAttendanceService.getSummary(student);
    final evaluation = BodyEvaluationStore.getLastByUserId(student.userId);
    final bodyScore = evaluation?.bodyScore ?? student.bodyScore;
    final statusColors = _statusColors(student.status);

    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Color(0xFF59D52D),
              child: Icon(Icons.person, color: Color(0xFF111214)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.plan,
                    style: const TextStyle(color: Color(0xFF616B76)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    student.phone,
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Asistencia: ${attendance.monthlyText} · Evaluación: $bodyScore/100',
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Vence: ${student.endDate}',
                    style: const TextStyle(
                      color: Color(0xFF616B76),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            StatusChip(
              text: student.status,
              background: statusColors.$1,
              textColor: statusColors.$2,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFF7A838C)),
          ],
        ),
      ),
    );
  }
}

(Color, Color) _statusColors(String status) {
  return switch (status) {
    'Por vencer' => (const Color(0xFFFFF2D9), const Color(0xFFD98200)),
    'Vencido' => (const Color(0xFFFFE4E6), const Color(0xFFE11D48)),
    'Inactivo' => (const Color(0xFFE9ECEF), const Color(0xFF616B76)),
    _ => (const Color(0xFFEDF9E8), const Color(0xFF3A9E1A)),
  };
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _formatRut(String rut) {
  final clean = rut
      .replaceAll('.', '')
      .replaceAll('-', '')
      .replaceAll(' ', '')
      .toUpperCase();
  if (clean.length < 2) return rut;

  final body = clean.substring(0, clean.length - 1);
  final verifier = clean.substring(clean.length - 1);
  final reversed = body.split('').reversed.toList();
  final grouped = <String>[];

  for (var index = 0; index < reversed.length; index += 3) {
    grouped.add(reversed.skip(index).take(3).toList().reversed.join());
  }

  return '${grouped.reversed.join('.')}-$verifier';
}
