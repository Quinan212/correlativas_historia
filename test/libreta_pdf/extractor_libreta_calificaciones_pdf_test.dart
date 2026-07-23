import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/libreta_pdf/extractor_libreta_calificaciones_pdf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const extractor = ExtractorLibretaCalificacionesPdf();

  test('extrae materias, nota y fecha desde el PDF de texto de SAGE', () {
    final result = extractor.extraer(
      _pdfConContenido(r'''
BT 472.946 765.139 Td /F1 11.0 Tf (Parana 20/7/2026) Tj ET
BT 60.000 705.027 Td /F2 10.0 Tf (Carrera) Tj /F1 10.0 Tf (: PROFESORADO DE HISTORIA) Tj ET
BT 62.500 637.181 Td /F1 7.5 Tf (DIDACTICA GENERAL) Tj ET
BT 245.415 637.181 Td /F1 7.5 Tf (1) Tj ET
BT 281.240 637.181 Td /F1 7.5 Tf (Aprobada) Tj ET
BT 348.735 637.181 Td /F1 7.5 Tf (17/11/2025) Tj ET
BT 428.118 637.181 Td /F1 7.5 Tf (10.00) Tj ET
BT 62.500 624.511 Td /F1 7.5 Tf (ORAL. -LECT. - ESCRITURA Y TIC) Tj ET
BT 245.415 624.511 Td /F1 7.5 Tf (1) Tj ET
BT 281.240 624.511 Td /F1 7.5 Tf (Aprobada) Tj ET
BT 348.735 624.511 Td /F1 7.5 Tf (15/11/2024) Tj ET
BT 430.202 624.511 Td /F1 7.5 Tf (9.00) Tj ET
'''),
    );

    expect(result.carrera, 'PROFESORADO DE HISTORIA');
    expect(result.fechaEmision, '20/7/2026');
    expect(result.materias, hasLength(2));
    expect(result.materias.first.nombre, 'DIDACTICA GENERAL');
    expect(result.materias.first.anio, 1);
    expect(result.materias.first.fecha, '17/11/2025');
    expect(result.materias.first.calificacion, '10');
    expect(result.materias.last.calificacion, '9');
  });

  test('une materias que ocupan dos líneas', () {
    final result = extractor.extraer(
      _pdfConContenido(r'''
BT 62.500 561.161 Td /F1 7.5 Tf (PROBLEMATICA DEL CONOCIMIENTO) Tj ET
BT 62.500 552.491 Td /F1 7.5 Tf (HISTORICO SUP) Tj ET
BT 245.415 561.161 Td /F1 7.5 Tf (1) Tj ET
BT 281.240 561.161 Td /F1 7.5 Tf (Aprobada) Tj ET
BT 348.735 561.161 Td /F1 7.5 Tf (14/11/2024) Tj ET
BT 430.202 561.161 Td /F1 7.5 Tf (7.00) Tj ET
BT 62.500 539.821 Td /F1 7.5 Tf (DIDACTICA DE LAS CIENCIAS SOCIALES) Tj ET
BT 245.415 539.821 Td /F1 7.5 Tf (2) Tj ET
BT 281.240 539.821 Td /F1 7.5 Tf (Aprobada) Tj ET
BT 348.735 539.821 Td /F1 7.5 Tf (26/11/2025) Tj ET
BT 430.202 539.821 Td /F1 7.5 Tf (9.00) Tj ET
'''),
    );

    expect(result.materias, hasLength(2));
    expect(
      result.materias.first.nombre,
      'PROBLEMATICA DEL CONOCIMIENTO HISTORICO SUP',
    );
    expect(result.materias.first.fecha, '14/11/2024');
    expect(result.materias.first.calificacion, '7');
  });

  test('rechaza un archivo que no contiene la tabla de libreta', () {
    expect(
      () => extractor.extraer(_pdfConContenido('BT 10 10 Td (Hola) Tj ET')),
      throwsFormatException,
    );
  });
}

Uint8List _pdfConContenido(String content) {
  final compressed = ZLibEncoder().convert(latin1.encode(content));
  final header = latin1.encode(
    '%PDF-1.3\n1 0 obj\n<< /Filter /FlateDecode /Length ${compressed.length} >>\nstream\n',
  );
  final footer = latin1.encode('\nendstream\nendobj\n%%EOF');
  return Uint8List.fromList(<int>[...header, ...compressed, ...footer]);
}
