class MateriaOpinion {
  const MateriaOpinion({
    required this.materiaId,
    required this.rating,
    this.comentario,
    this.tags = const <String>[],
  });

  final String materiaId;
  final int rating;
  final String? comentario;
  final List<String> tags;
}

class DocenteOpinion {
  const DocenteOpinion({
    required this.docenteId,
    required this.general,
    required this.aspectos,
    this.comentario,
  });

  final String docenteId;
  final int general;
  final Map<String, int> aspectos;
  final String? comentario;
}

class RatingResumen {
  const RatingResumen({
    required this.promedio,
    required this.votos,
    this.dispersion = 0,
    this.readingState = EstadoLecturaReferencia.insufficientData,
  });

  final double promedio;
  final int votos;
  final double dispersion;
  final EstadoLecturaReferencia readingState;

  bool get hasInterpretiveSignal => votos >= 2;
}

enum EstadoLecturaReferencia {
  insufficientData,
  consensus,
  mixed,
  divided,
}

class DocenteRatingResumen {
  const DocenteRatingResumen({
    required this.general,
    required this.aspectos,
  });

  final RatingResumen general;
  final Map<String, RatingResumen> aspectos;
}

class MateriaComunidadFicha {
  const MateriaComunidadFicha({
    required this.materiaId,
    required this.rating,
    required this.docentes,
    required this.tagsFrecuentes,
  });

  final String materiaId;
  final RatingResumen rating;
  final List<String> docentes;
  final List<String> tagsFrecuentes;
}

class DocenteComunidadFicha {
  const DocenteComunidadFicha({
    required this.docenteId,
    required this.rating,
    required this.materias,
  });

  final String docenteId;
  final DocenteRatingResumen rating;
  final List<String> materias;
}
