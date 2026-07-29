import '../configuracion/reglas_mesas_excel.dart';
import '../modelos/modelos_mesas_excel.dart';
import 'normalizador_mesas_excel.dart';

class ResolvedorMateriasMesasExcel {
  ResolvedorMateriasMesasExcel(List<MateriaCatalogoExcel> catalogo)
    : _catalogo = List<MateriaCatalogoExcel>.unmodifiable(catalogo),
      _porId = <String, MateriaCatalogoExcel>{
        for (final subject in catalogo) '${subject.careerId}|${subject.id}': subject,
      },
      _aliases = _buildAliases();

  final List<MateriaCatalogoExcel> _catalogo;
  final Map<String, MateriaCatalogoExcel> _porId;
  final Map<String, List<AliasMateriaExcel>> _aliases;

  static Map<String, List<AliasMateriaExcel>> _buildAliases() {
    final out = <String, List<AliasMateriaExcel>>{};
    for (final alias in aliasMateriasExcel) {
      out.putIfAbsent(alias.careerId, () => <AliasMateriaExcel>[]).add(alias);
    }
    return out;
  }

  ResultadoCoincidenciaMateriaExcel resolver({
    required String careerId,
    required String sourceName,
    int? year,
  }) {
    final normalizedSource = normalizarClaveExcel(sourceName);
    if (normalizedSource.isEmpty) {
      return ResultadoCoincidenciaMateriaExcel(
        tipo: TipoCoincidenciaMateriaExcel.sinCoincidencia,
        nombreFuente: sourceName,
        confianza: 0,
        margenSegundoCandidato: 0,
      );
    }

    final candidates = _catalogo
        .where((subject) => subject.careerId == careerId)
        .toList(growable: false);

    for (final subject in candidates) {
      if (normalizarClaveExcel(subject.nombre) == normalizedSource) {
        return ResultadoCoincidenciaMateriaExcel(
          tipo: TipoCoincidenciaMateriaExcel.exacta,
          nombreFuente: sourceName,
          materia: subject,
          confianza: 1,
          margenSegundoCandidato: 1,
        );
      }
      if (subject.codigo.trim().isNotEmpty &&
          normalizarClaveExcel(subject.codigo) == normalizedSource) {
        return ResultadoCoincidenciaMateriaExcel(
          tipo: TipoCoincidenciaMateriaExcel.codigo,
          nombreFuente: sourceName,
          materia: subject,
          confianza: 1,
          margenSegundoCandidato: 1,
        );
      }
    }

    for (final alias in _aliases[careerId] ?? const <AliasMateriaExcel>[]) {
      if (alias.year != null && year != null && alias.year != year) continue;
      if (normalizarClaveExcel(alias.alias) != normalizedSource) continue;
      final subject = _porId['$careerId|${alias.subjectId}'];
      if (subject == null) continue;
      return ResultadoCoincidenciaMateriaExcel(
        tipo: TipoCoincidenciaMateriaExcel.alias,
        nombreFuente: sourceName,
        materia: subject,
        confianza: 1,
        margenSegundoCandidato: 1,
      );
    }

    var scoped = candidates;
    if (year != null) {
      final sameYear = candidates
          .where((subject) => subject.anio == year)
          .toList(growable: false);
      if (sameYear.isNotEmpty) scoped = sameYear;
    }
    final scored = <({MateriaCatalogoExcel subject, double score})>[];
    for (final subject in scoped) {
      scored.add((subject: subject, score: _score(sourceName, subject, year)));
    }
    scored.sort((first, second) => second.score.compareTo(first.score));
    if (scored.isEmpty) {
      return ResultadoCoincidenciaMateriaExcel(
        tipo: TipoCoincidenciaMateriaExcel.sinCoincidencia,
        nombreFuente: sourceName,
        confianza: 0,
        margenSegundoCandidato: 0,
      );
    }
    final first = scored.first;
    final second = scored.length > 1 ? scored[1] : null;
    final margin = second == null ? first.score : first.score - second.score;
    if (first.score >= 0.88 && margin >= 0.10) {
      return ResultadoCoincidenciaMateriaExcel(
        tipo: TipoCoincidenciaMateriaExcel.aproximada,
        nombreFuente: sourceName,
        materia: first.subject,
        segundoCandidato: second?.subject,
        confianza: first.score,
        margenSegundoCandidato: margin,
      );
    }
    if (first.score >= 0.78) {
      return ResultadoCoincidenciaMateriaExcel(
        tipo: TipoCoincidenciaMateriaExcel.ambigua,
        nombreFuente: sourceName,
        materia: first.subject,
        segundoCandidato: second?.subject,
        confianza: first.score,
        margenSegundoCandidato: margin,
      );
    }
    return ResultadoCoincidenciaMateriaExcel(
      tipo: TipoCoincidenciaMateriaExcel.sinCoincidencia,
      nombreFuente: sourceName,
      segundoCandidato: second?.subject,
      confianza: first.score,
      margenSegundoCandidato: margin,
    );
  }

  double _score(
    String sourceName,
    MateriaCatalogoExcel subject,
    int? year,
  ) {
    final source = normalizarClaveExcel(sourceName);
    final target = normalizarClaveExcel(subject.nombre);
    if (source.isEmpty || target.isEmpty) return 0;
    final sourceTokens = source.split(' ').where((value) => value.isNotEmpty).toSet();
    final targetTokens = target.split(' ').where((value) => value.isNotEmpty).toSet();
    final intersection = sourceTokens.intersection(targetTokens).length;
    final tokenDice = sourceTokens.isEmpty && targetTokens.isEmpty
        ? 1.0
        : (2 * intersection) / (sourceTokens.length + targetTokens.length);
    final maxLength = source.length > target.length ? source.length : target.length;
    final charSimilarity = maxLength == 0
        ? 1.0
        : 1 - (levenshteinExcel(source, target) / maxLength);
    final acronymSimilarity = _acronym(source) == _acronym(target) ? 1.0 : 0.0;
    final yearScore = year == null ? 0.5 : (subject.anio == year ? 1.0 : 0.0);
    return (tokenDice * 0.45) +
        (charSimilarity * 0.35) +
        (acronymSimilarity * 0.10) +
        (yearScore * 0.10);
  }

  String _acronym(String value) {
    const ignored = <String>{
      'de',
      'del',
      'la',
      'las',
      'los',
      'y',
      'en',
      'el',
      'para',
    };
    return value
        .split(' ')
        .where((token) => token.isNotEmpty && !ignored.contains(token))
        .map((token) => token[0])
        .join();
  }
}
