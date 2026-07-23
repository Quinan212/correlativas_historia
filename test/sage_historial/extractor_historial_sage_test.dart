import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_historial/extractor_historial_sage.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_historial/modelos_historial_sage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extractor = ExtractorHistorialSage();

  test('normaliza números y conserva varias carreras', () async {
    final result = await extractor.leer(
      (_) async => '''{
      "state":"ready",
      "careers":[
        {"id":"carrera-a","career":"Profesorado","institution":"Instituto","startYear":"2024","status":"Activo","enrollmentStatus":"Regular","inProgress":"2","regular":0,"approved":"8"},
        {"id":"carrera-b","career":"Otra carrera","institution":"Otra institución","startYear":null,"status":null,"enrollmentStatus":"","inProgress":null,"regular":"1","approved":"0"}
      ]
    }''',
    );

    expect(result.estado, EstadoHistorialSage.disponible);
    expect(result.historial!.carreras, hasLength(2));
    expect(result.historial!.carreras.first.anioInicio, 2024);
    expect(result.historial!.carreras.first.cursando, 2);
    expect(result.historial!.carreras.last.anioInicio, isNull);
    expect(result.historial!.carreras.last.estado, isNull);
  });

  test(
    'el Historial web ignora Nota y Fecha aunque aparezcan en un payload',
    () async {
      final subjects = await extractor.leerMaterias(
        (_) async => '''{"state":"ready","subjects":[
          {"id":"m-1","name":"Historia","status":"Aprobada","year":"1","date":"14/07/2026","grade":"9"},
          {"id":"m-2","name":"Lengua","status":"Regular","year":null}
        ]}''',
        'carrera-a',
      );

      expect(subjects, hasLength(2));
      expect(subjects.first.anio, 1);
      expect(subjects.first.fecha, isNull);
      expect(subjects.first.nota, isNull);
      expect(subjects.last.anio, isNull);
      expect(subjects.last.fecha, isNull);
      expect(subjects.last.nota, isNull);
    },
  );

  test(
    'un esquema incompatible no se presenta como historial disponible',
    () async {
      final result = await extractor.leer(
        (_) async => '{"state":"incompatible"}',
      );

      expect(result.estado, EstadoHistorialSage.incompatible);
      expect(result.historial, isNull);
    },
  );

  test('filtra por texto/estado y agrupa materias sin año', () {
    const subjects = [
      MateriaHistorialSage(
        id: 'a',
        nombre: 'Historia Social',
        estado: 'Aprobada',
        anio: 1,
      ),
      MateriaHistorialSage(
        id: 'b',
        nombre: 'Didáctica',
        estado: 'Regular',
        anio: 2,
      ),
      MateriaHistorialSage(
        id: 'c',
        nombre: 'Taller',
        estado: 'Cursando',
        anio: null,
      ),
    ];

    expect(
      filtrarMateriasSage(subjects, query: 'historia', filtro: 'Aprobadas'),
      hasLength(1),
    );
    final groups = agruparMateriasPorAnioSage(subjects);
    expect(groups[1], hasLength(1));
    expect(groups[null], hasLength(1));
  });

  test('distingue subgrilla lista pero vacía de subgrilla cargando', () async {
    final result = await extractor.leerMateriasConEstado(
      (_) async => '{"state":"ready","subjects":[]}',
      'carrera-a',
    );

    expect(result.estado, EstadoCargaMateriasSage.disponible);
    expect(result.materias, isEmpty);
  });

  test('conserva el gridRowId separado del identificador interno', () async {
    final result = await extractor.leer(
      (_) async => '''{
        "state":"ready",
        "careers":[
          {"gridRowId":"row-7","internalId":"internal-9","career":"Profesorado","institution":"Instituto","startYear":"2024","status":"Activo","inProgress":"0","regular":"0","approved":"0"}
        ]
      }''',
    );

    final career = result.historial!.carreras.single;
    expect(career.gridRowId, 'row-7');
    expect(career.internalId, 'internal-9');
  });

  test('distingue B2 cargando de B2 vacío', () async {
    final result = await extractor.leerMateriasConEstado(
      (_) async =>
          '{"state":"loading","subjects":[],"subgridLoaderVisible":true,"subjectRowCount":0}',
      'row-7',
    );

    expect(result.estado, EstadoCargaMateriasSage.cargando);
    expect(result.materias, isEmpty);
  });
}
