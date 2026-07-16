import '../sage_navegacion/modelos_navegacion_sage.dart';

class OpcionAgenteSage {
  const OpcionAgenteSage({
    required this.claveCanonica,
    required this.etiqueta,
    this.ruta,
    this.icono = 0xe8b6,
    this.sigla,
  });

  final String claveCanonica;
  final String etiqueta;
  final String? ruta;
  final int icono;
  final String? sigla;

  OpcionSubmoduloSage asWebOption() => OpcionSubmoduloSage(
    titulo: etiqueta,
    icono: icono,
    pathname: ruta,
    etiquetasAlternativas: [
      etiqueta.toLowerCase(),
      if (sigla != null) sigla!.toLowerCase(),
    ],
  );
}

class PortadaAgenteSage {
  const PortadaAgenteSage({
    this.accesosSuperiores = const [],
    this.modulos = const [],
    this.submodulos = const [],
    this.informes = const [],
    this.frameId = '',
    this.pathname = '',
    this.shellPathname = '',
  });

  final List<OpcionAgenteSage> accesosSuperiores;
  final List<OpcionAgenteSage> modulos;
  final List<OpcionAgenteSage> submodulos;
  final List<OpcionAgenteSage> informes;
  final String frameId;
  final String pathname;
  final String shellPathname;

  bool get disponible =>
      accesosSuperiores.isNotEmpty ||
      modulos.isNotEmpty ||
      submodulos.isNotEmpty ||
      informes.isNotEmpty;
}

class MenuLegajoAlumnoAgenteSage {
  const MenuLegajoAlumnoAgenteSage({
    this.opciones = const [],
    this.shellPathname = '',
    this.menuEncontrado = false,
  });

  final List<OpcionAgenteSage> opciones;
  final String shellPathname;
  final bool menuEncontrado;

  bool get disponible => opciones.isNotEmpty;
}

const opcionesPortadaAgenteSage = <OpcionAgenteSage>[
  OpcionAgenteSage(
    claveCanonica: 'legajo_unico_personal_superior',
    etiqueta: 'Legajo Único Personal',
    sigla: 'L.U.P.',
    icono: 0xe7fd,
  ),
  OpcionAgenteSage(
    claveCanonica: 'legajo_unico_alumno_superior',
    etiqueta: 'Legajo Único Alumno',
    sigla: 'L.U.A.',
    icono: 0xe151,
  ),
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
    claveCanonica: 'declaracion_jurada',
    etiqueta: 'Declaración Jurada de Prestación de Servicios',
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

const opcionesLegajoUnicoAlumnoAgente = <OpcionAgenteSage>[
  OpcionAgenteSage(
    claveCanonica: 'legajo_alumnos',
    etiqueta: 'Legajo Alumnos',
    ruta: '/dic/Listar2.php',
    icono: 0xe151,
  ),
  OpcionAgenteSage(
    claveCanonica: 'certificado_alumno_regular_ns',
    etiqueta: 'Certificado de Alumno Regular. N. Superior',
    icono: 0xe873,
  ),
  OpcionAgenteSage(
    claveCanonica: 'inscripcion_nueva_materia_ns',
    etiqueta: 'Inscripción a una nueva materia (Nivel Superior)',
    ruta: '/alumnos_v2/NS_inscrip_nueva_materia_AL.php',
    icono: 0xe150,
  ),
  OpcionAgenteSage(
    claveCanonica: 'mis_inscripciones_anuales',
    etiqueta: 'Mis Inscripciones Anuales',
    icono: 0xe8f9,
  ),
  OpcionAgenteSage(
    claveCanonica: 'inscripcion_anual_obligatoria_ns',
    etiqueta: 'Inscripción anual obligatoria (Nivel Superior)',
    ruta: '/alumnos_v2/NS_inscrip_anual_obligatoria_AL.php',
    icono: 0xe878,
  ),
  OpcionAgenteSage(
    claveCanonica: 'consulta_tutor_alumnos',
    etiqueta: 'Consulta para Tutor/Alumnos',
    ruta: '/alumnosAdminPanel/seleccionHijo/seleccion-hijo.php',
    icono: 0xe7ef,
  ),
  OpcionAgenteSage(
    claveCanonica: 'notas_por_alumnos',
    etiqueta: 'Notas por Alumnos',
    icono: 0xe8d0,
  ),
];
