import '../modelos/calificacion_opiniones.dart';

const kMatterDimensionKeys = <String>[
  'classroom_climate',
  'reading_load',
  'demand_level',
  'problematization',
  'source_work',
  'past_present_link',
  'theory_practice',
  'course_clarity',
  'course_support',
  'formative_value',
];

const kTeacherDimensionKeys = <String>[
  'clarity_exposition',
  'classroom_climate',
  'word_circulation',
  'interpretation_openness',
  'question_space',
  'problematization',
  'source_work',
  'evaluation_clarity',
  'support',
];

String etiquetaDimensionMateria(String key) {
  switch (key) {
    case 'classroom_climate':
      return 'Clima general de cursada';
    case 'reading_load':
      return 'Carga de lectura';
    case 'demand_level':
      return 'Nivel de exigencia';
    case 'problematization':
      return 'Problematizacion';
    case 'source_work':
      return 'Trabajo con fuentes';
    case 'past_present_link':
      return 'Relacion pasado-presente';
    case 'theory_practice':
      return 'Articulacion teoria-practica';
    case 'course_clarity':
      return 'Claridad de la cursada';
    case 'course_support':
      return 'Acompanamiento en la cursada';
    case 'formative_value':
      return 'Valor formativo';
    default:
      return key;
  }
}

String etiquetaEscalaDimensionMateria(String key, int value) {
  if (value <= 0) return 'Sin marcar';

  switch (key) {
    case 'classroom_climate':
      return _etiquetaClima(value);
    case 'reading_load':
    case 'demand_level':
      return _etiquetaIntensidad(value);
    case 'course_clarity':
      return _etiquetaClaridad(value);
    case 'formative_value':
      return _etiquetaValorFormativo(value);
    case 'problematization':
    case 'source_work':
    case 'past_present_link':
    case 'theory_practice':
    case 'course_support':
      return _etiquetaPresencia(value);
    default:
      return _etiquetaPresencia(value);
  }
}

String etiquetaAspectoDocente(String key) {
  switch (key) {
    case 'clarity_exposition':
      return 'Claridad expositiva';
    case 'classroom_climate':
      return 'Clima en el aula';
    case 'word_circulation':
      return 'Circulacion de la palabra';
    case 'interpretation_openness':
      return 'Apertura a interpretaciones';
    case 'question_space':
      return 'Lugar para preguntas';
    case 'problematization':
      return 'Problematizacion';
    case 'source_work':
      return 'Trabajo con fuentes';
    case 'evaluation_clarity':
      return 'Claridad de criterios';
    case 'support':
      return 'Acompanamiento docente';
    default:
      return key;
  }
}

String etiquetaEscalaAspectoDocente(String key, int value) {
  if (value <= 0) return 'Sin marcar';

  switch (key) {
    case 'classroom_climate':
      return _etiquetaClima(value);
    case 'word_circulation':
    case 'interpretation_openness':
    case 'question_space':
      return _etiquetaApertura(value);
    case 'clarity_exposition':
    case 'evaluation_clarity':
      return _etiquetaClaridad(value);
    case 'problematization':
    case 'source_work':
    case 'support':
      return _etiquetaPresencia(value);
    default:
      return _etiquetaPresencia(value);
  }
}

String etiquetaTagMateria(String tag) {
  switch (tag) {
    case 'classroom_climate':
      return etiquetaDimensionMateria(tag);
    case 'reading_load':
      return etiquetaDimensionMateria(tag);
    case 'demand_level':
      return etiquetaDimensionMateria(tag);
    case 'problematization':
      return etiquetaDimensionMateria(tag);
    case 'source_work':
      return etiquetaDimensionMateria(tag);
    case 'past_present_link':
      return etiquetaDimensionMateria(tag);
    case 'theory_practice':
      return etiquetaDimensionMateria(tag);
    case 'course_clarity':
      return etiquetaDimensionMateria(tag);
    case 'course_support':
      return etiquetaDimensionMateria(tag);
    case 'formative_value':
      return etiquetaDimensionMateria(tag);
    case 'clima cuidado':
      return 'Clima general de cursada';
    case 'lectura intensa':
      return 'Carga de lectura';
    case 'problematiza los temas':
      return 'Problematizacion';
    case 'trabajo con fuentes':
      return 'Trabajo con fuentes';
    case 'pasado y presente':
      return 'Relacion pasado-presente';
    case 'teoria y practica':
      return 'Articulacion teoria-practica';
    case 'criterios claros':
      return 'Claridad de la cursada';
    case 'acompanamiento':
      return 'Acompanamiento en la cursada';
    case 'dificil':
      return 'Nivel de exigencia';
    case 'promocionable':
      return 'Claridad de la cursada';
    case 'mucho texto':
      return 'Carga de lectura';
    case 'mucho tp':
      return 'Articulacion teoria-practica';
    case 'parcial oral':
      return 'Nivel de exigencia';
    case 'buenos apuntes':
      return 'Claridad de la cursada';
    default:
      return tag;
  }
}

