import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la Libreta se procesa dentro del cierre de la sincronización', () {
    final source = File(
      'lib/funcionalidades/trayectoria_sage_laboratorio/sage/'
      'pantalla_sage_laboratorio.dart',
    ).readAsStringSync();

    final prepareIndex = source.indexOf(
      'Future<void> _prepareDocumentsAndCompleteAutomaticSync',
    );
    final bookletIndex = source.indexOf(
      'await _syncAutomaticGradeBooks(',
      prepareIndex,
    );
    final completeIndex = source.indexOf(
      'await _completeAutomaticSync(enriched',
      prepareIndex,
    );

    expect(prepareIndex, greaterThanOrEqualTo(0));
    expect(bookletIndex, greaterThan(prepareIndex));
    expect(completeIndex, greaterThan(bookletIndex));
    expect(
      source,
      contains('TipoDocumentoAcademicoSage.libreta.tituloReporte'),
    );
    expect(source, contains('abrirAlCompletar: false'));
    expect(source, contains('ExtractorLibretaCalificacionesPdf'));
    expect(source, contains('FusionadorLibretaTrayectoria'));
  });

  test('el Historial web queda limitado a sus cuatro columnas reales', () {
    final source = File(
      'lib/funcionalidades/acceso_estudiante/sage_historial/'
      'extractor_historial_sage.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('fecha_materia')));
    expect(source, isNot(contains('nota_materia')));
    expect(source, isNot(contains("row['date']")));
    expect(source, isNot(contains("row['grade']")));
  });
}
