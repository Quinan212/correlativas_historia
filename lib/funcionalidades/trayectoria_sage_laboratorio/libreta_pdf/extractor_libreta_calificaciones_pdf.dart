import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'modelos_libreta_pdf.dart';

/// Extractor acotado a la Libreta de Calificaciones generada por SAGE.
///
/// El documento actual es un PDF de texto producido por R&OS php pdf class.
/// Sus filas se reconstruyen usando las coordenadas de los operadores de texto,
/// por lo que las materias que ocupan dos líneas continúan perteneciendo a la
/// misma fila académica.
class ExtractorLibretaCalificacionesPdf {
  const ExtractorLibretaCalificacionesPdf();

  ResultadoExtraccionLibretaPdf extraer(Uint8List bytes) {
    if (bytes.length < 8 || latin1.decode(bytes.sublist(0, 5)) != '%PDF-') {
      throw const FormatException('El archivo no es un PDF válido.');
    }

    final streams = _extraerStreamsDeContenido(bytes);
    if (streams.isEmpty) {
      throw const FormatException('El PDF no contiene texto utilizable.');
    }

    final materias = <MateriaLibretaPdf>[];
    final todosLosTextos = <_TextoPdf>[];
    for (final stream in streams) {
      final textos = _leerTextos(stream);
      todosLosTextos.addAll(textos);
      materias.addAll(_reconstruirFilas(textos));
    }

    if (materias.isEmpty) {
      throw const FormatException(
        'No se encontró la tabla de Libreta de Calificaciones.',
      );
    }

    return ResultadoExtraccionLibretaPdf(
      materias: List<MateriaLibretaPdf>.unmodifiable(_sinDuplicados(materias)),
      carrera: _extraerCarrera(todosLosTextos),
      fechaEmision: _extraerFechaEmision(todosLosTextos),
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
        // Los streams de imágenes y recursos ajenos a la tabla se descartan.
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

  List<MateriaLibretaPdf> _reconstruirFilas(List<_TextoPdf> textos) {
    final groups = _agruparPorLinea(textos);
    final anchors = <_AnclaFila>[];

    for (final group in groups) {
      final sorted = [...group.textos]..sort((a, b) => a.x.compareTo(b.x));
      final year = sorted.where((item) => RegExp(r'^\d{1,2}$').hasMatch(item.texto)).firstOrNull;
      final date = sorted.where((item) => _fechaValida(item.texto)).firstOrNull;
      final grade = sorted.where((item) => _notaValida(item.texto)).lastOrNull;
      final status = sorted.where((item) => _estadoValido(item.texto)).firstOrNull;
      if (year == null || date == null || grade == null || status == null) continue;
      if (!(year.x < status.x && status.x < date.x && date.x < grade.x)) continue;
      anchors.add(
        _AnclaFila(
          y: group.y,
          xAnio: year.x,
          anio: int.parse(year.texto),
          estado: status.texto.trim(),
          fecha: date.texto.trim(),
          nota: _normalizarNota(grade.texto),
        ),
      );
    }

    anchors.sort((a, b) => b.y.compareTo(a.y));
    final rows = <MateriaLibretaPdf>[];
    for (var index = 0; index < anchors.length; index++) {
      final anchor = anchors[index];
      final nextY = index + 1 < anchors.length ? anchors[index + 1].y : anchor.y - 36;
      final nameParts = textos.where((item) {
        if (item.x >= anchor.xAnio - 12) return false;
        if (item.y > anchor.y + 0.9 || item.y <= nextY + 0.9) return false;
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
        MateriaLibretaPdf(
          nombre: name,
          anio: anchor.anio,
          estado: anchor.estado,
          fecha: anchor.fecha,
          calificacion: anchor.nota,
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

  bool _fechaValida(String value) {
    final match = RegExp(
      r'^(\d{1,2})/(\d{1,2})/(\d{4})$',
    ).firstMatch(value.trim());
    if (match == null) return false;
    final day = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final year = int.tryParse(match.group(3) ?? '');
    if (day == null || month == null || year == null) return false;
    final date = DateTime(year, month, day);
    return date.day == day && date.month == month && date.year == year;
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
    final normalized = _normalizar(value);
    return normalized == 'aprobada' ||
        normalized == 'aprobado' ||
        normalized == 'regular' ||
        normalized == 'equivalencia';
  }

  bool _esEncabezado(String value) {
    final normalized = _normalizar(value);
    return normalized.isEmpty ||
        normalized == 'materia' ||
        normalized == 'ano' ||
        normalized == 'anio' ||
        normalized == 'estado' ||
        normalized == 'fecha' ||
        normalized == 'movimiento' ||
        normalized == 'calificacion' ||
        normalized == 'firma' ||
        normalized.contains('libreta de calificaciones') ||
        normalized.contains('firma y sello');
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

  List<MateriaLibretaPdf> _sinDuplicados(List<MateriaLibretaPdf> values) {
    final result = <MateriaLibretaPdf>[];
    final seen = <String>{};
    for (final item in values) {
      final key = '${_normalizar(item.nombre)}|${item.anio}|${item.fecha}|${item.calificacion}';
      if (seen.add(key)) result.add(item);
    }
    return result;
  }

  String? _extraerCarrera(List<_TextoPdf> textos) {
    final lines = _agruparPorLinea(textos);
    for (final line in lines) {
      final text = ([...line.textos]..sort((a, b) => a.x.compareTo(b.x)))
          .map((item) => item.texto)
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (_normalizar(text).startsWith('carrera')) {
        final separator = text.indexOf(':');
        return separator < 0 ? text : text.substring(separator + 1).trim();
      }
    }
    return null;
  }

  String? _extraerFechaEmision(List<_TextoPdf> textos) {
    for (final text in textos) {
      final match = RegExp(r'\b(\d{1,2}/\d{1,2}/\d{4})\b').firstMatch(text.texto);
      if (match != null && _normalizar(text.texto).contains('parana')) {
        return match.group(1);
      }
    }
    return null;
  }

  String _normalizar(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
    required this.estado,
    required this.fecha,
    required this.nota,
  });

  final double y;
  final double xAnio;
  final int anio;
  final String estado;
  final String fecha;
  final String nota;
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
