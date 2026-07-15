import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_navegacion/detector_navegacion_sage.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/sage_navegacion/modelos_navegacion_sage.dart';
import 'package:flutter_test/flutter_test.dart';

CapturaNavegacionSage captura({
  String pathname = '/pregase/index.php',
  List<String> headings = const [],
  List<String> links = const [],
  String host = 'sage.entrerios.gov.ar',
}) {
  return CapturaNavegacionSage(
    host: host,
    pathname: pathname,
    tieneMain: true,
    encabezados: headings,
    enlaces: [
      for (final text in links)
        EnlaceNavegacionSage(
          texto: text,
          pathname: '/safe.php',
          hrefValido: true,
        ),
    ],
  );
}

DocumentoNavegacionSage documento({
  required String pathname,
  required List<String> headings,
  List<String> links = const [],
  bool visible = true,
  int depth = 0,
  String frameId = 'root',
  bool hasList2 = false,
  bool hasTabs = false,
  bool hasSchoolFrame = false,
  bool hasHistoryOption = false,
}) {
  return DocumentoNavegacionSage(
    host: 'sage.entrerios.gov.ar',
    pathname: pathname,
    frameId: frameId,
    frameName: '',
    profundidad: depth,
    visible: visible,
    hasList2: hasList2,
    hasTabs: hasTabs,
    hasSchoolFrame: hasSchoolFrame,
    hasHistoryOption: hasHistoryOption,
    encabezados: headings,
    enlaces: [
      for (final text in links)
        EnlaceNavegacionSage(
          texto: text,
          pathname: '/safe.php',
          hrefValido: true,
        ),
    ],
  );
}

