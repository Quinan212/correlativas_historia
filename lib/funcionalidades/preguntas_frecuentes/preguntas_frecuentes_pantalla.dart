import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// ===================== Estado de búsqueda =====================
final proveedorBusquedaPreguntasFrecuentes = StateProvider<String>((_) => '');

/// ===================== Helpers modo oscuro =====================
bool _isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;
Color _darken(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t)!;

/// Quita comillas externas (", “ ”, ', ‘ ’) si la respuesta ENTERA viene entrecomillada.
/// Conserva comillas internas.
String _stripOuterQuotes(String s) {
  var t = s.trim();
  bool has(String a, String b) =>
      t.length >= 2 && t.startsWith(a) && t.endsWith(b);
  const pairs = [
    ['“', '”'],
    ['"', '"'],
    ['‘', '’'],
    ["'", "'"],
  ];
  for (final p in pairs) {
    if (has(p[0], p[1])) {
      t = t.substring(p[0].length, t.length - p[1].length).trim();
      break;
    }
  }
  return t;
}

/// ===================== Modelo + datos =====================
class ItemPreguntaFrecuente {
  final int id;
  final String section;
  final String question;
  final String answer;

  const ItemPreguntaFrecuente(
    this.id,
    this.section,
    this.question,
    this.answer,
  );
}

