import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'modelos_documento_academico_pdf.dart';

/// Reconstruye los reportes académicos de SAGE desde sus operadores de texto.
///
/// El PDF oficial continúa siendo la fuente y el respaldo. La extracción se
/// rechaza cuando faltan campos estructurales para evitar una vista parcial.
class ExtractorDocumentoAcademicoPdf {
  const ExtractorDocumentoAcademicoPdf();

  DocumentoAcademicoPdf extraer(
    Uint8List bytes, {
    TipoDocumentoAcademicoPdf? tipoEsperado,
    bool requerirMetadatosCompletos = true,
  }) {
    if (bytes.length < 8 || latin1.decode(bytes.sublist(0, 5)) != '%PDF-') {
      throw const FormatException('El archivo no es un PDF válido.');
    }

    final paginas = <List<_TextoPdf>>[];
    for (final stream in _extraerStreamsDeContenido(bytes)) {
      final textos = _leerTextos(stream);
      if (textos.isNotEmpty) paginas.add(textos);
    }
    if (paginas.isEmpty) {
      throw const FormatException('El PDF no contiene texto utilizable.');
    }

    final todosLosTextos = <_TextoPdf>[
      for (final pagina in paginas) ...pagina,
    ];
    final detectado = _detectarTipo(todosLosTextos);
    if (detectado != null &&
        tipoEsperado != null &&
        detectado != tipoEsperado) {
      throw const FormatException(
        'El PDF no corresponde al documento académico solicitado.',
      );
    }
    final tipo = detectado ?? tipoEsperado;
    if (tipo == null) {
      throw const FormatException(
        'No se reconoció un documento académico compatible de SAGE.',
      );
    }

    final materias = <MateriaDocumentoAcademicoPdf>[];
    for (final pagina in paginas) {
      materias.addAll(_reconstruirFilas(pagina));
    }
    final materiasUnicas = _sinDuplicados(materias);
    if (materiasUnicas.isEmpty) {
      throw const FormatException(
        'No se encontró una tabla académica utilizable.',
      );
    }

    _validarFilas(tipo, materiasUnicas);

    final lineas = _reconstruirLineas(paginas);
    final identidad = _extraerAlumnoYDocumento(lineas);
    final establecimiento = _extraerValor(lineas, 'Establecimiento');
    final carrera = _extraerValor(lineas, 'Carrera');
    final fechaEmision = _extraerFechaEmision(todosLosTextos);
    if (requerirMetadatosCompletos &&
        (identidad.$1 == null ||
            establecimiento == null ||
            carrera == null ||
            fechaEmision == null)) {
      throw const FormatException(
        'El documento no contiene todos los datos institucionales esperados.',
      );
    }

    final condicion = _extraerValor(lineas, 'Condición del Alumno');
    final promedio = _extraerValor(lineas, 'Promedio de Materias Aprobadas');
    if (requerirMetadatosCompletos &&
        tipo == TipoDocumentoAcademicoPdf.analitico &&
        (condicion == null || promedio == null)) {
      throw const FormatException(
        'El certificado analítico no informa condición y promedio.',
      );
    }
    if (requerirMetadatosCompletos &&
        tipo == TipoDocumentoAcademicoPdf.situacionAcademica &&
        condicion == null) {
      throw const FormatException(
        'La situación académica no informa la condición del alumno.',
      );
    }

    return DocumentoAcademicoPdf(
      tipo: tipo,
      materias: List<MateriaDocumentoAcademicoPdf>.unmodifiable(
        materiasUnicas,
      ),
      alumno: identidad.$1,
      documento: identidad.$2,
      establecimiento: establecimiento,
      carrera: carrera,
      fechaEmision: fechaEmision,
      condicionAlumno: condicion,
      promedioOficial: promedio,
    );
  }

