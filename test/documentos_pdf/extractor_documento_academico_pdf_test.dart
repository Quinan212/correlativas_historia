import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/documentos_pdf/extractor_documento_academico_pdf.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/documentos_pdf/modelos_documento_academico_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extractor = ExtractorDocumentoAcademicoPdf();

  test('reconstruye una libreta y une materias de dos líneas', () {
    final document = extractor.extraer(
      _pdfConPaginas(<String>[
        r'''
BT 470 770 Td (Paraná 21/8/2026) Tj ET
BT 60 740 Td (Alumno: PERSONA DE PRUEBA. Documento: 00000000) Tj ET
BT 60 720 Td (Establecimiento: INSTITUTO DE PRUEBA) Tj ET
BT 60 700 Td (Carrera: PROFESORADO DE PRUEBA) Tj ET
BT 60 675 Td (Libreta de Calificaciones) Tj ET
BT 62 640 Td (MATERIA EXTENSA) Tj ET
BT 62 631 Td (SEGUNDA LINEA) Tj ET
BT 245 640 Td (1) Tj ET
BT 281 640 Td (Aprobada) Tj ET
BT 349 640 Td (17/11/2025) Tj ET
BT 430 640 Td (10.00) Tj ET
BT 62 610 Td (OTRA MATERIA) Tj ET
BT 245 610 Td (2) Tj ET
BT 281 610 Td (Aprobada) Tj ET
BT 349 610 Td (18/12/2025) Tj ET
BT 430 610 Td (9.00) Tj ET
''',
      ]),
    );

    expect(document.tipo, TipoDocumentoAcademicoPdf.libreta);
    expect(document.alumno, 'PERSONA DE PRUEBA');
    expect(document.documento, '00000000');
    expect(document.establecimiento, 'INSTITUTO DE PRUEBA');
    expect(document.carrera, 'PROFESORADO DE PRUEBA');
    expect(document.fechaEmision, '21/8/2026');
    expect(document.materias, hasLength(2));
    expect(document.materias.first.nombre, 'MATERIA EXTENSA SEGUNDA LINEA');
    expect(document.aprobadas, 2);
  });

  test('conserva condición y promedio oficial del analítico', () {
    final document = extractor.extraer(
      _pdfConPaginas(<String>[
        r'''
BT 470 770 Td (Paraná 21/8/2026) Tj ET
BT 60 740 Td (Alumno: PERSONA DE PRUEBA. Documento: 00000000) Tj ET
BT 60 720 Td (Establecimiento: INSTITUTO DE PRUEBA) Tj ET
BT 60 700 Td (Carrera: PROFESORADO DE PRUEBA) Tj ET
BT 60 675 Td (Certificado Analítico) Tj ET
BT 62 640 Td (MATERIA APROBADA) Tj ET
BT 245 640 Td (1) Tj ET
BT 281 640 Td (Aprobada) Tj ET
BT 349 640 Td (17/11/2025) Tj ET
BT 430 640 Td (8.00) Tj ET
BT 60 580 Td (Condición del Alumno: REGULAR) Tj ET
BT 60 560 Td (Promedio de Materias Aprobadas: 8.90) Tj ET
''',
      ]),
    );

    expect(document.tipo, TipoDocumentoAcademicoPdf.analitico);
    expect(document.condicionAlumno, 'REGULAR');
    expect(document.promedioOficial, '8.90');
    expect(document.promedioOficialNumerico, 8.9);
    expect(document.aprobadas, 1);
  });

  test('une dos páginas de situación académica y admite filas incompletas', () {
    final document = extractor.extraer(
      _pdfConPaginas(<String>[
        r'''
BT 470 770 Td (Paraná, 21/8/2026) Tj ET
BT 60 740 Td (Alumno: PERSONA DE PRUEBA. Documento: 00000000) Tj ET
BT 60 720 Td (Establecimiento: INSTITUTO DE PRUEBA) Tj ET
BT 60 700 Td (Carrera: PROFESORADO DE PRUEBA) Tj ET
BT 60 675 Td (Situación Académica del Alumno) Tj ET
BT 62 640 Td (MATERIA APROBADA) Tj ET
BT 245 640 Td (1) Tj ET
BT 281 640 Td (Aprobada) Tj ET
BT 349 640 Td (17/11/2025) Tj ET
BT 430 640 Td (8.00) Tj ET
BT 62 610 Td (MATERIA EN CURSO) Tj ET
BT 245 610 Td (3) Tj ET
BT 281 610 Td (Cursando) Tj ET
BT 349 610 Td (17/03/2026) Tj ET
BT 62 580 Td (MATERIA PENDIENTE) Tj ET
BT 245 580 Td (4) Tj ET
''',
        r'''
BT 62 740 Td (U.D.I. Cuarto Año) Tj ET
BT 245 740 Td (4) Tj ET
BT 60 690 Td (Condición del Alumno: REGULAR) Tj ET
BT 60 650 Td (Firma del Secretario) Tj ET
''',
      ]),
    );

    expect(document.tipo, TipoDocumentoAcademicoPdf.situacionAcademica);
    expect(document.materias, hasLength(4));
    expect(document.aprobadas, 1);
    expect(document.cursando, 1);
    expect(document.sinEstado, 2);
    expect(document.condicionAlumno, 'REGULAR');
    final udi = document.materias.singleWhere(
      (materia) => materia.nombre == 'U.D.I. Cuarto Año',
    );
    expect(udi.anio, 4);
    expect(udi.estado, isNull);
    expect(udi.fechaMovimiento, isNull);
    expect(udi.nota, isNull);
  });

  test('rechaza un tipo distinto del solicitado', () {
    final bytes = _pdfConPaginas(<String>[
      r'''
BT 470 770 Td (Paraná 21/8/2026) Tj ET
BT 60 740 Td (Alumno: PERSONA DE PRUEBA. Documento: 00000000) Tj ET
BT 60 720 Td (Establecimiento: INSTITUTO DE PRUEBA) Tj ET
BT 60 700 Td (Carrera: PROFESORADO DE PRUEBA) Tj ET
BT 60 675 Td (Certificado Analítico) Tj ET
BT 62 640 Td (MATERIA APROBADA) Tj ET
BT 245 640 Td (1) Tj ET
BT 281 640 Td (Aprobada) Tj ET
BT 349 640 Td (17/11/2025) Tj ET
BT 430 640 Td (8.00) Tj ET
BT 60 580 Td (Condición del Alumno: REGULAR) Tj ET
BT 60 560 Td (Promedio de Materias Aprobadas: 8.00) Tj ET
''',
    ]);

    expect(
      () => extractor.extraer(
        bytes,
        tipoEsperado: TipoDocumentoAcademicoPdf.libreta,
      ),
      throwsFormatException,
    );
  });

  test('rechaza un PDF que no es un documento académico compatible', () {
    expect(
      () => extractor.extraer(
        _pdfConPaginas(<String>['BT 10 10 Td (Hola) Tj ET']),
      ),
      throwsFormatException,
    );
  });
}

Uint8List _pdfConPaginas(List<String> pages) {
  final bytes = <int>[...latin1.encode('%PDF-1.3\n')];
  for (var index = 0; index < pages.length; index++) {
    final compressed = ZLibEncoder().convert(latin1.encode(pages[index]));
    bytes.addAll(
      latin1.encode(
        '${index + 1} 0 obj\n<< /Filter /FlateDecode /Length ${compressed.length} >>\nstream\n',
      ),
    );
    bytes.addAll(compressed);
    bytes.addAll(latin1.encode('\nendstream\nendobj\n'));
  }
  bytes.addAll(latin1.encode('%%EOF'));
  return Uint8List.fromList(bytes);
}