const List<ItemPreguntaFrecuente> _faqItems = [
  ItemPreguntaFrecuente(
    1,
    'Sobre el Ingreso',
    '1. ¿Qué pasa si todavía debo materias del secundario? ¿Puedo inscribirme igual?',
    'Sí. "Serán estudiantes provisorios quienes aún no posean estudios secundarios completos". '
        'Podrás "cursar y realizar todas las actividades académicas requeridas por los docentes a cargo de las unidades curriculares, '
        'excepto la evaluación de exámenes finales". La situación debe regularizarse "registrando como plazo máximo el último día hábil previo al inicio '
        'del receso de invierno, establecido por Calendario Escolar".',
  ),
  ItemPreguntaFrecuente(
    2,
    'Sobre el Ingreso',
    '2. Soy mayor de 25 años pero no terminé el secundario, ¿tengo alguna posibilidad de ingresar?',
    'Sí, excepcionalmente.\n\n'
        'Para Carreras de Formación Docente: Se puede ingresar "siempre que demuestren, a través de instancias de nivelación, que tienen preparación o '
        'experiencia laboral acorde con los estudios que se proponen iniciar, así como aptitudes y conocimientos suficientes para cursarlos satisfactoriamente".\n\n'
        'Para Carreras de Educación Técnico Profesional: Se puede ingresar "previa evaluación de su trayectoria, a cargo de una Comisión Institucional Ad hoc".',
  ),
  ItemPreguntaFrecuente(
    3,
    'Sobre el Ingreso',
    '3. Se me pasó la fecha de inscripción, ¿puedo anotarme más tarde?',
    'Sí, hay una posibilidad. "La presentación de la documentación para el ingreso de estudiantes, fuera de los plazos académicos estipulados, '
        'podrá realizarse hasta el último día hábil del mes de abril". Este ingreso "será puesto a consideración del Consejo Directivo u órgano análogo".',
  ),
  ItemPreguntaFrecuente(
    4,
    'Sobre Correlatividades y Promoción',
    '4. ¿Qué son las correlatividades?',
    '"Las unidades curriculares podrán cursarse ajustándose a lo establecido en el régimen de correlatividades correspondientes al plan de estudios vigente."',
  ),
  ItemPreguntaFrecuente(
    5,
    'Sobre Correlatividades y Promoción',
    '5. ¿Qué necesito para cursar una materia que tiene correlativas?',
    '"Para cursar una unidad curricular, el estudiante puede tener regularizada/s y/o aprobada/s las UC correlativa/s anterior/es."',
  ),
  ItemPreguntaFrecuente(
    6,
    'Sobre Correlatividades y Promoción',
    '6. ¿Y para rendir el examen final de una materia con correlativas?',
    '"Para rendir una UC, el estudiante debe tener aprobada/s la/s unidades curriculares correlativas."',
  ),
  ItemPreguntaFrecuente(
    7,
    'Sobre Correlatividades y Promoción',
    '7. ¿Cómo funcionan las correlatividades en la práctica para pasar de año?',
    'El sistema exige tener materias regularizadas (cursadas) para cursar las siguientes y aprobadas (con final rendido) para rendir otras. '
        'Ejemplo (Historia, 3er año, Práctica Docente III):\n'
        '• Práctica Docente II — Aprobada\n'
        '• Psicología Educacional — Regular\n'
        '• Sujetos de la Educación Secundaria — Regular\n'
        '• Procesos sociales, políticos, económicos y culturales del Feudalismo y la Modernidad — Aprobada\n'
        '…entre otras.',
  ),
  ItemPreguntaFrecuente(
    8,
    'Sobre Correlatividades y Promoción',
    '8. ¿Qué significa "promocionar" una unidad curricular?',
    'Es la posibilidad de acreditar (aprobar) una materia por "Promoción Directa" o por "Promoción con Coloquio Final Integrador", '
        'sin necesidad de rendir un examen final tradicional.',
  ),
  ItemPreguntaFrecuente(
    9,
    'Sobre Correlatividades y Promoción',
    '9. ¿Qué requisitos debo cumplir para promocionar una materia?',
    '• "Aprobación de las unidades correlativas teniendo como última instancia la primera mesa extraordinaria establecida por Calendario Escolar."\n'
        '• "Aprobación de las instancias evaluativas progresivas con nota siete (7) o más."\n'
        '• "Presentación y aprobación de todas las producciones requeridas con nota siete (7) o más."\n'
        '• "Mínimo de 70% de asistencia [...] y 60% para aquellos estudiantes que trabajen y/o presenten situaciones particulares."',
  ),
  ItemPreguntaFrecuente(
    10,
    'Sobre Correlatividades y Promoción',
    '10. Si estoy cursando una materia, ¿hasta cuándo tengo tiempo de aprobar su correlativa para poder promocionarla?',
    'Tenés tiempo hasta la primera mesa extraordinaria del ciclo lectivo. '
        'Requisito: "Aprobación de las unidades correlativas teniendo como última instancia la primera mesa extraordinaria establecida por Calendario Escolar".',
  ),
  ItemPreguntaFrecuente(
    11,
    'Sobre Correlatividades y Promoción',
    '11. ¿Qué pasa si no apruebo la correlativa en esa mesa extraordinaria?',
    'Perdés la posibilidad de promocionar la materia que estás cursando. Si no se cumplen los requisitos de promoción, '
        'la alternativa es alcanzar la condición de regular para luego rendir un examen final.',
  ),
  ItemPreguntaFrecuente(
    12,
    'Sobre Correlatividades y Promoción',
    '12. ¿Para eso existen las mesas extraordinarias?',
    'Exactamente. Se habilitan mesas extraordinarias "de las unidades curriculares correlativas a fin de generar las condiciones para la promoción o '
        'regularización de las unidades curriculares subsiguientes".',
  ),
  ItemPreguntaFrecuente(
    13,
    'Sobre el Cursado y Estatus del Estudiante',
    '13. ¿Cómo mantengo mi condición de "alumno regular" de la carrera?',
    '"Se considerará estudiante REGULAR de la carrera a aquel que, inscripto al año académico apruebe al menos una (1) unidad curricular en ese período".',
  ),
  ItemPreguntaFrecuente(
    14,
    'Sobre el Cursado y Estatus del Estudiante',
    '14. ¿Qué significa estar "regular" en una materia?',
    'Es la condición que se obtiene al cumplir con los requisitos del cursado. Se requiere:\n'
        '• "Contar con un mínimo de 70% de asistencia"\n'
        '• "Aprobar las instancias evaluativas parciales y/o recuperatorios con nota no inferior a 6 (seis)"\n'
        '• "Haber presentado y aprobado el 100% de las producciones constituidas como instancias evaluativas".',
  ),
  ItemPreguntaFrecuente(
    15,
    'Sobre el Cursado y Estatus del Estudiante',
    '15. ¿Cuánto tiempo dura la regularidad de una materia?',
    '"La condición de regularidad adquirida [...] se conservará por dos (2) años académicos".',
  ),
  ItemPreguntaFrecuente(
    16,
    'Sobre el Cursado y Estatus del Estudiante',
    '16. ¿Qué significa tener una materia "aprobada"?',
    'Es la condición que se obtiene cuando la materia está finalizada, ya sea por promoción o por aprobar una "Evaluación Final en mesa examinadora".',
  ),
  ItemPreguntaFrecuente(
    17,
    'Sobre el Cursado y Estatus del Estudiante',
    '17. Si se me vence la regularidad de una materia, ¿qué debo hacer para aprobarla?',
    '"De no acreditar en el tiempo estipulado el estudiante pasa a condición de LIBRE en las unidades curriculares". '
        'Para aprobar como libre, se deben "Aprobar las instancias evaluativas finales, una escrita y otra oral, con calificación mínima de seis (6), en cada caso".',
  ),
  ItemPreguntaFrecuente(
    18,
    'Sobre el Cursado y Estatus del Estudiante',
    '18. ¿Qué unidades curriculares no se pueden rendir en condición de "libre"?',
    '"Las unidades curriculares con formato taller, seminario, seminario taller [...] Bajo ninguna circunstancia se podrán cursar, acreditar y/o aprobar en condición de libre".',
  ),
  ItemPreguntaFrecuente(
    19,
    'Sobre el Cursado y Estatus del Estudiante',
    '19. Trabajo y se me complica cumplir con el 70% de asistencia, ¿hay alguna consideración para mi caso?',
    'Sí. "Se considerará el 60% de asistencia para aquellos/as estudiantes que trabajen y/o presenten situaciones particulares".',
  ),
  ItemPreguntaFrecuente(
    20,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '20. ¿Cómo es el proceso de evaluación durante el cursado?',
    '"Este proceso evaluativo consta de instancias progresivas y acreditables con sus correspondientes recuperatorios".',
  ),
  ItemPreguntaFrecuente(
    21,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '21. ¿Las evaluaciones son todas iguales?',
    'No. Se busca promover "el aprendizaje activo y significativo para los estudiantes, a través del estudio de casos, análisis de tendencias, discusión de lecturas, '
        'resolución de problemas, producción de informes orales y escritos, [...] trabajos de campo, entre otros".',
  ),
  ItemPreguntaFrecuente(
    22,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '22. ¿Cuál es la escala de calificaciones que se utiliza?',
    'La escala es de 1 a 10, donde "6" es "Aprobado" y de "1 a 5" es "Insuficiente".',
  ),
  ItemPreguntaFrecuente(
    23,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '23. ¿Qué hago si me inscribí a una mesa final y no puedo presentarme?',
    'Debés solicitar formalmente que anulen tu inscripción "24 (veinticuatro) horas hábiles antes de dicha sustanciación".',
  ),
  ItemPreguntaFrecuente(
    24,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '24. ¿Quiénes evalúan en una mesa de examen final?',
    '"Las mesas evaluadoras estarán integradas por una terna de docentes, será presidida por el docente a cargo de la unidad curricular y constituida por dos docentes adjuntos".',
  ),
  ItemPreguntaFrecuente(
    25,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '25. ¿Tengo derecho a saber por qué me calificaron de cierta manera en un final?',
    'Sí. "Los docentes integrantes de la mesa evaluadora deberán garantizar la devolución oral y/o escrita y formativa a los estudiantes a efectos de contribuir a la mejora de los aprendizajes".',
  ),
  ItemPreguntaFrecuente(
    26,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '26. ¿Qué son las mesas extraordinarias y para qué sirven?',
    'Son mesas de examen fuera de los turnos habituales que sirven "para acompañar las trayectorias formativas" y para "generar las condiciones para la promoción o regularización de las unidades curriculares subsiguientes".',
  ),
  ItemPreguntaFrecuente(
    27,
    'Sobre Pautas de Evaluación y Mesas de Examen',
    '27. ¿En qué casos puedo solicitar una mesa extraordinaria?',
    'En situaciones específicas como: si adeudar una materia te impide cursar Práctica Docente II, III, IV (en este caso la mesa es "exclusivamente en el mes de mayo"); '
        'por "finalización de la carrera por terminalidad, cierre de la misma o por cambio de diseño curricular".',
  ),
  ItemPreguntaFrecuente(
    28,
    'Sobre la Carrera y Contenidos',
    '28. ¿Cuál es la diferencia entre una "Asignatura", un "Seminario" y un "Taller"?',
    'Asignatura: Se define por "la enseñanza de marcos disciplinares".\n\n'
        'Seminario: Es para el "estudio en profundidad de problemas relevantes para la formación".\n\n'
        'Taller: Está "orientado a promover la resolución práctica de situaciones".',
  ),
  ItemPreguntaFrecuente(
    29,
    'Sobre la Carrera y Contenidos',
    '29. ¿Cómo se organizan los contenidos y la teoría a lo largo de la carrera?',
    'La carrera se estructura en tres marcos:\n\n'
        '• Campo de la Formación General: Busca "construir marcos conceptuales para pensar y comprender las realidades sociales, culturales y educativas, '
        'las instituciones y las prácticas docentes".\n\n'
        '• Campo de la Formación Específica: Se construye "en torno a la centralidad del sujeto, ¿quién es el que aprende?, ¿qué aprende?, ¿cómo lo hace?".\n\n'
        '• Campo de la Formación en la Práctica Profesional Docente: Se configura "como el eje integrador de la propuesta de formación inicial".',
  ),
  ItemPreguntaFrecuente(
    30,
    'Sobre la Carrera y Contenidos',
    '30. ¿Qué requisitos específicos existen para cursar la Práctica Docente IV (Residencia)?',
    'El Diseño Curricular del Profesorado de Historia establece como correlativa: "Todas las Unidades Curriculares de Tercer año.(A)" (Aprobadas). '
        'Además, "Aquellos estudiantes que adeuden la práctica docente anterior y/o unidades correlativas establecidas en el Diseño Curricular no podrán ingresar a la institución asociada".',
  ),
  ItemPreguntaFrecuente(
    31,
    'Sobre el Egreso',
    '31. Una vez que apruebo la última materia, ¿qué sucede? ¿Ya soy egresado?',
    'Sí. "Finalizada la aprobación de todas las unidades curriculares correspondientes a la carrera cursada, el estudiante obtendrá la condición de graduado".',
  ),
  ItemPreguntaFrecuente(
    32,
    'Sobre el Egreso',
    '32. ¿Qué pasa si estoy por terminar y anuncian el cierre de mi carrera?',
    '"Al estudiante en condición de LIBRE [...] se le garantizará como última instancia un total de 5 (cinco) turnos ordinarios/extraordinarios consecutivos '
        'de mesas de examen para que finalice su carrera y/o por cierre de carrera".',
  ),
];

