import '../modelos/modelos_trayectoria_sage_laboratorio.dart';

enum ModoPantallaSageLaboratorio {
  manual,
  sincronizacionAutomatica,
  descargaDocumento,
}

enum EtapaSincronizacionSageAutomatica {
  preparando,
  verificandoSesion,
  credenciales,
  autenticando,
  reanudandoSesion,
  detectandoPerfil,
  cambiandoAEstudiante,
  abriendoLegajo,
  seleccionandoLegajo,
  abriendoEscolares,
  abriendoHistorial,
  leyendoTrayectoria,
  preparandoDocumentos,
  descargandoDocumento,
  reintentandoPaso,
  guardando,
  completada,
  error,
}

enum PasoSincronizacionSageAutomatica {
  sesion,
  perfil,
  legajo,
  escolares,
  historial,
  carreras,
  documentos,
  guardado,
}

enum CodigoErrorSincronizacionSage {
  red,
  credenciales,
  sesionVencida,
  perfilEstudianteAusente,
  cambioPerfil,
  legajoAusente,
  abrirLegajo,
  escolaresAusente,
  abrirEscolares,
  historialAusente,
  abrirHistorial,
  historialVacio,
  lecturaCarrera,
  estructuraIncompatible,
  guardadoLocal,
  documentoNoDisponible,
  descargaDocumento,
  tiempoAgotado,
  cancelada,
  desconocido,
}

extension CodigoErrorSincronizacionSageX on CodigoErrorSincronizacionSage {
  String get clave => switch (this) {
    CodigoErrorSincronizacionSage.red => 'SAGE-RED',
    CodigoErrorSincronizacionSage.credenciales => 'SAGE-AUTH',
    CodigoErrorSincronizacionSage.sesionVencida => 'SAGE-SESION',
    CodigoErrorSincronizacionSage.perfilEstudianteAusente => 'SAGE-PERFIL-01',
    CodigoErrorSincronizacionSage.cambioPerfil => 'SAGE-PERFIL-02',
    CodigoErrorSincronizacionSage.legajoAusente => 'SAGE-LEGAJO-01',
    CodigoErrorSincronizacionSage.abrirLegajo => 'SAGE-LEGAJO-02',
    CodigoErrorSincronizacionSage.escolaresAusente => 'SAGE-ESC-01',
    CodigoErrorSincronizacionSage.abrirEscolares => 'SAGE-ESC-02',
    CodigoErrorSincronizacionSage.historialAusente => 'SAGE-HIST-01',
    CodigoErrorSincronizacionSage.abrirHistorial => 'SAGE-HIST-02',
    CodigoErrorSincronizacionSage.historialVacio => 'SAGE-HIST-03',
    CodigoErrorSincronizacionSage.lecturaCarrera => 'SAGE-CARRERA',
    CodigoErrorSincronizacionSage.estructuraIncompatible => 'SAGE-ESTRUCTURA',
    CodigoErrorSincronizacionSage.guardadoLocal => 'SAGE-GUARDADO',
    CodigoErrorSincronizacionSage.documentoNoDisponible => 'SAGE-DOC-01',
    CodigoErrorSincronizacionSage.descargaDocumento => 'SAGE-DOC-02',
    CodigoErrorSincronizacionSage.tiempoAgotado => 'SAGE-TIEMPO',
    CodigoErrorSincronizacionSage.cancelada => 'SAGE-CANCELADA',
    CodigoErrorSincronizacionSage.desconocido => 'SAGE-DESCONOCIDO',
  };
}

class EstadoSincronizacionSageAutomatica {
  const EstadoSincronizacionSageAutomatica({
    required this.etapa,
    required this.titulo,
    this.detalle,
    this.progreso,
    this.permiteReintentar = false,
    this.paso,
    this.codigoError,
    this.intentoActual = 0,
    this.intentosMaximos = 0,
    this.sesionReutilizada = false,
  });

  const EstadoSincronizacionSageAutomatica.preparando()
    : this(
        etapa: EtapaSincronizacionSageAutomatica.verificandoSesion,
        titulo: 'Verificando sesión',
        detalle: 'Comprobando si SAGE sigue conectado…',
        progreso: 0.03,
        paso: PasoSincronizacionSageAutomatica.sesion,
      );

  final EtapaSincronizacionSageAutomatica etapa;
  final String titulo;
  final String? detalle;
  final double? progreso;
  final bool permiteReintentar;
  final PasoSincronizacionSageAutomatica? paso;
  final CodigoErrorSincronizacionSage? codigoError;
  final int intentoActual;
  final int intentosMaximos;
  final bool sesionReutilizada;

  bool get solicitaCredenciales =>
      etapa == EtapaSincronizacionSageAutomatica.credenciales;

  bool get esError => etapa == EtapaSincronizacionSageAutomatica.error;

  bool get completada => etapa == EtapaSincronizacionSageAutomatica.completada;

  bool get reintentando =>
      etapa == EtapaSincronizacionSageAutomatica.reintentandoPaso;

  String? get codigoVisible => codigoError?.clave;
}

typedef GuardarTrayectoriaSageAutomatica =
    Future<TrayectoriaSageLaboratorio> Function(
      TrayectoriaSageLaboratorio trayectoria,
    );

class ErrorSincronizacionSageAutomatica implements Exception {
  const ErrorSincronizacionSageAutomatica(
    this.mensaje, {
    this.codigo = CodigoErrorSincronizacionSage.desconocido,
  });

  final String mensaje;
  final CodigoErrorSincronizacionSage codigo;

  @override
  String toString() => mensaje;
}
