import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final widgetsFile = File(
    'lib/funcionalidades/administrador/componentes/src/'
    'seccion_eventos_examen_administrador/widgets_carrera_examen.dart',
  );
  final screenFile = File(
    'lib/funcionalidades/administrador/componentes/src/'
    'seccion_eventos_examen_administrador/pantalla_carrera_examen.dart',
  );

  test('la vista por carrera usa una lista plana', () {
    final source = widgetsFile.readAsStringSync(encoding: utf8);

    expect(source, contains('class _FilaEventoExamenCarrera'));
    expect(source, contains('class _EncabezadoAnio'));
    expect(source, contains("metadata.join(' · ')"));
    expect(source, contains('Divider('));
    expect(source, isNot(contains('class _TarjetaGrupoAnio')));
    expect(source, isNot(contains('ExpansionTile(')));
  });

  test('las filas no muestran insignias redundantes', () {
    final source = widgetsFile.readAsStringSync(encoding: utf8);
    final rowStart = source.indexOf('class _FilaEventoExamenCarrera');
    final globalCardStart = source.indexOf('class _TarjetaEventoExamen');
    final rowSource = source.substring(rowStart, globalCardStart);

    expect(rowSource, isNot(contains('_Insignia(')));
    expect(rowSource, isNot(contains('_etiquetaCarrera(')));
    expect(rowSource, isNot(contains("'Mesa'")));
    expect(rowSource, isNot(contains("'Coloquio'")));
  });

  test('permite seleccionar eventos actuales o legacy', () {
    final widgetsSource = widgetsFile.readAsStringSync(encoding: utf8);
    final screenSource = screenFile.readAsStringSync(encoding: utf8);

    expect(widgetsSource, contains('class _SelectorOrigenEventos'));
    expect(widgetsSource, contains("label: const Text('Actuales')"));
    expect(widgetsSource, contains("label: const Text('Legacy')"));
    expect(widgetsSource, contains('event.legacy == wantsLegacy'));
    expect(screenSource, contains("String _legacyScope = 'actuales'"));
    expect(screenSource, contains('legacyScope: _legacyScope'));
  });

  test('conserva la corrección del enum en el archivo part', () {
    final source = widgetsFile.readAsStringSync(encoding: utf8);

    expect(source, contains('switch (event.estado.name)'));
    expect(source, isNot(contains('event.estado.valorBaseDatos')));
  });

  test('la vista global conserva sus tarjetas actuales', () {
    final source = widgetsFile.readAsStringSync(encoding: utf8);

    expect(source, contains('class _TarjetaEventoExamen'));
    expect(source, contains('class _Insignia'));
  });
}