  List<Uint8List> _extraerStreamsDeContenido(Uint8List bytes) {
    final raw = latin1.decode(bytes, allowInvalid: true);
    final result = <Uint8List>[];
    final objectPattern = RegExp(
      r'<<(.*?)>>\s*stream\r?\n',
      dotAll: true,
    );

    for (final match in objectPattern.allMatches(raw)) {
      final dictionary = match.group(1) ?? '';
      final lengthMatch = RegExp(r'/Length\s+(\d+)\b').firstMatch(dictionary);
      final length = int.tryParse(lengthMatch?.group(1) ?? '');
      if (length == null || length <= 0) continue;
      final dataStart = match.end;
      final dataEnd = dataStart + length;
      if (dataEnd > bytes.length) continue;

      try {
        final encoded = bytes.sublist(dataStart, dataEnd);
        final decoded = dictionary.contains('/FlateDecode')
            ? ZLibDecoder().convert(encoded)
            : encoded;
        final text = latin1.decode(decoded, allowInvalid: true);
        if (RegExp(r'\bBT\b').hasMatch(text) &&
            (text.contains('Tj') || text.contains('TJ'))) {
          result.add(Uint8List.fromList(decoded));
        }
      } catch (_) {
        // Streams de imágenes y recursos ajenos a la tabla se descartan.
      }
    }
    return result;
  }

  List<_TextoPdf> _leerTextos(Uint8List stream) {
    final source = latin1.decode(stream, allowInvalid: true);
    final blocks = RegExp(r'\bBT\b([\s\S]*?)\sET\b').allMatches(source);
    final result = <_TextoPdf>[];

    for (final block in blocks) {
      final body = block.group(1) ?? '';
      final position = _leerPosicion(body);
      if (position == null) continue;
      final fragments = _leerLiterales(body);
      if (fragments.isEmpty) continue;
      final text = fragments.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
      if (text.isEmpty) continue;
      result.add(_TextoPdf(x: position.$1, y: position.$2, texto: text));
    }
    return result;
  }

  (double, double)? _leerPosicion(String body) {
    final td = RegExp(
      r'(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s+Td\b',
    ).firstMatch(body);
    if (td != null) {
      final x = double.tryParse(td.group(1) ?? '');
      final y = double.tryParse(td.group(2) ?? '');
      if (x != null && y != null) return (x, y);
    }

    final tm = RegExp(
      r'-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?\s+'
      r'-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?\s+'
      r'(-?\d+(?:\.\d+)?)\s+(-?\d+(?:\.\d+)?)\s+Tm\b',
    ).firstMatch(body);
    if (tm == null) return null;
    final x = double.tryParse(tm.group(1) ?? '');
    final y = double.tryParse(tm.group(2) ?? '');
    return x == null || y == null ? null : (x, y);
  }

  List<String> _leerLiterales(String body) {
    final result = <String>[];
    var index = 0;
    while (index < body.length) {
      if (body.codeUnitAt(index) != 40) {
        index++;
        continue;
      }
      final buffer = StringBuffer();
      var depth = 1;
      index++;
      while (index < body.length && depth > 0) {
        final code = body.codeUnitAt(index);
        if (code == 92) {
          final decoded = _leerEscape(body, index);
          buffer.write(decoded.$1);
          index = decoded.$2;
          continue;
        }
        if (code == 40) {
          depth++;
          buffer.writeCharCode(code);
          index++;
          continue;
        }
        if (code == 41) {
          depth--;
          if (depth > 0) buffer.writeCharCode(code);
          index++;
          continue;
        }
        buffer.writeCharCode(code);
        index++;
      }
      result.add(buffer.toString());
    }
    return result;
  }

