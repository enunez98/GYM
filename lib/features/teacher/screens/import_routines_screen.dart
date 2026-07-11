import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/info_row.dart';
import '../../../models/routine_models.dart';
import '../../../services/imported_routine_store.dart';

class ImportRoutinesScreen extends StatefulWidget {
  const ImportRoutinesScreen({super.key});

  @override
  State<ImportRoutinesScreen> createState() => _ImportRoutinesScreenState();
}

class _ImportRoutinesScreenState extends State<ImportRoutinesScreen> {
  String selectedPlan = 'Plan 3 sesiones';
  String selectedFileName = 'Ningún archivo seleccionado';
  bool fileSelected = false;
  bool fileValidated = false;
  Uint8List? selectedFileBytes;
  String detectedSheetName = '-';
  int detectedSheets = 0;
  int detectedRows = 0;
  int detectedColumnsCount = 0;
  List<String> detectedColumns = [];
  List<List<String>> previewRows = [];
  List<String> missingColumns = [];
  int detectedWeeks = 0;
  int detectedSessions = 0;
  int detectedExercises = 0;
  List<DemoRoutineSession> extractedRoutinePreview = [];

  String normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .trim();
  }

  String cellToText(dynamic cell) {
    final value = cell?.value;
    if (value == null) return '';
    final text = value.toString().trim();
    return text
        .replaceAll('TextCellValue(', '')
        .replaceAll('IntCellValue(', '')
        .replaceAll('DoubleCellValue(', '')
        .replaceAll('FormulaCellValue(', '')
        .replaceAll(')', '')
        .trim();
  }

  void readExcelPreview(Uint8List bytes) {
    try {
      final workbook = xls.Excel.decodeBytes(bytes);
      final sheetNames = workbook.tables.keys.toList();
      if (sheetNames.isEmpty) {
        setState(() {
          detectedSheetName = '-';
          detectedSheets = 0;
          detectedRows = 0;
          detectedColumnsCount = 0;
          detectedColumns = [];
          previewRows = [];
          detectedWeeks = 0;
          detectedSessions = 0;
          detectedExercises = 0;
          extractedRoutinePreview = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El Excel no contiene hojas')),
        );
        return;
      }
      final firstSheetName = workbook.tables.containsKey('PLANIFICACION')
          ? 'PLANIFICACION'
          : sheetNames.first;
      final sheet = workbook.tables[firstSheetName];
      if (sheet == null || sheet.rows.isEmpty) {
        setState(() {
          detectedSheetName = firstSheetName;
          detectedSheets = sheetNames.length;
          detectedRows = 0;
          detectedColumnsCount = 0;
          detectedColumns = [];
          previewRows = [];
          detectedWeeks = 0;
          detectedSessions = 0;
          detectedExercises = 0;
          extractedRoutinePreview = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La hoja de planificación está vacía')),
        );
        return;
      }
      final rows = sheet.rows;
      final sessionHeaderRows = <int>[];
      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        if (row.isEmpty) continue;
        final firstCell = cellToText(row[0]);
        if (normalizeText(firstCell) == 'sesion 1') {
          sessionHeaderRows.add(rowIndex);
        }
      }
      const sessionConfigs = [
        {
          'session': 'Sesión 1',
          'exerciseCol': 0,
          'seriesCol': 2,
          'volumeCol': 3,
        },
        {
          'session': 'Sesión 2',
          'exerciseCol': 7,
          'seriesCol': 10,
          'volumeCol': 11,
        },
        {
          'session': 'Sesión 3',
          'exerciseCol': 23,
          'seriesCol': 26,
          'volumeCol': 27,
        },
        {
          'session': 'Sesión 4',
          'exerciseCol': 31,
          'seriesCol': 34,
          'volumeCol': 35,
        },
      ];
      final parsedSessions = <DemoRoutineSession>[];
      for (
        int blockIndex = 0;
        blockIndex < sessionHeaderRows.length;
        blockIndex++
      ) {
        final startRow = sessionHeaderRows[blockIndex];
        final endRow = blockIndex + 1 < sessionHeaderRows.length
            ? sessionHeaderRows[blockIndex + 1]
            : rows.length;
        final weekNumber = blockIndex + 1;
        for (final config in sessionConfigs) {
          final sessionName = config['session'] as String;
          final exerciseCol = config['exerciseCol'] as int;
          final seriesCol = config['seriesCol'] as int;
          final volumeCol = config['volumeCol'] as int;
          final exercises = <DemoRoutineExercise>[];
          for (int rowIndex = startRow + 2; rowIndex < endRow; rowIndex++) {
            final row = rows[rowIndex];
            if (exerciseCol >= row.length) continue;
            final exerciseName = cellToText(row[exerciseCol]).trim();
            if (exerciseName.isEmpty) continue;
            if (normalizeText(exerciseName).contains('medios')) continue;
            if (normalizeText(exerciseName).contains('sesion')) continue;
            final seriesText = seriesCol < row.length
                ? cellToText(row[seriesCol])
                : '';
            final volumeText = volumeCol < row.length
                ? cellToText(row[volumeCol])
                : '';
            final parsedSeries = int.tryParse(
              seriesText.replaceAll('.0', '').trim(),
            );
            exercises.add(
              DemoRoutineExercise(
                name: exerciseName,
                series: parsedSeries ?? 1,
                reps: volumeText.isNotEmpty ? volumeText : 'Por definir',
              ),
            );
          }
          if (exercises.isNotEmpty) {
            parsedSessions.add(
              DemoRoutineSession(
                session: 'Semana $weekNumber',
                title: sessionName,
                exercises: exercises,
              ),
            );
          }
        }
      }
      final totalExercises = parsedSessions.fold<int>(
        0,
        (total, session) => total + session.exercises.length,
      );
      final preview = parsedSessions
          .take(5)
          .map(
            (session) => [
              session.session,
              session.title,
              '${session.exercises.length} ejercicios',
              session.exercises
                  .take(3)
                  .map((exercise) => exercise.name)
                  .join(', '),
            ],
          )
          .toList();
      setState(() {
        detectedSheetName = firstSheetName;
        detectedSheets = sheetNames.length;
        detectedRows = rows.length;
        detectedColumnsCount = rows.fold<int>(
          0,
          (max, row) => row.length > max ? row.length : max,
        );
        detectedColumns = [
          'Formato matriz detectado',
          'Semanas',
          'Sesiones',
          'Ejercicios',
        ];
        previewRows = preview;
        missingColumns = [];
        detectedWeeks = sessionHeaderRows.length;
        detectedSessions = parsedSessions.length;
        detectedExercises = totalExercises;
        extractedRoutinePreview = parsedSessions;
        if (detectedSessions >= 4) {
          selectedPlan = 'Plan 4 sesiones';
        }
      });
    } catch (e) {
      setState(() {
        detectedSheetName = '-';
        detectedSheets = 0;
        detectedRows = 0;
        detectedColumnsCount = 0;
        detectedColumns = [];
        previewRows = [];
        missingColumns = [];
        detectedWeeks = 0;
        detectedSessions = 0;
        detectedExercises = 0;
        extractedRoutinePreview = [];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo leer el Excel: $e')));
    }
  }

  Future<void> selectFile() async {
    const XTypeGroup excelTypeGroup = XTypeGroup(
      label: 'Excel',
      extensions: <String>['xlsx'],
      mimeTypes: <String>[
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      ],
      uniformTypeIdentifiers: <String>[
        'org.openxmlformats.spreadsheetml.sheet',
      ],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: <XTypeGroup>[excelTypeGroup],
    );

    if (!mounted) return;

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se seleccionó ningún archivo')),
      );
      return;
    }

    final fileName = file.name;

    if (!fileName.toLowerCase().endsWith('.xlsx')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El archivo debe estar en formato .xlsx')),
      );
      return;
    }

    final bytes = await file.readAsBytes();

    setState(() {
      selectedFileName = fileName;
      selectedFileBytes = bytes;
      fileSelected = true;
      fileValidated = false;
      missingColumns = [];
    });

    readExcelPreview(bytes);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Archivo seleccionado: $fileName')));
  }

  void validateFile() {
    if (!fileSelected || selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero selecciona un archivo Excel')),
      );
      return;
    }

    if (detectedSheetName != 'PLANIFICACION') {
      setState(() {
        fileValidated = false;
        missingColumns = ['Hoja PLANIFICACION'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la hoja PLANIFICACION')),
      );
      return;
    }

    if (detectedWeeks == 0 || detectedSessions == 0 || detectedExercises == 0) {
      setState(() {
        fileValidated = false;
        missingColumns = ['Bloques de sesiones', 'Ejercicios planificados'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se detectaron sesiones o ejercicios en el Excel'),
        ),
      );
      return;
    }

    setState(() {
      fileValidated = true;
      missingColumns = [];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Excel validado: $detectedWeeks semanas, $detectedSessions sesiones, $detectedExercises ejercicios',
        ),
      ),
    );
  }

  void importRoutine() {
    if (!fileValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero valida el archivo antes de cargarlo'),
        ),
      );
      return;
    }
    ImportedRoutineStore.save(
      selectedPlan: selectedPlan,
      importedSessions: extractedRoutinePreview,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Rutina cargada: $detectedWeeks semanas, $detectedSessions sesiones, $detectedExercises ejercicios',
        ),
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
              title: 'Cargar rutinas',
              subtitle: 'Importar planificación desde Excel',
              icon: Icons.upload_file,
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
                            'Plan destino',
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
                              prefixIcon: const Icon(Icons.assignment),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Archivo Excel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F8FA),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: fileSelected
                                    ? const Color(0xFF20B2AA)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  fileSelected
                                      ? Icons.check_circle
                                      : Icons.upload_file,
                                  color: fileSelected
                                      ? const Color(0xFF20B2AA)
                                      : Colors.black45,
                                  size: 42,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  selectedFileName,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: fileSelected
                                        ? Colors.black87
                                        : Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Formato esperado: .xlsx',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF20B2AA),
                                side: const BorderSide(
                                  color: Color(0xFF20B2AA),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: selectFile,
                              icon: const Icon(Icons.attach_file),
                              label: const Text(
                                'Seleccionar Excel',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
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
                            'Columnas esperadas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 14),
                          _ImportColumnRow(
                            name: 'Semana',
                            description: 'Ej: Semana 1, Semana 2',
                          ),
                          _ImportColumnRow(
                            name: 'Tipo semana',
                            description: 'Ordinario, carga o recuperación',
                          ),
                          _ImportColumnRow(
                            name: 'Sesión',
                            description: 'Sesión 1, 2, 3 o 4',
                          ),
                          _ImportColumnRow(
                            name: 'Ejercicio',
                            description: 'Nombre del ejercicio',
                          ),
                          _ImportColumnRow(
                            name: 'Series',
                            description: 'Cantidad de series planificadas',
                          ),
                          _ImportColumnRow(
                            name: 'Repeticiones',
                            description: 'Rango objetivo de reps',
                          ),
                          _ImportColumnRow(
                            name: 'Orden',
                            description: 'Orden del ejercicio en la sesión',
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
                            'Lectura del Excel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          InfoRow(
                            icon: Icons.description_outlined,
                            label: 'Hoja detectada',
                            value: detectedSheetName,
                          ),
                          InfoRow(
                            icon: Icons.table_chart_outlined,
                            label: 'Hojas',
                            value: '$detectedSheets',
                          ),
                          InfoRow(
                            icon: Icons.view_list_outlined,
                            label: 'Filas',
                            value: '$detectedRows',
                          ),
                          InfoRow(
                            icon: Icons.view_column_outlined,
                            label: 'Columnas',
                            value: '$detectedColumnsCount',
                          ),
                          InfoRow(
                            icon: Icons.calendar_month,
                            label: 'Semanas detectadas',
                            value: '$detectedWeeks',
                          ),
                          InfoRow(
                            icon: Icons.fitness_center,
                            label: 'Sesiones detectadas',
                            value: '$detectedSessions',
                          ),
                          InfoRow(
                            icon: Icons.list_alt,
                            label: 'Ejercicios detectados',
                            value: '$detectedExercises',
                          ),
                          if (detectedColumns.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Columnas encontradas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: detectedColumns
                                  .map(
                                    (column) => Chip(
                                      label: Text(column),
                                      backgroundColor: const Color(0xFFE9F8F7),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (missingColumns.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            const Text(
                              'Columnas faltantes',
                              style: TextStyle(
                                color: Color(0xFFE11D48),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: missingColumns
                                  .map(
                                    (column) => Chip(
                                      label: Text(column),
                                      backgroundColor: const Color(0xFFFFE4E6),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (extractedRoutinePreview.isNotEmpty)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rutinas detectadas',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 14),
                            for (
                              int i = 0;
                              i < extractedRoutinePreview.take(8).length;
                              i++
                            ) ...[
                              Text(
                                '${extractedRoutinePreview[i].session} · ${extractedRoutinePreview[i].title}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF20B2AA),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                extractedRoutinePreview[i].exercises
                                    .take(4)
                                    .map((exercise) => exercise.name)
                                    .join(' | '),
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                              if (i <
                                  extractedRoutinePreview.take(8).length - 1)
                                const Divider(height: 18),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 14),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado de validación',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ValidationRow(
                            label: 'Archivo seleccionado',
                            isOk: fileSelected,
                          ),
                          _ValidationRow(
                            label: 'Formato .xlsx',
                            isOk: fileSelected,
                          ),
                          _ValidationRow(
                            label: 'Columnas obligatorias',
                            isOk: fileValidated,
                          ),
                          _ValidationRow(
                            label: 'Rutina lista para cargar',
                            isOk: fileValidated,
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
                        onPressed: validateFile,
                        icon: const Icon(Icons.fact_check),
                        label: const Text(
                          'Validar archivo',
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
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fileValidated
                              ? const Color(0xFF06111F)
                              : Colors.black26,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: importRoutine,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text(
                          'Cargar rutina',
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

class _ImportColumnRow extends StatelessWidget {
  final String name;
  final String description;

  const _ImportColumnRow({required this.name, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.table_chart_outlined,
            color: Color(0xFF20B2AA),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            description,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final String label;
  final bool isOk;

  const _ValidationRow({required this.label, required this.isOk});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isOk ? const Color(0xFF20B2AA) : Colors.black38,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isOk ? FontWeight.bold : FontWeight.normal,
                color: isOk ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
