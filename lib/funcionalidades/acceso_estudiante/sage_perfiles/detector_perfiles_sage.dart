import 'modelos_perfiles_sage.dart';

class DetectorPerfilesSage {
  const DetectorPerfilesSage();

  CapturaPerfilesSage detectar(Map<String, dynamic> json) {
    final raw = json['profiles'];
    final profiles = <PerfilDisponibleSage>[];
    if (raw is List) {
      for (final value in raw) {
        if (value is! Map) continue;
        final perfil = perfilSageDesdeTexto(value['label']?.toString() ?? '');
        if (perfil == null || profiles.any((item) => item.perfil == perfil)) {
          continue;
        }
        profiles.add(
          PerfilDisponibleSage(
            perfil: perfil,
            activo: value['active'] == true,
            disponible: value['available'] != false,
            controlEncontrado: value['found'] != false,
          ),
        );
      }
    }
    return CapturaPerfilesSage(
      perfiles: profiles,
      panelAbierto: json['panelOpen'] == true,
      avatarEncontrado: json['avatarFound'] == true,
    );
  }
}
