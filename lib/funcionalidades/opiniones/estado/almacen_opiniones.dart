import 'package:flutter_riverpod/legacy.dart';

import '../modelos/calificacion_opiniones.dart';

const kDocenteAspectos = <String>[
  'explica',
  'claridad',
  'exigencia',
  'trato',
  'organizacion',
  'recomendacion',
];

class EstadoOpiniones {
  const EstadoOpiniones({
    this.materias = const <String, List<MateriaOpinion>>{},
    this.docentes = const <String, List<DocenteOpinion>>{},
  });

  final Map<String, List<MateriaOpinion>> materias;
  final Map<String, List<DocenteOpinion>> docentes;

  EstadoOpiniones copyWith({
    Map<String, List<MateriaOpinion>>? materias,
    Map<String, List<DocenteOpinion>>? docentes,
  }) {
    return EstadoOpiniones(
      materias: materias ?? this.materias,
      docentes: docentes ?? this.docentes,
    );
  }
}

class AlmacenOpiniones extends StateNotifier<EstadoOpiniones> {
  AlmacenOpiniones() : super(_seedState);

  static final EstadoOpiniones _seedState = EstadoOpiniones(
    materias: {
      'pedagogia': const [
        MateriaOpinion(
          materiaId: 'pedagogia',
          rating: 4,
          tags: ['promocionable', 'mucha lectura'],
          comentario:
              'La cursada se hace llevadera si llevas los textos al día.',
        ),
        MateriaOpinion(
          materiaId: 'pedagogia',
          rating: 5,
          tags: ['clara', 'buenos apuntes'],
        ),
      ],
      'didactica_general': const [
        MateriaOpinion(
          materiaId: 'didactica_general',
          rating: 4,
          tags: ['mucho tp'],
        ),
      ],
    },
    docentes: {
      'borche_javier': const [
        DocenteOpinion(
          docenteId: 'borche_javier',
          general: 5,
          aspectos: {
            'explica': 5,
            'claridad': 5,
            'exigencia': 4,
            'trato': 4,
            'organizacion': 4,
            'recomendacion': 5,
          },
          comentario: 'Muy claro y ordenado para exponer los temas.',
        ),
      ],
      'leiva_carina': const [
        DocenteOpinion(
          docenteId: 'leiva_carina',
          general: 4,
          aspectos: {
            'explica': 4,
            'claridad': 4,
            'exigencia': 3,
            'trato': 5,
            'organizacion': 4,
            'recomendacion': 4,
          },
        ),
      ],
    },
  );

  void agregarOpinionMateria(MateriaOpinion opinion) {
    final actuales = List<MateriaOpinion>.from(
      state.materias[opinion.materiaId] ?? const <MateriaOpinion>[],
    )..add(opinion);

    state = state.copyWith(
      materias: {
        ...state.materias,
        opinion.materiaId: List<MateriaOpinion>.unmodifiable(actuales),
      },
    );
  }

  void agregarOpinionDocente(DocenteOpinion opinion) {
    final actuales = List<DocenteOpinion>.from(
      state.docentes[opinion.docenteId] ?? const <DocenteOpinion>[],
    )..add(opinion);

    state = state.copyWith(
      docentes: {
        ...state.docentes,
        opinion.docenteId: List<DocenteOpinion>.unmodifiable(actuales),
      },
    );
  }
}

final proveedorAlmacenOpiniones =
    StateNotifierProvider<AlmacenOpiniones, EstadoOpiniones>(
  (ref) => AlmacenOpiniones(),
);
