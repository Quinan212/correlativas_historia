import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../modelos/contenido_curricular.dart';

final proveedorContenidosCurriculares =
    FutureProvider<List<ContenidoCurricular>>((ref) async {
      return [
        ContenidoCurricular.fromMap(_pedagogia),
        ContenidoCurricular.fromMap(_didacticaGeneral),
        ContenidoCurricular.fromMap(_corporeidad),
        ContenidoCurricular.fromMap(_oralidad),
        ContenidoCurricular.fromMap(_antiguedad),
        ContenidoCurricular.fromMap(_pueblosOriginarios),
        ContenidoCurricular.fromMap(_historiaIdeas1),
        ContenidoCurricular.fromMap(_problematica),
        ContenidoCurricular.fromMap(_practica1),
        // 2do Año
        ContenidoCurricular.fromMap(_filosofia),
        ContenidoCurricular.fromMap(_psicologiaeducacional),
        ContenidoCurricular.fromMap(_educacionsexual),
        ContenidoCurricular.fromMap(_sujetoseducacion),
        ContenidoCurricular.fromMap(_procesosfeudalismomodernidad),
        ContenidoCurricular.fromMap(_procesosamericanos1),
        ContenidoCurricular.fromMap(_historiaideas2),
        ContenidoCurricular.fromMap(_mundoterritorialidades),
        ContenidoCurricular.fromMap(_economiapolitica),
        ContenidoCurricular.fromMap(_didacticacienciassociales),
        ContenidoCurricular.fromMap(_practica2),
      ];
    });

final proveedorContenidoPorId = Provider.family<ContenidoCurricular?, String>((
  ref,
  id,
) {
  final contenidos = ref.watch(proveedorContenidosCurriculares).value;
  if (contenidos == null) return null;
  try {
    return contenidos.firstWhere((c) => c.id == id);
  } catch (_) {
    return null;
  }
});

const _pedagogia = {
  'id': 'pedagogia',
  'nombre': 'Pedagogía',
  'anio': 1,
  'formato': 'Asignatura',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'La reflexión teórico - pedagógica y la problematización de la educación constituyen aspectos centrales de la formación docente ya que incorporan una lectura social, política y crítica de la situación educativa. '
      'En este espacio se brindan los marcos teóricos que permiten comprender la educación como una práctica situada, recuperando su sentido ético y político y, por ende, su potencial transformador. '
      'Constituye una instancia de reflexión teórica sobre los problemas del campo de la educación, porque desde los marcos referenciales se analizarán los supuestos subyacentes a las teorías y prácticas pedagógicas. '
      'El estudio de las huellas del discurso pedagógico moderno, sus debates y desarrollos en diferentes contextos, y la comprensión de que la Pedagogía, tal como se la concibe en la actualidad, es producto de ese discurso que atraviesa fuertemente las prácticas escolares, resulta fundamental para la formación docente inicial. '
      'La recuperación de los procesos de producción, distribución y apropiación de saberes en los distintos contextos históricos - políticos y las críticas que surgen en el siglo XX facilitará la construcción de marcos referenciales para la acción docente. En paralelo, el análisis de las corrientes de reflexión pedagógica, de sus tradiciones, de sus problemas históricos hará posible la comprensión de las problemáticas contemporáneas y las prácticas cotidianas en la escuela.',
  'ejes': [
    {
      'titulo': 'Educación y pedagogía: significados, sentidos y rupturas',
      'descripcion':
          'Configuración histórica y política del campo pedagógico. Los fundamentos antropológicos, filosóficos, políticos, sociológicos que subyacen a las teorías y a las prácticas pedagógicas. Educación y transmisión. Problemáticas epistemológicas de la pedagogía. Las transformaciones del vínculo Estado y Educación. Problemáticas y perspectivas pedagógicas de América Latina y Argentina.',
    },
    {
      'titulo':
          'Los sujetos y discursos pedagógicos: herencias y nuevas subjetividades',
      'descripcion':
          'Discursos pedagógicos. Pedagogización de la infancia y la escolarización del saber: del niño al alumno. Tensión entre homogenización e individualización. Reproductivismo. Pedagogías liberadoras.\n\n'
          'La construcción de la identidad del trabajo docente; los desafíos de una práctica autónoma y crítica. Culturas juveniles: identidades y mandatos.\n\n'
          'La educación secundaria: inclusión y obligatoriedad.',
    },
    {
      'titulo': 'La escuela como espacio pedagógico',
      'descripcion':
          'El surgimiento de la escuela, su función social. Desafíos actuales: continuidades y rupturas. Contexto institucional y áulico. El lugar de los sujetos.',
    },
    {
      'titulo': 'Conocimiento y saber escolar',
      'descripcion':
          'Legitimación del conocimiento en el campo educativo. Transmisión, nuevas tecnológicas y prácticas pedagógicas. Transformación del escenario pedagógico en la sociedad actual.',
    },
  ],
  'bibliografia': [
    'ANTELO, E Y ALLIAUD, A. (2009). Los gajes del oficio. Buenos Aires: Aique.',
    'CAMILLONI, A., CELMAN, S. y otros (1998). La Evaluación de los aprendizajes en el debate didáctico contemporáneo. Buenos Aires: Paidós.',
    'CARLI, S. (Comp.) (1999). De la familia a la escuela. Infancia, socialización y subjetividad. Buenos Aires: Santillana.',
    'CARR, W. y KEMMIS, S: (1986). Teoría crítica de la enseñanza. Barcelona: Martínez Roca.',
    'CARUSO, M; DUSSEL, I. (1996). De Sarmiento a Los Simpson. Buenos Aires: Kapelusz.',
    'CASTILLÓN, H. (2011). Epistemología de la Pedagogía. Colombia. Ediciones Educación y Pedagogía.',
    'COMENIO, J. (1922). Didáctica Magna. Madrid. Editorial Reus.',
    'CONTRERAS, D. y otros. (2010). Investigar la experiencia educativa. Madrid: Morata.',
    'COREA, C. Y LEWKOWICZ, I. (2004). Pedagogía del Aburrido. Buenos Aires: Paidós.',
    'DAVINI, M. C. (1995). La formación docente en cuestión: política y pedagogía. Cuestiones de Educación. Buenos Aires: Editorial Paidós.',
    'DAVINI, M.C (1995). La formación docente en cuestión: política y pedagogía. Cuestiones de Educación. Buenos Aires: Paidós.',
    'DEWEY, J. (1967). Experiencia y educación. Buenos Aires: Editorial Losada.',
    'DUSSEL, I. y CARUSO, M. (1999). La invención del aula. Buenos Aires: Exordio, Santillana.',
    'FERRY, G. (1990). Pedagogía de la formación. Buenos Aires: Paidós.',
    'FREIRE, P (1999). Pedagogía de la Autonomía. Saberes necesarios para la práctica educativa. México: Siglo XXI.',
    'FREIRE, P. (2002). Cartas a quien pretende enseñar. Argentina: Siglo XXI.',
    'FRIGERIO, G. Y DIKER, G. (Comp.) (2008). Educar: posiciones acerca de lo común. Buenos Aires: Del Estante Editorial.',
    'MARTINEZ BOOM, A y otro (2009). Instancias y estancias de la Pedagogía, la Pedagogía en movi-miento. Universidad de San Buenaventura. Bogotá: Colombia.',
    'MORÍN, E (1998). Introducción al pensamiento complejo. Barcelona: Gedisa.',
    'MORÍN, E. (1999). La cabeza bien puesta. Buenos Aires: Nueva Visión.',
    'PUIGGROS, A. (Comp.) (2007). Cartas a los educadores del siglo XXI. Buenos Aires: Editorial Galerna.',
    'ZULUAGA, O. (2003). Educación y Pedagogía una diferencia necesaria. En Pedagogía y Epistemología. Buenos Aires: Cooperativa Editorial Magisterio.',
  ],
};

const _didacticaGeneral = {
  'id': 'didactica-general',
  'nombre': 'Didáctica General',
  'anio': 1,
  'formato': 'Asignatura',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'La formación en el campo de la didáctica tiene que reconocer su construcción histórica y social en el marco de proyectos educativos y sociales amplios. Reflexionar sobre la complejidad de las prácticas de enseñanza que se desarrollan en escenarios institucionales particulares - las escuelas- así como la construcción de herramientas teórico - metodológicas implica pensar la enseñanza desde una perspectiva problematizadora y hermenéutica. '
      'La didáctica tiene que superar la mirada instrumentalista, y poder provocar la reflexión acerca de la enseñanza. Pensar, analizar, visualizar las complejidades de la acción docente, sus atravesamientos sociales, institucionales, históricos, interpersonales, lingüísticas, psíquicas26. '
      'La Didáctica como disciplina del campo pedagógico y por ende de las Ciencias Sociales, reconoce como objeto de estudio a la enseñanza desde una perspectiva teórico - epistemológica que no sólo permita apropiarse de determinados conceptos, categorías y teorías, sino comprender los tipos de razonamiento y lógicas que produjeron tales teorías. '
      '26 Aportes de los Institutos de Formación Docente. '
      'Incorpora además una perspectiva de formación crítico social que genere espacios para la lectura comprensiva del presente, las principales problemáticas y desafíos actuales de la escuela y el lugar sociopolítico que juegan los trabajadores de la educación. Por ello el recorrido por esta unidad curricular se aborda a través de tres ejes que tensionan y problematizan el campo de la didáctica desde distintas miradas. '
      'El estudiante podrá problematizar y construir herramientas teóricas - epistemológicas para pensar y diseñar propuestas didácticas, articulando los tres campos de formación.',
  'ejes': [
    {
      'titulo':
          'La constitución del campo de la didáctica: problematización de la enseñanza como su objeto de estudio',
      'descripcion':
          'Abordaje epistemológico de las Ciencias Sociales y la constitución de la didáctica como disciplina. Su objeto de estudio. Tradiciones en la configuración disciplinar de la didáctica. '
          'Problematización del campo de la didáctica: relaciones y tensiones. El lugar de los sujetos, las prácticas y la escuela.',
    },
    {
      'titulo':
          'Currículum como texto y contexto donde se desarrolla la enseñanza',
      'descripcion':
          'Conceptualizaciones de currículum. Enfoques teóricos actuales. Dimensiones políticas, sociales, filosóficas, pedagógicas, culturales, históricas y económica de un Currículum. Construcción y desarrollo curricular: debates y tensiones. Contrato didáctico y transposición didáctica. Agenda pedagógica.',
    },
    {
      'titulo': 'Configuraciones didácticas y práctica docente',
      'descripcion':
          'Relación didáctica-práctica docente. El lugar del conocimiento, la teoría, la práctica de la enseñanza y el currículum. Su vinculación con las teorías del conocimiento y la concepción del método. '
          'El problema del conocimiento en la escuela. La transposición didáctica. La perspectiva de la complejidad. La construcción metodológica: propuestas Didácticas: Selección y organización de contenidos, articulación entre estrategias, contenidos, intencionalidades educativas e intereses de los estudiantes de la formación docente. La evaluación como parte del proceso de enseñanza: concepciones, enfoques.',
    },
  ],
  'bibliografia': [
    'ÁLVAREZ MÉNDEZ, J. M. (2001). Evaluar para conocer, examinar para excluir. España: Ediciones Morata.',
    'BERTONI, A. (1997). Los significados de la evaluación educativa: alternativas teóricas. Buenos Aires: Editorial Kapelusz.',
    'CAMILLIONI, A. y otras; (2007). El Saber didáctico. Buenos Aires: Editorial Paidós.',
    'CAMILLONI A, CELMAN S y otros: (1998). La evaluación de los aprendizajes en el debate didáctico contemporáneo. Buenos Aires: Paidós.',
    'CAMILLONI A., EDELSTEIN, G. y otros, (1996). Corrientes didácticas contemporáneas. Buenos Aires: Paidós.',
    'CHEVALLARD, Y. (1997). La transposición didáctica. Buenos Aires: Aique.',
    'DE ALBA, A. (1995). Currículum, mito y perspectivas. Buenos Aires: Miño y Dávila.',
    'DIAZ BARRIGA, A. (1991). Didáctica, aportes para una polémica. Capítulo 1: Notas en relación con la didáctica. Buenos Aires: Rei.',
    'FREIRE, P Y GIROUX, H. (1990). La naturaleza política de la educación. Cultura, poder y liberación. Buenos Aires: Paidós.',
    'FREIRE, P (1993). Pedagogía de la esperanza. México: Siglo XXI.',
    '-------------- (1999). Pedagogía de la autonomía. Saberes necesarios para la práctica educativa. Buenos Aires: Siglo XXI.',
    '--------------- (2003). Cartas a quien pretende enseñar. Buenos Aires: Siglo XXI.',
    'GIROUX, H. (1992). Teoría y resistencia en educación. Madrid: Siglo XXI.',
    'LARROSA, J. (1997). Escuela, poder y Subjetivación. Madrid: La Piqueta.',
    'LITWIN, E. (2008). El oficio de enseñar. Condiciones y contextos. Buenos Aires: Paidós.',
    'MATEO, J: (2000). La evaluación educativa, su práctica y otras metáforas. Cuadernos de Educación Nº 33. España: Horsori.',
    'MEIRIEU, P. (1998). Frankestein Educador. Barcelona: Laerte.',
    '----------------- (2001). La opción de educar: Ética y Pedagogía. Barcelona: Octaedro.',
    '----------------- (2005). Carta a un joven profesor. Barcelona: Barcelona.',
    'PUIGGRÓS, A. (1995). Volver a educar. El desafío de la enseñanza argentina a finales del siglo XX. Buenos Aires: Ariel.',
    'SALEME, M. (1997). Decires. Narvaja editores. Córdoba.',
    'SCHLEMENSON, S. (1996). El aprendizaje: un encuentro de sentidos. Buenos Aires: Kapelusz.',
    'TADEU DA SILVA, T. (1999). Documento de identidad. Una introducción a las teorías del currículum. Belo Horizonte: Autentica.',
    'TERIGI, F. y DIKER, G. (1997). La formación de maestros y profesores. Hojas de ruta. Buenos Aires: Paidós.',
  ],
};

