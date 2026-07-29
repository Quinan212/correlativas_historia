import 'package:correlativas_historia/funcionalidades/administrador/'
    'modelos/evento_examen_administrador.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventoExamenAdministrador legacy', () {
    Map<String, dynamic> row({required bool legacy}) => {
      'id': legacy ? 'legacy-1' : 'actual-1',
      'career_id': 'historia',
      'anio': 1,
      'fecha': '2026-07-20',
      'hora': '18:30',
      'materia': 'Historia Antigua',
      'instancia': 'llamado_1',
      'docentes': const <String>['Docente Uno'],
      'acta_url': null,
      'legacy': legacy,
    };

    test('lee legacy desde la fila de Supabase', () {
      final actual = EventoExamenAdministrador.fromRow(
        row(legacy: false),
      );
      final legacy = EventoExamenAdministrador.fromRow(
        row(legacy: true),
      );

      expect(actual.legacy, isFalse);
      expect(legacy.legacy, isTrue);
    });

    test('copyWith conserva o modifica la clasificación', () {
      final event = EventoExamenAdministrador.fromRow(
        row(legacy: true),
      );

      expect(event.copyWith(materia: 'Otra materia').legacy, isTrue);
      expect(event.copyWith(legacy: false).legacy, isFalse);
    });

    test('usa false como respaldo cuando falta el campo', () {
      final incomplete = row(legacy: false)..remove('legacy');
      final event = EventoExamenAdministrador.fromRow(incomplete);

      expect(event.legacy, isFalse);
    });
  });
}
