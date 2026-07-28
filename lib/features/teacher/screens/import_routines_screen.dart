import 'dart:typed_data';

import 'package:excel/excel.dart' as xls;
import 'package:file_selector/file_selector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/form_header.dart';
import '../../../core/widgets/responsive_action_button.dart';
import '../../../core/widgets/responsive_form_field.dart';
import '../../../core/widgets/info_row.dart';
import '../../../models/routine_models.dart';
import '../../../services/imported_routine_store.dart';
import '../../../services/routine_persistence_service.dart';

class ImportRoutinesScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const ImportRoutinesScreen({super.key, this.onClose});

  @override
  State<ImportRoutinesScreen> createState() => _ImportRoutinesScreenState();
}

class _ImportRoutinesScreenState extends State<ImportRoutinesScreen> {
  String? selectedPlan;
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
  bool isImporting = false;
  bool showTechnicalValidationDetails = false;

  void closeScreen() {
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose();
      return;
    }
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<void> showRoutineResult({required bool success, String? detail}) {
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
          success ? 'Rutina cargada' : 'No se pudo cargar la rutina',
          textAlign: TextAlign.center,
        ),
        content: Text(
          success
              ? 'La rutina se ha cargado exitosamente.${detail == null ? '' : '\n\n$detail'}'
              : detail ?? 'Inténtalo nuevamente.',
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

  int getSessionNumber(String value) {
    return int.tryParse(RegExp(r'\d+').firstMatch(value)?.group(0) ?? '') ?? 0;
  }

  int _selectedPlanSessionCount() {
    return selectedPlan == null ? 0 : getSessionNumber(selectedPlan!);
  }

  List<DemoRoutineSession> _sessionsForSelectedPlan() {
    final maximumSession = _selectedPlanSessionCount();
    return extractedRoutinePreview
        .where(
          (session) =>
              getSessionNumber(session.title) > 0 &&
              getSessionNumber(session.title) <= maximumSession,
        )
        .toList();
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
        final sessionHeader = rows[startRow];
        final fieldHeader = startRow + 1 < rows.length
            ? rows[startRow + 1]
            : sessionHeader.take(0).toList();
        final sessionColumns = <({int number, int start, int end})>[];

        for (int column = 0; column < sessionHeader.length; column++) {
          final header = normalizeText(cellToText(sessionHeader[column]));
          final match = RegExp(r'^sesion\s*([1-4])$').firstMatch(header);
          if (match == null) continue;
          sessionColumns.add((
            number: int.parse(match.group(1)!),
            start: column,
            end: sessionHeader.length,
          ));
        }
        sessionColumns.sort(
          (first, second) => first.start.compareTo(second.start),
        );
        final boundedSessionColumns = <({int number, int start, int end})>[
          for (int index = 0; index < sessionColumns.length; index++)
            (
              number: sessionColumns[index].number,
              start: sessionColumns[index].start,
              end: index + 1 < sessionColumns.length
                  ? sessionColumns[index + 1].start
                  : sessionHeader.length,
            ),
        ];

        for (final sessionColumn in boundedSessionColumns) {
          var seriesCol = sessionColumn.start + 2;
          var volumeCol = sessionColumn.start + 3;
          for (
            int column = sessionColumn.start;
            column < sessionColumn.end && column < fieldHeader.length;
            column++
          ) {
            final field = normalizeText(cellToText(fieldHeader[column]));
            if (field.contains('serie')) seriesCol = column;
            if (field.contains('volumen') ||
                field.contains('repet') ||
                field == 'reps') {
              volumeCol = column;
            }
          }

          final sessionName = 'Sesión ${sessionColumn.number}';
          final exerciseCol = sessionColumn.start;
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

    XFile? file;
    try {
      file = await openFile(acceptedTypeGroups: <XTypeGroup>[excelTypeGroup]);
    } catch (error) {
      debugPrint('Error al seleccionar el archivo de rutina: $error');
      if (!mounted) return;
      await showRoutineResult(
        success: false,
        detail: 'No fue posible abrir el archivo seleccionado.',
      );
      return;
    }

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

    late final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (error) {
      debugPrint('Error al leer el archivo de rutina: $error');
      if (!mounted) return;
      await showRoutineResult(
        success: false,
        detail: 'No fue posible leer el archivo seleccionado.',
      );
      return;
    }
    if (!mounted) return;

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

  String? validationError() {
    if (selectedPlan == null) {
      return 'Debes seleccionar el plan de destino.';
    }
    if (!fileSelected || selectedFileBytes == null) {
      return 'Debes seleccionar un archivo Excel.';
    }
    if (!selectedFileName.toLowerCase().endsWith('.xlsx')) {
      return 'El archivo seleccionado debe estar en formato .xlsx.';
    }
    if (detectedSheetName != 'PLANIFICACION') {
      return 'No se encontró la hoja obligatoria PLANIFICACION.';
    }
    if (detectedWeeks == 0 || detectedSessions == 0 || detectedExercises == 0) {
      return 'No se detectaron semanas, sesiones o ejercicios válidos en el Excel.';
    }
    final sessionsToImport = _sessionsForSelectedPlan();
    if (sessionsToImport.isEmpty) {
      return 'El Excel no contiene sesiones válidas para el plan seleccionado.';
    }
    final expectedSessions = _selectedPlanSessionCount();
    final weeks = sessionsToImport.map((session) => session.session).toSet();
    final incompleteWeek = weeks.any((week) {
      final sessionNumbers = sessionsToImport
          .where((session) => session.session == week)
          .map((session) => getSessionNumber(session.title))
          .toSet();
      return [
        for (int number = 1; number <= expectedSessions; number++) number,
      ].any((number) => !sessionNumbers.contains(number));
    });
    if (incompleteWeek) {
      return 'El archivo no contiene las $expectedSessions sesiones del plan en cada semana.';
    }
    return null;
  }

  Future<void> importRoutine() async {
    if (isImporting) return;
    final error = validationError();
    if (error != null) {
      await showRoutineResult(success: false, detail: error);
      return;
    }
    final destinationPlan = selectedPlan;
    if (destinationPlan == null) return;
    final sessionsToImport = _sessionsForSelectedPlan();

    setState(() => isImporting = true);
    try {
      final result = Firebase.apps.isEmpty
          ? RoutinePersistenceService.replaceLocally(
              plan: destinationPlan,
              sourceFileName: selectedFileName,
              sessions: sessionsToImport,
            )
          : await RoutinePersistenceService.replaceForPlan(
              plan: destinationPlan,
              sourceFileName: selectedFileName,
              sessions: sessionsToImport,
            );
      ImportedRoutineStore.save(
        selectedPlan: destinationPlan,
        importedSessions: sessionsToImport,
        sourceFileName: selectedFileName,
      );

      if (!mounted) return;
      setState(() => isImporting = false);
      await showRoutineResult(
        success: true,
        detail:
            '${result.assignedStudents} ${result.assignedStudents == 1 ? 'alumno actualizado' : 'alumnos actualizados'}.',
      );
      if (!mounted) return;
      closeScreen();
    } catch (error) {
      debugPrint('Error al cargar la rutina: $error');
      if (!mounted) return;
      setState(() => isImporting = false);
      await showRoutineResult(
        success: false,
        detail:
            'No fue posible guardar la rutina. Revisa tu conexión e inténtalo nuevamente.',
      );
    }
  }

  Widget buildSelectFileButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF59D52D),
          side: const BorderSide(color: Color(0xFF59D52D)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isImporting ? null : selectFile,
        icon: const Icon(Icons.attach_file),
        label: const Text(
          'Seleccionar Excel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildImportButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111214),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isImporting ? null : importRoutine,
        icon: isImporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cloud_upload),
        label: Text(
          isImporting ? 'Cargando rutina...' : 'Cargar rutina',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      body: SafeArea(
        child: Column(
          children: [
            FormHeader(
              title: 'Cargar rutinas',
              subtitle: 'Importar planificación desde Excel',
              icon: Icons.upload_file,
              onBack: closeScreen,
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
                          ResponsiveFormField(
                            child: AppSelectField(
                              value: selectedPlan,
                              hint: 'Seleccionar plan',
                              decoration: InputDecoration(
                                labelText: 'Plan',
                                prefixIcon: const Icon(Icons.assignment),
                                filled: true,
                                fillColor: const Color(0xFFF6F7F7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
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
                          ResponsiveFormField(
                            webMaxWidth: 720,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7F7),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: fileSelected
                                      ? const Color(0xFF59D52D)
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
                                        ? const Color(0xFF59D52D)
                                        : Color(0xFF616B76),
                                    size: 42,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    selectedFileName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF616B76),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Formato esperado: .xlsx',
                                    style: TextStyle(
                                      color: Color(0xFF616B76),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ResponsiveFormField(
                            webMaxWidth: 720,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                if (MediaQuery.sizeOf(context).width >= 900) {
                                  return Row(
                                    children: [
                                      Expanded(child: buildSelectFileButton()),
                                      const SizedBox(width: 14),
                                      Expanded(child: buildImportButton()),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: buildSelectFileButton(),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      child: buildImportButton(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (showTechnicalValidationDetails) ...[
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
                                        backgroundColor: const Color(
                                          0xFFEDF9E8,
                                        ),
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
                                        backgroundColor: const Color(
                                          0xFFFFE4E6,
                                        ),
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
                                    color: Color(0xFF59D52D),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  extractedRoutinePreview[i].exercises
                                      .take(4)
                                      .map((exercise) => exercise.name)
                                      .join(' | '),
                                  style: const TextStyle(
                                    color: Color(0xFF616B76),
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
                              isOk: fileValidated && selectedPlan != null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ResponsiveActionButton(
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
                            onPressed: null,
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
                      ),
                      const SizedBox(height: 10),
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
            color: Color(0xFF59D52D),
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
            style: const TextStyle(color: Color(0xFF616B76), fontSize: 12),
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
            color: isOk ? const Color(0xFF59D52D) : Color(0xFF7A838C),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isOk ? FontWeight.bold : FontWeight.normal,
                color: isOk ? const Color(0xFFF6F7F7) : Color(0xFF616B76),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
