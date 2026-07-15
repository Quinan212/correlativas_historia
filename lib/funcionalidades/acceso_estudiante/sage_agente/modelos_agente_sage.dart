import '../sage_navegacion/modelos_navegacion_sage.dart';

class OpcionAgenteSage {
  const OpcionAgenteSage({
    required this.claveCanonica,
    required this.etiqueta,
    this.ruta,
    this.icono = 0xe8b6,
  });
  final String claveCanonica;
  final String etiqueta;
  final String? ruta;
  final int icono;

  OpcionSubmoduloSage asWebOption() => OpcionSubmoduloSage(
    titulo: etiqueta,
    icono: icono,
    pathname: ruta,
    etiquetasAlternativas: [etiqueta.toLowerCase()],
  );
}

class PortadaAgenteSage {
  const PortadaAgenteSage({
    this.modulos = const [],
    this.submodulos = const [],
    this.informes = const [],
    this.frameId = '',
    this.pathname = '',
  });

  final List<OpcionAgenteSage> modulos;
  final List<OpcionAgenteSage> submodulos;
  final List<OpcionAgenteSage> informes;
  final String frameId;
  final String pathname;

  bool get disponible =>
      modulos.isNotEmpty || submodulos.isNotEmpty || informes.isNotEmpty;
}

const opcionesPortadaAgenteSage = <OpcionAgenteSage>[
  OpcionAgenteSage(
    claveCanonica: 'agenda',
    etiqueta: 'Agenda',
    ruta: '/pregase/menuprincipal_nuevo.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'legajo_unico_personal',
    etiqueta: 'Legajo Único Personal',
    ruta: '/pregase/menuprincipal_nuevo.php',
    icono: 0xe7fd,
  ),
  OpcionAgenteSage(
    claveCanonica: 'consultas',
    etiqueta: 'Consultas',
    ruta: '/pregase/menuprincipal_nuevo.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'listado_complementario',
    etiqueta: 'Listado Complementario Anexo Inscripción',
    ruta: '/pregase/Titulos/listado_complementario/listado_complementario.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'reclamos',
    etiqueta: 'Reclamos Listado Complementario',
    ruta:
        '/pregase/Titulos/listado_complementario/reclamos_listadoComplementario.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'formulario_agentes',
    etiqueta: 'Formulario de Agentes',
    ruta: '/nuevoFormularioAgente/index.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'traslado',
    etiqueta: 'Traslado',
    ruta: '/pregase/formularios/Traslado/index.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'horas_extras',
    etiqueta: 'Horas Extras Personales',
    ruta: '/rrhh/reporteHorasExtrasPersonal.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'documentos',
    etiqueta: 'Documentos y manuales',
    ruta: '/documentacionExternos/',
  ),
  OpcionAgenteSage(
    claveCanonica: 'alumnos_docente_nivel_superior',
    etiqueta: 'Alumnos por Docente Nivel Superior',
    ruta: '/dic/Listar2.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'legajo_agentes',
    etiqueta: 'Legajo Agentes',
    ruta: '/dic/Listar2.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'mi_credencial',
    etiqueta: 'Mi Credencial',
    ruta: '/pregase/cinfo/CredencialesNuevas/index.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'sueldo_personal',
    etiqueta: 'Sueldo Personal',
    ruta: '/pregase/menuprincipal_nuevo.php',
  ),
  OpcionAgenteSage(
    claveCanonica: 'alumnos_docente',
    etiqueta: 'Alumnos por Docente',
    ruta: '/dic/Listar2.php',
  ),
];
