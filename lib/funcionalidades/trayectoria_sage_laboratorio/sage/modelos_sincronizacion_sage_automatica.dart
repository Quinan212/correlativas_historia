import '../modelos/modelos_trayectoria_sage_laboratorio.dart';

enum ModoPantallaSageLaboratorio { manual, sincronizacionAutomatica }

enum EtapaSincronizacionSageAutomatica {
  preparando,
  credenciales,
  autenticando,
  detectandoPerfil,
  cambiandoAEstudiante,
  abriendoLegajo,
  seleccionandoLegajo,
  abriendoEscolares,
  abriendoHistorial,
  leyendoTrayectoria,
  guardando,
  completada,
  error,
}

class EstadoSincronizacionSageAutomatica {
  const EstadoSincronizacionSageAutomatica({
    required this.etapa,
    required this.titulo,
    this.detalle,
    this.progreso,
    this.permiteReintentar = false,
  });

  const EstadoSincronizacionSageAutomatica.preparando()
    : this(
        etapa: EtapaSincronizacionSageAutomatica.preparando,
        titulo: 'Preparando SAGE',
        detalle: 'Conectando con el servicio académico…',
        progreso: 0.04,
      );

  final EtapaSincronizacionSageAutomatica etapa;
  final String titulo;
  final String? detalle;
  final double? progreso;
  final bool permiteReintentar;

  bool get solicitaCredenciales =>
      etapa == EtapaSincronizacionSageAutomatica.credenciales;

  bool get esError => etapa == EtapaSincronizacionSageAutomatica.error;

  bool get completada => etapa == EtapaSincronizacionSageAutomatica.completada;
}

typedef GuardarTrayectoriaSageAutomatica =
    Future<TrayectoriaSageLaboratorio> Function(
      TrayectoriaSageLaboratorio trayectoria,
    );

class ErrorSincronizacionSageAutomatica implements Exception {
  const ErrorSincronizacionSageAutomatica(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}