Map<String, int> matterDimensionsFromLegacyTags(List<String> tags) {
  final dimensions = <String, int>{};
  for (final rawTag in tags) {
    if (rawTag == 'clima cuidado') {
      dimensions['classroom_climate'] =
          _maxOf(dimensions['classroom_climate'], 4);
    } else if (rawTag == 'lectura intensa' || rawTag == 'mucho texto') {
      dimensions['reading_load'] = _maxOf(dimensions['reading_load'], 4);
    } else if (rawTag == 'dificil' || rawTag == 'parcial oral') {
      dimensions['demand_level'] = _maxOf(dimensions['demand_level'], 4);
    } else if (rawTag == 'problematiza los temas') {
      dimensions['problematization'] =
          _maxOf(dimensions['problematization'], 4);
    } else if (rawTag == 'trabajo con fuentes') {
      dimensions['source_work'] = _maxOf(dimensions['source_work'], 4);
    } else if (rawTag == 'pasado y presente') {
      dimensions['past_present_link'] =
          _maxOf(dimensions['past_present_link'], 4);
    } else if (rawTag == 'teoria y practica' || rawTag == 'mucho tp') {
      dimensions['theory_practice'] = _maxOf(dimensions['theory_practice'], 4);
    } else if (rawTag == 'criterios claros' ||
        rawTag == 'promocionable' ||
        rawTag == 'buenos apuntes') {
      dimensions['course_clarity'] = _maxOf(dimensions['course_clarity'], 4);
    } else if (rawTag == 'acompanamiento') {
      dimensions['course_support'] = _maxOf(dimensions['course_support'], 4);
    }
  }
  return dimensions;
}

Map<String, int> teacherDimensionsFromLegacyAspectos(Map<String, int> legacy) {
  return <String, int>{
    'clarity_exposition': legacy['explica'] ?? 0,
    'question_space': legacy['claridad'] ?? 0,
    'support': legacy['recomendacion'] ?? 0,
    'classroom_climate': legacy['trato'] ?? 0,
    'evaluation_clarity': legacy['organizacion'] ?? 0,
    'problematization': legacy['explica'] ?? 0,
    'source_work': legacy['claridad'] ?? 0,
  }..removeWhere((_, value) => value <= 0);
}

int _maxOf(int? current, int next) =>
    current == null ? next : (current > next ? current : next);

String _etiquetaPresencia(int value) {
  switch (value) {
    case 1:
      return 'Muy baja';
    case 2:
      return 'Baja';
    case 3:
      return 'Intermedia';
    case 4:
      return 'Presente';
    case 5:
      return 'Muy presente';
    default:
      return 'Sin marcar';
  }
}

String _etiquetaClaridad(int value) {
  switch (value) {
    case 1:
      return 'Muy confusa';
    case 2:
      return 'Confusa';
    case 3:
      return 'Variable';
    case 4:
      return 'Clara';
    case 5:
      return 'Muy clara';
    default:
      return 'Sin marcar';
  }
}

String _etiquetaClima(int value) {
  switch (value) {
    case 1:
      return 'Muy tenso';
    case 2:
      return 'Tenso';
    case 3:
      return 'Intermedio';
    case 4:
      return 'Cuidado';
    case 5:
      return 'Muy cuidado';
    default:
      return 'Sin marcar';
  }
}

