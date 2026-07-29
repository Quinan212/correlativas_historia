import 'dart:math' as math;

import '../../../compartido/utilidades/sanitizar_texto.dart';

String normalizarClaveExcel(String input) {
  var value = sanitizeLowerNoAccents(input)
      .replaceAll('º', 'o')
      .replaceAll('°', 'o')
      .replaceAll('ª', 'a');
  value = value.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String? normalizarCarreraExcel(
  dynamic raw,
  Map<String, List<String>> aliases,
) {
  final value = normalizarClaveExcel(raw?.toString() ?? '');
  if (value.isEmpty) return null;
  for (final entry in aliases.entries) {
    for (final alias in entry.value) {
      final normalizedAlias = normalizarClaveExcel(alias);
      if (value == normalizedAlias || value.contains(normalizedAlias)) {
        return entry.key;
      }
    }
  }
  return null;
}

class UbicacionAcademicaExcel {
  const UbicacionAcademicaExcel({this.anio, this.division});

  final int? anio;
  final String? division;
}

UbicacionAcademicaExcel normalizarAnioDivisionExcel(dynamic raw) {
  final original = sanitizarTexto(raw?.toString() ?? '').trim();
  if (original.isEmpty) return const UbicacionAcademicaExcel();
  final normalized = normalizarClaveExcel(original);
  final numbers = RegExp(r'\d+').allMatches(normalized).toList();
  if (numbers.isEmpty) return const UbicacionAcademicaExcel();
  final year = int.tryParse(numbers.first.group(0) ?? '');
  String? division;
  if (numbers.length >= 2) {
    final divisionNumber = int.tryParse(numbers[1].group(0) ?? '');
    if (divisionNumber != null) {
      division = switch (divisionNumber) {
        1 => '1.ª',
        2 => '2.ª',
        3 => '3.ª',
        _ => '$divisionNumber.ª',
      };
    }
  }
  return UbicacionAcademicaExcel(anio: year, division: division);
}

DateTime? normalizarFechaExcel(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) {
    return DateTime(raw.year, raw.month, raw.day);
  }
  if (raw is num) {
    if (raw >= 1000 && raw <= 100000) {
      final base = DateTime(1899, 12, 30);
      final date = base.add(Duration(days: raw.floor()));
      return DateTime(date.year, date.month, date.day);
    }
    return null;
  }

  final text = sanitizarTexto(raw.toString()).trim();
  if (text.isEmpty) return null;
  final iso = DateTime.tryParse(text);
  if (iso != null) return DateTime(iso.year, iso.month, iso.day);

  final standard = RegExp(
    r'^(\d{1,2})[\-/\.](\d{1,2})[\-/\.](\d{2,4})$',
  ).firstMatch(text);
  if (standard != null) {
    return _safeDate(
      int.parse(standard.group(1)!),
      int.parse(standard.group(2)!),
      _expandYear(int.parse(standard.group(3)!)),
    );
  }

  final compactSeparated = RegExp(
    r'^(\d{1,2})[\-/\.](\d{2})(\d{2})$',
  ).firstMatch(text);
  if (compactSeparated != null) {
    return _safeDate(
      int.parse(compactSeparated.group(1)!),
      int.parse(compactSeparated.group(2)!),
      _expandYear(int.parse(compactSeparated.group(3)!)),
    );
  }

  final compact = RegExp(r'^(\d{2})(\d{2})(\d{2,4})$').firstMatch(text);
  if (compact != null) {
    return _safeDate(
      int.parse(compact.group(1)!),
      int.parse(compact.group(2)!),
      _expandYear(int.parse(compact.group(3)!)),
    );
  }
  return null;
}