const _corporeidad = {
  'id': 'corporeidad-juego',
  'nombre': 'Corporeidad, Juego y Lenguajes Artísticos',
  'anio': 1,
  'formato': 'Taller',
  'cargaHoraria':
      '3 horas cátedra semanales - 2 horas reloj. Carga para los docentes: 2 horas cátedra (Perfil Educación Física), 2 horas cátedra (Perfil Artes Plásticas), 2 horas cátedra (Perfil Música)',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'La cultura, dice Roland Barthes27, es un campo de dispersión de los lenguajes, y el estallido de la llamada cultura de masas ha contribuido a profundizar su carácter heteróclito. En la sociedad de la cultura de masas, todo habla. La proliferación de significantes, la irrupción de nuevas concepciones estéticas y soportes derivados del desarrollo tecnológico hacen más compleja la reflexión sobre los diferentes lenguajes. '
      'Asumir esta complejidad sin intentar reducirla o compartimentarla requiere una reflexión sobre los modos en que organizamos y significamos nuestras sensaciones, percepciones, emociones, pensamientos, a través de nuestras experiencias vinculares y sociales. '
      'Este taller se orienta, entonces, a sensibilizar a los alumnos a partir de la experimentación con los diferentes lenguajes, a la frecuentación de diversas manifestaciones artísticas y a la reflexión acerca de cómo los nuevos modos de producción y circulación, así como la diversidad de soportes, generan relaciones inéditas entre cuerpo, lenguaje y percepción, social e históricamente situadas. Estos procesos tienen como propósito que los alumnos observen críticamente todas las configuraciones de movimiento y sentido socialmente valoradas, desnaturalizando las prácticas instituidas. '
      'Es necesario desarrollar en la formación inicial una disposición lúdico motriz para la acción, expresión y comunicación que le permita a los estudiantes, a partir de sus recorridos experienciales, una comprensión de estos mismos procesos en sus prácticas pedagógicas. '
      'El formato taller de esta unidad curricular ha de posibilitar que los diferentes lenguajes y disciplinas se integren total o parcialmente en torno a los ejes propuestos a partir de diferentes proyectos que diseñen e implementen los docentes responsables.',
  'ejes': [
    {
      'titulo': 'La corporeidad: biografías e identidades',
      'descripcion':
          'Cuerpo, vínculo y subjetividad. Condiciones materiales y simbólicas de producción de las prácticas corporales en los docentes. El cuerpo como construcción social, política y cultural. '
          'Diálogo entre sociedad y construcción de identidades. El sujeto como intérprete de sus propios procesos. El sujeto, sus procesos creativos a través del cuerpo, el juego, la imagen y la tecnología (percepción, sensibilidad, intuición, espontaneidad, creatividad e innovación).',
    },
    {
      'titulo': 'Apertura a otros modos de comunicación y expresión',
      'descripcion':
          'Disponibilidad corporal para jugar, expresarse, comunicarse, interaccionar colaborativamente, en cooperación y oposición. El carácter integrador del hecho estético. Nuevos lenguajes de expresión y comunicación corporal.',
    },
    {
      'titulo': 'Prácticas pedagógicas y los distintos lenguajes',
      'descripcion':
          'Creación y producción a través de diferentes lenguajes. Redescubrimiento en las relaciones de confianza y la producción de mensaje con intencionalidad expresiva y comunicativa. La identidad cultural vinculada con la sociedad actual y la institución educativa.',
    },
  ],
  'bibliografia': [
    'AIZENCANG, N. (2005). Jugar, aprender y enseñar. Relaciones que potencian los aprendizajes escolares. Buenos Aires: Manantial.',
    'ARNHEIM, R. (1962). Arte y percepción visual. Psicología de la Visión Creadora. Buenos Aires. Eudeba.',
    'BLEICHMAR, S. (2005). La subjetividad en riesgo. Buenos Aires: Topía.',
    '---------------------- (2009). El desmantelamiento de la subjetividad. Estallido del yo. Buenos Aires: Topía.',
    'BOZZINI, F. y otros (2000). El juego y la música. Buenos. Aires: Noveduc.',
    'CALMELS, D. (2001). Cuerpo y saber. Buenos Aires: Noveduc.',
    '------------------- (2001). Del sostén a la transgresión. Buenos Aires: Noveduc.',
    'CASTAÑER BALCELLS, M. comp. (2006). La inteligencia corporal en la escuela. Barcelona: Graó.',
    'DIAZ GOMEZ M, R.; GALAN, M. E. (2007). Creatividad en educación musical. España: Universidad de Cantabria. Fundación Marcelino Botín.',
    'ELLIOT, E. (1998). Educar la visión artística. Buenos Aires: Paidós SAICF.',
    'FARRERAS, C. (2002). Culturas Estéticas Contemporáneas. Buenos Aires: Puerto de Palos.',
    'FERNÁNDEZ, A. (2000). Psicopedagogía en psicodrama. Buenos Aires: Nueva Visión.',
    'FREGA, A. L. (1980). Creatividad musical: fundamentos y estrategias para su desarrollo, en colaboración con Margery M. Vaughan. Buenos Aires: Edición DDMCA.',
    'FREIRE, P. (2008). Cartas a quien pretende enseñar. Buenos Aires: Siglo XXI.',
    'FRIGERIO, G. y DIKER G. comp. (2007). Educar: (sobre) impresiones estéticas. Buenos Aires: Del Estante Editorial.',
    'GAINZA, V. H. de (ed.) (1993). La Educación Musical Frente al Futuro. Enfoques interdisciplinarios desde la Filosofía, la Sociología, la Antropología, la Psicología, la Pedagogía y la Terapia. Buenos Aires: Ediciones Guadalupe.',
    'GIRADEZ, A. (2005). Internet y Educación Musical. Barcelona: Ediciones Graó.',
    'GÓMEZ, R. (2003). El aprendizaje de las habilidades y los esquemas motrices en el niño y el joven. Buenos Aires: Stadium.',
    'GRASSO, A. (2005). Construyendo identidad corporal. Buenos Aires: Noveduc.',
    'GRASSO, A.; ERRAMOUSPE, B. colab. (2005). La corporeidad escuchada. Buenos Aires: Noveduc.',
    'MATOSO, E. (1996). El cuerpo, territorio escénico. Buenos Aires: Paidós.',
    'NAJMANOVICH, D. (2005). El juego de los vínculos. Subjetividad y redes: figuras en mutación. Buenos Airea: Biblos.',
    'NUN DE NEGRO, B. (2008). Los proyectos de arte. Enfoque metodológico en la enseñanza de las artes plásticas en el sistema escolar. Magisterio del Río de la Plata: Grupo Editorial Lumen.',
    'OLIVERAS, E. (2007). Cuestiones de arte contemporáneo. Buenos Aires: Emecé.',
    '-------------------- (2007). Estética La cuestión del arte. (3ra edición). Buenos Aires: Emecé',
    '------------------- (2009). La metáfora en el arte: retórica y filosofía de la imagen. (2da edición), Buenos Aires: Emecé.',
    'RASSKIN, M. (1994). Música Virtual. Sociedad General de autores de España. España: ANAYA Multimedia.',
    'ROSBACO, C.I. (2000). El desnutrido escolar .Rosario: Homo Sapiens.',
    '---------------------- (2004). Constitución del pensamiento relativamente autónomo: incidencia de la estructura narrativa. Tesis doctoral Universidad Nacional de Rosario. Facultad de Psicología. Instituto de investigaciones.',
    '------------------------ El docente como representante del otro social: su función subjetivante. Ponencia Paraná, Entre Ríos, Colegio de Psicopedagogos.',
    'SANTOS GUERRA, M. (1998). Imagen y Educación. Buenos Aires: Editorial magisterio Río de la Plata.',
    'SCHLEMENSON, S. (1995). El aprendizaje un encuentro de sentidos. Buenos Aires: Kapelusz.',
    'SCHNITMAN, F. D. (1994). Nuevos paradigmas, cultura y subjetividad. Buenos Aires: Paidós.',
    'SIMMEL, G. (2003). Estudios psicológicos y etnológicos sobre música. Buenos Aires: Graó.',
    'SKLIAR, C. (2009). La obsesión de lo diferente. Conferencia en el marco de la Jornada “Escuela, infancia y diversidad”. Paraná.',
  ],
};

const _oralidad = {
  'id': 'oralidad-lectura',
  'nombre': 'Oralidad, Lectura, Escritura y TIC',
  'anio': 1,
  'formato': 'Taller',
  'cargaHoraria':
      '3 horas cátedra semanales - 2 horas reloj semanales. Carga para los docentes: 3 horas cátedra (Perfil Lengua) 3 horas cátedra (Perfil TIC)',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'Los procesos de lectura y escritura se vinculan con diferentes prácticas de lenguaje y pensamiento de acuerdo al ámbito o área de conocimiento y a los modos particulares de circulación de los discursos. '
      'El ámbito de la Educación Superior no es una excepción: hay prácticas de lenguaje y pensamiento que le son propias, modos instituidos de circulación de la palabra, de validación de la misma, condiciones de producción y socialización de los conocimientos. '
      'Proponer un taller de estas características en el comienzo de la carrera docente implica preguntarse cuál es la relación de la lectura, la escritura con el aprendizaje. '
      'Leer y escribir son procesos cognitivos que se aprenden leyendo y escribiendo, y a partir de reflexiones posteriores sobre esas prácticas. Asimismo se hace necesaria una reflexión sobre los modos en que estos procesos se construyen en contextos y culturas diversas que evidencian el fenómeno de socialización tecnológica de las nuevas generaciones. '
      'Desde esta perspectiva, el trabajo del Taller se orientará a que los alumnos desarrollen sus propios modos de construcción, organización y comunicación del conocimiento, ya que los modos de indagar, aprender y pensar en las distintas áreas están estrechamente vinculados con modos de leer y escribir, y con los soportes que se utilizan. '
      'Por esta particular relación entre lectura, escritura y prácticas de oralidad con los modos peculiares de ser el discurso en las distintas áreas disciplinares, el trabajo sobre los discursos y los textos no puede estar desvinculado del contenido de los mismos, y se hace necesario el trabajo colaborativo con los docentes de las otras unidades curriculares, tanto en las actividades del taller, como en sus propias clases.',
  'ejes': [
    {
      'titulo': 'Lectura, escritura y oralidad académica',
      'descripcion':
          'Escritura y lectura como procesos en relación con la subjetividad. Leer y escribir: prácticas históricas. Escritura académica: género discursivo, estilo, destinatarios, producción y revisión, documentación y referencias bibliográficas. '
          'Lectura académica: exposición y argumentación. Textos, paratextos e hipertextos. Aspectos gráficos y soportes textuales. '
          'La gramática en los procesos de lectura y escritura: su vinculación con la construcción de sentido. La normativa.',
    },
    {
      'titulo': 'TIC y Educación',
      'descripcion':
          'Las TIC, procesos de circulación, consumo y producción de información y comunicación como objeto de problematización constante. La relación entre las transformaciones sociales, políticas y culturales y los cambios tecnológicos. Comunicación y educación en el escenario actual.',
    },
    {
      'titulo': 'Enseñanzas y aprendizajes en escenarios virtuales',
      'descripcion':
          'Reconfiguración de las prácticas de lectura y escritura: nexos, conexión y tramas. Textualidad múltiple. Hipertexto electrónico.',
    },
  ],
  'bibliografia': [
    'ALVARADO, M. y otros. (2001). Entre líneas. Teorías y enfoques en la enseñanza de la escritura, la gramática y la literatura. Buenos Aires: FLACSO Manantial.',
    'ARNOUX, E., y otros (1999). Talleres de lectura y escritura. Buenos Aires: Eudeba.',
    '----------------------------- (2002). La lectura y la escritura en la Universidad. Buenos Aires: Eudeba.',
    'BAS A. y otros (2001). Escribir: apuntes sobre una práctica. Buenos Aires: Eudeba.',
    'BLANCHE - BENVENISTE, C. (1998). Estudios lingüísticos sobre la relación entre oralidad y escritura, Barcelona: Gedisa.',
    'BOMBINI, G. (2006). Prácticas de lectura. Una perspectiva sociocultural. En Lengua y Literatura. Prácticas de enseñanza, perspectivas y propuestas. Santa Fe: Universidad Nacional del Litoral.',
    'BURBULES, N. y CALLISTER, T. (2006). Educación: riesgos y promesas de las nuevas tecnologías de la información. Buenos Aires: Grónica.',
    'CARLINO, P. (2005). Escribir, leer y aprender en la universidad. Una introducción a la alfabetización académica. Buenos Aires: FCE.',
    'CASSANY, D. (1998). Reparar la escritura. Didáctica de la corrección de lo escrito. Barcelona: Graó.',
    '-------------------- (2003). Describir el escribir. Cómo se aprende a escribir. Barcelona: Paidós.',
    '-------------------- (2006). Tras las líneas. Sobre la lectura contemporánea. Barcelona: Anagrama.',
    '-------------------- (2008). Taller de textos. Leer, escribir y comentar en el aula. Buenos Aires: Paidós.',
    'CASTELLS, M. (2005). La era de la información, (volumen 1) Economía, sociedad y cultura. La sociedad en red. Madrid: Colección Libros singulares.',
    'CICALESE, G. (2010). Comunicación comunitaria. Apuntes para abordarlas dimensiones de la construcción colectiva. Buenos Aires: La Crujía.',
    'CHARTIER, R. (1997). Pluma de ganso, libro de letras, ojo de viajero. México: Universidad Iberoamericana.',
    'FERNÁNDEZ BRAVO, Á. y TORRE, C. (2003). Introducción a la escritura universitaria. Montevideo: Granica.',
    'HUERGO, J. (2000). Cultura escolar, cultura mediática. Intersecciones. Colombia: Universidad Pedagógica Nacional. CACE.',
    'KAPLÚN, M. (1994). Del educando oyente al educando hablante, en Perspectivas de la Comunicación. Educación en tiempos de eclipse. Buenos Aires: Lumen Humanitas.',
    'LANDOW, G. (1995). Hipertexto. Barcelona: Paidós.',
    'LARROSA J (1995). Escuela, poder, subjetivación. Madrid: La Piqueta.',
    '----------------- (1996). La experiencia de la lectura. Barcelona: Laertes.',
    'MILIAN M. Y CAMPS A (2000). El papel de la actividad metalingüística en el aprendizaje de la escritura. Rosario: Homo Sapiens.',
    'MEIRIEU P. (2006). El significado de educar en un mundo sin referencias. Conferencia dictada el 27 junio 2006. Ministerio de Educación Ciencia y Tecnología. www.me.gov.ar/curriform/meirieu.html.',
    'MC.EWAN Y KIERAN E. comps. (1995). La Narrativa en la enseñanza, el aprendizaje y la investigación.  Buenos Aires: Amorrortu.',
    'OLSON, D. y TORRANCE, N. (1998). Cultura escrita y oralidad. Buenos Aires: Gedisa',
    'ONG, W. (1987). Oralidad y escritura. Tecnologías de la palabra. México: FCE.',
    'PÉTIT, M. (1999). Nuevos acercamientos a los jóvenes y la lectura. México: FCE.',
    'PETRUCCI, A. (1999). Alfabetismo, escritura, sociedad. Barcelona: Gedisa.',
    'PISCITELLI, A. (1991). La digitalización de la palabra. Metamedios, reestructuración del psiquismo y planetarización. Ponencia presentada al Seminario sobre Comunicación y Ciencias Sociales organizado por FELAFACS en Colombia.',
    'PRIETO CASTILLO, D. (2004). La comunicación en la educación. Buenos Aires: La Crujía.',
    'QUIROZ, M T. en VVAA (S/D). Educar en la comunicación/Comunicar en la educación en Comunicación y Educación como campos problemáticos desde una perspectiva epistemológica. Facultad de Ciencias de la Educación. Universidad Nacional de Entre Ríos. ISBN 950-698-011-X.',
    'R.A.E. (1999). Ortografía de la lengua española. Madrid: Espasa Calpe.',
    'R.A.E. (2009). Nueva gramática de la lengua española. Madrid, Espasa Calpe, selección de páginas.',
  ],
};