void main() {
  const detector = DetectorNavegacionSage();

  test('login no se clasifica como módulos', () {
    expect(
      detector.detectar(captura(pathname: '/login/')),
      EstadoNavegacionSage.login,
    );
  });

  test('Legajo Único Alumno se clasifica como módulos', () {
    expect(
      detector.detectar(
        captura(
          headings: const ['Módulos'],
          links: const ['Legajo Único Alumno'],
        ),
      ),
      EstadoNavegacionSage.modulos,
    );
  });

  test('el conjunto de opciones se clasifica como submódulos', () {
    expect(
      detector.detectar(
        captura(
          headings: const ['Submódulos'],
          links: const [
            'Legajo Alumnos',
            'Certificado de Alumno Regular. N. Superior',
            'Inscripción a una nueva materia (Nivel Superior)',
            'Mis Inscripciones Anuales',
          ],
        ),
      ),
      EstadoNavegacionSage.submodulosLegajoUnico,
    );
  });

  test('normaliza mayúsculas, acentos y espacios', () {
    expect(
      detector.detectar(
        captura(
          headings: const ['  MÓDULOS  '],
          links: const ['  LEGajo   ÚNICO   ALUMNO  '],
        ),
      ),
      EstadoNavegacionSage.modulos,
    );
  });

  test('una captura parcial no se clasifica prematuramente', () {
    expect(
      detector.detectar(captura(headings: const ['Submódulos'])),
      EstadoNavegacionSage.otraPagina,
    );
  });

  test('una página desconocida devuelve otraPagina', () {
    expect(
      detector.detectar(
        captura(pathname: '/pregase/otra.php', headings: const ['Ayuda']),
      ),
      EstadoNavegacionSage.otraPagina,
    );
  });

  test('un host externo no se clasifica como SAGE', () {
    expect(
      detector.detectar(
        captura(host: 'example.org', links: const ['Legajo Único Alumno']),
      ),
      EstadoNavegacionSage.desconocido,
    );
  });

  test(
    'el modelo solo conserva texto funcional y rutas, no inputs ni cookies',
    () {
      final value = captura(links: const ['Legajo Alumnos']);
      expect(value.enlaces.single.texto, 'Legajo Alumnos');
      expect(value.enlaces.single.pathname, '/safe.php');
      expect(value.toString(), isNot(contains('cookie')));
      expect(value.toString(), isNot(contains('password')));
    },
  );

  test('un listado activo tiene prioridad sobre enlaces residuales', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/pregase/index.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/pregase/menuprincipal_nuevo.php',
          headings: const ['Submódulos'],
          links: const [
            'Legajo Alumnos',
            'Certificado de Alumno Regular. N. Superior',
            'Inscripción a una nueva materia (Nivel Superior)',
            'Mis Inscripciones Anuales',
          ],
        ),
        documento(
          pathname: '/dic/Listar2.php',
          headings: const ['Listado de alumnos'],
          depth: 1,
          frameId: 'Main',
          hasList2: true,
        ),
      ],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.listadoLegajos);
  });

  test('un documento activo con encabezado y enlaces es submódulos válido', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/pregase/index.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/pregase/menuprincipal_nuevo.php',
          headings: const ['Submódulos'],
          links: const [
            'Legajo Alumnos',
            'Certificado de Alumno Regular. N. Superior',
            'Inscripción a una nueva materia (Nivel Superior)',
          ],
        ),
      ],
    );
    expect(
      detector.detectar(value),
      EstadoNavegacionSage.submodulosLegajoUnico,
    );
  });

  test('no combina encabezado y enlaces de documentos diferentes', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/pregase/index.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/pregase/menuprincipal_nuevo.php',
          headings: const ['Submódulos'],
        ),
        documento(
          pathname: '/pregase/menuprincipal_nuevo.php',
          headings: const [],
          links: const [
            'Legajo Alumnos',
            'Certificado de Alumno Regular. N. Superior',
            'Inscripción a una nueva materia (Nivel Superior)',
          ],
          frameId: 'residual',
        ),
      ],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.otraPagina);
  });

  test('alumnos_v2 activo bloquea el menú residual', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/pregase/index.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/pregase/menuprincipal_nuevo.php',
          headings: const ['Submódulos'],
          links: const [
            'Legajo Alumnos',
            'Certificado de Alumno Regular. N. Superior',
            'Mis Inscripciones Anuales',
          ],
        ),
        documento(
          pathname: '/alumnos_v2/NS_inscrip_nueva_materia_AL.php',
          headings: const ['Inscripción'],
          depth: 1,
        ),
      ],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.otraPagina);
  });

  test('tabs se clasifica como Secciones aunque el contenido sea parcial', () {
    const value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/dic/tabs.php',
      tieneMain: true,
      encabezados: ['Legajo Alumnos'],
      enlaces: [],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.seccionesLegajo);
  });

  test('módulos y submódulos con igual pathname tienen firmas distintas', () {
    final modules = detector.detectarResultado(
      CapturaNavegacionSage(
        host: 'sage.entrerios.gov.ar',
        pathname: '/pregase/index.php',
        tieneMain: true,
        encabezados: const [],
        enlaces: const [],
        documentos: [
          documento(
            pathname: '/pregase/menuprincipal_nuevo.php',
            headings: const ['Módulos'],
            links: const ['Legajo Único Alumno'],
            frameId: 'Main',
          ),
        ],
      ),
    );
    final submodules = detector.detectarResultado(
      CapturaNavegacionSage(
        host: 'sage.entrerios.gov.ar',
        pathname: '/pregase/index.php',
        tieneMain: true,
        encabezados: const [],
        enlaces: const [],
        documentos: [
          documento(
            pathname: '/pregase/menuprincipal_nuevo.php',
            headings: const ['Submódulos'],
            links: const [
              'Legajo Alumnos',
              'Certificado de Alumno Regular. N. Superior',
              'Inscripción a una nueva materia (Nivel Superior)',
            ],
            frameId: 'Main',
          ),
        ],
      ),
    );

    expect(modules.firma, isNot(submodules.firma));
    expect(
      cambioNavegacionSageConfirmado(
        resultado: submodules,
        firmaOrigen: modules.firma,
        estadoOrigen: modules.estado,
      ),
      isTrue,
    );
  });

  test('found sin activated es una acción fallida', () {
    expect(
      activacionNavegacionSageExitosa(found: true, activated: false),
      isFalse,
    );
    expect(
      activacionNavegacionSageExitosa(found: true, activated: true),
      isTrue,
    );
  });

  test('la capa de carga mantiene oculta la WebView', () {
    expect(
      webViewSageVisible(
        historial: false,
        modulos: false,
        submodulos: false,
        carga: true,
      ),
      isFalse,
    );
  });

  test('el resultado conserva el documento activo elegido', () {
    final active = documento(
      pathname: '/dic/Listar2.php',
      headings: const ['Listado'],
      depth: 2,
      frameId: 'frm_alumnos',
    );
    final result = detector.detectarResultado(
      CapturaNavegacionSage(
        host: 'sage.entrerios.gov.ar',
        pathname: '/pregase/index.php',
        tieneMain: true,
        encabezados: const [],
        enlaces: const [],
        documentos: [active],
      ),
    );
    expect(result.documentoActivo?.frameId, 'frm_alumnos');
    expect(result.documentoActivo?.pathname, '/dic/Listar2.php');
  });

  test('listado de legajos tiene prioridad sobre el menú residual', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/pregase/index.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/pregase/menuprincipal_nuevo.php',
          headings: const ['Submódulos'],
          links: const [
            'Legajo Alumnos',
            'Certificado de Alumno Regular. N. Superior',
            'Inscripción a una nueva materia (Nivel Superior)',
          ],
        ),
        documento(
          pathname: '/dic/Listar2.php',
          headings: const ['Listado de alumnos'],
          depth: 1,
          frameId: 'frm_alumnos',
          hasList2: true,
        ),
      ],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.listadoLegajos);
  });

  test('tabs con Escolares se clasifica como secciones del legajo', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/pregase/index.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/dic/tabs.php',
          headings: const ['Legajo'],
          links: const ['Escolares'],
          hasTabs: true,
        ),
      ],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.seccionesLegajo);
  });

  test('tabs con hijo escolar conserva prioridad de Secciones', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/dic/tabs.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/dic/tabs.php',
          headings: const ['Secciones'],
          links: const ['Escolares'],
          frameId: 'frm_alumnos',
          depth: 1,
          hasTabs: true,
        ),
        documento(
          pathname: '/dic/tabs.php',
          headings: const ['Nivel Superior - Historial'],
          links: const ['Nivel Superior - Historial'],
          frameId: 'frm_alumnos_escolares',
          depth: 2,
          hasSchoolFrame: true,
          hasHistoryOption: true,
        ),
      ],
    );
    expect(detector.detectar(value), EstadoNavegacionSage.seccionesLegajo);
  });

  test('el hijo solo no activa Escolares sin el padre correcto', () {
    final value = CapturaNavegacionSage(
      host: 'sage.entrerios.gov.ar',
      pathname: '/dic/tabs.php',
      tieneMain: true,
      encabezados: const [],
      enlaces: const [],
      documentos: [
        documento(
          pathname: '/dic/tabs.php',
          headings: const ['Nivel Superior - Historial'],
          frameId: 'frm_alumnos_escolares',
          hasSchoolFrame: true,
          hasHistoryOption: true,
        ),
      ],
    );
    expect(detector.detectar(value), isNot(EstadoNavegacionSage.escolares));
  });

  test(
    'tabs en Main se clasifica como Secciones aunque el hijo sea profundo',
    () {
      final value = CapturaNavegacionSage(
        host: 'sage.entrerios.gov.ar',
        pathname: '/pregase/index.php',
        tieneMain: true,
        encabezados: const [],
        enlaces: const [],
        documentos: [
          documento(
            pathname: '/dic/tabs.php',
            headings: const [],
            frameId: 'Main',
            depth: 1,
          ),
          documento(
            pathname: '/alumnos_v2/NS_historial_alumnado.php',
            headings: const ['Historial'],
            frameId: 'frm_alumnos_escolares',
            depth: 3,
          ),
        ],
      );
      expect(detector.detectar(value), EstadoNavegacionSage.seccionesLegajo);
    },
  );
}
