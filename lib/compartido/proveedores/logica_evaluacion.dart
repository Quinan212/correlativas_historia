// lib/compartido/proveedores/logica_evaluacion.dart
import '../../modelos/materia.dart';

class EvalResult {
  final bool canEnroll;
  final String overallLabel;
  final bool activities;
  final bool activitiesRestricted;
  final bool exams;
  final bool examsRestricted;
  final bool promotion;
  final List<String> notes;
  final String? detailedExplanation;
  final String? strategy;

  const EvalResult({
    required this.canEnroll,
    required this.overallLabel,
    required this.activities,
    required this.activitiesRestricted,
    required this.exams,
    required this.examsRestricted,
    required this.promotion,
    required this.notes,
    this.detailedExplanation,
    this.strategy,
  });
}

const _noPuede = 'Todavía no podés cursar';
const _condicional = 'Cursada condicionada';
const _restricciones = 'Podés cursar con restricciones';
const _sinRestricciones = 'Podés cursar';

const _notaNoPuede = [
  'Para habilitar esta cursada, primero tenés que regularizar o aprobar las correlativas pendientes.'
];

const _notasCondicional = [
  'Podés cursar y hacer actividades o trabajos prácticos si la cátedra lo habilita.',
  'Los parciales y la promoción no quedan habilitados hasta que apruebes las correlativas pendientes en una mesa de examen.',
];

const _notasSinRestr = [
  'Podés hacer actividades, rendir parciales y acceder a la promoción.',
  'Si cumplís con la asistencia y las notas requeridas, no hace falta rendir final.',
];

const _notasRestr = [
  'Podés cursar y hacer actividades o trabajos prácticos.',
  'Para rendir parciales o acceder a la promoción, primero tenés que aprobar las correlativas que hoy figuran regularizadas.',
  'Si no las aprobás a tiempo en una mesa de examen, no vas a poder promocionar y vas a quedar en condición regular si cumplís los requisitos de la cursada.',
  'El final de esta materia queda habilitado una vez que apruebes todas las correlativas pendientes.',
];

EvalResult evaluateCourse(
  Materia? course,
  Map<String, String> map,
  List<Materia> all,
) {
  if (course == null) {
    return const EvalResult(
      canEnroll: false,
      overallLabel: 'Seleccioná una materia',
      activities: false,
      activitiesRestricted: false,
      exams: false,
      examsRestricted: false,
      promotion: false,
      notes: ['Seleccioná una materia para empezar.'],
    );
  }

  final aItems =
      course.correlativasDetalladas.where((c) => c.type == 'A').toList();
  final rItems =
      course.correlativasDetalladas.where((c) => c.type == 'R').toList();

  final notSet =
      course.correlativasDetalladas.where((c) => map[c.id] == null).toList();
  if (notSet.isNotEmpty) {
    final nombresPend = notSet.map((c) {
      if (c.isSpecial == true && c.nombre != null) return c.nombre!;
      final hit = all.where((x) => x.id == c.id);
      if (hit.isEmpty) return course.nombre;
      return hit.first.nombre;
    }).join(', ');

    return EvalResult(
      canEnroll: false,
      overallLabel: 'Seleccioná estados',
      activities: false,
      activitiesRestricted: false,
      exams: false,
      examsRestricted: false,
      promotion: false,
      notes: [
        'Tenés que marcar el estado de estas correlativas: $nombresPend.',
        'Marca cada una como no regularizada, regularizada o aprobada.',
      ],
      strategy: 'Completá los estados y volvé a revisar el escenario.',
    );
  }

  final anyNoReg = course.correlativasDetalladas.any(
    (c) => map[c.id] == 'no-regularizada',
  );

  final aAllApproved = aItems.every((c) => map[c.id] == 'aprobada');

  final rAllAtLeastReg = rItems.every(
    (c) => map[c.id] == 'aprobada' || map[c.id] == 'regularizada',
  );

  final allApproved =
      course.correlativasDetalladas.every((c) => map[c.id] == 'aprobada');

  if (anyNoReg) {
    return const EvalResult(
      canEnroll: false,
      overallLabel: _noPuede,
      activities: false,
      activitiesRestricted: false,
      exams: false,
      examsRestricted: false,
      promotion: false,
      notes: _notaNoPuede,
      strategy:
          'Regularizá o aprobá las correlativas que faltan antes de inscribirte.',
    );
  }

  if (!aAllApproved) {
    final missingNames = aItems.where((c) => map[c.id] != 'aprobada').map((c) {
      if (c.isSpecial == true && c.nombre != null) return c.nombre!;
      final hit = all.where((x) => x.id == c.id);
      if (hit.isEmpty) return course.nombre;
      return hit.first.nombre;
    }).join(', ');

    return EvalResult(
      canEnroll: false,
      overallLabel: _condicional,
      activities: true,
      activitiesRestricted: true,
      exams: true,
      examsRestricted: true,
      promotion: false,
      notes: _notasCondicional,
      detailedExplanation:
          'Según el reglamento, esta cursada no debería quedar plenamente habilitada hasta que apruebes todas las (A) pendientes: $missingNames. En algunos casos la cátedra puede permitir una cursada condicionada si te comprometés a aprobarlas pronto en una mesa habilitada.',
      strategy:
          'Hablá con la cátedra y priorizá aprobar las (A) en la próxima mesa.',
    );
  }

  if (rAllAtLeastReg) {
    if (allApproved) {
      return const EvalResult(
        canEnroll: true,
        overallLabel: _sinRestricciones,
        activities: true,
        activitiesRestricted: false,
        exams: true,
        examsRestricted: false,
        promotion: true,
        notes: _notasSinRestr,
        strategy:
            'Sostené las notas y la asistencia para llegar a la promoción.',
      );
    } else {
      return const EvalResult(
        canEnroll: true,
        overallLabel: _restricciones,
        activities: true,
        activitiesRestricted: false,
        exams: true,
        examsRestricted: true,
        promotion: false,
        notes: _notasRestr,
        strategy:
            'Aprobá las (R) cuanto antes para habilitar la evaluación completa y la posibilidad de promocionar.',
      );
    }
  }

  return const EvalResult(
    canEnroll: false,
    overallLabel: _noPuede,
    activities: false,
    activitiesRestricted: false,
    exams: false,
    examsRestricted: false,
    promotion: false,
    notes: ['Revisa y completa el estado de las correlativas.'],
  );
}