String _etiquetaApertura(int value) {
  switch (value) {
    case 1:
      return 'Muy cerrada';
    case 2:
      return 'Cerrada';
    case 3:
      return 'Variable';
    case 4:
      return 'Abierta';
    case 5:
      return 'Muy abierta';
    default:
      return 'Sin marcar';
  }
}

String _etiquetaIntensidad(int value) {
  switch (value) {
    case 1:
      return 'Muy baja';
    case 2:
      return 'Baja';
    case 3:
      return 'Media';
    case 4:
      return 'Alta';
    case 5:
      return 'Muy alta';
    default:
      return 'Sin marcar';
  }
}

String _etiquetaValorFormativo(int value) {
  switch (value) {
    case 1:
      return 'Muy bajo';
    case 2:
      return 'Bajo';
    case 3:
      return 'Intermedio';
    case 4:
      return 'Valioso';
    case 5:
      return 'Muy valioso';
    default:
      return 'Sin marcar';
  }
}

String etiquetaEstadoLecturaReferencia(RatingResumen rating) {
  switch (rating.readingState) {
    case EstadoLecturaReferencia.consensus:
      return 'Hay acuerdo';
    case EstadoLecturaReferencia.divided:
      return 'Referencias divididas';
    case EstadoLecturaReferencia.mixed:
      return 'Lectura mixta';
    case EstadoLecturaReferencia.insufficientData:
      return 'Pocas referencias';
  }
}

List<String> buildMatterReferenceInsights(
    Map<String, RatingResumen> dimensions) {
  final entries = dimensions.entries
      .where((entry) => entry.value.votos > 0)
      .toList(growable: false);
  if (entries.isEmpty) return const <String>[];

  final sorted = [...entries]..sort((a, b) {
      final byVotes = b.value.votos.compareTo(a.value.votos);
      if (byVotes != 0) return byVotes;
      final byDistance = (b.value.promedio - 3).abs().compareTo(
            (a.value.promedio - 3).abs(),
          );
      if (byDistance != 0) return byDistance;
      return a.key.compareTo(b.key);
    });

  return sorted
      .map((entry) => _buildMatterInsight(entry.key, entry.value))
      .whereType<String>()
      .take(3)
      .toList(growable: false);
}

List<String> buildTeacherReferenceInsights(Map<String, RatingResumen> aspects) {
  final entries = aspects.entries
      .where((entry) => entry.value.votos > 0)
      .toList(growable: false);
  if (entries.isEmpty) return const <String>[];

  final sorted = [...entries]..sort((a, b) {
      final byVotes = b.value.votos.compareTo(a.value.votos);
      if (byVotes != 0) return byVotes;
      final byDistance = (b.value.promedio - 3).abs().compareTo(
            (a.value.promedio - 3).abs(),
          );
      if (byDistance != 0) return byDistance;
      return a.key.compareTo(b.key);
    });

  return sorted
      .map((entry) => _buildTeacherInsight(entry.key, entry.value))
      .whereType<String>()
      .take(3)
      .toList(growable: false);
}

