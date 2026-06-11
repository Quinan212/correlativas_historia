import '../../../modelos/materia.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../datos/historia_docentes_reference.dart';

const _emdash = '\u2014';

String normalizeOpinionText(String value) =>
    sanitizeLowerNoAccents(value).replaceAll(RegExp(r'\s+'), ' ').trim();

String buildDocenteId(String nombre) {
  var value = normalizeOpinionText(nombre);
  value = value.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return value.replaceAll(' ', '_');
}

String cleanDocenteNombre(String nombre) {
  var value = sanitizarTexto(nombre);
  value = value.replaceAll(
    RegExp(r'\((o\s+su\s+suplente|o\s+suplente)\)', caseSensitive: false),
    '',
  );
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return canonicalizeHistoriaDocenteNombre(value);
}

final Map<String, HistoriaDocenteCanon> _historiaDocenteAliasIndex = () {
  final counts = <String, int>{};
  for (final entry in kHistoriaDocentesCanon) {
    final surname = _normalizedSurnameKey(entry);
    counts[surname] = (counts[surname] ?? 0) + 1;
  }

  final index = <String, HistoriaDocenteCanon>{};
  for (final entry in kHistoriaDocentesCanon) {
    for (final alias in _aliasesForCanon(entry, counts)) {
      index.putIfAbsent(alias, () => entry);
    }
  }
  return index;
}();

String canonicalizeHistoriaDocenteNombre(String rawNombre) {
  final cleaned =
      sanitizarTexto(rawNombre).replaceAll(RegExp(r'\s+'), ' ').trim();
  if (cleaned.isEmpty) return cleaned;

  final normalized = _normalizeDocenteForMatch(cleaned);
  final exact = _historiaDocenteAliasIndex[normalized];
  if (exact != null) return exact.displayName;

  HistoriaDocenteCanon? best;
  var bestScore = 0.0;
  for (final entry in kHistoriaDocentesCanon) {
    final score = _scoreCanonCandidate(normalized, entry);
    if (score > bestScore) {
      bestScore = score;
      best = entry;
    }
  }

  if (best != null && bestScore >= 0.86) {
    return best.displayName;
  }
  return cleaned;
}

String _normalizeDocenteForMatch(String value) {
  var normalized = normalizeOpinionText(value);
  normalized = normalized.replaceAll(RegExp(r'[\.,;:/()\-_]'), ' ');
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalized;
}

Set<String> _docenteTokens(String value) {
  return _normalizeDocenteForMatch(value)
      .split(' ')
      .where((part) => part.isNotEmpty)
      .toSet();
}

String _normalizedSurnameKey(HistoriaDocenteCanon entry) {
  final sort = sanitizarTexto(entry.sortName);
  if (!sort.contains(',')) {
    return _normalizeDocenteForMatch(sort);
  }
  return _normalizeDocenteForMatch(sort.split(',').first);
}

Iterable<String> _aliasesForCanon(
  HistoriaDocenteCanon entry,
  Map<String, int> surnameCounts,
) sync* {
  final display = sanitizarTexto(entry.displayName);
  final sort = sanitizarTexto(entry.sortName);
  yield _normalizeDocenteForMatch(display);
  yield _normalizeDocenteForMatch(sort);

  if (sort.contains(',')) {
    final parts = sort.split(',');
    final surname = sanitizarTexto(parts.first);
    final names = sanitizarTexto(parts.sublist(1).join(' '));
    final firstNameParts = names.split(' ').where((e) => e.isNotEmpty).toList();
    final firstName = firstNameParts.isEmpty ? '' : firstNameParts.first;
    yield _normalizeDocenteForMatch('$surname $names');
    yield _normalizeDocenteForMatch('$names $surname');
    if (firstName.isNotEmpty) {
      yield _normalizeDocenteForMatch('$surname $firstName');
      yield _normalizeDocenteForMatch('$firstName $surname');
    }
    final surnameKey = _normalizeDocenteForMatch(surname);
    if ((surnameCounts[surnameKey] ?? 0) == 1) {
      yield surnameKey;
    }
  }

  for (final alias in entry.aliases) {
    yield _normalizeDocenteForMatch(alias);
  }
}

double _scoreCanonCandidate(String rawNormalized, HistoriaDocenteCanon entry) {
  var best = 0.0;
  final rawTokens = _docenteTokens(rawNormalized);
  final rawCompact = rawNormalized.replaceAll(' ', '');

  for (final alias in _aliasesForCanon(entry, const <String, int>{})) {
    if (alias.isEmpty) continue;
    if (rawNormalized == alias) return 1.0;

    final aliasTokens = _docenteTokens(alias);
    final tokenScore = _scoreTokenSets(rawTokens, aliasTokens);
    if (tokenScore > best) best = tokenScore;

    final aliasCompact = alias.replaceAll(' ', '');
    final compactScore = _normalizedSimilarity(rawCompact, aliasCompact);
    if (compactScore > best) best = compactScore;
  }

  return best;
}

double _scoreTokenSets(Set<String> rawTokens, Set<String> aliasTokens) {
  if (rawTokens.isEmpty || aliasTokens.isEmpty) return 0;

  var matched = 0;
  for (final raw in rawTokens) {
    for (final alias in aliasTokens) {
      if (raw == alias ||
          raw.startsWith(alias) ||
          alias.startsWith(raw) ||
          _normalizedSimilarity(raw, alias) >= 0.88) {
        matched += 1;
        break;
      }
    }
  }

  final denom = rawTokens.length > aliasTokens.length
      ? rawTokens.length
      : aliasTokens.length;
  return matched / denom;
}

double _normalizedSimilarity(String a, String b) {
  if (a.isEmpty || b.isEmpty) return 0;
  if (a == b) return 1;
  final distance = _levenshteinDistance(a, b);
  final maxLen = a.length > b.length ? a.length : b.length;
  return 1 - (distance / maxLen);
}

