import 'package:correlativas_historia/funcionalidades/examenes/modelos/evento_examen.dart';
import 'package:correlativas_historia/funcionalidades/trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import 'package:correlativas_historia/compartido/proveedores/datos_catalogo.dart';
import 'package:correlativas_historia/modelos/contenido_curricular.dart';
import 'package:correlativas_historia/modelos/materia.dart';

enum TipoDestinoBusquedaAtlassian {
  seccion,
  calendario,
  disenos,
  escenarios,
  ayuda,
  proximosPasos,
  avance,
  sage,
  sincronizar,
  documentoAcademico,
  desincronizar,
  cerrarSesionSage,
  salir,
  detalleExamen,
  detallePlan,
  detalleDiseno,
  detalleTrayectoria,
}

class DestinoBusquedaAtlassian {
  const DestinoBusquedaAtlassian({
    required this.tipo,
    this.seccion,
    this.careerId,
    this.career,
    this.fecha,
    this.evento,
    this.materiaPlan,
    this.materiasPlan,
    this.contenidoCurricular,
    this.materiaTrayectoria,
    this.carreraTrayectoria,
    this.tipoDocumento,
    this.query,
    this.year,
    this.status,
    this.scope,
  });

  final TipoDestinoBusquedaAtlassian tipo;
  final int? seccion;
  final String? careerId;
  final CareerInfo? career;
  final DateTime? fecha;
  final EventoExamen? evento;
  final Materia? materiaPlan;
  final List<Materia>? materiasPlan;
  final ContenidoCurricular? contenidoCurricular;
  final MateriaTrayectoriaSageLaboratorio? materiaTrayectoria;
  final CarreraTrayectoriaSageLaboratorio? carreraTrayectoria;
  final TipoDocumentoAcademicoSage? tipoDocumento;
  final String? query;
  final int? year;
  final EstadoMateriaSageLaboratorio? status;
  final String? scope;
}

class SolicitudExamenesAtlassian {
  const SolicitudExamenesAtlassian({
    this.careerId,
    this.query,
    this.year,
    this.scope,
  });

  final String? careerId;
  final String? query;
  final int? year;
  final String? scope;
}

class SolicitudPlanAtlassian {
  const SolicitudPlanAtlassian({this.careerId, this.query, this.year});

  final String? careerId;
  final String? query;
  final int? year;
}

class SolicitudMateriasAtlassian {
  const SolicitudMateriasAtlassian({
    this.careerIndex,
    this.query,
    this.year,
    this.status,
    this.focusSearch = false,
  });

  final int? careerIndex;
  final String? query;
  final int? year;
  final EstadoMateriaSageLaboratorio? status;
  final bool focusSearch;
}

enum AccionInicioAtlassian {
  abrirSage,
  sincronizar,
  descargarDocumento,
  cerrarSesionSage,
}

class SolicitudInicioAtlassian {
  const SolicitudInicioAtlassian(this.accion, {this.tipoDocumento});

  final AccionInicioAtlassian accion;
  final TipoDocumentoAcademicoSage? tipoDocumento;
}
