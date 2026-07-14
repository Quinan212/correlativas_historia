import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_legajo/extractor_legajo_sage.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_legajo/modelos_legajo_sage.dart';
import 'package:flutter_test/flutter_test.dart';

Future<String> _respuesta(String value) async => value;

void main() {
  test(
    'decodifica una fila técnica de jqGrid sin exponer datos en la firma',
    () async {
      const raw =
          '''{"stage":"listadoLegajos","state":"ready","frameId":"frm_alumnos","pathname":"/dic/Listar2.php","signature":"frm_alumnos|listadoLegajos|a1","profiles":[{"rowId":"r1","signature":"a1","name":"Perfil","fields":{"documento":"valor visible"}}]}''';
      final result = await ExtractorLegajoSage(
        (_) => _respuesta(raw),
      ).extraer();

      expect(result.etapa, EtapaLegajoSage.miLegajo);
      expect(result.estado, EstadoExtraccionLegajoSage.disponible);
      expect(result.perfiles.single.rowId, 'r1');
      expect(result.perfiles.single.firmaTecnica, 'a1');
      expect(result.firma, isNot(contains('valor visible')));
    },
  );

  test('conserva estados de carga y vacío', () async {
    final loading = await ExtractorLegajoSage(
      (_) => _respuesta('{"stage":"listadoLegajos","state":"loading"}'),
    ).extraer();
    final empty = await ExtractorLegajoSage(
      (_) => _respuesta('{"stage":"listadoLegajos","state":"empty"}'),
    ).extraer();

    expect(loading.estado, EstadoExtraccionLegajoSage.cargando);
    expect(empty.estado, EstadoExtraccionLegajoSage.vacio);
  });

  test('decodifica secciones y opciones escolares', () async {
    const raw =
        '''{"stage":"seccionesLegajo","state":"ready","frameId":"tabs","pathname":"/dic/tabs.php","sections":[{"label":"Escolares","signature":"s1","frameId":"tabs","pathname":"/dic/tabs.php"}]}''';
    final result = await ExtractorLegajoSage((_) => _respuesta(raw)).extraer();

    expect(result.etapa, EtapaLegajoSage.secciones);
    expect(result.secciones.single.titulo, 'Escolares');
    expect(result.secciones.single.pathnameDestino, isNull);
  });

  test('extrae Escolares desde el padre y conserva señales del hijo', () async {
    const raw =
        '''{"stage":"escolares","state":"ready","frameId":"frm_alumnos","pathname":"/dic/tabs.php","parentFrameFound":true,"childFrameFound":true,"childReady":true,"historyGridFound":false,"schoolOptions":[{"label":"Historial del alumnado","signature":"a","frameId":"frm_alumnos","pathname":"/dic/tabs.php"},{"label":"Nivel Superior: Historial","signature":"b","frameId":"frm_alumnos","pathname":"/dic/tabs.php"}],"signature":"frm_alumnos|/dic/tabs.php|escolares_disponible|child_frame=true|child_ready=true"}''';
    final result = await ExtractorLegajoSage((_) => _respuesta(raw)).extraer();

    expect(result.etapa, EtapaLegajoSage.escolares);
    expect(result.parentFrameFound, isTrue);
    expect(result.childFrameFound, isTrue);
    expect(result.childReady, isTrue);
    expect(result.historyGridFound, isFalse);
    expect(
      result.opcionesEscolares.map((item) => item.titulo),
      contains('Nivel Superior: Historial'),
    );
    expect(
      normalizarLegajoSage('NIVEL SUPERIOR – HISTORIAL'),
      'nivel superior - historial',
    );
    expect(
      normalizarLegajoSage('Nivel Superior: Historial'),
      'nivel superior - historial',
    );
  });

  test('una acción requiere elemento encontrado y activado', () {
    const failed = ResultadoAccionLegajoSage(
      found: true,
      activated: false,
      mechanism: 'none',
      frameId: 'frm_alumnos',
      pathnameBefore: '/dic/Listar2.php',
    );
    const success = ResultadoAccionLegajoSage(
      found: true,
      activated: true,
      mechanism: 'jqgrid_ondblclickrow',
      frameId: 'frm_alumnos',
      pathnameBefore: '/dic/Listar2.php',
    );

    expect(failed.success, isFalse);
    expect(success.success, isTrue);
  });
}