int _levenshteinDistance(String a, String b) {
  final costs = List<int>.generate(b.length + 1, (i) => i);

  for (var i = 1; i <= a.length; i++) {
    var previous = costs.first;
    costs[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final temp = costs[j];
      final substitution = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      costs[j] = [
        costs[j] + 1,
        costs[j - 1] + 1,
        previous + substitution,
      ].reduce((x, y) => x < y ? x : y);
      previous = temp;
    }
  }

  return costs.last;
}

String _limpiarParaMatch(String s) {
  var value = normalizeOpinionText(s);

  value = value.replaceAll(
    RegExp(r'cult\.?\s*americanos', caseSensitive: false),
    'culturales americanos',
  );

  value = value.replaceAll(RegExp('[$_emdash\u2013]'), ' ');
  value = value.replaceAll(RegExp(r'[\.\,\;\:\-\(\)\/]'), ' ');

  value = value
      .replaceAll(RegExp(r'\bproc\b'), 'procesos')
      .replaceAll(RegExp(r'\bsoc\b'), 'sociales')
      .replaceAll(RegExp(r'\bpolit\b'), 'politicos')
      .replaceAll(RegExp(r'\bpol\b'), 'politicos')
      .replaceAll(RegExp(r'\becon\b'), 'economicos')
      .replaceAll(RegExp(r'\bcult\b'), 'culturales')
      .replaceAll(RegExp(r'\bamer\b'), 'americanos')
      .replaceAll(RegExp(r'\bcs\b'), 'ciencias')
      .replaceAll(RegExp(r'\barg\b'), 'argentina')
      .replaceAll(RegExp(r'\besi\b'), 'educacion sexual integral')
      .replaceAll(RegExp(r'\budi\b'), 'unidad de definicion institucional');

  value = value
      .replaceAll(RegExp(r'\biv\b'), '4')
      .replaceAll(RegExp(r'\biii\b'), '3')
      .replaceAll(RegExp(r'\bii\b'), '2')
      .replaceAll(RegExp(r'\bi\b'), '1');

  value = value.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  return value;
}

Set<String> _tokensMatch(String s) {
  final value = _limpiarParaMatch(s);

  const stop = {
    'de',
    'del',
    'la',
    'las',
    'el',
    'los',
    'y',
    'en',
    'a',
    'al',
    'educacion',
    'ciencias',
    'sociales',
    'procesos',
    'culturales',
    'politicos',
    'economicos',
    'americanos',
  };

  return value
      .split(' ')
      .where((part) => part.length >= 3 && !stop.contains(part))
      .toSet();
}

double _scoreTokens(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final inter = a.intersection(b).length;
  final denom = a.length > b.length ? a.length : b.length;
  return inter / denom;
}

int? _numeroPractica(String s) {
  final value = _limpiarParaMatch(s);
  if (RegExp(r'\b4\b').hasMatch(value)) return 4;
  if (RegExp(r'\b3\b').hasMatch(value)) return 3;
  if (RegExp(r'\b2\b').hasMatch(value)) return 2;
  if (RegExp(r'\b1\b').hasMatch(value)) return 1;
  return null;
}

String _baseDesdeTap(String tap) {
  final value = sanitizarTexto(tap).trim();
  final index = value.lastIndexOf(_emdash);
  if (index == -1) return value;
  return value.substring(0, index).trim();
}

String _stripDivisionNoise(String value) {
  var text = sanitizarTexto(value).trim();
  text = text.replaceAll(
    RegExp(
      r'\s*[-–—]?\s*(comision|comisión|division|división|grupo)\s+([ab])\b',
      caseSensitive: false,
    ),
    '',
  );
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _matchPracticaDocenteN(String evento, Materia plan) {
  final eventoNormalizado = _limpiarParaMatch(evento);
  if (!eventoNormalizado.contains('practica')) return false;

  final nEv = _numeroPractica(evento);
  if (nEv == null) return false;

  final planValue = _limpiarParaMatch(plan.displayNombre);
  final esPracticaPlan = planValue.contains('practica');
  final esDocentePlan =
      planValue.contains('docente') || planValue.contains('profesional');

  if (!(esPracticaPlan && esDocentePlan)) return false;
  return _numeroPractica(plan.displayNombre) == nEv;
}

Materia? resolveMateriaPlan({
  required String nombreEvento,
  required int? anioEvento,
  required List<Materia> materiasPlan,
}) {
  final limpio = _stripDivisionNoise(_baseDesdeTap(nombreEvento));
  final target = _limpiarParaMatch(limpio);

  for (final materia in materiasPlan) {
    if (anioEvento != null && materia.anio != anioEvento) continue;
    if (_matchPracticaDocenteN(limpio, materia)) return materia;
  }

  for (final materia in materiasPlan) {
    if (anioEvento != null && materia.anio != anioEvento) continue;
    if (_limpiarParaMatch(materia.displayNombre) == target) return materia;
  }

  final candidatos = anioEvento != null
      ? materiasPlan.where((m) => m.anio == anioEvento).toList()
      : materiasPlan;

  for (final materia in candidatos) {
    final cleaned = _limpiarParaMatch(materia.displayNombre);
    if (cleaned.contains(target) || target.contains(cleaned)) return materia;
  }

  final tokEvento = _tokensMatch(limpio);
  Materia? mejor;
  var mejorScore = 0.0;

  for (final materia in candidatos) {
    final score = _scoreTokens(tokEvento, _tokensMatch(materia.displayNombre));
    if (score > mejorScore) {
      mejorScore = score;
      mejor = materia;
    }
  }

  if (mejorScore >= 0.50) return mejor;
  return null;
}