String _normalize(String s) {
  const map = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'Á': 'a',
    'À': 'a',
    'Ä': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'É': 'e',
    'È': 'e',
    'Ë': 'e',
    'Ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'Í': 'i',
    'Ì': 'i',
    'Ï': 'i',
    'Î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'Ó': 'o',
    'Ò': 'o',
    'Ö': 'o',
    'Ô': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'Ú': 'u',
    'Ù': 'u',
    'Ü': 'u',
    'Û': 'u',
    'ñ': 'n',
    'Ñ': 'n',
  };
  final lower = s.toLowerCase();
  final buf = StringBuffer();
  for (final ch in lower.characters) {
    buf.write(map[ch] ?? ch);
  }
  return buf.toString();
}

int _levenshtein(String a, String b, {int max = 2}) {
  if (a == b) return 0;
  if (a.isEmpty || b.isEmpty) return (a.length + b.length);
  if ((a.length - b.length).abs() > max) return max + 1;

  final ac = a.codeUnits, bc = b.codeUnits;
  final m = ac.length, n = bc.length;

  List<int> prev = List<int>.generate(n + 1, (j) => j);
  List<int> curr = List<int>.filled(n + 1, 0);

  for (int i = 1; i <= m; i++) {
    curr[0] = i;
    int rowMin = curr[0];
    for (int j = 1; j <= n; j++) {
      final cost = (ac[i - 1] == bc[j - 1]) ? 0 : 1;
      final del = prev[j] + 1;
      final ins = curr[j - 1] + 1;
      final sub = prev[j - 1] + cost;
      final v = (del < ins ? del : ins);
      curr[j] = (v < sub ? v : sub);
      if (curr[j] < rowMin) rowMin = curr[j];
    }
    if (rowMin > max) return max + 1;
    final tmp = prev;
    prev = curr;
    curr = tmp;
  }
  return prev[n];
}