const _antiguedad = {
  'id': 'procesos-antiguedad',
  'nombre':
      'Procesos Sociales, Políticos, Económicos y Culturales de la Antigüedad',
  'anio': 1,
  'formato': 'Asignatura',
  'cargaHoraria': '4 horas cátedra semanal - 2 horas 40 min. reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular con formato asignatura está pensada como un espacio de acercamiento al espacio asiático, africano y europeo; desde que el hombre comienza a manifestarse en sus distintas acciones y relaciones para ir construyendo sociedades basadas en el desarrollo económico a partir de los recursos naturales que encuentre en su entorno, en relaciones de poder a partir de las organizaciones políticas o en sus manifestaciones culturales. '
      'Se han propuesto cuatro ejes que se compartirán con Procesos sociales, políticos, económicos y culturales del Feudalismo y la Modernidad y Procesos sociales, políticos, económicos y culturales Contemporáneos I y II. Se plantea una mirada histórica compleja e integral desde cuatro perspectivas; lo social, lo económico, lo político y lo cultural para que el docente junto a los estudiantes puedan ir generando relaciones y comprender el movimiento de las sociedades urbanas y rurales. Asimismo, la forma en que están planteadas las unidades curriculares mencionadas permitirá abordar contenidos de otras unidades curriculares y contextualizar desde lo conceptual con aportes realizados por otras disciplinas o ciencias. '
      'Hablar de las sociedades antiguas es hablar del origen mismo de la humanidad, por ende el recorrido que se propone realizar está orientado a comprender múltiples recorridos desde los diversos contextos y múltiples perspectivas historiográficas.',
  'ejes': [
    {
      'titulo': 'Organización y desarrollo de las relaciones sociales',
      'descripcion':
          'De la sociedad nómade a la sociedad sedentaria. Origen y proceso de cambios de las sociedades agrarias a las urbanas. Relaciones de parentesco y construcción del poder.',
    },
    {
      'titulo':
          'Formas de organización de la subsistencia y la reproducción de la sociedad',
      'descripcion':
          'La apropiación de la tierra. Producción, distribución, cambio, consumo. El trabajo. Esclavismo y resistencia.',
    },
    {
      'titulo':
          'Constitución de lo político y la política en las sociedades de la antigüedad',
      'descripcion':
          'la ocupación del espacio africano, europeo y asiático. El umbral de las sociedades complejas. Las ciudades-estado. Expansión, auge y crisis de los Imperios. Origen de diversas formas de gobierno.',
    },
    {
      'titulo':
          'Construcción de los sentidos y significados sobre la propia existencia y sobre el mundo',
      'descripcion':
          'Agrupamientos sociales en relación a lo lingüístico y lo cultural. El poder y relaciones de autoridad. El valor del arte en la construcción cultural de la antigüedad: Egipto, Mesopotamia, Creta, Grecia y Roma.  Cosmovisiones y religión.',
    },
  ],
  'bibliografia': [
    'AYMAR, A. y otros. (1979). Oriente y Grecia Antigua. En Historia General de las civilizaciones. Barcelona: Destino.',
    'BRAUDEL, F. (1998). La historia y las ciencias sociales. Buenos Aires: Alianza.',
    'BRAUDEL, F. (1998). Las civilizaciones actuales. Madrid: Tecnos.',
    'BURROW, J. (2008). Historia de la Historia. Argentina: Crítica.',
    'CARR, E. (1993). Que es la Historia. Barcelona: Planeta-Agostini.',
    'CARRETERO, M. (2009). Constructivismo y educación. Argentina: Paidós.',
    'CASSIN,  E. y otros (1972). Los imperios del Antiguo Oriente. Madrid: Siglo XXI.',
    'CONTENEAU, G. (1993). Antiguas Civilizaciones del Asia Anterior. Buenos Aires: Eudeba.',
    'DUBY, G. (1995). Año 1000, año 2000. Santiago de Chile: Andrés Bello.',
    'FONTANA, J. (1973). La historia. Barcelona: Salvat.',
    'KINDER, H.; HILGEMANN, W. (1992). Atlas histórico mundial. España: Istmo.',
    'LE GOFF, J. (1997). Pensar la Historia. Barcelona: Altaya.',
    'PLÁCIDO D. (1995). Introducción al mundo antiguo: problemas teóricos y metodológicos. Madrid: Síntesis.',
    'REDMAN CH. (1990). Los orígenes de la civilización. Barcelona: Crítica.',
  ],
};

const _pueblosOriginarios = {
  'id': 'pueblos-originarios',
  'nombre':
      'Procesos Sociales, Políticos, Económicos y Culturales de los Pueblos Originarios de América',
  'anio': 1,
  'formato': 'Taller',
  'cargaHoraria': '3 horas cátedra - 2 horas reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular con formato asignatura, propone partir de un eje que contextualice, desde la arqueología y la etnohistoria, los orígenes de las sociedades de pueblos originarios pensados como un entramado donde se van estableciendo procesos de hominización, nomadismo y sedentarismo en América. '
      'Acercarse a la Historia desde otras ciencias permitirá comprender y analizar este proceso en América desde las manifestaciones socioculturales y políticas así como el desarrollo de las distintas economías basadas en los recursos naturales y su subsistencia. '
      'Mirar las sociedades de pueblos originarios en sus diversas dimensiones enmarcadas en un espacio y tiempo particulares, diferido de la mirada euro-céntrica, permitirá ubicar la historia de América planteada en los Procesos sociales, políticos, económicos y culturales americanos I, II y III desde un aspecto integral.',
  'ejes': [
    {
      'titulo': 'Arqueología y Etnohistoria',
      'descripcion':
          'Relaciones y construcción de interdisciplinariedades: Historia, Arqueología y Antropología. Aportes de categorías, métodos, perspectivas teóricas en relación a las Ciencias Sociales.',
    },
    {
      'titulo':
          'Relaciones y configuraciones sociales en relación a lo político y la política',
      'descripcion':
          'Procesos de hominización, nomadismo y sedentarización. Poblamiento y ocupación del territorio americano: sociedades de cazadores y recolectores. Hacia la conformación de la aldea: la agricultura y el pastoreo. Organización de las primeras formas sociopolíticas en Mesoamérica, la Región Andina y el actual territorio argentino. Relaciones de Poder.Relaciones sociales generadas durante el nomadismo y sedentarismo. Organización de la sociedad en los diversos contextos culturales. '
          'Los grupos sociales y las manifestaciones de sus creencias. Representaciones y prácticas culturales, cosmovisiones y creencias.',
    },
    {
      'titulo':
          'Utilización de los recursos naturales y organización de la subsistencia de las sociedades de pueblos originarios',
      'descripcion':
          'Sociedades que organizan su subsistencia: productores, agricultores y pastores en América. Organización de la producción y el intercambio entre las diferentes culturas. Tecnologías en función de la subsistencia.',
    },
  ],
  'bibliografia': [
    'BETHELL, L. (1991). Historia de América Latina. Buenos Aires: Siglo XXI.',
    'CARRASCO, M. (2000). Los derechos de los pueblos indígenas en Argentina. Buenos Aires: IWGIA.',
    'DÍAZ POLANCO, H. (1991). Autonomía Regional. La autodeterminación de los pueblos indios. México: Siglo XXI.',
    'GALEANO, E. (1997). Las venas abiertas de América Latina. Chile: Catálogos.',
    'GARCÍA CANCLINI, N. (2004). Diferentes, desiguales y desconectados. Mapas de la interculturalidad. Buenos Aires: Gedisa.',
    'GRIMSON, A. (2005). Relatos de la diferencia y la igualdad. Buenos Aires: Eudeba.',
    'LÓPEZ, L., REGALSKY P. (2005). Movimientos indígenas y estado en Bolivia. La Paz: Plural.',
    'MANZANO, V. (2007). Movimientos sociales y protesta social: una perspectiva antropológica. Buenos Aires: Eudeba.',
    'MONTANER, C. (2001). Las raíces torcidas de América Latina. España: Plaza Jánes.',
    'RIBEIRO, D. (1985). Las Américas y la Civilización. Buenos Aires: Centro Editor de América Latina.',
    'SANCHEZ, C. (1999). Los pueblos Indígenas: del indigenismo a la autonomía. México: Siglo XXI.',
    'TAMAGNO, L. (2001). Los tobas en la casa del hombre blanco. Identidad, memoria y utopía. Buenos Aires: Ediciones Al Margen.',
  ],
};

const _historiaIdeas1 = {
  'id': 'historia-ideas-1',
  'nombre': 'Historia de las Ideas I',
  'anio': 1,
  'formato': 'Seminario',
  'cargaHoraria': '3 horas cátedra - 2horas. reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular propone que los estudiantes comiencen a relacionarse con conceptos teóricos y metodológicos para contextualizar diversos contenidos, ubicando los mismos desde la antigüedad hasta el S. XV. Asimismo, es fundamental acercarse a pensadores y autores desde la Grecia Clásica hasta el S. XV e ir acompañando procesos de aprendizajes junto a otras unidades curriculares. '
      'De este modo, al comprender las diferentes concepciones epistemológicas presentes en las teorías políticas de la antigüedad, se irán relacionando y comprendiendo conceptos como poder, estado o gobierno, entre otros que le permitan identificar el marco filosófico-político en que han surgido las ideas. Es necesario visualizar conceptos y categorías desde distintas disciplinas y ciencias como la sociología, antropología, ciencia política o economía entre otras. '
      'Este seminario está relacionado directamente con Historia de las Ideas Políticas II y Economía Política y del mismo modo, deberá abordarse holísticamente junto a otras unidades curriculares de primero y segundo año del profesorado.',
  'ejes': [
    {
      'titulo': 'Aportes de las ciencias sociales a la historia',
      'descripcion':
          'Objeto de estudio de la Ciencia Política, la Sociología y la Economía. Aportes a la Historia. Recorrido ideológico desde la antigüedad hasta el S. XV. Concepción del mito. El mito como manifestación política.',
    },
    {
      'titulo': 'Orígenes del pensamiento político occidental',
      'descripcion':
          'Las ideas de sociedad, estado, democracia, gobierno y poder en la antigüedad clásica. '
          'La visión cristiana de lo político en la Edad Media. '
          'El impacto de las ideas de los siglos X al XV en el pensamiento Europeo. De la Escolástica, al Humanismo y el Renacimiento.',
    },
    {
      'titulo': 'El desembarco del pensamiento europeo en América',
      'descripcion':
          'Ideologías; Conceptualización. El dominio del otro, de Europa a América.',
    },
  ],
  'bibliografia': [
    'ANDERSON, P. (1979). El estado absolutista.Madrid: Siglo XXI.',
    'ARENDT, H. (1997). ¿Qué es la política? Barcelona: Paidós.',
    'ARMSTRONG, A. (2007). Introducción a la filosofía antigua. Buenos Aires: Eudeba.',
    'BOBBIO, N. (1991). Diccionario de política.México: Siglo XXI.',
    'BORÓN, A. Comp. (2000). La filosofía política clásica. De la antigüedad al renacimiento. Buenos Aires: Eudeba.',
    'BROWN P. (1989). El mundo en la Antigüedad Tardía. De Marco Aurelio a Mahoma. Madrid: Taurus.',
    'CASTILLO GARCÍA, C. y otros (2003). Sociedad y economía en el Occidente Romano. España: EUNSA.',
    'DI TELLA T. y otros. (2004). Diccionario de Ciencias Sociales y Políticas. Buenos Aires: Planeta Ariel.',
    'ECCLESHALL, R. y otros (1993). Ideologías Políticas.Madrid: Tecnos.',
    'GARCÍA MORENO, L. y otros (1999). Historia del Mundo Clásico a través de sus textos. Roma. Madrid: Alianza.',
    'HUBEÑÁK, F. (1997). Roma, el mito político. Buenos Aires: Ciudad.',
    'LERNER, D.; STELLA P.; TORRES M. (2009). Formación docente en lectura y escritura. Recorridos didácticos. Buenos Aires: Paidós.',
    'LÓPEZ BARJA DE QUIROGA, P. y LOMAS SALMONTE, F.J (2004). Historia de Roma. Madrid: Akal.',
    'PALMA, H.; PARDO, R. (2012). Epistemología de las ciencias sociales. Perspectivas y problemas de las representaciones científicas de lo social. Buenos Aires: Biblos.',
    'SABINE, G. (1994). Historia de la teoría Política. México: FCE.',
    'SCHMITT, C. (1999). El concepto de lo político. Madrid: Alianza.',
    'TOUCHARD, J. (2000). Historia de las ideas políticas. Madrid: Tecnos.',
    'Constitución de la Nación Argentina.',
    'Constitución de la Provincia De Entre Ríos.',
  ],
};

const _problematica = {
  'id': 'problematica-conocimiento',
  'nombre': 'Problemática del Conocimiento Histórico',
  'anio': 1,
  'formato': 'Asignatura',
  'cargaHoraria':
      '4 horas cátedra semanales - 2 horas 40 minutos reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular, con formato de asignatura, propone reconocer las relaciones que se van generando entre  las Ciencias Sociales y la forma en que el concepto Historia, según Silvia Gojman, describe la realidad histórica tal cual objetivamente aconteció y el conocimiento histórico, como la ciencia que pretende develar la realidad histórica mediante el trabajo del historiador. '
      'Asimismo, se pretende comprender la forma en que la historia se va transformando en una disciplina social y humana, acompañando con un análisis profundo respecto a las categorías primordiales como Tiempo y Espacio, Objeto de estudio, Causalidad y Multicausalidad, Subjetividad y Objetividad. Se sugiere el acompañamiento de lectura de textos que permitan a los estudiantes visualizar las características particulares y las diferencias de los discursos historiográficos y el uso de recursos TIC para la construcción del conocimiento histórico.',
  'ejes': [
    {
      'titulo': 'La Historia como ciencia',
      'descripcion':
          'Las Ciencias Sociales. Multidisciplinariedad e interdisciplinariedad.  La realidad histórica y las categorías o campos de la Historia. La objetividad en Historia; conciencia y saber histórico. Procedimientos y producción de la Historia.',
    },
    {
      'titulo':
          'La historia como disciplina social y humana y sus diferentes discursos historiográficos.',
      'descripcion':
          'Historia. Memoria. Conciencia histórica. Fuentes para la producción historiográfica. Discursos historiográficos. Carácter Provisional del conocimiento histórico. Los sujetos de la Historia. Objetividad y subjetividad. Acercamiento a las corrientes historiográficas desde la Historia Literaria a la Historia del Tiempo Presente. Historia y Narración.',
    },
    {
      'titulo': 'Construcción del tiempo y el espacio',
      'descripcion':
          'Representaciones del tiempo y espacio en las ciencias sociales. El tiempo histórico. Cambios y construcción del espacio histórico. Cronologías, periodizaciones y múltiples temporalidades. Sincronías y Diacronías. Software para la construcción de tiempo histórico.',
    },
  ],
  'bibliografia': [
    'BENEJAM, P. (1997). Enseñar y aprender ciencias sociales, geografía e historia en la educación secundaria, Cuadernos de Formación del profesorado. España. ICE/Horsori.',
    'BOURDIEU, P. (2003). Capital cultural, escuela y espacio social. Argentina: Siglo XXI.',
    'BRAUDEL, F. (1998). La historia y las ciencias sociales. Buenos Aires: Alianza.',
    'GALETTI, A. (2001). Hablemos de Historia, Cuestiones teóricas y metodológicas de la historia. Entre Ríos: Editorial de Entre Ríos.',
    'CARRETERO, M. (2009). Constructivismo y educación. Argentina: Paidós.',
    'HELER, M. (2004). Ciencia Incierta. La producción social del conocimiento. Buenos Aires: Biblos.',
    'LE GOFF, J. (2005). Pensar la Historia. Modernidad, presente, progreso. Barcelona: Paidós.',
    'LEVINE, R. (2006). Una geografía del tiempo o como cada cultura percibe el tiempo de manera un poquito diferente. Buenos Aires: Siglo XXI.',
    'MORADELLIOS, E. (2008). El oficio del historiador. España: Siglo XXI.',
    'PEREZ AMUCHÁSTEGUI, A. (1979). Algo más sobre la historia. Teoría y metodología de la investigación histórica. Buenos Aires: Ábaco de Rodolfo Depalma SRL.',
    'RINESI, E. (2009). Las máscaras de Jano. Notas sobre el drama de la historia. Argentina: Gorla.',
    'RÍOS, M. (1996). Un programa para leer y escribir historia. Rosario: IRICE.',
    'ROMERO, L. (2007). Volver a pensar la Historia. Argentina: Aique.',
    'TERÁN, O. (2008). Historia de las ideas en la Argentina. Diez lecciones iniciales: 1810 - 1980. Argentina: Siglo XXI.',
    'TERÁN, O. (2004). Ideas en el siglo. Intelectuales y cultura en el siglo XX latinoamericano. Argentina: Siglo XXI.',
  ],
};