  (String, int) _leerEscape(String source, int slashIndex) {
    var cursor = slashIndex + 1;
    if (cursor >= source.length) return ('', cursor);
    final code = source.codeUnitAt(cursor);
    const simple = <int, int>{
      110: 10,
      114: 13,
      116: 9,
      98: 8,
      102: 12,
      40: 40,
      41: 41,
      92: 92,
    };
    final replacement = simple[code];
    if (replacement != null) {
      return (String.fromCharCode(replacement), cursor + 1);
    }
    if (code == 10) return ('', cursor + 1);
    if (code == 13) {
      cursor++;
      if (cursor < source.length && source.codeUnitAt(cursor) == 10) cursor++;
      return ('', cursor);
    }
    if (code >= 48 && code <= 55) {
      final digits = StringBuffer();
      var count = 0;
      while (cursor < source.length && count < 3) {
        final current = source.codeUnitAt(cursor);
        if (current < 48 || current > 55) break;
        digits.writeCharCode(current);
        cursor++;
        count++;
      }
      final value = int.tryParse(digits.toString(), radix: 8);
      return (value == null ? '' : String.fromCharCode(value), cursor);
    }
    return (String.fromCharCode(code), cursor + 1);
  }

  List<MateriaDocumentoAcademicoPdf> _reconstruirFilas(
    List<_TextoPdf> textos,
  ) {
    final groups = _agruparPorLinea(textos);
    final anchors = <_AnclaFila>[];

    for (final group in groups) {
      final sorted = [...group.textos]..sort((a, b) => a.x.compareTo(b.x));
      _TextoPdf? year;
      for (final item in sorted) {
        final parsed = int.tryParse(item.texto.trim());
        if (parsed == null || parsed < 1 || parsed > 12) continue;
        final hasName = sorted.any(
          (candidate) =>
              candidate.x < item.x - 12 && !_esEncabezado(candidate.texto),
        );
        if (hasName) {
          year = item;
          break;
        }
      }
      final yearAnchor = year;
      if (yearAnchor == null) continue;

      final status = sorted
          .where(
            (item) =>
                item.x > yearAnchor.x + 10 && _estadoValido(item.texto),
          )
          .firstOrNull;
      final date = sorted
          .where(
            (item) =>
                item.x > yearAnchor.x + 10 && _fechaValida(item.texto),
          )
          .firstOrNull;
      final grade = sorted
          .where(
            (item) =>
                item.x > yearAnchor.x + 24 && _notaValida(item.texto),
          )
          .lastOrNull;

      var lastX = yearAnchor.x;
      if (status != null) {
        if (status.x <= lastX) continue;
        lastX = status.x;
      }
      if (date != null) {
        if (date.x <= lastX) continue;
        lastX = date.x;
      }
      if (grade != null && grade.x <= lastX) continue;

      anchors.add(
        _AnclaFila(
          y: group.y,
          xAnio: yearAnchor.x,
          anio: int.parse(yearAnchor.texto.trim()),
          estado: _textoOpcional(status?.texto),
          fecha: _textoOpcional(date?.texto),
          nota: _textoOpcional(grade?.texto),
        ),
      );
    }

    anchors.sort((a, b) => b.y.compareTo(a.y));
    final rows = <MateriaDocumentoAcademicoPdf>[];
    for (var index = 0; index < anchors.length; index++) {
      final anchor = anchors[index];
      final nextY = index + 1 < anchors.length
          ? anchors[index + 1].y
          : anchor.y - 24;
      final lowerBoundary = nextY + 0.9 > anchor.y - 24
          ? nextY + 0.9
          : anchor.y - 24;
      final nameParts = textos.where((item) {
        if (item.x >= anchor.xAnio - 12) return false;
        if (item.y > anchor.y + 0.9 || item.y <= lowerBoundary) return false;
        return !_esEncabezado(item.texto);
      }).toList()
        ..sort((a, b) {
          final byY = b.y.compareTo(a.y);
          return byY != 0 ? byY : a.x.compareTo(b.x);
        });
      final name = nameParts
          .map((item) => item.texto.trim())
          .where((item) => item.isNotEmpty)
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (name.isEmpty) continue;
      rows.add(
        MateriaDocumentoAcademicoPdf(
          nombre: name,
          anio: anchor.anio,
          estado: anchor.estado,
          fechaMovimiento: anchor.fecha,
          nota: anchor.nota,
        ),
      );
    }
    return rows;
  }

