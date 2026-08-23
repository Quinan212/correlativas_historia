import 'dart:typed_data';

import '../documentos_pdf/extractor_documento_academico_pdf.dart';
import '../documentos_pdf/modelos_documento_academico_pdf.dart';
import 'modelos_libreta_pdf.dart';

/// Adaptador compatible con la sincronización de notas ya existente.
class ExtractorLibretaCalificacionesPdf {
  const ExtractorLibretaCalificacionesPdf();

  ResultadoExtraccionLibretaPdf extraer(Uint8List bytes) {
    final document = const ExtractorDocumentoAcademicoPdf().extraer(
      bytes,
      tipoEsperado: TipoDocumentoAcademicoPdf.libreta,
      requerirMetadatosCompletos: false,
    );
    return ResultadoExtraccionLibretaPdf(
      materias: List<MateriaLibretaPdf>.unmodifiable(
        document.materias.map(
          (materia) => MateriaLibretaPdf(
            nombre: materia.nombre,
            anio: materia.anio,
            estado: materia.estado ?? '',
            fecha: materia.fechaMovimiento ?? '',
            calificacion: _normalizarNota(materia.nota ?? ''),
          ),
        ),
      ),
      carrera: document.carrera,
      fechaEmision: document.fechaEmision,
    );
  }

  String _normalizarNota(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    final number = double.tryParse(normalized);
    if (number == null) return normalized;
    if (number == number.roundToDouble()) return number.toInt().toString();
    return number
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
}