String? _buildMatterInsight(String key, RatingResumen rating) {
  final average = rating.promedio;
  switch (key) {
    case 'reading_load':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una percepción de carga de lectura ${_etiquetaIntensidad(_roundScale(average)).toLowerCase()}.',
        mixed:
            'Las experiencias son mixtas respecto de la carga de lectura que exige esta cursada.',
        divided:
            'Las referencias aparecen divididas sobre la carga de lectura que exige esta cursada.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad la carga de lectura.',
      );
    case 'demand_level':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una percepción de exigencia ${_etiquetaIntensidad(_roundScale(average)).toLowerCase()}.',
        mixed: 'Las experiencias son mixtas respecto del nivel de exigencia.',
        divided:
            'Las referencias aparecen divididas sobre el nivel de exigencia.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad el nivel de exigencia.',
      );
    case 'classroom_climate':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en un clima de cursada ${_etiquetaClima(_roundScale(average)).toLowerCase()}.',
        mixed:
            'Las referencias muestran un clima de cursada más bien variable.',
        divided:
            'Las referencias aparecen divididas sobre el clima general de cursada.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad el clima de cursada.',
      );
    case 'course_clarity':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una lectura ${_etiquetaClaridad(_roundScale(average)).toLowerCase()} de la cursada.',
        mixed:
            'Predomina una lectura sobre la claridad de la cursada, aunque no de forma homogénea.',
        divided:
            'Las referencias aparecen divididas sobre la claridad de la cursada.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad este eje.',
      );
    case 'formative_value':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en que aparece como una materia ${_etiquetaValorFormativo(_roundScale(average)).toLowerCase()} para la formación.',
        mixed: 'Las referencias son mixtas respecto de su valor formativo.',
        divided: 'Las referencias aparecen divididas sobre su valor formativo.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad su valor formativo.',
      );
    case 'problematization':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza la problematización de los temas.',
        intermediateLabel:
            'Predomina una lectura intermedia de la problematización.',
        lowLabel:
            'Predomina una lectura de baja problematización en las referencias.',
        mixedLabel:
            'Las referencias son mixtas sobre el nivel de problematización.',
        dividedLabel:
            'Las referencias aparecen divididas sobre la problematización de los temas.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad la problematización.',
      );
    case 'source_work':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza el trabajo con fuentes.',
        intermediateLabel:
            'Predomina una lectura intermedia del trabajo con fuentes.',
        lowLabel:
            'Predomina una lectura de baja presencia del trabajo con fuentes.',
        mixedLabel: 'Las referencias son mixtas sobre el trabajo con fuentes.',
        dividedLabel:
            'Las referencias aparecen divididas sobre el trabajo con fuentes.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad el trabajo con fuentes.',
      );
    case 'past_present_link':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza la relación entre pasado y presente.',
        intermediateLabel:
            'Predomina una lectura intermedia de la relación entre pasado y presente.',
        lowLabel:
            'Predomina una lectura de baja presencia de la relación entre pasado y presente.',
        mixedLabel:
            'Las referencias son mixtas sobre la relación entre pasado y presente.',
        dividedLabel:
            'Las referencias aparecen divididas sobre la relación entre pasado y presente.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad la relación entre pasado y presente.',
      );
    case 'theory_practice':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza la articulación entre teoría y práctica.',
        intermediateLabel:
            'Predomina una lectura intermedia de la articulación entre teoría y práctica.',
        lowLabel:
            'Predomina una lectura de baja articulación entre teoría y práctica.',
        mixedLabel:
            'Las referencias son mixtas sobre la articulación entre teoría y práctica.',
        dividedLabel:
            'Las referencias aparecen divididas sobre la articulación entre teoría y práctica.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad la articulación entre teoría y práctica.',
      );
    case 'course_support':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza el acompañamiento en la cursada.',
        intermediateLabel:
            'Predomina una lectura intermedia del acompañamiento en la cursada.',
        lowLabel: 'Predomina una lectura de bajo acompañamiento en la cursada.',
        mixedLabel:
            'Las referencias son mixtas sobre el acompañamiento en la cursada.',
        dividedLabel:
            'Las referencias aparecen divididas sobre el acompañamiento en la cursada.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad el acompañamiento en la cursada.',
      );
    default:
      return null;
  }
}