  List<_GrupoLinea> _agruparPorLinea(List<_TextoPdf> textos) {
    final sorted = [...textos]..sort((a, b) => b.y.compareTo(a.y));
    final groups = <_GrupoLinea>[];
    for (final text in sorted) {
      _GrupoLinea? target;
      for (final group in groups) {
        if ((group.y - text.y).abs() <= 0.8) {
          target = group;
          break;
        }
      }
      if (target == null) {
        groups.add(_GrupoLinea(y: text.y, textos: <_TextoPdf>[text]));
      } else {
        target.textos.add(text);
      }
    }
    return groups;
  }

  List<String> _reconstruirLineas(List<List<_TextoPdf>> paginas) {
    final result = <String>[];
    for (final pagina in paginas) {
      for (final group in _agruparPorLinea(pagina)) {
        final line = ([...group.textos]..sort((a, b) => a.x.compareTo(b.x)))
            .map((item) => item.texto.trim())
            .where((item) => item.isNotEmpty)
            .join(' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        if (line.isNotEmpty) result.add(line);
      }
    }
    return result;
  }

  TipoDocumentoAcademicoPdf? _detectarTipo(List<_TextoPdf> textos) {
    final content = normalizarTextoDocumentoPdf(
      textos.map((item) => item.texto).join(' '),
    );
    if (content.contains('situacion academica del alumno')) {
      return TipoDocumentoAcademicoPdf.situacionAcademica;
    }
    if (content.contains('certificado analitico')) {
      return TipoDocumentoAcademicoPdf.analitico;
    }
    if (content.contains('libreta de calificaciones')) {
      return TipoDocumentoAcademicoPdf.libreta;
    }
    return null;
  }

  (String?, String?) _extraerAlumnoYDocumento(List<String> lineas) {
    final pattern = RegExp(
      r'Alumno\s*:\s*(.*?)\s+Documento\s*:\s*([^\s]+)',
      caseSensitive: false,
    );
    for (final line in lineas) {
      final match = pattern.firstMatch(line);
      if (match == null) continue;
      final alumno = (match.group(1) ?? '')
          .replaceFirst(RegExp(r'[.\s]+$'), '')
          .trim();
      final documento = (match.group(2) ?? '')
          .replaceFirst(RegExp(r'[^0-9A-Za-z.-]+$'), '')
          .trim();
      return (
        alumno.isEmpty ? null : alumno,
        documento.isEmpty ? null : documento,
      );
    }
    return (null, null);
  }

  String? _extraerValor(List<String> lineas, String etiqueta) {
    final target = normalizarTextoDocumentoPdf(etiqueta);
    for (final line in lineas) {
      if (!normalizarTextoDocumentoPdf(line).startsWith(target)) continue;
      final separator = line.indexOf(':');
      if (separator < 0 || separator == line.length - 1) continue;
      final value = line.substring(separator + 1).trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  String? _extraerFechaEmision(List<_TextoPdf> textos) {
    for (final text in textos) {
      final match = RegExp(
        r'\b(\d{1,2}/\d{1,2}/\d{4})\b',
      ).firstMatch(text.texto);
      if (match != null &&
          normalizarTextoDocumentoPdf(text.texto).contains('parana')) {
        return match.group(1);
      }
    }
    return null;
  }

  void _validarFilas(
    TipoDocumentoAcademicoPdf tipo,
    List<MateriaDocumentoAcademicoPdf> materias,
  ) {
    for (final materia in materias) {
      if (materia.anio < 1 || materia.nombre.trim().isEmpty) {
        throw const FormatException('La tabla contiene una fila inválida.');
      }
      if (tipo == TipoDocumentoAcademicoPdf.situacionAcademica) {
        final category = materia.categoriaEstado;
        if (category == CategoriaEstadoDocumentoPdf.aprobada &&
            (materia.fechaMovimientoDateTime == null ||
                materia.notaNumerica == null)) {
          throw const FormatException(
            'Una materia aprobada está incompleta en la situación académica.',
          );
        }
        continue;
      }
      if (materia.categoriaEstado != CategoriaEstadoDocumentoPdf.aprobada ||
          materia.fechaMovimientoDateTime == null ||
          materia.notaNumerica == null) {
        throw const FormatException(
          'La tabla de calificaciones contiene una fila incompleta.',
        );
      }
    }
  }

  bool _fechaValida(String value) {
    return parsearFechaDocumentoAcademico(value) != null;
  }

  bool _notaValida(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    if (!RegExp(r'^\d{1,2}(?:\.\d{1,2})?$').hasMatch(normalized)) {
      return false;
    }
    final grade = double.tryParse(normalized);
    return grade != null && grade >= 0 && grade <= 10;
  }

  bool _estadoValido(String value) {
    final normalized = normalizarTextoDocumentoPdf(value);
    return normalized == 'aprobada' ||
        normalized == 'aprobado' ||
        normalized == 'regular' ||
        normalized == 'equivalencia' ||
        normalized == 'cursando' ||
        normalized == 'promocionada' ||
        normalized == 'libre' ||
        normalized == 'no regularizada';
  }

  bool _esEncabezado(String value) {
    final normalized = normalizarTextoDocumentoPdf(value);
    return normalized.isEmpty ||
        normalized == 'materia' ||
        normalized == 'ano' ||
        normalized == 'anio' ||
        normalized == 'estado' ||
        normalized == 'fecha' ||
        normalized == 'movimiento' ||
        normalized == 'fecha movimiento' ||
        normalized == 'calificacion' ||
        normalized == 'nota' ||
        normalized == 'firma' ||
        normalized.contains('libreta de calificaciones') ||
        normalized.contains('certificado analitico') ||
        normalized.contains('situacion academica del alumno') ||
        normalized.startsWith('alumno ') ||
        normalized.startsWith('establecimiento ') ||
        normalized.startsWith('carrera ') ||
        normalized.startsWith('condicion del alumno') ||
        normalized.startsWith('promedio de materias aprobadas') ||
        normalized.startsWith('parana') ||
        normalized.contains('firma y sello') ||
        normalized.contains('firma del secretario') ||
        normalized.contains('firma del rector');
  }

  List<MateriaDocumentoAcademicoPdf> _sinDuplicados(
    List<MateriaDocumentoAcademicoPdf> values,
  ) {
    final result = <MateriaDocumentoAcademicoPdf>[];
    final seen = <String>{};
    for (final item in values) {
      final key = <String>[
        normalizarTextoDocumentoPdf(item.nombre),
        item.anio.toString(),
        normalizarTextoDocumentoPdf(item.estado ?? ''),
        item.fechaMovimiento ?? '',
        item.nota ?? '',
      ].join('|');
      if (seen.add(key)) result.add(item);
    }
    return result;
  }

  String? _textoOpcional(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}

class _TextoPdf {
  const _TextoPdf({required this.x, required this.y, required this.texto});

  final double x;
  final double y;
  final String texto;
}

class _GrupoLinea {
  _GrupoLinea({required this.y, required this.textos});

  final double y;
  final List<_TextoPdf> textos;
}

class _AnclaFila {
  const _AnclaFila({
    required this.y,
    required this.xAnio,
    required this.anio,
    this.estado,
    this.fecha,
    this.nota,
  });

  final double y;
  final double xAnio;
  final int anio;
  final String? estado;
  final String? fecha;
  final String? nota;
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }

  T? get lastOrNull {
    final iterator = this.iterator;
    T? result;
    while (iterator.moveNext()) {
      result = iterator.current;
    }
    return result;
  }
}