bool _matches(ItemPreguntaFrecuente item, String query) {
  if (query.trim().isEmpty) return true;
  final q = _normalize(query);
  final haystack = _normalize('${item.question} ${item.answer}');

  if (haystack.contains(q)) return true;

  final qTokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
  final titleTokens = _normalize(
    item.question,
  ).split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty);

  for (final qt in qTokens) {
    for (final tt in titleTokens) {
      if (tt.startsWith(qt) && qt.length >= 3) return true;
      if (_levenshtein(qt, tt, max: 1) <= 1 &&
          (qt.length >= 5 || tt.length >= 5)) {
        return true;
      }
    }
  }
  return false;
}

Map<String, List<ItemPreguntaFrecuente>> _groupBySection(
  List<ItemPreguntaFrecuente> items,
) {
  final map = <String, List<ItemPreguntaFrecuente>>{};
  for (final it in items) {
    map.putIfAbsent(it.section, () => <ItemPreguntaFrecuente>[]).add(it);
  }
  return map;
}

class PantallaPreguntasFrecuentes extends ConsumerWidget {
  const PantallaPreguntasFrecuentes({
    super.key,
    this.showHeader = true,
    this.atlassianStyle = false,
  });

  final bool showHeader;
  final bool atlassianStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: atlassianStyle
          ? Theme.of(context).scaffoldBackgroundColor
          : null,
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          slivers: [
            if (showHeader)
              SliverPersistentHeader(
                pinned: true,
                delegate: _DelegadoBannerColapsable(
                  topInset: topInset,
                  subtitle: 'Normativa y trayectorias',
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(atlassianStyle: atlassianStyle),
                    const SizedBox(height: 12),
                    _FaqList(atlassianStyle: atlassianStyle),
                    const SizedBox(height: 24),
                    _AutorBlock(atlassianStyle: atlassianStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar({required this.atlassianStyle});

  final bool atlassianStyle;

  static InputDecoration _dec(
    BuildContext context, {
    String? hint,
    required bool atlassianStyle,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    return InputDecoration(
      hintText: hint ?? 'Buscar en preguntas…',
      filled: true,
      fillColor: atlassianStyle
          ? cs.surface
          : (isDark ? _darken(cs.surface, 0.25) : Colors.white),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(atlassianStyle ? 28 : 12),
        borderSide: BorderSide(
          color: atlassianStyle
              ? cs.outlineVariant
              : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(atlassianStyle ? 28 : 12),
        borderSide: BorderSide(
          color: atlassianStyle
              ? cs.outlineVariant
              : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(atlassianStyle ? 28 : 12),
        borderSide: BorderSide(
          color: atlassianStyle
              ? cs.primary
              : (isDark ? cs.primary : const Color(0xFF93C5FD)),
          width: atlassianStyle ? 1.5 : 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final term = ref.watch(proveedorBusquedaPreguntasFrecuentes);
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return TextField(
      style: TextStyle(color: isDark ? cs.onSurface : null),
      controller: TextEditingController(text: term)
        ..selection = TextSelection.collapsed(offset: term.length),
      decoration:
          _dec(
            context,
            hint: 'Busca por tema o situacion: promocion, correlativa, mesa...',
            atlassianStyle: atlassianStyle,
          ).copyWith(
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? cs.onSurfaceVariant : const Color(0xFF6B7280),
            ),
            suffixIcon: term.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpiar',
                    onPressed: () =>
                        ref
                                .read(
                                  proveedorBusquedaPreguntasFrecuentes.notifier,
                                )
                                .state =
                            '',
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? cs.onSurfaceVariant
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
          ),
      onChanged: (v) =>
          ref.read(proveedorBusquedaPreguntasFrecuentes.notifier).state = v,
      textInputAction: TextInputAction.search,
    );
  }
}

class _FaqList extends ConsumerWidget {
  const _FaqList({required this.atlassianStyle});

  final bool atlassianStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final term = ref.watch(proveedorBusquedaPreguntasFrecuentes);
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    final filtered = _faqItems.where((it) => _matches(it, term)).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: atlassianStyle
              ? cs.surface
              : (isDark ? _darken(cs.surface) : Colors.white),
          borderRadius: BorderRadius.circular(atlassianStyle ? 8 : 14),
          border: Border.all(
            color: atlassianStyle
                ? cs.outlineVariant
                : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
          ),
          boxShadow: atlassianStyle
              ? const []
              : const [BoxShadow(blurRadius: 4, color: Color(0x0F000000))],
        ),
        child: Text(
          'No encontramos respuestas para esa busqueda. Proba con otra palabra o un tema mas general.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isDark ? cs.onSurfaceVariant : const Color(0xFF6B7280),
          ),
        ),
      );
    }

    final grouped = _groupBySection(filtered);
    final sectionOrder = <String>[];
    for (final it in filtered) {
      if (!sectionOrder.contains(it.section)) sectionOrder.add(it.section);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final section in sectionOrder) ...[
          _TituloSeccion(section, atlassianStyle: atlassianStyle),
          const SizedBox(height: 8),
          for (final qa in grouped[section]!) ...[
            _TarjetaPreguntaRespuesta(
              q: qa.question,
              a: qa.answer,
              atlassianStyle: atlassianStyle,
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String text;
  final bool atlassianStyle;

  const _TituloSeccion(this.text, {required this.atlassianStyle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: atlassianStyle
            ? cs.surface
            : (isDark ? _darken(cs.surface) : Colors.white),
        borderRadius: BorderRadius.circular(atlassianStyle ? 8 : 12),
        border: Border.all(
          color: atlassianStyle
              ? cs.outlineVariant
              : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: isDark ? cs.onSurface : const Color(0xFF111827),
        ),
      ),
    );
  }
}

class _TarjetaPreguntaRespuesta extends StatelessWidget {
  final String q;
  final String a;
  final bool atlassianStyle;

  const _TarjetaPreguntaRespuesta({
    required this.q,
    required this.a,
    required this.atlassianStyle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    final cardColor = atlassianStyle
        ? cs.surface
        : (isDark ? _darken(cs.surface) : Colors.white);
    final innerColor = atlassianStyle
        ? cs.surfaceContainerLowest
        : (isDark ? _darken(cs.surface, 0.28) : const Color(0xFFFAFAFA));

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(atlassianStyle ? 8 : 14),
        border: Border.all(
          color: atlassianStyle
              ? cs.outlineVariant
              : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
        ),
        boxShadow: atlassianStyle
            ? const []
            : const [BoxShadow(blurRadius: 4, color: Color(0x0F000000))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          backgroundColor: cardColor,
          collapsedBackgroundColor: cardColor,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          collapsedShape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
          ),
          iconColor: isDark ? cs.onSurfaceVariant : const Color(0xFF6B7280),
          collapsedIconColor: isDark
              ? cs.onSurfaceVariant
              : const Color(0xFF6B7280),
          title: Text(
            q,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: atlassianStyle
                  ? cs.onSurface
                  : (isDark ? cs.onSurface : const Color(0xFF111827)),
            ),
          ),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: innerColor,
                borderRadius: BorderRadius.circular(atlassianStyle ? 6 : 10),
                border: Border.all(
                  color: atlassianStyle
                      ? cs.outlineVariant
                      : (isDark ? cs.outlineVariant : const Color(0xFFE5E7EB)),
                ),
              ),
              child: Text(
                _stripOuterQuotes(a),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? cs.onSurface : const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AutorBlock extends StatelessWidget {
  const _AutorBlock({required this.atlassianStyle});

  final bool atlassianStyle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: atlassianStyle
            ? cs.surface
            : (isDark ? _darken(cs.surface) : Colors.white),
        borderRadius: BorderRadius.circular(atlassianStyle ? 8 : 16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
        boxShadow: atlassianStyle
            ? const []
            : const [BoxShadow(blurRadius: 6, color: Color(0x12000000))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proyecto',
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          const SizedBox(height: 6),
          Text(
            'Curaduria y desarrollo inicial: Alan Gabriel Maillet.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? cs.onSurfaceVariant : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Material didactico de apoyo para leer la normativa desde problemas concretos de cursada y acompanar trayectorias estudiantiles.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? cs.onSurfaceVariant : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _DelegadoBannerColapsable extends SliverPersistentHeaderDelegate {
  _DelegadoBannerColapsable({required this.topInset, required this.subtitle});

  final double topInset;
  final String subtitle;

  static const double _h1 = 56.0;
  static const double _h2 = 40.0;
  static const c1 = Color(0xFF005B7F);
  static const c2 = Color(0xFF004966);

  @override
  double get minExtent => topInset + _h2;

  @override
  double get maxExtent => topInset + _h1 + _h2;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final t = (maxExtent - shrinkOffset - minExtent) / range;
    final vis = t.clamp(0.0, 1.0);

    final smallT = 1.0 - vis;
    final smallOpacity = Curves.easeIn.transform(smallT);

    return Material(
      color: c2,
      elevation: overlapsContent ? 4 : 0,
      child: Column(
        children: [
          SizedBox(
            height: topInset + (_h1 * vis),
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: c1),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 8,
                    child: Opacity(
                      opacity: Curves.easeOut.transform(vis),
                      child: Transform.translate(
                        offset: Offset(0, (1 - vis) * -8),
                        child: const Text(
                          'Preguntas Frecuentes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: _h2,
            child: Container(
              width: double.infinity,
              color: c2,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Opacity(
                opacity: smallOpacity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DelegadoBannerColapsable old) =>
      old.topInset != topInset || old.subtitle != subtitle;
}
