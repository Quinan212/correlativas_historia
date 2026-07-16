enum PerfilSage { alumnos, agente }

extension PerfilSageX on PerfilSage {
  String get clave => this == PerfilSage.alumnos ? 'alumnos' : 'agente';
  String get etiqueta => this == PerfilSage.alumnos ? 'Estudiante' : 'Docente';
  String get etiquetaSage => this == PerfilSage.alumnos ? 'Alumnos' : 'Agente';
}

class PerfilDisponibleSage {
  const PerfilDisponibleSage({
    required this.perfil,
    required this.activo,
    required this.disponible,
    this.controlEncontrado = true,
  });

  final PerfilSage perfil;
  final bool activo;
  final bool disponible;
  final bool controlEncontrado;
}

PerfilSage? perfilSageDesdeTexto(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (normalized == 'agente' || normalized == 'docente') {
    return PerfilSage.agente;
  }
  if (normalized == 'alumnos' || normalized == 'estudiante') {
    return PerfilSage.alumnos;
  }
  return null;
}

class CapturaPerfilesSage {
  const CapturaPerfilesSage({
    required this.perfiles,
    this.panelAbierto = false,
    this.avatarEncontrado = false,
    this.avatarActivado = false,
    this.documento = '',
  });

  final List<PerfilDisponibleSage> perfiles;
  final bool panelAbierto;
  final bool avatarEncontrado;
  final bool avatarActivado;
  final String documento;

  PerfilSage? get activo {
    for (final perfil in perfiles) {
      if (perfil.activo) return perfil.perfil;
    }
    return null;
  }

  bool contiene(PerfilSage perfil) =>
      perfiles.any((item) => item.perfil == perfil && item.disponible);
}