String? _buildTeacherInsight(String key, RatingResumen rating) {
  final average = rating.promedio;
  switch (key) {
    case 'clarity_exposition':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una lectura ${_etiquetaClaridad(_roundScale(average)).toLowerCase()} de la claridad expositiva.',
        mixed:
            'Predomina una lectura sobre la claridad expositiva, aunque no de forma homogénea.',
        divided:
            'Las referencias aparecen divididas sobre la claridad expositiva.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad la claridad expositiva.',
      );
    case 'evaluation_clarity':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una lectura ${_etiquetaClaridad(_roundScale(average)).toLowerCase()} de los criterios de evaluación.',
        mixed:
            'Predomina una lectura sobre los criterios de evaluación, aunque no de forma homogénea.',
        divided:
            'Las referencias aparecen divididas sobre los criterios de evaluación.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad los criterios de evaluación.',
      );
    case 'classroom_climate':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en un clima de aula ${_etiquetaClima(_roundScale(average)).toLowerCase()}.',
        mixed: 'Las referencias muestran un clima de aula más bien variable.',
        divided:
            'Las referencias aparecen divididas sobre el clima en el aula.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad el clima en el aula.',
      );
    case 'word_circulation':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una circulación de la palabra ${_etiquetaApertura(_roundScale(average)).toLowerCase()}.',
        mixed:
            'Predomina una lectura sobre la circulación de la palabra, aunque no de forma homogénea.',
        divided:
            'Las referencias aparecen divididas sobre la circulación de la palabra.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad la circulación de la palabra.',
      );
    case 'interpretation_openness':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en una apertura ${_etiquetaApertura(_roundScale(average)).toLowerCase()} a otras interpretaciones.',
        mixed:
            'Predomina una lectura sobre la apertura a otras interpretaciones, aunque no de forma homogénea.',
        divided:
            'Las referencias aparecen divididas sobre la apertura a otras interpretaciones.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad la apertura a otras interpretaciones.',
      );
    case 'question_space':
      return _framedInsight(
        rating,
        dominant:
            'Hay acuerdo en un lugar para preguntas ${_etiquetaApertura(_roundScale(average)).toLowerCase()}.',
        mixed:
            'Predomina una lectura sobre el lugar para preguntas, aunque no de forma homogénea.',
        divided:
            'Las referencias aparecen divididas sobre el lugar para preguntas.',
        scarce:
            'Todavía hay pocas referencias para leer con claridad el lugar para preguntas.',
      );
    case 'problematization':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza la problematización en clase.',
        intermediateLabel:
            'Predomina una lectura intermedia de la problematización en clase.',
        lowLabel: 'Predomina una lectura de baja problematización en clase.',
        mixedLabel: 'Las referencias son mixtas sobre la problematización.',
        dividedLabel:
            'Las referencias aparecen divididas sobre la problematización en clase.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad la problematización en clase.',
      );
    case 'source_work':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza el trabajo con fuentes.',
        intermediateLabel:
            'Predomina una lectura intermedia del trabajo con fuentes.',
        lowLabel:
            'Predomina una lectura de baja presencia del trabajo con fuentes.',
        mixedLabel: 'Las referencias son mixtas sobre el trabajo con fuentes.',
        dividedLabel:
            'Las referencias aparecen divididas sobre el trabajo con fuentes.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad el trabajo con fuentes.',
      );
    case 'support':
      return _presenceInsight(
        rating: rating,
        strongLabel:
            'Hay acuerdo en que aparece con fuerza el acompañamiento docente.',
        intermediateLabel:
            'Predomina una lectura intermedia del acompañamiento docente.',
        lowLabel: 'Predomina una lectura de bajo acompañamiento docente.',
        mixedLabel:
            'Las referencias son mixtas sobre el acompañamiento docente.',
        dividedLabel:
            'Las referencias aparecen divididas sobre el acompañamiento docente.',
        scarceLabel:
            'Todavía hay pocas referencias para leer con claridad el acompañamiento docente.',
      );
    default:
      return null;
  }
}

String _presenceInsight({
  required RatingResumen rating,
  required String strongLabel,
  required String intermediateLabel,
  required String lowLabel,
  required String mixedLabel,
  required String dividedLabel,
  required String scarceLabel,
}) {
  switch (rating.readingState) {
    case EstadoLecturaReferencia.insufficientData:
      return scarceLabel;
    case EstadoLecturaReferencia.divided:
      return dividedLabel;
    case EstadoLecturaReferencia.mixed:
      return mixedLabel;
    case EstadoLecturaReferencia.consensus:
      break;
  }
  if (rating.promedio >= 3.6) return strongLabel;
  if (rating.promedio <= 2.4) return lowLabel;
  return intermediateLabel;
}

String _framedInsight(
  RatingResumen rating, {
  required String dominant,
  required String mixed,
  required String divided,
  required String scarce,
}) {
  switch (rating.readingState) {
    case EstadoLecturaReferencia.consensus:
      return dominant;
    case EstadoLecturaReferencia.divided:
      return divided;
    case EstadoLecturaReferencia.mixed:
      return mixed;
    case EstadoLecturaReferencia.insufficientData:
      return scarce;
  }
}

int _roundScale(double average) => average.round().clamp(1, 5);
