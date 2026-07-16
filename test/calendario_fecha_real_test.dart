import 'dart:io';

import 'package:correlativas_historia/funcionalidades/acceso_estudiante/modelos/modelos_acceso_estudiante.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el mes visible sale de la fecha académica real', () {
    expect(nombreMesAcademico(DateTime(2025, 11, 26)), 'Noviembre');
    expect(nombreMesAcademico(DateTime(2025, 12, 18)), 'Diciembre');
  });

  test('el calendario usa la fecha académica declarada', () {
    final source = File(
      'lib/funcionalidades/acceso_estudiante/dominio/entrada_plan_estudios.dart',
    ).readAsStringSync();
    final start = source.indexOf(
      'List<_EventoCalendarioAcademico> _buildAcademicCalendarEvents(',
    );
    final end = source.indexOf('String _progressDiagnosis(', start);

    expect(start, isNonNegative);
    expect(end, greaterThan(start));

    final calendarBuilder = source.substring(start, end);
    expect(calendarBuilder, contains('current.sourceDate'));
    expect(calendarBuilder, isNot(contains('_buildStudentMovements')));
    expect(calendarBuilder, isNot(contains('createdAt')));
  });

  test('el detalle prioriza la fecha real para la acreditación', () {
    final source = File(
      'lib/funcionalidades/acceso_estudiante/dominio/entrada_plan_estudios.dart',
    ).readAsStringSync();
    final start = source.indexOf('List<_PasoHistorialMateria>');
    final end = source.indexOf('DateTime? _parseHistoryDate(', start);

    expect(start, isNonNegative);
    expect(end, greaterThan(start));

    final historyBuilder = source.substring(start, end);
    expect(
      historyBuilder,
      contains('_historyDateLabel(current?.sourceDate) ?? historyDateLabel'),
    );
    expect(historyBuilder, contains('_subjectCreditDetail(current)'));
  });
}
