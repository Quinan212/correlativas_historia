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
      nombre: profile.nombreVisible.trim().isEmpty
          ? 'Estudiante SAGE'
          : profile.nombreVisible.trim(),
      dni: _extraerDni(profile.camposVisibles),
      campos: Map<String, String>.unmodifiable(profile.camposVisibles),
    );
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
