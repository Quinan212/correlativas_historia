import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelos/modelos_trayectoria_sage_laboratorio.dart';

class RepositorioTrayectoriaSageLaboratorio {
  const RepositorioTrayectoriaSageLaboratorio();

  static const String _storageKey = 'trayectoria_sage_laboratorio_v1';

  Future<TrayectoriaSageLaboratorio?> cargar() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return TrayectoriaSageLaboratorio.fromJson(
        Map<String, dynamic>.from(decoded),
      );
    } catch (_) {
      return null;
    }
  }

  Future<TrayectoriaSageLaboratorio> guardar(
    TrayectoriaSageLaboratorio draft,
  ) => guardarIdempotente(draft);

  Future<TrayectoriaSageLaboratorio> guardarIdempotente(
    TrayectoriaSageLaboratorio draft,
  ) async {
    final normalized = _normalizarTrayectoria(draft);
    if (!normalized.listaParaSincronizar) {
      throw StateError('La trayectoria no contiene materias válidas.');
    }

    final confirmed = normalized.confirmarSincronizacion(DateTime.now());
    final preferences = await SharedPreferences.getInstance();
    final stored = await preferences.setString(
      _storageKey,
      jsonEncode(confirmed.toJson()),
    );
    if (!stored) {
      throw StateError('No se pudo guardar la trayectoria en el dispositivo.');
    }
    return confirmed;
  }

  Future<void> borrar() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_storageKey);
  }

  TrayectoriaSageLaboratorio _normalizarTrayectoria(
    TrayectoriaSageLaboratorio draft,
  ) {
    final careers = <CarreraTrayectoriaSageLaboratorio>[];
    final careerIndexes = <String, int>{};

    for (final career in draft.carreras) {
      final key = _careerIdentity(career);
      final normalized = _normalizarCarrera(career);
      final previousIndex = careerIndexes[key];
      if (previousIndex == null) {
        careerIndexes[key] = careers.length;
        careers.add(normalized);
        continue;
      }
      careers[previousIndex] = _fusionarCarreras(
        careers[previousIndex],
        normalized,
      );
    }

    return TrayectoriaSageLaboratorio(
      versionEsquema: draft.versionEsquema,
      perfil: draft.perfil,
      carreras: List<CarreraTrayectoriaSageLaboratorio>.unmodifiable(careers),
      capturadaEn: draft.capturadaEn,
      sincronizadaEn: draft.sincronizadaEn,
    );
  }

  CarreraTrayectoriaSageLaboratorio _normalizarCarrera(
    CarreraTrayectoriaSageLaboratorio career,
  ) {
    final subjects = <MateriaTrayectoriaSageLaboratorio>[];
    final subjectIndexes = <String, int>{};
    for (final subject in career.materias) {
      if (subject.nombre.trim().isEmpty) continue;
      final key = _subjectIdentity(subject);
      final previousIndex = subjectIndexes[key];
      if (previousIndex == null) {
        subjectIndexes[key] = subjects.length;
        subjects.add(subject);
        continue;
      }
      subjects[previousIndex] = _preferirMateria(
        subjects[previousIndex],
        subject,
      );
    }
    return CarreraTrayectoriaSageLaboratorio(
      gridRowId: career.gridRowId,
      internalId: career.internalId,
      careerContextId: career.careerContextId,
      careerKey: career.careerKey,
      nombre: career.nombre,
      institucion: career.institucion,
      anioInicio: career.anioInicio,
      estado: career.estado,
      estadoInscripcion: career.estadoInscripcion,
      aprobadasInformadas: career.aprobadasInformadas,
      regularesInformadas: career.regularesInformadas,
      cursandoInformadas: career.cursandoInformadas,
      materias: List<MateriaTrayectoriaSageLaboratorio>.unmodifiable(subjects),
    );
  }

  CarreraTrayectoriaSageLaboratorio _fusionarCarreras(
    CarreraTrayectoriaSageLaboratorio first,
    CarreraTrayectoriaSageLaboratorio second,
  ) {
    final combined = <MateriaTrayectoriaSageLaboratorio>[
      ...first.materias,
      ...second.materias,
    ];
    return _normalizarCarrera(
      CarreraTrayectoriaSageLaboratorio(
        gridRowId: first.gridRowId.trim().isNotEmpty
            ? first.gridRowId
            : second.gridRowId,
        internalId: first.internalId ?? second.internalId,
        careerContextId: first.careerContextId ?? second.careerContextId,
        careerKey: first.careerKey.trim().isNotEmpty
            ? first.careerKey
            : second.careerKey,
        nombre: first.nombre.trim().isNotEmpty ? first.nombre : second.nombre,
        institucion: first.institucion.trim().isNotEmpty
            ? first.institucion
            : second.institucion,
        anioInicio: first.anioInicio ?? second.anioInicio,
        estado: first.estado ?? second.estado,
        estadoInscripcion: first.estadoInscripcion ?? second.estadoInscripcion,
        aprobadasInformadas:
            first.aprobadasInformadas ?? second.aprobadasInformadas,
        regularesInformadas:
            first.regularesInformadas ?? second.regularesInformadas,
        cursandoInformadas:
            first.cursandoInformadas ?? second.cursandoInformadas,
        materias: combined,
      ),
    );
  }

  MateriaTrayectoriaSageLaboratorio _preferirMateria(
    MateriaTrayectoriaSageLaboratorio first,
    MateriaTrayectoriaSageLaboratorio second,
  ) {
    final firstRank = _statusRank(first.estado);
    final secondRank = _statusRank(second.estado);
    if (secondRank > firstRank) return second;
    if (secondRank < firstRank) return first;
    if (second.estadoOriginal.trim().length >
        first.estadoOriginal.trim().length) {
      return second;
    }
    return first;
  }

  int _statusRank(EstadoMateriaSageLaboratorio status) => switch (status) {
    EstadoMateriaSageLaboratorio.aprobada => 5,
    EstadoMateriaSageLaboratorio.regular => 4,
    EstadoMateriaSageLaboratorio.cursando => 3,
    EstadoMateriaSageLaboratorio.noRegularizada => 2,
    EstadoMateriaSageLaboratorio.desconocida => 1,
  };

  String _careerIdentity(CarreraTrayectoriaSageLaboratorio career) {
    if (career.careerKey.trim().isNotEmpty) {
      return _normalize(career.careerKey);
    }
    return <String>[
      _normalize(career.nombre),
      _normalize(career.institucion),
      career.anioInicio?.toString() ?? '',
    ].join('|');
  }

  String _subjectIdentity(MateriaTrayectoriaSageLaboratorio subject) {
    if (subject.idSage.trim().isNotEmpty) {
      return 'id:${subject.idSage.trim().toLowerCase()}';
    }
    return <String>[
      _normalize(subject.nombre),
      subject.anio?.toString() ?? '',
    ].join('|');
  }

  String _normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}
