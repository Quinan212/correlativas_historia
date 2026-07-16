import '../../acceso_estudiante/sage_historial/modelos_historial_sage.dart';
import '../../acceso_estudiante/sage_legajo/modelos_legajo_sage.dart';
import '../modelos/modelos_trayectoria_sage_laboratorio.dart';

class ConstructorTrayectoriaSageLaboratorio {
  const ConstructorTrayectoriaSageLaboratorio._();

  static TrayectoriaSageLaboratorio construir({
    required HistorialNivelSuperiorSage historial,
    PerfilLegajoSage? perfil,
  }) {
    return TrayectoriaSageLaboratorio(
      perfil: _perfil(perfil),
      carreras: historial.carreras
          .map(
            (carrera) => CarreraTrayectoriaSageLaboratorio(
              gridRowId: carrera.gridRowId,
              internalId: carrera.internalId,
              careerContextId: carrera.careerContextId,
              careerKey: carrera.careerKey,
              nombre: carrera.nombre,
              institucion: carrera.institucion,
              anioInicio: carrera.anioInicio,
              estado: carrera.estado,
              estadoInscripcion: carrera.estadoInscripcion,
              aprobadasInformadas: carrera.aprobadas,
              regularesInformadas: carrera.regulares,
              cursandoInformadas: carrera.cursando,
              materias: carrera.materias
                  .map(
                    (materia) => MateriaTrayectoriaSageLaboratorio(
                      idSage: materia.id,
                      nombre: materia.nombre,
                      estadoOriginal: materia.estado,
                      estado: clasificarEstado(materia.estado),
                      anio: materia.anio,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      capturadaEn: DateTime.now(),
    );
  }

  static EstadoMateriaSageLaboratorio clasificarEstado(String raw) {
    final value = _normalizar(raw);
    if (value.contains('no regular') ||
        value.contains('desaprob') ||
        value.contains('recursa')) {
      return EstadoMateriaSageLaboratorio.noRegularizada;
    }
    if (value.contains('aprob') ||
        value.contains('promoc') ||
        value.contains('equival') ||
        value.contains('acredit')) {
      return EstadoMateriaSageLaboratorio.aprobada;
    }
    if (value.contains('regular')) {
      return EstadoMateriaSageLaboratorio.regular;
    }
    if (value.contains('curs') ||
        value.contains('inscrip') ||
        value.contains('en curso')) {
      return EstadoMateriaSageLaboratorio.cursando;
    }
    return EstadoMateriaSageLaboratorio.desconocida;
  }

  static PerfilTrayectoriaSageLaboratorio _perfil(PerfilLegajoSage? profile) {
    if (profile == null) {
      return const PerfilTrayectoriaSageLaboratorio(
        nombre: 'Estudiante SAGE',
      );
    }
    return PerfilTrayectoriaSageLaboratorio(
      nombre: _extraerNombre(profile),
      dni: _extraerDni(profile.camposVisibles),
      campos: Map<String, String>.unmodifiable(profile.camposVisibles),
    );
  }

  static String _extraerNombre(PerfilLegajoSage profile) {
    final entries = profile.camposVisibles.entries.toList(growable: false);

    String? fieldValue(
      Iterable<String> tokens, {
      bool allowSingleWord = false,
    }) {
      for (final entry in entries) {
        final key = _normalizar(entry.key);
        if (!tokens.any(key.contains)) continue;
        final candidate = allowSingleWord
            ? _candidatoTextoNombre(entry.value)
            : _candidatoNombre(entry.value);
        if (candidate != null) return candidate;
      }
      return null;
    }

    final names = fieldValue(const ['nombres', 'nombre']);
    final surname = fieldValue(
      const ['apellidos', 'apellido'],
      allowSingleWord: true,
    );
    if (names != null && surname != null && names != surname) {
      return _capitalizar('$names $surname');
    }

    final direct = _candidatoNombre(profile.nombreVisible);
    if (direct != null) return _ordenarNombreSage(direct);

    final prioritized = <MapEntry<String, String>>[
      ...entries.where((entry) {
        final key = _normalizar(entry.key);
        return key.contains('alumno') ||
            key.contains('estudiante') ||
            key.contains('persona') ||
            key.contains('titular');
      }),
      ...entries,
    ];
    for (final entry in prioritized) {
      for (final segment in entry.value.split(RegExp(r'[·|;]'))) {
        final candidate = _candidatoNombre(segment);
        if (candidate != null) return _ordenarNombreSage(candidate);
      }
    }
    return 'Estudiante SAGE';
  }

  static String? _candidatoNombre(String value) {
    final clean = _candidatoTextoNombre(value);
    if (clean == null) return null;
    final words = clean
        .split(RegExp(r'\s+'))
        .where((word) => RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(word))
        .toList(growable: false);
    return words.length < 2 ? null : clean;
  }

  static String? _candidatoTextoNombre(String value) {
    final clean = value
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (clean.isEmpty || clean.length > 90) return null;
    final normalized = _normalizar(clean);
    const rejected = <String>{
      'dni',
      'perfil',
      'estudiante',
      'estudiante sage',
      'alumno',
      'alumna',
      'legajo',
    };
    if (rejected.contains(normalized)) return null;
    if (RegExp(r'\d').hasMatch(clean)) return null;
    final generic = RegExp(
      r'\b(carrera|resolucion|profesorado|institucion|telefono|celular|correo|domicilio)\b',
    );
    if (generic.hasMatch(normalized)) return null;
    return RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(clean) ? clean : null;
  }

  static String _ordenarNombreSage(String value) {
    final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.contains(',')) {
      final parts = clean.split(',');
      if (parts.length >= 2) {
        final surname = parts.first.trim();
        final names = parts.sublist(1).join(' ').trim();
        return _capitalizar('$names $surname');
      }
    }
    final words = clean.split(' ');
    final uppercase = clean == clean.toUpperCase() && clean != clean.toLowerCase();
    if (uppercase && words.length >= 2) {
      return _capitalizar('${words.sublist(1).join(' ')} ${words.first}');
    }
    return _capitalizar(clean);
  }

  static String _capitalizar(String value) {
    return value
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  static String? _extraerDni(Map<String, String> fields) {
    for (final entry in fields.entries) {
      final key = _normalizar(entry.key);
      if (key.contains('dni') ||
          key.contains('documento') ||
          key.contains('nro doc')) {
        final digits = entry.value.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 7 && digits.length <= 11) return digits;
      }
    }
    for (final value in fields.values) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 7 && digits.length <= 9) return digits;
    }
    return null;
  }

  static String _normalizar(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
