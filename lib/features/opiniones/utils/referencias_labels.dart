import '../models/opiniones_rating.dart';

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

String matterDimensionLabel(String key) {
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

String matterDimensionScaleLabel(String key, int value) {
  if (value <= 0) return 'Sin marcar';

  switch (key) {
    case 'classroom_climate':
      return _climateLabel(value);
    case 'reading_load':
    case 'demand_level':
      return _intensityLabel(value);
    case 'course_clarity':
      return _clarityLabel(value);
    case 'formative_value':
      return _formativeValueLabel(value);
    case 'problematization':
    case 'source_work':
    case 'past_present_link':
    case 'theory_practice':
    case 'course_support':
      return _presenceLabel(value);
    default:
      return _presenceLabel(value);
  }
}

String teacherAspectLabel(String key) {
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

String teacherAspectScaleLabel(String key, int value) {
  if (value <= 0) return 'Sin marcar';

  switch (key) {
    case 'classroom_climate':
      return _climateLabel(value);
    case 'word_circulation':
    case 'interpretation_openness':
    case 'question_space':
      return _opennessLabel(value);
    case 'clarity_exposition':
    case 'evaluation_clarity':
      return _clarityLabel(value);
    case 'problematization':
    case 'source_work':
    case 'support':
      return _presenceLabel(value);
    default:
      return _presenceLabel(value);
  }
}

String matterTagLabel(String tag) {
  switch (tag) {
    case 'classroom_climate':
      return matterDimensionLabel(tag);
    case 'reading_load':
      return matterDimensionLabel(tag);
    case 'demand_level':
      return matterDimensionLabel(tag);
    case 'problematization':
      return matterDimensionLabel(tag);
    case 'source_work':
      return matterDimensionLabel(tag);
    case 'past_present_link':
      return matterDimensionLabel(tag);
    case 'theory_practice':
      return matterDimensionLabel(tag);
    case 'course_clarity':
      return matterDimensionLabel(tag);
    case 'course_support':
      return matterDimensionLabel(tag);
    case 'formative_value':
      return matterDimensionLabel(tag);
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

int _maxOf(int? current, int next) => current == null ? next : (current > next ? current : next);

String _presenceLabel(int value) {
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

String _clarityLabel(int value) {
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

String _climateLabel(int value) {
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

String _opennessLabel(int value) {
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

String _intensityLabel(int value) {
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

String _formativeValueLabel(int value) {
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

List<String> buildMatterReferenceInsights(Map<String, RatingResumen> dimensions) {
  final entries = dimensions.entries
      .where((entry) => entry.value.votos > 0)
      .toList(growable: false);
  if (entries.isEmpty) return const <String>[];

  final sorted = [...entries]
    ..sort((a, b) {
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

  final sorted = [...entries]
    ..sort((a, b) {
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
  final mixed = _isMixed(average);
  switch (key) {
    case 'reading_load':
      return mixed
          ? 'Hay referencias mixtas sobre la carga de lectura.'
          : 'Predomina una percepcion de carga de lectura ${_intensityLabel(_roundScale(average)).toLowerCase()}.';
    case 'demand_level':
      return mixed
          ? 'Hay referencias mixtas sobre el nivel de exigencia.'
          : 'Predomina una percepcion de exigencia ${_intensityLabel(_roundScale(average)).toLowerCase()}.';
    case 'classroom_climate':
      return mixed
          ? 'Las referencias muestran un clima de cursada mas bien variable.'
          : 'El clima general de cursada aparece como ${_climateLabel(_roundScale(average)).toLowerCase()}.';
    case 'course_clarity':
      return mixed
          ? 'Hay referencias divididas sobre la claridad de la cursada.'
          : 'La cursada suele describirse como ${_clarityLabel(_roundScale(average)).toLowerCase()}.';
    case 'formative_value':
      return mixed
          ? 'Las referencias son mixtas respecto de su valor formativo.'
          : 'Se la describe como ${_formativeValueLabel(_roundScale(average)).toLowerCase()} para la formacion.';
    case 'problematization':
      return _presenceInsight(
        average: average,
        presentLabel: 'Aparece con fuerza la problematizacion de los temas.',
        intermediateLabel:
            'La problematizacion aparece de manera intermedia en las referencias.',
        lowLabel:
            'La problematizacion aparece con poca fuerza en las referencias.',
        mixedLabel: 'Hay referencias mixtas sobre el nivel de problematizacion.',
      );
    case 'source_work':
      return _presenceInsight(
        average: average,
        presentLabel: 'Aparece con fuerza el trabajo con fuentes.',
        intermediateLabel:
            'El trabajo con fuentes aparece de manera intermedia.',
        lowLabel:
            'El trabajo con fuentes aparece con poca fuerza en las referencias.',
        mixedLabel: 'Hay referencias mixtas sobre el trabajo con fuentes.',
      );
    case 'past_present_link':
      return _presenceInsight(
        average: average,
        presentLabel:
            'Aparece con fuerza la relacion entre pasado y presente.',
        intermediateLabel:
            'La relacion entre pasado y presente aparece de manera intermedia.',
        lowLabel:
            'La relacion entre pasado y presente aparece con poca fuerza en las referencias.',
        mixedLabel:
            'Hay referencias mixtas sobre la relacion entre pasado y presente.',
      );
    case 'theory_practice':
      return _presenceInsight(
        average: average,
        presentLabel:
            'Aparece con fuerza la articulacion entre teoria y practica.',
        intermediateLabel:
            'La articulacion entre teoria y practica aparece de manera intermedia.',
        lowLabel:
            'La articulacion entre teoria y practica aparece con poca fuerza en las referencias.',
        mixedLabel:
            'Hay referencias mixtas sobre la articulacion entre teoria y practica.',
      );
    case 'course_support':
      return _presenceInsight(
        average: average,
        presentLabel: 'Aparece con fuerza el acompanamiento en la cursada.',
        intermediateLabel:
            'El acompanamiento en la cursada aparece de manera intermedia.',
        lowLabel:
            'El acompanamiento en la cursada aparece con poca fuerza en las referencias.',
        mixedLabel:
            'Hay referencias mixtas sobre el acompanamiento en la cursada.',
      );
    default:
      return null;
  }
}

String? _buildTeacherInsight(String key, RatingResumen rating) {
  final average = rating.promedio;
  final mixed = _isMixed(average);
  switch (key) {
    case 'clarity_exposition':
      return mixed
          ? 'Hay referencias mixtas sobre la claridad expositiva.'
          : 'La claridad expositiva suele describirse como ${_clarityLabel(_roundScale(average)).toLowerCase()}.';
    case 'evaluation_clarity':
      return mixed
          ? 'Hay referencias divididas sobre los criterios de evaluacion.'
          : 'Los criterios de evaluacion suelen describirse como ${_clarityLabel(_roundScale(average)).toLowerCase()}.';
    case 'classroom_climate':
      return mixed
          ? 'Las referencias muestran un clima de aula mas bien variable.'
          : 'El clima en el aula aparece como ${_climateLabel(_roundScale(average)).toLowerCase()}.';
    case 'word_circulation':
      return mixed
          ? 'Hay referencias mixtas sobre la circulacion de la palabra.'
          : 'La circulacion de la palabra se describe como ${_opennessLabel(_roundScale(average)).toLowerCase()}.';
    case 'interpretation_openness':
      return mixed
          ? 'Hay referencias mixtas sobre la apertura a otras interpretaciones.'
          : 'La apertura a otras interpretaciones aparece como ${_opennessLabel(_roundScale(average)).toLowerCase()}.';
    case 'question_space':
      return mixed
          ? 'Hay referencias mixtas sobre el lugar para preguntas.'
          : 'El lugar para preguntas se describe como ${_opennessLabel(_roundScale(average)).toLowerCase()}.';
    case 'problematization':
      return _presenceInsight(
        average: average,
        presentLabel: 'Aparece con fuerza la problematizacion en clase.',
        intermediateLabel:
            'La problematizacion aparece de manera intermedia en las referencias.',
        lowLabel:
            'La problematizacion aparece con poca fuerza en las referencias.',
        mixedLabel: 'Hay referencias mixtas sobre la problematizacion.',
      );
    case 'source_work':
      return _presenceInsight(
        average: average,
        presentLabel: 'Aparece con fuerza el trabajo con fuentes.',
        intermediateLabel:
            'El trabajo con fuentes aparece de manera intermedia.',
        lowLabel:
            'El trabajo con fuentes aparece con poca fuerza en las referencias.',
        mixedLabel: 'Hay referencias mixtas sobre el trabajo con fuentes.',
      );
    case 'support':
      return _presenceInsight(
        average: average,
        presentLabel: 'Aparece con fuerza el acompanamiento docente.',
        intermediateLabel:
            'El acompanamiento docente aparece de manera intermedia.',
        lowLabel:
            'El acompanamiento docente aparece con poca fuerza en las referencias.',
        mixedLabel: 'Hay referencias mixtas sobre el acompanamiento docente.',
      );
    default:
      return null;
  }
}

String _presenceInsight({
  required double average,
  required String presentLabel,
  required String intermediateLabel,
  required String lowLabel,
  required String mixedLabel,
}) {
  if (_isMixed(average)) return mixedLabel;
  if (average >= 3.6) return presentLabel;
  if (average <= 2.4) return lowLabel;
  return intermediateLabel;
}

bool _isMixed(double average) => average >= 2.7 && average <= 3.3;

int _roundScale(double average) => average.round().clamp(1, 5);