const _practica1 = {
  'id': 'practica-1',
  'nombre': 'Práctica Docente I - Sujetos y Contextos',
  'anio': 1,
  'formato': 'Seminario-Taller',
  'cargaHoraria':
      '4 horas cátedra semanales (2 horas 40 min reloj). Presenciales en el instituto: 3 horas cátedra semanales (2 horas reloj) y en las instituciones asociadas: 1 hora cátedra semanales (40 min). Carga horaria anual: 128 horas cátedra (85 horas 20 min reloj), de las cuales se considerarán 32 horas (21 horas 20 min) para la inserción en las instituciones asociadas. Carga horaria para los docentes: 3 horas cátedra perfil generalista - 3 horas cátedra perfil disciplinar.',
  'regimenCursado': 'Anual',
  'tipo': 'Práctica Profesional',
  'marcoOrientador':
      'El formato seminario taller de este espacio se plantea como un recorrido pedagógico flexible que entiende los procesos complejos y multidimensionales de la práctica docente y permite la formación reflexiva de los estudiantes durante el primer año de la carrera a través de las primeras herramientas que les proporciona la investigación. '
      'Es propósito de esta unidad curricular que los estudiantes reconozcan y transiten distintas experiencias de práctica educativa que se desarrollan en diferentes contextos socioculturales y educativos formales y no formales. '
      'Se plantean dos ejes de contenidos consecutivos. En el eje: “La práctica docente como práctica social en contextos contemporáneos”, se reconocen los múltiples cruces que se expresan en dichas prácticas a fin de lograr un enfoque teórico-metodológico que posibilite abordar su complejidad y problematicidad. Se recupera el enfoque socio - antropológico, sobre todo de la etnografía en la investigación educativa. '
      'Es importante que en esta unidad se realice un abordaje teórico epistemológico de problemáticas propias del campo de la investigación educativa a fin de no caer en un uso instrumental de las propias estrategias. Incorporar la investigación en la formación docente entendida como una práctica social, caracterizada fundamentalmente por un modo particular de confrontación entre teoría y empiria, que permite desnaturalizar, complejizar la mirada e interrogar las prácticas. '
      'Desde este enfoque, la reconstrucción de los procesos por los cuales los sujetos se apropian de los conocimientos, las costumbres, usos, tiempos, espacios, relaciones y reglas de juego, admiten la descripción de diversas tramas. '
      'En el segundo eje: “Compartiendo miradas: experiencias en instituciones asociadas”, se proponen instancias en las que, las narrativas y reflexiones sobre las praxis docentes documenten  los recorridos y  registren las prácticas educativas como actividades complejas, que se desarrollan en escenarios singulares, determinados por el contexto, con resultados en gran parte imprevisibles, y cargadas de conflictos de valor que requieren pronunciamientos políticos y éticos. '
      'Este último tramo del recorrido de la Práctica Docente I, tiene como propósito principal, generar espacios de producción individual y colectiva en los que se reflexione acerca de las diferentes experiencias que fueron desarrollando durante el año; para ser compartidas luego, junto a los profesores de práctica y de las instituciones asociadas. '
      'Las instancias de inserción en las instituciones asociadas, que han de llevarse a cabo en simultáneo con el desarrollo de los ejes posibilitarán a los estudiantes realizar observaciones, registros y análisis de escenas educativas en distintos ámbitos formales y no formales.',
  'ejes': [
    {
      'titulo':
          'La práctica docente como práctica social en contextos contemporáneos',
      'descripcion':
          'La investigación como práctica social y como proceso de producción de conocimiento. Los paradigmas de investigación social y los contextos histórico- políticos en que surgen. Marcos conceptuales y herramientas metodológicas para recoger y analizar información: identificación, caracterización y construcción de problemas de los diferentes contextos de enseñanza y aprendizaje. Análisis interpretativo y sociocrítico de la realidad abordada. La construcción de problemas - objeto de estudio. Técnicas de recolección y análisis de información. El campo de la práctica y su articulación con los otros campos. La práctica docente como espacio de aprendizaje y de “enseñar a enseñar”. Las biografías escolares. Problemáticas y tensiones en diferentes contextos. La práctica docente en distintos ámbitos formales y no formales. Circulación de saberes y experiencias educativas.',
    },
    {
      'titulo': 'Compartiendo miradas: experiencias en instituciones asociadas',
      'descripcion':
          'Documentación y narrativa de experiencias pedagógicas en instituciones educativas y espacios socio-comunitarios. '
          'Producción y socialización de saberes, recuperando, resignificando y sistematizando los aportes y trabajos desarrollados en el IFD y las instituciones asociadas. Escrituras académicas.',
    },
  ],
  'bibliografia': [
    'ACHILLI, E. (1986). La práctica docente: una interpretación desde los saberes del maestro. Buenos Aires: Clacso.',
    '------------------ (2000). Investigación y formación docente. Rosario: Laborde.',
    'AGENO, R. (1989). El taller de educadores y la investigación. En Cuadernos de formación docente. Rosario: Universidad Nacional de Rosario.',
    'BOLIVAR, A. (1995). El conocimiento de la enseñanza. Epistemología de la investigación del curriculum. España: Force/ Universidad de Granada.',
    'CARUSO, M Y DUSSEL, I. (1995). De Sarmiento a los Simpson. Cinco conceptos para pensar la educación contemporánea. Buenos Aires: Kapelusz.',
    'FREIRE, P. (1994). Educación y participación comunitaria. En AA.VV: Nuevas perspectiva criticas en educación. Barcelona: Paidós.',
    'LA BELLE, T. (1994). Educación no formal y cambio social en América Latina. México: Nueva Imagen.',
    'MEIRIEU. P, (2007). Es responsabilidad del educador provocar el deseo de aprender. Cuadernos de pedagogía. Nº 373.',
    'PIEVI, N. y BRAVIN, C. (2009). Documento metodológico orientador para la investigación educativa 1ª ed. Buenos Aires: Ministerio de Educación de la Nación.',
    'ROCKWELL, E. (2009). La experiencia etnográfica. Historia y cultura en los procesos educativos. Buenos Aires: Paidós.',
    'SIRVENT, M.T. (2004). El proceso de investigación. 2ª edición (revisada). Facultad de Filosofía y Letras. Buenos Aires: Cuadernos de la Oficina de Publicaciones de la Facultad de Filosofía y Letras (Opfyl).',
    'TAYLOR, S y BOGDAN, R. (1990). La investigación cualitativa. Buenos Aires: Paidós.',
  ],
};

// ==================== 2DO AÑO ====================

const _filosofia = {
  'id': 'filosofia',
  'nombre': 'Filosofía',
  'anio': 2,
  'formato': 'Asignatura',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'La filosofía, desde la racionalidad y la pasión, problematiza las grandes '
      'cuestiones que han afectado y afectan al sujeto, que se pregunta sobre el '
      'sentido y el fundamento de la existencia, exige un diálogo con las grandes '
      'corrientes del pensamiento que configuran la vida y las culturas de nuestra '
      'sociedad, poniéndonos en contacto con los pensadores-filósofos más '
      'importantes y sus reflexiones para encontrar, mediante la razón respuesta a '
      'los interrogantes que hoy planteamos. Para poder concretar esta propuesta, '
      'las problemáticas se abordarán desde una lectura culturalmente situada. Esta '
      'forma de hacer filosofía permite mostrar que los sujetos no estamos '
      'aislados, sino incluidos en una compleja red de relaciones históricas, '
      'sociales, políticas, culturales que orientan y condicionan nuestro pensar. '
      'Desde esta mirada, desde un análisis histórico y contextual de las '
      'corrientes del pensamiento más significativas, se pretende que la filosofía '
      'deje su huella en los estudiantes, que abra caminos al cuestionamiento, a la '
      'interrogación de nuestra propia realidad, buscando respuestas con '
      'fundamentos. Las propuestas pedagógicas deberán asegurar el tratamiento '
      'interdisciplinario y contextualiza-do de los conocimientos de filosofía, y '
      'de esta manera articular conocimientos filosóficos con diferentes contenidos '
      'y modos discursivos en las ciencias naturales, humanas, en las artes y en '
      'otras producciones culturales: La filosofía puede cooperar decisivamente en '
      'el trabajo de articulación de los diversos sistemas teóricos y conceptuales '
      'curriculares.28',
  'ejes': [
    {
      'titulo': 'Introducción a la Problemática filosófica',
      'descripcion':
          'Configuraciones históricas, sociales, políticas y epistemológicas en '
          'relación a Sujeto, política, conocimiento, educación, ética y '
          'estética.',
    },
    {
      'titulo':
          'Historicidad del campo de la filosofía. Tensiones y debates actuales. Pensamiento',
      'descripcion': 'latinoamericano.',
    },
    {
      'titulo': 'Reflexión epistemológica: miradas acerca del conocimiento',
      'descripcion':
          'La Epistemología diversos modos de abordarla. Perspectivas y análisis '
          'de las ciencias y el conocimiento. La situación actual de la '
          'epistemología: supuestos, debates y tensiones. Construcciones '
          'epistemológicas en el campo de la Historia.',
    },
    {
      'titulo': 'Filosofía y Educación: entramados y sentidos',
      'descripcion':
          'Experiencia. Saber. Herencias. Educación como deseo de conocer. '
          'Problematización de lo dado. Sentidos de educar. Supuestos '
          'epistemológicos y políticos en las prácticas docentes.',
    },
  ],
  'bibliografia': [
    'ADORNO, T. (1931). La actualidad de la filosofía. Buenos Aires: Editorial Paidós.',
    'ARENDT, H. (2007). La condición humana. Buenos Aires: Paidós.',
    'CABANCHIK, S. (2000). Introducción a la Filosofía. Barcelona:Gedisa.',
    'CARPIO, A. (2004). Principios de la Filosofia. Buenos Aires: Glauco.',
    'DUSSEL, E. (1998). Ética de la liberación. En la edad de la globalización y de la exclusión. Madrid: Totta.',
    'ELSTER, J. (1983). Uvas amargas. Sobre la subversión de la racionalidad. Barcelona: Peninsula.',
    'FEIMANN, J.P. (2006). Qué es la filosofía. Buenos Aires: Prometeo.',
    'FEITOSA, C. (2005). Cuestiones filosóficas - metodológicas. Noveduc.',
    'FOUCAULT, M. (1999). La arqueología del saber. México: Siglo XXI.',
    'GARCÍA CANCLINI, N. (1990). Culturas híbridas. Estrategias para entrar y salir de la modernidad, México: Grijalbo.',
    'HERLINGHAUS, H y WALTER, M. (1994). Posmodernidad en la periferia. Enfoques latinoamericanos de la nueva teoría cultural. Berlín: Langer.',
    'HERNANDEZ PACHECO, J. (1996). Corrientes actuales de filosofía. Madrid: Tecnos.',
    'KUSCH, R. (2011). Geocultura del hombre americano. Buenos Aires: Editorial Fundación Ross.',
    'LOBOSCO, M. (2005). Filosofía fuera de los muros. Buenos Aires: Noveduc. Nº169.',
    'ONFRAY, M. (2005). Antimanual de Filosofía. Lecciones socráticas y alternativas. Madrid: EDAF.',
    'RICHARD, N. (1994). Latinoamérica y la posmodernidad en: Herlinghaus/ Walter (eds.) Posmodernidad en la periferia.',
  ],
};

const _psicologiaeducacional = {
  'id': 'psicologia-educacional',
  'nombre': 'Psicología Educacional',
  'anio': 2,
  'formato': 'Asignatura',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'Esta unidad curricular tiene como principal objetivo aportar a los '
      'estudiantes una trama de conocimientos significativos para construir desde '
      'diferentes aproximaciones teóricas, conceptos y reflexiones acerca de los '
      'sujetos, su constitución, los modos de aprender, de conocer y de '
      'socializarse en diferentes escenarios educativos mostrando los alcances y '
      'límites de los diferentes modelos psicológicos y de aprendizaje29. Es '
      'necesario un debate profundo en la formación de los nuevos docentes que los '
      'lleve al conocimiento y a la reflexión sobre las transformaciones actuales y '
      'a los efectos de desubjetivación, observados en las nuevas formas de '
      'presentarse hoy las infancias, en las nuevas filiaciones de la identidades '
      'juveniles y en las configuraciones de los adultos. Es necesario recuperar '
      'los nuevos modos de producción de las subjetividades y delinear otros '
      'escenarios posibles, buscar nuevas narrativas escolares, analizar nuevos '
      'sentidos de historias, de representaciones, que posibiliten a los niños, '
      'jóvenes y adultos encontrar sus propias significaciones en las diferentes '
      'formas de transitar sus vidas. Pensar estas problemáticas desde la Formación '
      'General y desde la unidad curricular Psicología Educacional significa '
      'incluir nuevas perspectivas teóricas, categorías, conceptos y reflexiones '
      'para su análisis y un abordaje donde puedan entrecruzarse los aportes '
      'provenientes de los diferentes campos.',
  'ejes': [
    {
      'titulo':
          'El campo de las Psicologías: aportes y debates epistemológicos',
      'descripcion':
          'Abordajes según el campo, enfoques, teorías psicológicas, y sujetos '
          'que ellas definen. Historia de la relación psicología y educación: '
          'aplicacionismo y reduccionismo. Rupturas epistemológicas, '
          'continuidades y discontinuidades. Tensión entre la homogeneidad y la '
          'atención a la diversidad en la enseñanza escolar moderna. los diseños '
          'curriculares. Campo de la Formación General.',
    },
    {
      'titulo': 'El aprendizaje escolar: aportes desde las diferentes teorías',
      'descripcion':
          'Las particularidades del aprendizaje y la construcción de conocimiento '
          'en la escuela. Conocimiento cotidiano, escolar y científico. Enfoques '
          'generales sobre los procesos de enseñanza y aprendizaje. El proceso de '
          'aprendizaje: dimensiones afectivas, cognitivas, lingüística y social. '
          'Algunos criterios de progreso en el aprendizaje escolar: el desarrollo '
          'de formas “descontextualizadas” de uso de los signos y la creciente '
          'autonomía. Análisis de los dispositivos tipo “andamiaje”.',
    },
    {
      'titulo':
          'Problemas y perspectivas teóricas: desarrollo, aprendizaje y enseñanza',
      'descripcion':
          'Revisión de las perspectivas evolutivas. Critica a las visiones '
          'naturalistas del desarrollo. Las miradas centradas en el sujeto, la '
          'interacción y el desarrollo. El sujeto epistémico: la construcción de '
          'las estructuras cognoscitivas. Estructura y génesis y los factores del '
          'desarrollo de la inteligencia. El sujeto sociocultural: aprendizaje '
          'desde la perspectiva cognitiva. Los procesos de razonamiento, '
          'aprendizaje y cognición. Sujeto psíquico: constitución del aparato '
          'psíquico: de-constitución originaria, la alteridad constitutiva, la '
          'intersubjetividad. La constitución del sujeto como sujeto del deseo. '
          'Los procesos inconscientes implicados en la relación docente-alumno: '
          'procesos de transferencias, identificación, sublimación. Análisis y '
          'comprensión de las problemáticas afectivas y socio- afectivas que se '
          'suscitan en la relación docente - alumno.',
    },
    {
      'titulo':
          'Prácticas educativas: abordaje desde una perspectiva psicoeducativa',
      'descripcion':
          'El problema de la motivación y el desarrollo de estrategias de '
          'aprendizaje autorregulado. Las interacciones en el aula y los procesos '
          'de enseñanza y aprendizaje. La variedad de modalidades de interacción '
          'docente. Interacciones docente – alumnos y entre pares. Relación '
          'docente y alumno: asimetría y autoridad. Su influencia sobre la '
          'motivación y las posibilidades de apropiación e identificación. '
          'Concepciones sobre el fracaso escolar: aportes y discusiones.',
    },
  ],
  'bibliografia': [
    'AMBRAMOSKY, A. (2010). Maneras de querer. Los afectos docentes en las relaciones pedagógicas. Buenos Aires: Paidós.',
    'ARFUCH, L. Comp. (2005). Identidades, sujetos y subjetividades. Buenos Aires: Prometeo.',
    'AUGÉ, M. (1996). El sentido de los otros. Barcelona: Paidós.',
    '-------------- (2001). Los no lugares. Barcelona: Gedisa.',
    'BLEICHMAR, S. (2005). La subjetividad en riesgo. Buenos Aires: Topía.',
    'BOURHIS, R. Y LAYTUS J. comps (1996). Estereotipos, discriminación y relaciones entre grupos. Madrid: Mc Graw Hill.',
    'BRUNER J. (1984). Acción, pensamiento y lenguaje. Madrid: Alianza.',
    'BRUNER J. (1994). Realidad mental y mundo posibles. Barcelona: Gedisa.',
    'CARLI, S. comp. (1999). De la familia a la escuela. Infancia, socialización y subjetividad. Buenos Aires: Santillana.',
    'CALVO GARCIA, A. (1989). Cómo se mata a un niño para hacer un hombre. Asociación Antipatriarcal San Sebastián, Conferencia 26 de septiembre.',
    'FERRY, G. (1997). Pedagogía de la formación. Buenos Aires: Noveduc.',
    'FRIGERIO, G., DIKER G. comp. (2004). La transmisión en las sociedades, las instituciones y los sujetos. Buenos Aires: Noveduc.',
    'FRIGERIO G., DIKER G. comp. (2008). Educar: posiciones acerca de lo común. Buenos Aires: Del Estante editorial.',
    'FRIGERIO, G. y otros. (2002). Educar: rasgos filosóficos para una identidad. Buenos Aires: Santillana.',
    'FRIGERIO, G. (2004). Una ética en el trabajo con niños y adolescentes. La habilitación de la oportunidad. Buenos Aires: Ediciones. Noveduc.',
    'GARDNER, H. (1983). Teorías de la Inteligencias Múltiples. Buenos Aires: Paidós.',
    'GVIRTZ, S. comp. (2000). Textos para pensar el día a día escolar. Buenos Aires: Santillana.',
    'IMBERTI, J. comp. (2006). Violencia y escuela. Buenos Aires: Paidós.',
    'KINCHELOE y STIENBERG. (1999). Repensar el Multiculturalismo. España: Octaedro.',
    'LARROSA, J. y otros: (2001). Habitantes de Babel. Políticas y poéticas de la diferencia. Barcelona: Laertes.',
    'LARROSA, J. (1995). Escuela, Poder y Subjetivación. Madrid: Ediciones La Piqueta.',
    'MORIN, E. (2001). Los siete saberes necesarios para la educación del futuro. Bogotá: Cooperativa Editorial Magisterio.',
    'NUÑEZ, V. (1999). Pedagogía Social. Cartas para navegar el nuevo milenio. Buenos Aires: Santillana.',
    'NEUFELD, M. R. y J. A. THISTED comp (1999). De eso no se habla. Los usos de la diversidad sociocultural en la escuela. Buenos Aires: Eudeba.',
    'PERRENOUD, P. (1990). La construcción del éxito y del fracaso escolar. Madrid: Morata.',
    'POZO, J.J. (1989).Teorías cognitivas del aprendizaje. Madrid: Morata.',
    'PUIGGRÓS, A. y CAGLIANO, C. (2004). La fábrica del conocimiento. Los saberes socialmente productivos en América Latina. Rosario: Homo Sapiens.',
    'ROSBACO, I. (2003). Impacto de las políticas socioeconómicas en los procesos de desubjetivación en niños de contextos sociales vulnerables. Charla debate dictada en la Facultad de Trabajo Social. Paraná, Entre Ríos.',
    'SCHLEMENSON S. (1996). El aprendizaje: un encuentro de sentidos. Buenos Aires: Kapelusz.',
    'SKLIAR, C. (2005). La intimidad y la alteridad (Experiencias con la palabra). Buenos Aires: Miño y Dávila.',
    'VIGOTSKY L. (1995). Pensamiento y Lenguaje. Buenos Aires: Ediciones Fausto. Educación Sexual Integral Formato: Seminario - Taller Carga horaria: 2 horas cátedra semanales - 1 hora 20 minutos reloj semanales Régimen de cursado: Anual Marco Orientador Las políticas educativas vigentes consideran importante incluir en un proyecto curricular la educación sexual integral que articule aspectos epistemológicos, biológicos, psicológicos, socia- les, afectivos, éticos, religiosos, espirituales, jurídicos y pedagógicos. Pensar en una educación sexual integral, interdisciplinaria, es superar el reduccionismo biológico y ubicarla como un eslabón relacional dentro de las diferentes culturas. Es dialogar con otros saberes, provenientes de la antropología, de las historiografías, de la biología, de la sexología, de las ciencias de la salud, de la ética, de la sociología, de la política, buscando comprender cuáles son las formas y las modalidades de relación consigo mismo y con los otros, por las que cada uno se constituye y se reconoce como sujeto. Hoy se espera que cada docente pueda transmitir saberes sobre sexualidad. Para ello, durante la formación inicial, se hace necesaria la resignificación de los conocimientos acerca de la sexualidad y la genitalidad, de las conductas y prácticas sexuales, de las reglas y normas que se apoyan en instituciones religiosas, judiciales, pedagógicas y médicas, de las subjetividades producidas desde este campo, y, de ese modo, estar en condiciones de analizar los contextos a los que se ha asociado históricamente la sexualidad y las prácticas discursivas que se fueron construyendo sobre ella.',
  ],
};

