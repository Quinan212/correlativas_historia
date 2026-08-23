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
    final previous = await cargar();
    final normalizedDraft = _normalizarTrayectoria(draft);
    final normalized = previous == null ||
            !_mismaIdentidad(normalizedDraft.perfil, previous.perfil)
        ? normalizedDraft
        : _conservarDatosAcademicosPrevios(normalizedDraft, previous);
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
      versionEsquema: draft.versionEsquema < 3 ? 3 : draft.versionEsquema,
      perfil: draft.perfil,
      carreras: List<CarreraTrayectoriaSageLaboratorio>.unmodifiable(careers),
      documentos: _normalizarDocumentos(draft.documentos),
      capturadaEn: draft.capturadaEn,
      sincronizadaEn: draft.sincronizadaEn,
    );
  }

  bool _mismaIdentidad(
    PerfilTrayectoriaSageLaboratorio actual,
    PerfilTrayectoriaSageLaboratorio anterior,
  ) {
    final dniActual = actual.dni?.replaceAll(RegExp(r'[^0-9]+'), '') ?? '';
    final dniAnterior = anterior.dni?.replaceAll(RegExp(r'[^0-9]+'), '') ?? '';
    if (dniActual.isNotEmpty || dniAnterior.isNotEmpty) {
      return dniActual.isNotEmpty && dniActual == dniAnterior;
    }
    final nombreActual = _normalizarIdentidad(actual.nombre);
    final nombreAnterior = _normalizarIdentidad(anterior.nombre);
    return nombreActual.isNotEmpty && nombreActual == nombreAnterior;
  }

  String _normalizarIdentidad(String value) => value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  TrayectoriaSageLaboratorio _conservarDatosAcademicosPrevios(
    TrayectoriaSageLaboratorio current,
    TrayectoriaSageLaboratorio previous,
  ) {
    final previousCareers = <String, CarreraTrayectoriaSageLaboratorio>{
      for (final career in previous.carreras) _careerIdentity(career): career,
    };
    final careers = <CarreraTrayectoriaSageLaboratorio>[];

    for (final career in current.carreras) {
      final previousCareer = previousCareers[_careerIdentity(career)];
      if (previousCareer == null) {
        careers.add(career);
        continue;
      }
      final previousSubjects = <String, MateriaTrayectoriaSageLaboratorio>{
        for (final subject in previousCareer.materias)
          _subjectIdentity(subject): subject,
      };
      final subjects = <MateriaTrayectoriaSageLaboratorio>[];
      for (final subject in career.materias) {
        final previousSubject = previousSubjects[_subjectIdentity(subject)];
        if (previousSubject == null) {
          subjects.add(subject);
          continue;
        }
        final preserveApprovedData =
            subject.estado == EstadoMateriaSageLaboratorio.aprobada;
        subjects.add(
          subject.copyWith(
            anio: subject.anio ?? previousSubject.anio,
            fecha: preserveApprovedData
                ? _preferirFecha(subject.fecha, previousSubject.fecha)
                : subject.fecha,
            nota: preserveApprovedData
                ? _preferirTexto(subject.nota, previousSubject.nota)
                : subject.nota,
          ),
        );
      }
      careers.add(
        CarreraTrayectoriaSageLaboratorio(
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
          materias: List<MateriaTrayectoriaSageLaboratorio>.unmodifiable(
            subjects,
          ),
        ),
      );
    }

    return TrayectoriaSageLaboratorio(
      versionEsquema: current.versionEsquema,
      perfil: current.perfil,
      carreras: List<CarreraTrayectoriaSageLaboratorio>.unmodifiable(careers),
      documentos: current.documentos,
      capturadaEn: current.capturadaEn,
      sincronizadaEn: current.sincronizadaEn,
    );
  }

  List<DocumentoAcademicoSage> _normalizarDocumentos(
    List<DocumentoAcademicoSage> documentos,
  ) {
    final result = <DocumentoAcademicoSage>[];
    final indexes = <String, int>{};
    for (final documento in documentos) {
      final key = <String>[
        documento.identidadCarrera,
        documento.tipo.clave,
      ].join('|');
      final existingIndex = indexes[key];
      if (existingIndex == null) {
        indexes[key] = result.length;
        result.add(documento);
        continue;
      }
      if (!result[existingIndex].disponible && documento.disponible) {
        result[existingIndex] = documento;
      }
    }
    return List<DocumentoAcademicoSage>.unmodifiable(result);
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
    final preferred = secondRank > firstRank
        ? second
        : secondRank < firstRank
        ? first
        : second.estadoOriginal.trim().length > first.estadoOriginal.trim().length
        ? second
        : first;
    final alternate = identical(preferred, first) ? second : first;

    return MateriaTrayectoriaSageLaboratorio(
      idSage: preferred.idSage.trim().isNotEmpty
          ? preferred.idSage
          : alternate.idSage,
      nombre: preferred.nombre.trim().isNotEmpty
          ? preferred.nombre
          : alternate.nombre,
      estadoOriginal: preferred.estadoOriginal.trim().isNotEmpty
          ? preferred.estadoOriginal
          : alternate.estadoOriginal,
      estado: preferred.estado,
      anio: preferred.anio ?? alternate.anio,
      fecha: _preferirFecha(preferred.fecha, alternate.fecha),
      nota: _preferirTexto(preferred.nota, alternate.nota),
    );
  }

  String? _preferirTexto(String? primary, String? alternate) {
    final first = primary?.trim() ?? '';
    if (first.isNotEmpty) return first;
    final second = alternate?.trim() ?? '';
    return second.isEmpty ? null : second;
  }

  String? _preferirFecha(String? primary, String? alternate) {
    final first = primary?.trim() ?? '';
    final second = alternate?.trim() ?? '';
    if (first.isEmpty) return second.isEmpty ? null : second;
    if (second.isEmpty) return first;
    final firstDate = parsearFechaAcademicaSage(first);
    final secondDate = parsearFechaAcademicaSage(second);
    if (firstDate == null) return secondDate == null ? first : second;
    if (secondDate == null) return first;
    return secondDate.isAfter(firstDate) ? second : first;
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
