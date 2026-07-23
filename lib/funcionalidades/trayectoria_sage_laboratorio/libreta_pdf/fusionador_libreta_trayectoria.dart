import '../modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'modelos_libreta_pdf.dart';

class ResultadoFusionLibretaTrayectoria {
  const ResultadoFusionLibretaTrayectoria({
    required this.trayectoria,
    required this.coincidencias,
    required this.sinCoincidencia,
    required this.ambiguas,
  });

  final TrayectoriaSageLaboratorio trayectoria;
  final int coincidencias;
  final int sinCoincidencia;
  final int ambiguas;
}

class FusionadorLibretaTrayectoria {
  const FusionadorLibretaTrayectoria();

  ResultadoFusionLibretaTrayectoria aplicar({
    required TrayectoriaSageLaboratorio trayectoria,
    required String gridRowId,
    required ResultadoExtraccionLibretaPdf libreta,
  }) {
    var coincidencias = 0;
    var sinCoincidencia = 0;
    var ambiguas = 0;
    final carreras = <CarreraTrayectoriaSageLaboratorio>[];

    for (final carrera in trayectoria.carreras) {
      if (carrera.gridRowId != gridRowId) {
        carreras.add(carrera);
        continue;
      }

      final usedSubjects = <int>{};
      final assignments = <int, MateriaLibretaPdf>{};
      for (final row in libreta.materias) {
        final candidates = _candidatos(row, carrera.materias, usedSubjects);
        if (candidates.isEmpty) {
          sinCoincidencia++;
          continue;
        }
        final bestScore = candidates.first.score;
        final best = candidates
            .where((candidate) => (candidate.score - bestScore).abs() < 0.0001)
            .toList(growable: false);
        if (best.length != 1 || bestScore < 0.86) {
          ambiguas++;
          continue;
        }
        final candidate = best.single;
        usedSubjects.add(candidate.index);
        assignments[candidate.index] = row;
        coincidencias++;
      }

      final subjects = <MateriaTrayectoriaSageLaboratorio>[];
      for (var index = 0; index < carrera.materias.length; index++) {
        final subject = carrera.materias[index];
        final row = assignments[index];
        if (row == null) {
          subjects.add(subject);
          continue;
        }
        subjects.add(
          subject.copyWith(
            fecha: row.fecha,
            nota: row.calificacion,
          ),
        );
      }
      carreras.add(_copiarCarrera(carrera, subjects));
    }

    return ResultadoFusionLibretaTrayectoria(
      trayectoria: TrayectoriaSageLaboratorio(
        versionEsquema: trayectoria.versionEsquema,
        perfil: trayectoria.perfil,
        carreras: List<CarreraTrayectoriaSageLaboratorio>.unmodifiable(carreras),
        documentos: trayectoria.documentos,
        capturadaEn: trayectoria.capturadaEn,
        sincronizadaEn: trayectoria.sincronizadaEn,
      ),
      coincidencias: coincidencias,
      sinCoincidencia: sinCoincidencia,
      ambiguas: ambiguas,
    );
  }

  List<_CandidatoMateria> _candidatos(
    MateriaLibretaPdf row,
    List<MateriaTrayectoriaSageLaboratorio> subjects,
    Set<int> used,
  ) {
    final result = <_CandidatoMateria>[];
    for (var index = 0; index < subjects.length; index++) {
      if (used.contains(index)) continue;
      final subject = subjects[index];
      if (subject.anio != null && subject.anio != row.anio) continue;
      final score = _similitud(row.nombre, subject.nombre);
      if (score < 0.70) continue;
      result.add(_CandidatoMateria(index: index, score: score));
    }
    result.sort((a, b) => b.score.compareTo(a.score));
    return result;
  }

  double _similitud(String first, String second) {
    final a = _normalizarNombre(first);
    final b = _normalizarNombre(second);
    if (a.isEmpty || b.isEmpty) return 0;
    if (a == b) return 1;
    if (a.contains(b) || b.contains(a)) {
      final shorter = a.length < b.length ? a.length : b.length;
      final longer = a.length > b.length ? a.length : b.length;
      final coverage = shorter / longer;
      if (coverage >= 0.78) return 0.90 + coverage * 0.05;
    }

    final aTokens = a.split(' ').where((token) => token.isNotEmpty).toSet();
    final bTokens = b.split(' ').where((token) => token.isNotEmpty).toSet();
    final intersection = aTokens.intersection(bTokens).length;
    final union = aTokens.union(bTokens).length;
    if (union == 0) return 0;
    final jaccard = intersection / union;
    final prefix = _prefijoComun(a, b) / (a.length < b.length ? a.length : b.length);
    return jaccard * 0.82 + prefix * 0.18;
  }

  int _prefijoComun(String first, String second) {
    final limit = first.length < second.length ? first.length : second.length;
    var index = 0;
    while (index < limit && first.codeUnitAt(index) == second.codeUnitAt(index)) {
      index++;
    }
    return index;
  }

  String _normalizarNombre(String value) {
    final normalized = value
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
    return normalized
        .split(' ')
        .map((token) => _abreviaturas[token] ?? token)
        .join(' ');
  }

  CarreraTrayectoriaSageLaboratorio _copiarCarrera(
    CarreraTrayectoriaSageLaboratorio source,
    List<MateriaTrayectoriaSageLaboratorio> subjects,
  ) {
    return CarreraTrayectoriaSageLaboratorio(
      gridRowId: source.gridRowId,
      internalId: source.internalId,
      careerContextId: source.careerContextId,
      careerKey: source.careerKey,
      nombre: source.nombre,
      institucion: source.institucion,
      anioInicio: source.anioInicio,
      estado: source.estado,
      estadoInscripcion: source.estadoInscripcion,
      aprobadasInformadas: source.aprobadasInformadas,
      regularesInformadas: source.regularesInformadas,
      cursandoInformadas: source.cursandoInformadas,
      materias: List<MateriaTrayectoriaSageLaboratorio>.unmodifiable(subjects),
    );
  }

  static const Map<String, String> _abreviaturas = <String, String>{
    'corp': 'corporeidad',
    'oral': 'oralidad',
    'juego': 'juegos',
    'proc': 'procesos',
    'soc': 'sociales',
    'econ': 'economicos',
    'cult': 'culturales',
    'orig': 'originarios',
    'feud': 'feudalismo',
    'lect': 'lectura',
    'sup': 'superior',
  };
}

class _CandidatoMateria {
  const _CandidatoMateria({required this.index, required this.score});

  final int index;
  final double score;
}
