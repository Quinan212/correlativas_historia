import 'dart:io';

import 'package:correlativas_historia/funcionalidades/laboratorio_mesas_excel/datos/repositorio_catalogo_materias_excel.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_mesas_excel/dominio/importador_mesas_excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el libro real produce un conjunto publicable e íntegro', () async {
    final bytes = File(
      'test/fixtures/mesas_julio_2026.xlsx',
    ).readAsBytesSync();
    final catalog = await const RepositorioCatalogoMateriasExcel().cargar();
    final result = const ImportadorMesasExcel().importar(
      bytes: bytes,
      catalogo: catalog,
    );

    expect(result.diagnostico.publicable, isTrue);
    expect(result.eventos, hasLength(140));
    expect(result.diagnostico.actasEncontradas, 76);
    expect(result.diagnostico.actasAsociadas, 76);
    expect(result.diagnostico.materiasAmbiguas, 0);
    expect(result.diagnostico.materiasSinCoincidencia, 0);
    expect(result.diagnostico.erroresBloqueantes, isEmpty);

    final colloquia = result.eventos
        .where((item) => item.evento.instancia == 'coloquio')
        .toList();
    expect(colloquia, hasLength(18));
    final ideas = colloquia.singleWhere(
      (item) => item.materiaId == 'historia-ideas-2',
    );
    expect(ideas.origen.filas, <int>[12, 13]);
    expect(ideas.evento.puedeAbrirActa, isTrue);

    final totalDuplicateMerges = result.diagnostico.hojas.fold<int>(
      0,
      (total, sheet) => total + sheet.duplicadosFusionados,
    );
    expect(totalDuplicateMerges, 2);
  });
}
