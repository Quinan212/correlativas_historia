import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Exámenes usa skeleton durante toda actualización del Excel', () {
    final source = File(
      'lib/funcionalidades/laboratorio_mesas_excel/pantallas/'
      'pantalla_examenes_excel_atlassian.dart',
    ).readAsStringSync();

    expect(source, contains('if (widget.controller.estaComprobando) {'));
    expect(source, isNot(contains('estaComprobando && all.isEmpty')));
    expect(source, contains('const _EsqueletoExamenesAtlassian()'));
  });

  test('Calendario usa skeleton en carga inicial y actualización', () {
    final source = File(
      'lib/funcionalidades/laboratorio_mesas_excel/pantallas/'
      'pantalla_calendario_excel_atlassian.dart',
    ).readAsStringSync();

    expect(source, contains('if (widget.controller.estaComprobando) {'));
    expect(source, isNot(contains('estaComprobando && events.isEmpty')));
    expect(source, contains('return _EsqueletoCalendarioAtlassian('));
    expect(source, contains('onChooseCareer: () {},'));
  });
}