String? normalizarHoraExcel(dynamic raw) {
  if (raw == null) return null;
  if (raw is Duration) {
    final totalMinutes = raw.inMinutes.remainder(24 * 60);
    return _formatTime(totalMinutes ~/ 60, totalMinutes % 60);
  }
  if (raw is DateTime) return _formatTime(raw.hour, raw.minute);
  if (raw is num) {
    final value = raw.toDouble();
    if (value >= 0 && value < 1) {
      final totalMinutes = (value * 24 * 60).round().remainder(24 * 60);
      return _formatTime(totalMinutes ~/ 60, totalMinutes % 60);
    }
    if (value >= 0 && value <= 24) {
      final hour = value.floor();
      final minute = ((value - hour) * 60).round();
      final normalizedHour = hour == 24 && minute == 0 ? 0 : hour;
      if (normalizedHour >= 0 && normalizedHour <= 23 && minute <= 59) {
        return _formatTime(normalizedHour, minute);
      }
    }
  }

  var text = sanitizarTexto(raw.toString()).toLowerCase().trim();
  if (text.isEmpty) return null;
  text = text
      .replaceAll('horas', '')
      .replaceAll('hora', '')
      .replaceAll('hs', '')
      .replaceAll('h', '')
      .replaceAll(' ', '')
      .replaceAll(',', ':');
  final match = RegExp(r'^(\d{1,2})(?:[:\.](\d{1,2}))?$').firstMatch(text);
  if (match == null) return null;
  final hour = int.tryParse(match.group(1) ?? '');
  final minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  if (hour == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
    return null;
  }
  return _formatTime(hour, minute);
}

List<String> normalizarDocentesExcel(dynamic raw) {
  final text = sanitizarTexto(raw?.toString() ?? '').trim();
  if (text.isEmpty || normalizarClaveExcel(text) == 'acta') {
    return const <String>[];
  }
  return text
      .split(RegExp(r'[/;\n]+'))
      .map((value) => normalizeDocenteDisplayName(value.trim()))
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
}

String nombreCarreraExcel(String careerId) {
  return switch (careerId) {
    'historia' => 'Historia',
    'geografia' => 'Geografía',
    'politica' => 'Ciencia Política',
    _ => careerId,
  };
}

String generarFirmaDocentesExcel(List<String> teachers) {
  final normalized = teachers.map(normalizarClaveExcel).toList()..sort();
  return normalized.join('|');
}

String generarIdentidadBaseEventoExcel({
  required String instancia,
  required String careerId,
  required String subjectId,
  required int? anio,
  required String? division,
  required DateTime? fecha,
  required String? hora,
}) {
  final date = fecha == null
      ? 'sin-fecha'
      : '${fecha.year.toString().padLeft(4, '0')}-'
            '${fecha.month.toString().padLeft(2, '0')}-'
            '${fecha.day.toString().padLeft(2, '0')}';
  return <String>[
    instancia,
    careerId,
    subjectId,
    anio?.toString() ?? 'sin-anio',
    normalizarClaveExcel(division ?? 'sin-division'),
    date,
    hora ?? 'sin-hora',
  ].join('|');
}

int levenshteinExcel(String first, String second) {
  if (first == second) return 0;
  if (first.isEmpty) return second.length;
  if (second.isEmpty) return first.length;
  var previous = List<int>.generate(second.length + 1, (index) => index);
  for (var i = 0; i < first.length; i++) {
    final current = List<int>.filled(second.length + 1, 0);
    current[0] = i + 1;
    for (var j = 0; j < second.length; j++) {
      final insertion = current[j] + 1;
      final deletion = previous[j + 1] + 1;
      final substitution = previous[j] + (first[i] == second[j] ? 0 : 1);
      current[j + 1] = math.min(insertion, math.min(deletion, substitution));
    }
    previous = current;
  }
  return previous.last;
}

DateTime? _safeDate(int day, int month, int year) {
  if (year < 2000 || year > 2100 || month < 1 || month > 12 || day < 1) {
    return null;
  }
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

int _expandYear(int year) {
  if (year >= 100) return year;
  return year >= 70 ? 1900 + year : 2000 + year;
}

String _formatTime(int hour, int minute) {
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}