const _educacionsexual = {
  'id': 'educacion-sexual',
  'nombre': 'Educación Sexual Integral',
  'anio': 2,
  'formato': 'Seminario - Taller',
  'cargaHoraria':
      '2 horas cátedra semanales - 1 hora 20 minutos reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'Las políticas educativas vigentes consideran importante incluir en un '
      'proyecto curricular la educación sexual integral que articule aspectos '
      'epistemológicos, biológicos, psicológicos, socia- les, afectivos, éticos, '
      'religiosos, espirituales, jurídicos y pedagógicos. Pensar en una educación '
      'sexual integral, interdisciplinaria, es superar el reduccionismo biológico y '
      'ubicarla como un eslabón relacional dentro de las diferentes culturas. Es '
      'dialogar con otros saberes, provenientes de la antropología, de las '
      'historiografías, de la biología, de la sexología, de las ciencias de la '
      'salud, de la ética, de la sociología, de la política, buscando comprender '
      'cuáles son las formas y las modalidades de relación consigo mismo y con los '
      'otros, por las que cada uno se constituye y se reconoce como sujeto. Hoy se '
      'espera que cada docente pueda transmitir saberes sobre sexualidad. Para '
      'ello, durante la formación inicial, se hace necesaria la resignificación de '
      'los conocimientos acerca de la sexualidad y la genitalidad, de las conductas '
      'y prácticas sexuales, de las reglas y normas que se apoyan en instituciones '
      'religiosas, judiciales, pedagógicas y médicas, de las subjetividades '
      'producidas desde este campo, y, de ese modo, estar en condiciones de '
      'analizar los contextos a los que se ha asociado históricamente la sexualidad '
      'y las prácticas discursivas que se fueron construyendo sobre ella. 77',
  'ejes': [
    {
      'titulo': 'Pluralidad de enfoques sobre la sexualidad',
      'descripcion':
          'Interpretaciones desde la sociología, antropología, historia y '
          'psicología. Enfoques actuales de la sexualidad. Represión, vigilancia, '
          'normalización. Maltrato, violencia familiar. Abuso sexual. Control y '
          'subordinación en las relaciones de género. Mercantilización.',
    },
    {
      'titulo':
          'Los saberes referidos a los cuerpos, la subjetividad y la sexualidad',
      'descripcion':
          'Educación y promoción de la salud. Autoestima. Vínculos '
          'interpersonales y grupales, el género como categoría relacional en la '
          'historia. Mandatos culturales. Roles y estereotipos.',
    },
    {
      'titulo': 'Educación sexual en la escuela',
      'descripcion':
          'La escuela como lugar de construcción de subjetividades. La sexualidad '
          'como parte de la condición humana. Medios de comunicación y '
          'sexualidad. Responsabilidades y derechos. Desarrollo de la confianza, '
          'libertad y seguridad. La educación sexual como temática transversal en '
          'la Educación Secundaria.',
    },
  ],
  'bibliografia': [
    'DARRE, S. (2005). Sobre políticas de género en el discurso pedagógico. Educación sexual en el Uruguay a través del siglo XX. Montevideo: Ediciones Trilce.',
    'FOUCAULT, M. (2006). Los anormales. Buenos Aires: FCE.',
    '---------------------- (2004). Historia de la sexualidad. Tomo 2: El uso de los placeres. Buenos Aires: Siglo XXI. 2º reimpresión.',
    'FREIRE, P. (1970). Pedagogía del oprimido. Montevideo: Tierra Nueva.',
    'GIBERTI, E; LA BRUNA DE ANDRA, L. (1993). Sexualidades: de padres a hijos. Preguntas y res- puestas inquietantes. Buenos Aires: Paidós.',
    'MARGULIS, My otros. (2003). Juventud, cultura, sexualidad. Dimensión cultural en la afectividad y la sexualidad de los jóvenes de Buenos Aires: Buenos Aires: Biblos.',
    'POMIÉS, J. (1995).Temas de sexualidad, informe para educadores. Buenos Aires: Aique.',
    'REYBET, C; HERNÁNDEZ, A. (2007). La/s sexualidad/es ¿tema de quiénes? En El Monitor de la Educación. Mar-abr 2007. Año 5, Nº 11.',
    'VILLA, A. (2007). Cuerpo, sexualidad y socialización. Intervenciones e investigaciones en salud y educación. Buenos Aires: Noveduc. Serie Interlíneas.',
  ],
};

const _sujetoseducacion = {
  'id': 'sujetos-educacion',
  'nombre': 'Sujetos de la Educación Secundaria',
  'anio': 2,
  'formato': 'Seminario',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales.',
  'regimenCursado': 'Anual',
  'tipo': 'Formación General',
  'marcoOrientador':
      'Para pensar el sujeto constituyéndose, es necesario hacer referencia a la '
      'subjetividad, a los modos o formas sociales, culturales, históricas y '
      'políticas, en el que él se interpreta y reconoce a sí mismo, como resultado '
      'de una trayectoria singular de experiencias vinculares con los otros. La '
      'subjetividad constituye un lugar desde el cual el sujeto es mirado, se mira '
      'y mira el mundo, de un modo particular. Desde la institución educativa, como '
      'lugar de encuentro entre distintos sujetos, se tienen que abrir debates en '
      'torno a la construcción de subjetividades, a los procesos de integración e '
      'inclusión socioeducativos, a las problemáticas contemporáneas que interpelan '
      'a docentes de todos los niveles educativos y contextos. De acuerdo con la '
      'estructura del diseño para la formación de docentes, esta unidad curricular '
      'pretende abordar y tensionar al sujeto de la educación desde múltiples '
      'miradas. La misma se enlaza con los aportes que las distintas disciplinas '
      'posibilitan desde el campo de la Formación General, con el campo de la '
      'Práctica, que es el eje integrador en este diseño curricular. La '
      'articulación se dará a partir de la reflexión sobre los sujetos del nivel, '
      'las aulas, las trayectorias escolares y la institución educativa en relación '
      'a la transmisión y a la enseñanza.',
  'ejes': [
    {
      'titulo':
          'Mirada desde la perspectiva socio-antropológica histórica y política',
      'descripcion':
          'La complejidad y diversidad de formas de representar y vivir las '
          'infancias, adolescencias, juventudes y adultez. La escolarización en '
          'el desarrollo socio histórico. Infancia y escuela: La escuela como '
          'dispositivo pedagógico.',
    },
    {
      'titulo':
          'Aprendizajes en distintos contextos de práctica social y especificidad del aprendizaje',
      'descripcion':
          'escolar.Subjetividades y multiculturalidad: problemáticas culturales y '
          'sociales, diversidad y desigualdad. Cuestiones de género. Nuevas '
          'configuraciones sociales, culturales, familiares y grupales. '
          'Subjetividades mediáticas.',
    },
    {
      'titulo':
          'Educación y subjetividad aporte desde las perspectivas psicológicas',
      'descripcion':
          'La psicológica educativa y sus aportes a la comprensión de la '
          'construcción de conocimiento. Enfoques socioculturales y la educación '
          'como factor inherente al desarrollo de los procesos psicológicos '
          'superiores. Las perspectivas cognitivas y el estudio del aprendizaje '
          'como cambio en las maneras en que la información es representada y '
          'procesada.Subjetividad: concepto, diferencias con el aparato psíquico. '
          'Lógicas de producción en la relación del sujeto y su otro. Las '
          'paradojas de la cultura entre la necesidad de exigir una renuncia '
          'pulsional y los sustitutos que arroja la cultura. El problema del '
          'inconsciente. Subjetividad y sostén: el lugar de las instituciones y '
          'los adultos en la constitución de la subjetividad.',
    },
    {
      'titulo': 'Sujetos, vínculos y aprendizaje escolar',
      'descripcion':
          'Representaciones de infancia, adolescencia-juventud y adultez que '
          'sustentan nuestras teorías y prácticas pedagógicas. La diversidad de '
          'las poblaciones escolares y el mandato de homogeneidad en la escuela. '
          'Sujetos en contextos educativos. El acceso a la Educación Secundaria '
          'en los diferentes contextos y modalidades - en nuestro país. La '
          'Transmisión, autoridad, memorias, tradición.',
    },
    {
      'titulo': 'Sujetos escolares y recorridos: trayectorias escolares',
      'descripcion':
          'Situación de la escolarización en los distintos niveles del sistema '
          'educativo argentino. Trayectorias escolares teóricas. Trayectorias '
          'reales: la detección de los puntos críticos. El problema del fracaso '
          'escolar masivo. El problema de transiciones educativas. Propuestas '
          'pedagógicas para acompañar las trayectorias escolares.',
    },
  ],
  'bibliografia': [
    'AUSUBEL, D. (2002). Adquisición y retención del conocimiento. Una perspectiva cognitiva. Barcelona: Paidós.',
    'BECK, R. (2006). La sociedad del riesgo. Barcelona: Paidós.',
    'BUTLER, J. (2006). Vida precaria. El poder del duelo y la violencia. Buenos Aires: Paidós.',
    'CASTORINA, J. A. (2005). “Las prácticas sociales en la formación del sentido común. La naturalización en la psicología”. En LLOMOVATTE, S. Y KAPLAN, C. comp Desigualdad educativa. La naturaleza como pretexto. Buenos Aires: Noveduc.',
    'CASTORINA, J. A. (1984). Psicología Genética. Aspectos Metodológicos e implicancias pedagógicas. Buenos Aires: Miño y Dávila.',
    'COREA, C y LEWKOWICZ, I. (1999). ¿Se acabó la infancia? Buenos Aires: LUMEN.',
    'COLE, M. (1999). Psicología cultural. Una disciplina del pasado y del futuro. Madrid: Morata.',
    'DOMINGO CURTO, J. M. (2005). La cultura en el laberinto de la mente. Aproximación filosófica a la Psicología Explicativa. Santiago de Chile: Oficina Regional de Educación de la',
    'UNESCO para América Latina y el Caribe (OREALC/UNESCO).',
    'FERREIRO, E. (1999). Vigencia de Jean Piaget. México: Siglo XXI.',
    'GARCÍA, R. (2000). El conocimiento en construcción. De las formulaciones de Jean Piaget a la teoría de sistemas complejos. Barcelona: Gedisa.',
    'JACINTO, C. y TERIGI, F. (2007). ¿Qué hacer ante las desigualdades en la educación secundaria? Buenos Aires: Santillana/ IIPE- UNESCO sede regional Buenos Aires.',
    'HASSOUN, J. (1996). Los contrabandistas de la memoria. Ediciones de la Flor.',
    'KESSLER, G. (2004). Sociología del delito amateur. Buenos Aires: Paidós.',
    'KINCHELOE J. Y STIEMBERG, R. (1999). Pensar el Multiculturalismo. España: Octaedro.',
    'KOZULIN, A. (2000). Instrumentos psicológicos. La educación desde una perspectiva sociocultural. Barcelona: Paidós.',
    'MORGADE, G. y ALONSO, G. (2008). Cuerpos y sexualidades en la escuela: de la normalidad a la disidencia. Buenos Aires: Paidós.',
    'NAJMANOVICH, D. (2005). El juego de los vínculos. Subjetividad y redes: figuras en mutación. Buenos Aires: Biblos.',
    'NOVAK, J. (1997). Teoría y práctica de la educación. Madrid: Alianza.',
    'PINEU, P. (2001). La escuela como máquina de educar: tres escritos sobre un proyecto de la modernidad. Buenos Aires: Paidós.',
    'RACEDO, J. y REQUEJO, M.I. (2004). Patrimonio cultural e identidad. Buenos Aires: Cinco.',
    'ROSBACO, I. (2000). El desnutrido escolar. Dificultades de aprendizaje en los niños de contextos de pobreza urbana. Rosario: Homo Sapiens.',
    'ROSSANO, A. (2006). El pasaje de la primaria a la secundaria como transición educativa. En TERIGI, F. comp. Diez miradas sobre la escuela primaria. Buenos Aires: Siglo XXI.',
    'SUSINOS RADA, T. y CALVO SALVADOR A. (2005). Yo no valgo para estudiar…. Un análisis crítico de la narración de las experiencias de exclusión social. En: Contextos Educativos, 8-9 (2005-2006), pp. 87-106.',
    'TERIGI, F. (2004). La aceleración del tiempo y la habilitación de la oportunidad de aprender. En AAVV.',
    '-------------- (2008). Los desafíos que plantean las trayectorias escolares. En DUSSEL, I et al (2008), Jóvenes y docentes en el mundo de hoy. Buenos Aires: Santillana. Pp. 161/178.',
    '-------------- (2009). Las trayectorias escolares: del problema individual al desafío de política educativa. Proyecto Hemisférico Elaboración de Políticas y Estrategias para la Prevención del Fracaso Escolar. Organización de Estados Americanos (OEA) / Agencia Interamericana para la Cooperación y el Desarrollo (AICD). Buenos Aires: Ministerio de Educación de la Nación.',
    'VIGOTSKY, L. (1988). El desarrollo de los procesos psicológicos superiores. México: Crítica Grijalbo.',
    'WERTSCH, J. (1999). La mente en acción. Buenos Aires: Aique.',
  ],
};

