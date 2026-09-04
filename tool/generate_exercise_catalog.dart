import 'dart:convert';
import 'dart:io';

String slug(String value) => value
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('é', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ñ', 'n')
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_|_$'), '');

void main() {
  const variants = ['con barra', 'con mancuernas', 'en máquina'];
  const exercises = <String, List<String>>{
    'Pecho': [
      'Press banca plano',
      'Press banca inclinado',
      'Press banca declinado',
      'Press de pecho sentado',
      'Press de pecho unilateral',
      'Press de pecho agarre neutro',
      'Press de pecho en suelo',
      'Press hexagonal',
      'Press Svend',
      'Press guillotina',
      'Apertura plana',
      'Apertura inclinada',
      'Apertura declinada',
      'Apertura unilateral',
      'Cruce de poleas alto',
      'Cruce de poleas medio',
      'Cruce de poleas bajo',
      'Fondos para pecho',
      'Flexión tradicional',
      'Flexión inclinada',
      'Flexión declinada',
      'Flexión diamante',
      'Flexión amplia',
      'Pullover de pecho',
      'Pec deck',
    ],
    'Piernas': [
      'Sentadilla trasera',
      'Sentadilla frontal',
      'Sentadilla goblet',
      'Sentadilla sumo',
      'Sentadilla búlgara',
      'Sentadilla hack',
      'Sentadilla sissy',
      'Prensa de piernas',
      'Prensa unilateral',
      'Peso muerto rumano',
      'Peso muerto sumo',
      'Peso muerto piernas rígidas',
      'Zancada frontal',
      'Zancada inversa',
      'Zancada lateral',
      'Zancada caminando',
      'Step up',
      'Extensión de cuádriceps',
      'Curl femoral sentado',
      'Curl femoral tumbado',
      'Curl femoral de pie',
      'Hip thrust',
      'Puente de glúteos',
      'Abducción de cadera',
      'Elevación de pantorrillas',
    ],
    'Hombro': [
      'Press militar',
      'Press Arnold',
      'Press de hombro sentado',
      'Press de hombro unilateral',
      'Press tras nuca',
      'Press landmine',
      'Elevación lateral',
      'Elevación lateral inclinada',
      'Elevación lateral unilateral',
      'Elevación frontal',
      'Elevación frontal alternada',
      'Elevación posterior',
      'Pájaro inclinado',
      'Pájaro sentado',
      'Reverse fly',
      'Face pull',
      'Remo al mentón',
      'Remo alto',
      'Cuban press',
      'Rotación externa',
      'Rotación interna',
      'Y raise',
      'T raise',
      'Encogimiento sobre cabeza',
      'Plancha con toque de hombro',
    ],
    'Espalda': [
      'Dominada pronada',
      'Dominada supina',
      'Dominada neutra',
      'Dominada asistida',
      'Jalón al pecho',
      'Jalón tras nuca',
      'Jalón agarre cerrado',
      'Jalón unilateral',
      'Remo con barra',
      'Remo Pendlay',
      'Remo T',
      'Remo sentado',
      'Remo unilateral',
      'Remo invertido',
      'Remo Meadows',
      'Remo pecho apoyado',
      'Pullover en polea',
      'Pullover tumbado',
      'Peso muerto convencional',
      'Buenos días',
      'Hiperextensión lumbar',
      'Extensión lumbar',
      'Encogimiento escapular',
      'Rack pull',
      'Superman',
    ],
  };

  final catalog = <Map<String, Object>>[];
  var id = 1;
  for (final group in exercises.entries) {
    for (final base in group.value) {
      for (final variant in variants) {
        final name = '$base $variant';
        final file = slug(name);
        catalog.add({
          'id': id++,
          'nombre': name,
          'musculo': group.key,
          'imagen': '${file}_inicio.webp',
          'imagenes': {
            'inicio': '${file}_inicio.webp',
            'bajada': '${file}_bajada.webp',
            'subida': '${file}_subida.webp',
          },
          'series': '4',
          'repeticiones': group.key == 'Piernas' ? '10-12' : '8-12',
        });
      }
    }
  }

  final output = File('assets/data/exercises.json');
  output.parent.createSync(recursive: true);
  output.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(catalog)}\n');
  Directory('assets/images/exercises_3d').createSync(recursive: true);
  stdout.writeln('Generated ${catalog.length} exercises at ${output.path}');
}
