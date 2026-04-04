import '../../../models/materia.dart';
import '../../examenes/models/examen_event.dart';
import 'historia_horarios_docentes_reference.dart';
import '../models/opiniones_catalog.dart';
import '../utils/opiniones_normalize.dart';

class OpinionesCatalogRepository {
  const OpinionesCatalogRepository();

  OpinionesCatalogo buildCatalogo({
    required String careerId,
    required List<Materia> materias,
    required List<ExamenEvent> eventos,
  }) {
    final docentesPorMateria = <String, Map<String, _DocenteAccumulator>>{};
    final docentes = <String, _DocenteBaseAccumulator>{};

    for (final evento in eventos) {
      final materiaPlan = resolveMateriaPlan(
        nombreEvento: evento.materia,
        anioEvento: evento.anio,
        materiasPlan: materias,
      );
      if (materiaPlan == null) continue;

      for (final rawNombre in evento.docentes) {
        _mergeDocenteLink(
          materiaPlan: materiaPlan,
          rawNombre: rawNombre,
          apariciones: 1,
          docentesPorMateria: docentesPorMateria,
          docentes: docentes,
        );
      }
    }

    if (careerId == 'historia') {
      _applyHistoriaHorarios(
        materias: materias,
        docentesPorMateria: docentesPorMateria,
        docentes: docentes,
      );
    }

    return OpinionesCatalogo(
      docentesPorMateria: {
        for (final entry in docentesPorMateria.entries)
          entry.key: entry.value.values
              .map((value) => DocenteLite(
                    id: value.id,
                    nombre: value.nombre,
                    apariciones: value.apariciones,
                  ))
              .toList()
            ..sort((a, b) {
              final byAppearances = b.apariciones.compareTo(a.apariciones);
              if (byAppearances != 0) return byAppearances;
              return a.nombre.compareTo(b.nombre);
            }),
      },
      docentes: {
        for (final entry in docentes.entries)
          entry.key: DocenteComunidadBase(
            id: entry.value.id,
            nombre: entry.value.nombre,
            materias: entry.value.materias.values.toList()
              ..sort((a, b) {
                final byYear = a.anio.compareTo(b.anio);
                if (byYear != 0) return byYear;
                return a.nombre.compareTo(b.nombre);
              }),
            aparicionesTotales: entry.value.aparicionesTotales,
          ),
      },
    );
  }

  void _applyHistoriaHorarios({
    required List<Materia> materias,
    required Map<String, Map<String, _DocenteAccumulator>> docentesPorMateria,
    required Map<String, _DocenteBaseAccumulator> docentes,
  }) {
    for (final ref in kHistoriaHorariosDocentesRef) {
      final materiaPlan = resolveMateriaPlan(
        nombreEvento: ref.materiaNombre,
        anioEvento: ref.anio,
        materiasPlan: materias,
      );
      if (materiaPlan == null) continue;

      for (final entry in ref.docentes.entries) {
        _mergeDocenteLink(
          materiaPlan: materiaPlan,
          rawNombre: entry.key,
          apariciones: entry.value,
          docentesPorMateria: docentesPorMateria,
          docentes: docentes,
        );
      }
    }
  }

  void _mergeDocenteLink({
    required Materia materiaPlan,
    required String rawNombre,
    required int apariciones,
    required Map<String, Map<String, _DocenteAccumulator>> docentesPorMateria,
    required Map<String, _DocenteBaseAccumulator> docentes,
  }) {
    final nombre = cleanDocenteNombre(rawNombre);
    if (nombre.isEmpty) return;

    final docenteId = buildDocenteId(nombre);
    final materiaMap = docentesPorMateria.putIfAbsent(
      materiaPlan.id,
      () => <String, _DocenteAccumulator>{},
    );
    final materiaAcc = materiaMap.putIfAbsent(
      docenteId,
      () => _DocenteAccumulator(id: docenteId, nombre: nombre),
    );
    materiaAcc.apariciones += apariciones;

    final docenteAcc = docentes.putIfAbsent(
      docenteId,
      () => _DocenteBaseAccumulator(id: docenteId, nombre: nombre),
    );
    docenteAcc.aparicionesTotales += apariciones;
    docenteAcc.materias[materiaPlan.id] = MateriaLite(
      id: materiaPlan.id,
      nombre: materiaPlan.displayNombre,
      anio: materiaPlan.anio,
    );
  }
}

class _DocenteAccumulator {
  _DocenteAccumulator({
    required this.id,
    required this.nombre,
  });

  final String id;
  final String nombre;
  int apariciones = 0;
}

class _DocenteBaseAccumulator {
  _DocenteBaseAccumulator({
    required this.id,
    required this.nombre,
  });

  final String id;
  final String nombre;
  int aparicionesTotales = 0;
  final Map<String, MateriaLite> materias = <String, MateriaLite>{};
}