const _procesosfeudalismomodernidad = {
  'id': 'procesos-feudalismo-modernidad',
  'nombre':
      'Procesos Sociales, Políticos, Económicos y Culturales del Feudalismo y la Modernidad',
  'anio': 2,
  'formato': 'Asignatura',
  'cargaHoraria':
      '4 horas cátedras semanales - 2 horas 40 minutos reloj semanales',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular propone el abordaje de los contextos asiático, '
      'africano y europeo desde el S. VI al S. XVIII en relación a las '
      'organizaciones sociopolíticas que fueron surgiendo en estos espacios sin '
      'perder de vista los cambios económicos que van a ir generando sistemas '
      'dominantes. Como así también el surgimiento de la cultura europea que '
      'impactará sobre los nuevos territorios incorporados a los imperios. En el '
      'recorrido temporal y espacial se van a ir generando cambios y continuidades; '
      'sociedades muy dispares que deberán ser comprendidas integrando los enfoques '
      'propuestos en los ejes. El contexto europeo se va a ir transformando en una '
      'cultura dominante que se va a expandir desde el S. XIV hacia otras '
      'periferias motivadas por el crecimiento y fortalecimiento de la economía de '
      'los Estados Modernos. La propuesta permite la integración de los contenidos '
      'a partir del análisis de la bibliografía así como la incorporación de obras '
      'de arte y literarias que permitirán un acercamiento al pensamiento de las '
      'distintas sociedades tanto en lo político como en lo económico, social y '
      'cultural.',
  'ejes': [
    {
      'titulo':
          'Organización y desarrollo de las relaciones sociales de sujetos que conforman',
      'descripcion':
          'procesos históricos complejos, coherentes y contradictorios: Comunidad '
          'Doméstica, Feudalismo y relaciones de los estamentos sociales. '
          'Revueltas campesinas. La sociedad estamental. La aristocracia, la '
          'burguesía y los grupos subalternos urbanos en la Europa Moderna.',
    },
    {
      'titulo':
          'Formas de organización de la subsistencia y la reproducción de la sociedad',
      'descripcion':
          'Feudalismo, Mercantilismo y Capitalismo. De la economía de '
          'subsistencia al comercio de larga distancia. La economía-mundo. '
          'Expansión y dominio occidental.',
    },
    {
      'titulo':
          'Constitución de lo político y la política en las sociedades hacia la modernidad: El',
      'descripcion':
          'feudalismo como orden político-institucional y como formación socio- '
          'económica. De la fragmentación a la centralización del Poder. El '
          'Estado Moderno.',
    },
    {
      'titulo':
          'Construcción de los sentidos y significados sobre la propia existencia y sobre el',
      'descripcion':
          'mundo: Fe y Poder; la Iglesia medieval y la expansión del '
          'cristianismo. Crisis del feudalismo y su impacto en las mentalidades. '
          'El Islam. La conquista de la realidad: Humanismo y Renacimiento. El '
          'Barroco. Intercambios de ciencia y tecnología entre el “mundo '
          'occidental y oriente”. La Reforma.',
    },
  ],
  'bibliografia': [
    'ANDERSON, P. (1992). El Estado Absolutista. Madrid: Siglo XIX.',
    'ARIES, P. y DUBY G. (1992). Historia de la vida privada. Madrid: Taurus.',
    'BARK, W. (1978). Orígenes del mundo medieval. Buenos Aires: Eudeba.',
    'BIANCHI, S. (2011). Historia Social del Mundo Occidental. Buenos Aires: UNQ.',
    'BOIS, G. (1990). La revolución del año mil. Barcelona: Crítica.',
    'BONNASSIE, P. (1983). Del esclavismo al feudalismo en Europa Occidental. Barcelona: Crítica.',
    'BRAUDEL, F. (1998). Las civilizaciones actuales. Madrid: Tecnos.',
    'BRAUDEL, F. (1991). Carlos V y Felipe II. Buenos Aires: Centro editor de América Latina.',
    'CAHEN, C. (1989). El Islam. Desde los orígenes hasta el comienzo del Imperio Otomano. Madrid: Siglo XXI.',
    'CHAUNU, P. (1973). La expansión europea. Barcelona: Labor.',
    'DAVIS, R. (1998). La Europa Atlántica. Madrid: Siglo XXI.',
    'DELUMEAU, J. (1973). El Catolicismo de Lutero a Voltaire. Barcelona: Labor.',
    'DOBB, M. (1971). Estudios sobre el desarrollo del capitalismo. Madrid: Siglo XXI.',
    'DOMINGUÉZ ORTÍZ A. (1983). La Historia Universal. Edad Moderna. España: Vicens Universidad.',
    'DUBY, G. (1977). Guerreros y campesinos. Desarrollo inicial de la economía europea 500– 1200. Historia Económica Mundial. Madrid: Siglo XXI.',
    'DUBY, G. (1997). Hombres y estructuras de la Edad Media. Madrid. Siglo XXI.',
    'DUBY, B. Dir. (2001). Historia de la vida privada. Madrid: Taurus.',
    'ELLIOT, J. (1986). La España Imperial. 1469 - 1716. España: Vicens Vives.',
    'FLORISTÁN, A. (2005). Historia Moderna Universal. España: Ariel.',
    'GARCÍA DE CORTAZAR, J. M. Y SESMA MUÑOZ, J. A. (1999). Historia de la Edad Media. Una síntesis Interpretativa. Madrid: Alianza.',
    'HILTON, R. (1998). Conflictos de clases y crisis del feudalismo. Barcelona: Crítica.',
    'HOBSBAWM, E. (1998). Sobre la Historia. Barcelona: Crítica.',
    'KINDER, H., HILGEMANN, W. (1992). Atlas histórico mundial. España: ISTMO.',
    'LE GOFF, J. (1985). Lo maravilloso y lo cotidiano en el occidente medieval.Barcelona: Gedisa.',
    'MUNCK, T. (2001). Historia Social de la Ilustración. Barcelona: Crítica.',
    'OLDENBOURG, Z. (1975). Las cruzadas. España: Destino.',
    'PARAIN CH., VILAR P. (1985). El feudalismo. España: Hispanoamérica.',
    'PARRY, J. (1975). Europa y la Expansión del Mundo. México: FCE.',
    'PIRENNE, H. (1979). Mahoma y Carlomagno. Madrid: Alianza.',
    'POUNDS, N. (1984). Historia Económica de la Europa Medieval. Barcelona: Crítica.',
    'ROMERO, J. (1997). La crisis del mundo burgués. Buenos Aires: FCE.',
    'ROMERO, J. (1999). Estudio de la mentalidad burguesa. Argentina: Alianza.',
    'SCHULZE H. (1997). Estado y Nación en Europa. España: Crítica.',
    'TENENTI, A. (1985). La Formación del Mundo Moderno. España: Crítica.',
    'UBIERNA, P. (2007). El mundo mediterráneo en la Antigüedad tardía, 300-800 d. C. Buenos Aires: Eudeba.',
    'ULLMAN, W. (1983). Historia del pensamiento político en la Edad Media. Barcelona: Ariel.',
    'VAN DÜLMEN, R. (1984). Los Inicios de la Europa Moderna. Madrid: Siglo XIX.',
  ],
};

const _procesosamericanos1 = {
  'id': 'procesos-americanos-1',
  'nombre':
      'Procesos Sociales, Políticos, Económicos y Culturales Americanos I',
  'anio': 2,
  'formato': 'Asignatura',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales.',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Se propone un recorrido desde la conquista y colonización del espacio '
      'americano por parte de los estados monárquicos europeos y la relación de '
      'estos con los recursos naturales de América, así como los cambios y '
      'transformaciones que se fueron generando en las sociedades de pueblos '
      'originarios entre el S. XV hasta principios del S. XIX. De la misma forma, '
      'se propone el análisis de las representaciones que se fueron configurando en '
      'las sociedades en torno a lo simbólico, científico, ideológico y religioso, '
      'las cosmovisiones que fueron surgiendo en toda América y las relaciones de '
      'esto con el poder imperante tanto en Latinoamérica como América Anglosajona. '
      'Asimismo, se propone realizar el estudio de la conquista del territorio '
      'americano desde las distintas miradas que se han ido planteando desde el S. '
      'XV hasta el presente, ya que, además de conocer los acontecimientos, esto '
      'permitirá comprender las miradas que han realizado los historiadores acerca '
      'de los mismos.',
  'ejes': [
    {
      'titulo':
          'Relaciones y configuraciones sociales en relación a lo político y la política',
      'descripcion':
          'Las sociedades americanas y el impacto de la conquista y expansión '
          'europea: cambios y continuidades. La ocupación española y la ocupación '
          'portuguesa: transportación política y sus consecuencias '
          'socioculturales. La expansión británica: compañías y propietarios. El '
          'mestizaje. La esclavitud. Organización y conflictos de la sociedad. El '
          'orden colonial. Impacto de la Revolución Atlántica. Crisis y reformas '
          'en el contexto americano hacia el S. XVII. Cambios y continuidades de '
          'lo político en América. Construcción y representación de la sociedad '
          'en torno a lo simbólico, científico, ideológico y religioso '
          'Construcción de una cosmovisión diferente a partir de nuevas prácticas '
          'y representaciones culturales de pueblos originarios y europeos. '
          'Mecanismos de dominación. Accionar de los europeos a través de la '
          'imposición de prácticas culturales y las resistencias de los pueblos '
          'originarios. El debate acerca de la conquista y la colonización y su '
          'impacto en los pueblos originarios.',
    },
    {
      'titulo':
          'Utilización de los recursos naturales y organización de la subsistencia de las',
      'descripcion':
          'sociedades en América Reestructuración y resignificación de los '
          'espacios socio-económicos. El espacio americano incorporado a la '
          'economía-mundo. Impacto del dominio y la explotación. Periferia – '
          'centro y la organización de los nuevos territorios americanos: '
          'variedad de actividades económicas a partir de la utilización de los '
          'recursos naturales. Ciclos productivos.',
    },
  ],
  'bibliografia': [
    'ALLEN, H. (1975). Historia de los Estados Unidos. Buenos Aires: Paidós.',
    'ARGUMEDO, A. (2001). Los silencios y las voces de América Latina. Notas sobre el pensamiento nacional y popular. Buenos Aires: Ediciones del Pensamiento.',
    'BETHELL, L. (ed.) (1990). Historia de América Latina. Cambridge University Press y Barcelona: Crítica.',
    'CARMAGNANI, M., HERNÁNDEZ CHÁVEZ y RUGGIERO R. Coord. (1999). Para una historia de América. México: Fondo de Cultura Económica.',
    'CICERCHIA, R. (1998). Historia de la vida privada en la Argentina. Buenos Aires: Troquel.',
    'GONZALEZ CASANOVA, P. Comp. (1985). Historia política de los campesinos latinoamericanos. México: Siglo XXI.',
    'HALPERINDONGHI, T. (1990). Historia contemporánea de América Latina. México: Alianza.',
    'HARRIS, O., BROOKE L. y TANDETER, E. Comps (1987). La participación indígena en los mercados sur-andinos. Estrategias y reproducción social. Siglos XVI a XX.La Paz: Ceres.',
    'HENRIQUE CARDOZO F. (1969). Dependencia y desarrollo en América Latina. México: Siglo XXI.',
    'KONETZKE, R. (1979). América Latina II. La época colonial. México: Siglo XXI.',
    'LABASTIDA MARIN DEL CAMPO, J. (1986). Dictaduras y dictadores. México: Siglo XXI.',
    'LACLAU, E. (1978). Política e ideología en la teoría marxista. Capitalismo, fascismo ypopulismo.México: Siglo XXI.',
    'LYNCH, F. (1976). Las revoluciones hispanoamericanas, 1808-1826. Barcelona: Ariel.',
    'MONTANER, C. (2001). Las raíces torcidas de América Latina. España: Plaza Janés. O\'DONNELL, G. (1972). Modernización y autoritarismo. Buenos Aires: Paidós.',
    'RIBEIRO, D. (1985). Las Américas y la Civilización. Buenos Aires: Centro Editor de América Latina.',
    'TODOROV, T. (1987). La Conquista de América. La cuestión del otro. México: Siglo XXI.',
    'VIVES, V. (1979). Historia Social y económica de España y América. Barcelona: VicensVives. Historia de las Ideas II Formato: Seminario. Carga horaria: 3 horas cátedra semanales - 2 horas reloj semanales. Régimen de cursado: Anual Marco Orientador La propuesta de esta unidad curricular se sustenta en el formato de seminario a partir de dos ejes, el primero aborda un recorrido por las ideologías dominantes en occidente a partir del XVI hasta la actualidad y el impacto que esto ocasiona en las relaciones y manifestaciones sociales. En el segundo eje, se realiza un recorte espacio-temporal a partir de la teoría abordada previamente, proponiéndose el análisis de las ideologías en Argentina y su impacto en la sociedad a lo largo del siglo XIX y XX. De esta manera estos contenidos deberán generar propuestas metodológicas que promuevan la indagación, la discusión, análisis y posterior socialización de lo investigado en torno a la temática. Esta modalidad permite que los estudiantes comiencen a trabajar desde una perspectiva metodológica con estrategias del campo de la investigación. El recorrido puede iniciarse de acuerdo a los fundamentos que los docentes establezcan, pues los contenidos propuestos permiten iniciar el mismo desde la modernidad a la realidad de la sociedad argentina en la que está inmersa el estudiante cotidianamente. Lo significativo será acercarse al presente y al pasado como un actor social crítico, desde un marco normativo que nos sostiene como sociedad. Ejes de contenidos Líneas del pensamiento contemporáneo desde la modernidad Ideologías dominantes en occidente desde el S. XVI a la actualidad. Ideologías críticas al sistema liberal y al capitalismo. Manifestaciones ideológicas en el S. XX y S. XXI y su impacto en la sociedad y la cultura. Los Derechos Humanos y la necesidad de establecerlos a mediados del S. XX.',
  ],
};

const _historiaideas2 = {
  'id': 'historia-ideas-2',
  'nombre': 'Historia de las Ideas II',
  'anio': 2,
  'formato': 'Seminario',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales.',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'La propuesta de esta unidad curricular se sustenta en el formato de '
      'seminario a partir de dos ejes, el primero aborda un recorrido por las '
      'ideologías dominantes en occidente a partir del XVI hasta la actualidad y el '
      'impacto que esto ocasiona en las relaciones y manifestaciones sociales. En '
      'el segundo eje, se realiza un recorte espacio-temporal a partir de la teoría '
      'abordada previamente, proponiéndose el análisis de las ideologías en '
      'Argentina y su impacto en la sociedad a lo largo del siglo XIX y XX. De esta '
      'manera estos contenidos deberán generar propuestas metodológicas que '
      'promuevan la indagación, la discusión, análisis y posterior socialización de '
      'lo investigado en torno a la temática. Esta modalidad permite que los '
      'estudiantes comiencen a trabajar desde una perspectiva metodológica con '
      'estrategias del campo de la investigación. El recorrido puede iniciarse de '
      'acuerdo a los fundamentos que los docentes establezcan, pues los contenidos '
      'propuestos permiten iniciar el mismo desde la modernidad a la realidad de la '
      'sociedad argentina en la que está inmersa el estudiante cotidianamente. Lo '
      'significativo será acercarse al presente y al pasado como un actor social '
      'crítico, desde un marco normativo que nos sostiene como sociedad.',
  'ejes': [
    {
      'titulo': 'Líneas del pensamiento contemporáneo desde la modernidad',
      'descripcion':
          'Ideologías dominantes en occidente desde el S. XVI a la actualidad. '
          'Ideologías críticas al sistema liberal y al capitalismo. '
          'Manifestaciones ideológicas en el S. XX y S. XXI y su impacto en la '
          'sociedad y la cultura. Los Derechos Humanos y la necesidad de '
          'establecerlos a mediados del S. XX.',
    },
    {
      'titulo': 'Líneas de pensamiento en la Argentina',
      'descripcion':
          'Educación ética-política. Ideologías en Argentina desde el S. XIX '
          'hasta la actualidad. Construcción de una política argentina. La '
          'formación de la ciudadanía y la democracia en Argentina. Afianzamiento '
          'de la democracia como sistema de político y como estilo de vida. '
          'Defensa de los Derechos Humanos a partir del Terrorismo de Estado. '
          'Constitución Nacional y Provincial: fundamentos ideológicos. y Carta '
          'Orgánica Municipal.',
    },
  ],
  'bibliografia': [
    'ADAMS, W. (1984). Los Estados Unidos de América. México: Siglo XXI.',
    'ANDERSON, P. (1979). El estado absolutista. Madrid: Siglo XXI.',
    'ARENDT, H. (1997). ¿Qué es la política? Barcelona: Paidós.',
    'BAUMAN, Z. (2001). En busca de la política. Buenos Aires: FCE.',
    'BOBBIO, N. (1991). Diccionario de política. México: Siglo XXI.',
    'BOBBIO, N. (1999). Ni con Marx, ni contra Marx.México: FCE.',
    'BORON, A. (Comp.) (2001). La filosofía política moderna. De Hobbes a Marx. Buenos Aires: Eudeba.',
    'BOURGEOIS, B. (1974). El pensamiento político de Hegel. Buenos Aires: Amorrortu.',
    'CARIDE, J. Coord. (2009). Los derechos humanos en la educación y la cultura. Del discurso político a las prácticas educativas. Rosario: Homo Sapiens.',
    'DI TELLA, T. y otros (2004). Diccionario de Ciencias Sociales y Políticas. Buenos Aires: Planeta Ariel.',
    'DUHALDE, E. (1999). El estado terrorista Argentino. Quince años después, una mirada crítica. Buenos Aires: Eudeba.',
    'DUSSEL, I.; FINOCCHIO, S.; GOJMAN S. (2003). Haciendo memoria en el país de nunca más. Buenos Aires: Eudeba.',
    'ECCLESHALL, R. y otros (1993). Ideologías Políticas. Madrid: Tecnos.',
    'COMISIÓN SOBRE LA DESAPARICIÓN DE PERSONAS. (1984). Nunca Más. Buenos Aires: Eudeba.',
    'LERNER, D., STELLA P. TORRES M. (2009). Formación docente en lectura y escritura. Recorridos didácticos. Buenos Aires: Paidós.',
    'MILSTEIN, D. (2009). La nación en la escuela, Viejas y nuevas políticas. Buenos Aires: Miño y Davila.',
    'PALMA, H., PARDO R. (2012). Epistemología de las ciencias sociales. Perspectivas y problemas de las representaciones científicas de lo social. Buenos Aires: Biblos.',
    'SABINE, G. (1994). Historia de la teoría Política. México: FCE.',
    'SCHMITT, C. (1999). El concepto de lo político.Madrid: Alianza.',
    'TOUCHARD, J. (2000). Historia de las ideas políticas. Madrid: Tecnos.',
  ],
};

const _mundoterritorialidades = {
  'id': 'mundo-territorialidades',
  'nombre': 'El Mundo y las Nuevas Territorialidades',
  'anio': 2,
  'formato': 'Asignatura',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales.',
  'regimenCursado': 'Anuall',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular, propuesta como asignatura, propone un acercamiento '
      'de lo histórico relacionando conceptos y categorías con otras ciencias, como '
      'la economía, política y geografía. Esto permitirá realizar un recorrido por '
      'los contenidos desde categorías como Sistemas Económicos; Formas de '
      'gobierno; Territorio; Espacio urbano; Espacio rural; Migraciones y Bloques '
      'económicos. El objetivo es poder analizar temáticas de la actualidad con una '
      'mirada histórica y comprender los cambios que se van produciendo en los '
      'espacios en donde el hombre ha intervenido a lo largo de la historia a '
      'través de la expansión, la conquista, las guerras, las migraciones, los '
      'acuerdos o las alianzas entre otros aspectos. De este modo, los ejes '
      'propuestos van interactuando entre lo espacial del mundo y Latinoamérica y '
      'se pretende que al construir una mirada sobre la actualidad, el docente '
      'accederá a una amplia variedad de recursos digitales, estos deberán ser '
      'incorporados a los procesos de enseñanza y aprendizaje de los estudiantes, '
      'pues los recursos virtuales y digitales son muy amplios para conocer, '
      'analizar y comprender las definiciones de las nuevas territorialidades en '
      'diversas partes del mundo.',
  'ejes': [
    {
      'titulo': 'Conjuntos espaciales',
      'descripcion':
          'La representación de la superficie terrestre. Variables cartográficas. '
          'Sistemas de Teledetección y Sistemas de Información Geográfica. Las '
          'bases naturales de los continentes. Organización del mapa político '
          'mundial, cambios y continuidades. Los conflictos socio-territoriales '
          'en el marco de la globalización.',
    },
    {
      'titulo':
          'El mapa político de América: cambios y continuidades. Territorios independientes y',
      'descripcion':
          'dependientes y la convivencia de las Américas. Alianzas y acuerdos '
          'internacionales',
    },
    {
      'titulo': 'Espacio rural y urbano',
      'descripcion':
          'Lo rural y lo urbano. El campo y la ciudad, diferenciación de los '
          'espacios: ritmos y características socio-demográficas. Migraciones. '
          'Espacios rurales: estructura agraria, modelos productivos y sociedades '
          'campesinas. La ciudad, representaciones y conceptos. Las ciudades '
          'constituidas a través del tiempo. Las ciudades globales: capitalismo, '
          'tecnologías, mercados y pobreza. Espacios rurales en Latinoamérica: '
          'estructura agraria, modelos productivos y sociedades campesinas. El '
          'campo y la ciudad: corrientes migratorias en América Latina. La ciudad '
          'y la responsabilidad del estado de cubrir las necesidades básicas de '
          'la población.',
    },
    {
      'titulo': 'Problemáticas espaciotemporales',
      'descripcion':
          'La población en Europa: el envejecimiento y las migraciones '
          'extracontinentales. La población en África: los cambios socio- '
          'políticos originados entre 1989-1999; movimientos sociales y '
          'conflictos socio-territoriales. La ocupación de Oceanía. Las '
          'sociedades tradicionales. La Commonwealth, las colonias, ensayos '
          'independentistas y Nuevos países. El complejo proceso de integración '
          'social de las comunidades autóctonas. La Antártida, formas de '
          'ocupación y disputa. Impacto de los problemas ambientales en las '
          'sociedades americanas.',
    },
  ],
  'bibliografia': [
    'ASTORI, D. (1984). Controversias sobre el agro latinoamericano. Buenos Aires: CLACSO.',
    'CHALIAND, G y RAGEAU, J. (1983). Atlas estratégico y geopolítico. Argentina: Alianza.',
    'CORAGGIO, J. (1993). Economía popular y pobreza en la construcción de la ciudad. Quito: Instituto Frónesis.',
    'CUNILL GRAU, P. (1995). Las transformaciones del espacio geohistórico latinoamericano. 1930-1990.México: F.C.E.',
    'FURTADO, C. (1986). La economía latinoamericana. Formación histórica y problemas contemporáneos. México: Siglo XXI.',
    'GUIDENS, A. (1995). Tiempo, espacio y regionalización. Argentina: Amorrortu.',
    'HARVEY, D. (1990). La condición de la posmodernidad. Argentina: Amorrortu.',
    'IURNO, G. CRESPO E. y BAEZA B. (2008).Nuevos espacios, nuevos problemas. Los territorios nacionales. Argentina: Educo.',
    'KOROL, J. y TANDETER, E. (1998). Historia económica de América latina. Problemas y recursos. Buenos Aires: F.C.E.',
    'LINDON, A. y HIERNAUX, D. (2006). Tratado de Geografía Humana. México Anthropos.',
    'LINDON, A. y HIERNAUX, D. (2010). Los giros de la geografía humana. Desafíos y horizontes. México: Anthropos.',
    'OLIVIER, S. (1988). Ecología y subdesarrollo en América Latina. Buenos Aires: Siglo XXI.',
    'OZLAK, O. (1986). Formación histórica del estado en América Latina: elementos teórico- metodológicos para su estudio .Buenos Aires: CEDES.',
    'ROE CRONE, G. (1998). Historia de los mapas. Argentina: FCE.',
    'ROFMAN, A. y ROMERO L. (1997). Sistema socioeconómico y estructura regional en la Argentina. Buenos Aires: Amorrortu.',
    'ROMERO, J. (2008). Latinoamérica, las ciudades y las ideas. Buenos Aires: Siglo XXI.',
    'ROUQUIÉ, A. (1990). Extremo Occidente: introducción a América Latina. Buenos Aires:',
    'EMECE.',
    'SANTOS, M. (1990). Por una geografía nueva. Madrid: Espasa Calpe.',
    'SANTOS, M. (1996). Metamorfosis del espacio habitado. Barcelona: Oikos-tau.',
    'SANTOS, M. (2000). La naturaleza del Espacio. Barcelona: Ariel Geografía.',
    'SUNKEL O. (1984). El subdesarrollo latinoamericano y la teoría del desarrollo. México: Siglo',
    'XXI.',
    'SVAMPA, M.; BOTTARO, L. y ALVAREZ, M. (2009). La problemática de la minería metalífera a cielo abierto: modelo de desarrollo, territorio y discursos dominantes. Buenos Aires: Biblos.',
    'SVAMPA, M. y PEREYRA, S. (2003). Entre la ruta y el barrio. La experiencia de las organizaciones piqueteros. Buenos Aires: Biblos.',
    'TAYLOR, P. (2002). Geografía política: economía mundo, estado nación y localidad. España: Trama.',
    'WILLIAMS, R. (2011). El campo y la ciudad. Argentina: Paidós.',
  ],
};

const _economiapolitica = {
  'id': 'economia-politica',
  'nombre': 'Economía Política',
  'anio': 2,
  'formato': 'Seminario',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales.',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Este seminario propone una relación con Historia de las Ideas I y II, así '
      'como una interacción entre diferentes estudiantes Ciencias Sociales, ya que '
      'el abordaje de estas temáticas permitirán que los fortalezcan sus '
      'constructos mentales y generen nuevas relaciones en base al conocimiento '
      'histórico desde lo social, político, económico y cultural. Se propone '
      'trabajar dos ejes, el primero en relación a la Economía, donde se establecen '
      'conceptos básicos para la interpretación de los sistemas económicos '
      'imperantes en diferentes etapas históricas. El segundo eje planteado desde '
      'la Política como ciencia, se establecen conceptos básicos para una lectura '
      'crítica de diversos contextos institucionales, el rol de la sociedad y las '
      'definiciones políticas realizadas por los gobernantes.',
  'ejes': [
    {
      'titulo': 'La mirada de la Economía',
      'descripcion':
          'Concepto. La economía como ciencia. Su objeto de estudio y '
          'clasificación. Actores económicos: circuito económico. Los sistemas '
          'económicos y la relación Estado - Mercado. Significación de la '
          'historia de la economía política en el conocimiento histórico. Las '
          'fases de los diferentes Ciclos económicos. Evolución del pensamiento '
          'económico: El período clásico. El ideario socialista y la Segunda '
          'Revolución Industrial. El pensamiento económico neoclásico. El '
          'estructuralismo latinoamericano: ideas y posturas.',
    },
    {
      'titulo': 'La Política como disciplina',
      'descripcion':
          'El lugar de lo político y la política en las sociedades '
          'contemporáneas. La relación Política y poder en las sociedades '
          'contemporáneas. Las características y funciones del Estado en la '
          'actualidad. Lar relación Estado-Sociedad Civil. La Democracia como '
          'forma de gobierno y como estilo de vida: roles de la ciudadanía, su '
          'representación y la participación política. El sistema de partidos en '
          'la Argentina. Gobierno y sistemas de gobierno. Parlamentarismo, '
          'presidencialismo.',
    },
  ],
  'bibliografia': [
    'ARENDT, H. (1997). ¿Qué es la política? Barcelona: Paidós.',
    'BAUMAN, Z. (2001). En busca de la política. Buenos Aires: Fondo de Cultura Económica.',
    'BOBBIO, N. (1991). Diccionario de política. México: Siglo XXI.',
    'BOBBIO, N. (1999). Ni con Marx, ni contra Marx. México: FCE.',
    'BORON, A. Comp. (2001). La filosofía política moderna. De Hobbes a Marx. Buenos Aires: Eudeba.',
    'BRAUDEL, F. (1970). Las civilizaciones actuales. Estudio de historia económica y social. Madrid: Tecnos.',
    'BULMER THOMAS, V. (1998). La Historia Económica de América Latina desde la independencia. Buenos Aires: FCE.',
    'BOURGEOIS, B. (1974). El pensamiento político de Hegel. Buenos Aires: Amorrortu.',
    'COLE, G. (1973). Introducción a la Historia Económica. México: F.C.E.',
    'CRESPO, R. (1998). Las crisis de las teorías económicas liberales. Problemas de los enfoques neoclásicos y austríacos. Buenos Aires: Fundación Banco Boston.',
    'DI TELLA, T. y otros. (2004). Diccionario de Ciencias Sociales y Políticas. Buenos Aires: Planeta Ariel.',
    'ECCLESHALL, R. y otros. (1993). Ideologías Políticas. Madrid: Tecnos.',
    'EKELUND, R, HERBERT R. (1992). Historia de la teoría económica y de su método. Madrid: Mc Graw Hill.',
    'FERNÁNDEZ LÓPEZ, M. (1998). Historia del pensamiento económico. Buenos Aires: A-Z editora.',
    'FOREMAN PECK, J. (S/D). Historia Económica Mundial. Madrid: Prentice Hall.',
    'GALBRAITH, J. (1983). El dinero. De dónde vino. A dónde fue Argentina. Argentina: Hyspamérica.',
    'LEVÍN, P. (1997). El Capital Tecnológico, Buenos Aires: Eudeba - Catálogos.',
    'LAGUJIE, J. (1970). Los Sistemas Económicos. Buenos Aires: Eudeba.',
    'RAPOPORT, M. (2006). Historia económica, política y social de la Argentina (1880- 2003).Buenos Aires: Ariel.',
    'SABINE, G. (1994). Historia de la teoría Política. México: FCE.',
    'SCHMITT, C. (1999). El concepto de lo político. Madrid: Alianza Editorial.',
    'SCREPANTI, E. y ZAMAGNI, S. (1993). Panorama de Historia del Pensamiento Económico. Barcelona: Ariel Economía.',
    'TORRES LÓPEZ, J. (2005). Economía Política. Madrid: Ediciones Pirámide.',
    'TOUCHARD, J. (2000). Historia de las ideas políticas. Madrid: Tecnos.',
    'VAZQUEZ PRESEDO, V. (1996).Globalización, Integración, Argentina, Brasil. Buenos Aires: Academia Nacional de Ciencias Económicas. Didáctica de las Ciencias Sociales Formato: Seminario Carga horaria: 3 horas cátedra semanales - 2 horas reloj semanales. Régimen de cursado: Anual Marco Orientador Esta unidad curricular propone el abordaje de los contenidos desde el formato de seminario, un recorrido por los fundamentos teóricos para la construcción de herramientas conceptuales desde diferentes miradas de la Didáctica de las Ciencias Sociales, deberá estar en constante discusión con la Práctica Profesional así como el resto de las unidades curriculares desde primero y segundo año. El estudiante deberá aprender a relacionar y entrecruzar el ¿qué?, ¿para quién? Y ¿cómo?, lo que implicará analizar aspectos del conocimiento en las ciencias sociales, las características del adolescente en la actualidad y estrategias didácticas posibles a trabajar en diversos contextos educativos. En relación a estos aspectos, deberá discutirse y fundamentarse el para qué de las Ciencias Sociales lo que llevará a relacionar los contenidos y autores abordados con Didáctica General y la amplia gama de investigaciones acerca de la didáctica de las ciencias sociales realizadas en diferentes contextos universitarios en la actualidad. Ejes de contenidos Teorías que sustentan las prácticas pedagógicas didácticas en las ciencias sociales Epistemología de la didáctica de las Ciencias Sociales. Discusiones en torno a la Didáctica de las Ciencias Sociales: status epistemológico de las ciencias sociales; relación e integración de las ciencias sociales; el valor de verdad o certeza del conocimiento social, los límites de la objetividad o neutralidad del conocimiento que se ha generado.Textos de divulgación histórica y textos en didáctica de las Ciencias Sociales y la Historia como disciplinas. Producción de textos científicos. Construcción del género. Formatos académicos: informes, monografías, ensayos, tesinas.',
  ],
};

const _didacticacienciassociales = {
  'id': 'didactica-ciencias-sociales',
  'nombre': 'Didáctica de las Ciencias Sociales',
  'anio': 2,
  'formato': 'Seminario',
  'cargaHoraria': '3 horas cátedra semanales - 2 horas reloj semanales.',
  'regimenCursado': 'Anual',
  'tipo': 'Formación Específica',
  'marcoOrientador':
      'Esta unidad curricular propone el abordaje de los contenidos desde el '
      'formato de seminario, un recorrido por los fundamentos teóricos para la '
      'construcción de herramientas conceptuales desde diferentes miradas de la '
      'Didáctica de las Ciencias Sociales, deberá estar en constante discusión con '
      'la Práctica Profesional así como el resto de las unidades curriculares desde '
      'primero y segundo año. El estudiante deberá aprender a relacionar y '
      'entrecruzar el ¿qué?, ¿para quién? Y ¿cómo?, lo que implicará analizar '
      'aspectos del conocimiento en las ciencias sociales, las características del '
      'adolescente en la actualidad y estrategias didácticas posibles a trabajar en '
      'diversos contextos educativos. En relación a estos aspectos, deberá '
      'discutirse y fundamentarse el para qué de las Ciencias Sociales lo que '
      'llevará a relacionar los contenidos y autores abordados con Didáctica '
      'General y la amplia gama de investigaciones acerca de la didáctica de las '
      'ciencias sociales realizadas en diferentes contextos universitarios en la '
      'actualidad.',
  'ejes': [
    {
      'titulo':
          'Teorías que sustentan las prácticas pedagógicas didácticas en las ciencias sociales',
      'descripcion':
          'Epistemología de la didáctica de las Ciencias Sociales. Discusiones en '
          'torno a la Didáctica de las Ciencias Sociales: status epistemológico '
          'de las ciencias sociales; relación e integración de las ciencias '
          'sociales; el valor de verdad o certeza del conocimiento social, los '
          'límites de la objetividad o neutralidad del conocimiento que se ha '
          'generado.Textos de divulgación histórica y textos en didáctica de las '
          'Ciencias Sociales y la Historia como disciplinas. Producción de textos '
          'científicos. Construcción del género. Formatos académicos: informes, '
          'monografías, ensayos, tesinas.',
    },
    {
      'titulo': 'Categorías que permiten la discusión en las ciencias sociales',
      'descripcion':
          'La realidad social. Tiempo y espacio como un entramado que interactúa. '
          'Multicausalidad, multiperspectividad, cambios y continuidades, el '
          'tiempo y las periodizaciones (diacronía y sincronía).',
    },
  ],
  'bibliografia': [
    'AISENBERG, B. y ALDEROQUI, S. (Comps). (1995). Nuevos aportes de la Didáctica de las Ciencias Sociales. Buenos Aires: Paidós.',
    '------------------------------------------------------------ (1994). Didáctica de las Ciencias Sociales. Aportes y Reflexiones. Buenos Aires: Paidós.',
    'BENEJAM, P. (1997). Enseñar y aprender ciencias sociales, geografía e historia en la educación secundaria, Cuadernos de Formación del profesorado. Barcelona:',
    'ICE/HORSORI.',
    'CAMILLONI, A., DAVINI M., EDELSTEIN G. y otros (2008). Corrientes Didácticas Contemporáneas. Buenos Aires: Paidós.',
    'CARRETERO, M. (2009). Constructivismo y educación. Argentina: Paidós.',
    'CARRETERO, M. (2007). Construir y enseñar. Las ciencias sociales y la historia. Buenos Aires: Aique.',
    'CARRETERO, M. y CASTORINA, J. (2010). La construcción del conocimiento histórico. Enseñanza, narración e identidades. Argentina: Paidós.',
    'CORONADO, M. (2009). Competencias docentes. Ampliación, enriquecimiento y consolidación de la práctica profesional. Argentina: Noveduc.',
    'DAVINI, C. (2008). Métodos de enseñanza. Didáctica general para maestros y profesores. Buenos Aires: Santillana.',
    'FINOCCHIO, S. (1993). Enseñar ciencias sociales. Buenos Aires: Troquel Flacso.',
    'LE GOFF J. (1995). Pensar la Historia. Barcelona: Altaya.',
    'LERNER, D.; STELLA, P. y TORRES, M. (2009). Formación docente en lectura y escritura. Recorridos didácticos. Buenos Aires: Paidós.',
    'MANSIONE, I. (2000). Las tensiones entre la formación y la práctica docente. La experiencia emocional del docente. Rosario: Homo Sapiens.',
    'MILSTEIN, D. (2009). La Nación en la escuela. Viejas y nuevas tensiones políticas. Argentina: Miño y Dávila.',
    'PLUCKROSE, H. (1996). Enseñanza y aprendizaje de la historia. España: Morata.',
    'ROMERO, L. (2007).Volver a pensar la Historia. Argentina: Aique.',
    'SANJURJO, L. Y RODRÍGUEZ, X. (2009). Volver a pensar la clase. Las formas básicas de Enseñar. Rosario: Homo Sapiens.',
    'SANJURJO, L. Y VERA, M. (2006). Aprendizaje significativo y enseñanza en los niveles medio y superior. Rosario: Homo Sapiens.',
    'SANJURJO, L. (Coord.) (2009). Los dispositivos para la formación en las prácticas profesionales. Rosario: Homo Sapiens.',
    'ZELMANOVICH, P.; GONZÁLEZ y otros (2006). Efemérides, entre el mito y la Historia. Argentina: Paidós. Sujetos de la Educación Secundaria Formato: Seminario Carga horaria: 3 horas cátedra semanales - 2 horas reloj semanales. Régimen de cursado: Anual Marco Orientador Para pensar el sujeto constituyéndose, es necesario hacer referencia a la subjetividad, a los modos o formas sociales, culturales, históricas y políticas, en el que él se interpreta y reconoce a sí mismo, como resultado de una trayectoria singular de experiencias vinculares con los otros. La subjetividad constituye un lugar desde el cual el sujeto es mirado, se mira y mira el mundo, de un modo particular. Desde la institución educativa, como lugar de encuentro entre distintos sujetos, se tienen que abrir debates en torno a la construcción de subjetividades, a los procesos de integración e inclusión socioeducativos, a las problemáticas contemporáneas que interpelan a docentes de todos los niveles educativos y contextos. De acuerdo con la estructura del diseño para la formación de docentes, esta unidad curricular pretende abordar y tensionar al sujeto de la educación desde múltiples miradas. La misma se enlaza con los aportes que las distintas disciplinas posibilitan desde el campo de la Formación General, con el campo de la Práctica, que es el eje integrador en este diseño curricular. La articulación se dará a partir de la reflexión sobre los sujetos del nivel, las aulas, las trayectorias escolares y la institución educativa en relación a la transmisión y a la enseñanza. Ejes de contenidos Mirada desde la perspectiva socio-antropológica histórica y política La complejidad y diversidad de formas de representar y vivir las infancias, adolescencias, juventudes y adultez. La escolarización en el desarrollo socio histórico. Infancia y escuela: La escuela como dispositivo pedagógico.',
  ],
};

const _practica2 = {
  'id': 'practica-2',
  'nombre': 'Práctica Docente II - Educación Secundaria y Práctica Docente',
  'anio': 2,
  'formato': 'Seminario - Taller',
  'cargaHoraria': '4 horas cátedra semanales (2 horas 40 min reloj).',
  'regimenCursado': 'Anual',
  'tipo': 'Práctica Profesional',
  'marcoOrientador':
      'La unidad curricular Práctica Docente II tiene como propósito que los '
      'estudiantes reconozcan y transiten la dinámica de las instituciones '
      'educativas urbanas, periurbanas, rurales y de distintas modalidades del '
      'sistema formal de educación secundaria, desde una perspectiva interpretativa '
      'y colaborativa. Está organizado en tres ejes: los dos primeros consecutivos '
      'y el tercero transversal. El primero: “La práctica docente y la identidad '
      'pedagógica en el nivel secundario” permite comprender la escuela secundaria '
      'como espacio institucional complejo, en el que se vinculan distintas '
      'generaciones y se constituyen subjetividades. Es un espacio de estudio de '
      'problemas desde una perspectiva interdisciplinaria. El formato seminario '
      'propiciará que se desarrollen instancias de reflexión crítica, análisis, '
      'profundización, comprensión de los contextos institucionales a través de los '
      'aportes de la investigación y de lectura y debate de materiales '
      'bibliográficos. El segundo: “Análisis de la dinámica institucional”, '
      'propiciará un acercamiento a las instituciones educativas en diferentes '
      'realidades socioculturales, contextos y modalidades, identificando las '
      'culturas escolares, historias, rutinas, lógicas de organización, '
      'problemáticas, conflictos, proyectos y prácticas cotidianas. Se realizarán '
      'entrevistas, observaciones participantes, relatos de vida y topografías que '
      'permitan describir y analizar las prácticas y las tramas vinculares. Se '
      'propone la organización de los estudiantes en equipos de trabajo móviles, '
      'asegurando el aprendizaje de distintos roles, la intervención colaborativa '
      'de los mismos desde roles complementarios al trabajo docente, y la reflexión '
      'en forma conjunta con los pares, los docentes de los institutos, los equipos '
      'docentes y 166 directivos de las escuelas asociadas. En el eje '
      '“Documentación pedagógica” se considera que la escritura es una instancia '
      'funda- mental para sistematizar las experiencias, recuperar las memorias y '
      'producir escritos académicos que fortalecen las reflexiones sobre las '
      'prácticas. En el marco de la articulación de los contenidos con los otros '
      'campos, los estudiantes harán una proyección de sus reflexiones en relación '
      'con la Didáctica General, Psicología Educacional, Historia de la Educación '
      'Argentina y las Didácticas específicas, resignificando la historia, '
      'identidad y características organizacionales y pedagógicas del Nivel '
      'Secundario. Este recorrido permite comprender la escuela como espacio '
      'institucional complejo, en el que se vinculan distintas generaciones y se '
      'construyen subjetividades. La propuesta compromete la participación de los '
      'equipos directivos de las escuelas asociadas desde un rol protagónico, junto '
      'a formadores y estudiantes para discutir y re pensar proyectos '
      'institucionales, modos y estilos de conducción, la historia, problemáticas e '
      'identidad pedagógica del nivel. Las instancias de inserción en las '
      'instituciones asociadas, que han de llevarse a cabo en simultáneo con el '
      'desarrollo de los ejes posibilitarán a los estudiantes realizar: - Análisis '
      'de documentación institucional: proyectos educativos, proyectos '
      'curriculares, proyectos áulicos, circulares, registros de clases, acuerdos '
      'de convivencia, entre otros. - Observación y registro de escenas educativas: '
      'vínculos entre docente y alumno, estrategias de enseñanza, modos de '
      'evaluación, recursos, materiales bibliográficos en el campo de la '
      'disciplina. - Ayudantías docentes: en clases, acompañamiento en actividades '
      'individuales y grupales, tutorías, recuperación de aprendizajes, '
      'planificación y desarrollo de propuesta educativa en la enseñanza de la '
      'disciplina.',
  'ejes': [
    {
      'titulo':
          'La práctica docente y la identidad pedagógica en el nivel secundario',
      'descripcion':
          'El nivel secundario, historia, especificidad y organización en los '
          'distintos contextos y modalidades. La configuración institucional del '
          'nivel secundario en la actualidad, ciclos, modalidades, objetivos, '
          'programas. Caracterización del trabajo docente en el nivel secundario: '
          'mitos, tradiciones y construcciones. Los sujetos de las prácticas: '
          'estudiantes, formadores, docentes de las escuelas asociadas.',
    },
    {
      'titulo':
          'Análisis de la dinámica institucional e intervenciones colaborativas',
      'descripcion':
          'Dinámica institucional: el cotidiano escolar como espacio de '
          'tensiones, acuerdos e intereses. Dimensiones del proceso de '
          'investigación: la construcción de problemas - objeto de estudio. '
          'Trabajo de campo, técnicas de recolección y análisis de la '
          'información. Abordaje interpretativo de la institución educativa desde '
          'una perspectiva socio antropológica. Gramática Institucional. '
          'Historias institucionales. Escuela, vida cotidiana y las '
          'representaciones en los sujetos. Costumbres, mitos, ritos, rutinas, '
          'códigos, símbolos. Articulación entre el Nivel Primario, Nivel '
          'Secundario y el Nivel Superior. Proyectos institucionales en '
          'contextos: la práctica docente como experiencia formativa. El lugar de '
          'la disciplina en la escuela asociada. Sentidos y significados. Diseño '
          'de propuestas pedagógicas colaborativas. Documentación y narrativa de '
          'experiencias y estrategias en espacios de educación secundaria.',
    },
    {
      'titulo': 'Documentación pedagógica',
      'descripcion':
          'Documentación y narrativa de experiencias pedagógicas en instituciones '
          'educativas y espacios socio-comunitarios. Recuperación y análisis de '
          'narrativas y proyectos educativos. Resignificación y sistematización '
          'de los trabajos desarrollados en el IFD y en las instituciones '
          'asociada. Escrituras académicas.',
    },
  ],
  'bibliografia': [
    'CHAVES, M. (2005). Juventud negada y negativizada: representaciones y formaciones discursivas vigentes en la Argentina contemporánea. Última década N° 23. Valparaíso: CIDPA.',
    'CORONADO, M. (2008). Competencias sociales y convivencia. Buenos Aires: Noveduc.',
    'DUBET, F. (2007). El declive y las mutaciones de la institución. En Revista de antropología social: Universidad Complutense ediciones.',
    'LARROSA, J. (1995). Déjame que te cuente. Ensayos sobre narrativa y educación. Barcelona: Laertes.',
    'FERRY, G. (1990). Pedagogía de la formación. Buenos Aires: Paidós.',
    'FRIGERIO, G. POGGI, M. y KORINFELD, D. Comp. (1999). Construyendo un saber sobre el interior de la escuela. Buenos Aires: CEM. Noveduc.',
    'GORE, J. M. (1996). Controversias entre las pedagogías. Madrid: Morata.',
    'JACKSON, P. (1992). La vida en las aulas. Madrid: Morata.',
    'MANSIONE, I. (2004). Las tensiones entre la formación y la práctica docente. La experiencia emocional del docente. Rosario: Homo Sapiens.',
    'MORZÁN, A, (2007). Saberes y sabores de la práctica docente. Textos y contextos. Resistencia, Chaco: Librería La Paz.',
    'NICASTRO, S. (2006). Revisitar la mirada sobre la escuela. Rosario: Homo Sapiens.',
    'WAINERMAN, C. SAUTU, R. comp. (2001). La trastienda de la investigación. Buenos Aires: Lumiere.',
  ],
};
