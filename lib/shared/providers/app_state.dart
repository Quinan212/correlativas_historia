// lib/shared/providers/app_state.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/html_source_loader.dart';
import '../../models/materia.dart';

class CareerInfo {
  final String id;
  final String nombre;
  final String assetHtml;
  final String downloadUrl;
  final String categoria;
  final String? iconAsset;
  final bool hidden;

  const CareerInfo({
    required this.id,
    required this.nombre,
    required this.assetHtml,
    required this.downloadUrl,
    required this.categoria,
    this.iconAsset,
    this.hidden = false,
  });
}

class MateriaOverride {
  final String materiaId;
  final String? codigo;
  final String? nombre;
  final int? anio;
  final int? cuatri;
  final String? tipo;
  final String? formato;
  final String? horas;

  const MateriaOverride({
    required this.materiaId,
    this.codigo,
    this.nombre,
    this.anio,
    this.cuatri,
    this.tipo,
    this.formato,
    this.horas,
  });
}

class InstitutionInfo {
  final String id;
  final String careerId;
  final String nombre;
  final String? iconAsset;
  final String? downloadUrl;
  final List<MateriaOverride> overrides;
  final bool hidden;

  const InstitutionInfo({
    required this.id,
    required this.careerId,
    required this.nombre,
    this.iconAsset,
    this.downloadUrl,
    this.overrides = const [],
    this.hidden = false,
  });
}

String? institutionIconForCareer(String careerId) {
  for (final institution in kInstitutions) {
    if (institution.careerId == careerId && institution.iconAsset != null) {
      return institution.iconAsset;
    }
  }
  return null;
}

const List<CareerInfo> kCareers = [
  CareerInfo(
    id: 'historia',
    nombre: 'Profesorado de Historia',
    assetHtml: 'assets/historia.html',
    downloadUrl:
        'https://drive.google.com/file/d/13znCaPZBl00OHVRLZhJ6Fh8CQaGIKi63/view?usp=sharing',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  CareerInfo(
    id: 'geografia',
    nombre: 'Profesorado en Geografía',
    assetHtml: 'assets/geografia.html',
    downloadUrl:
        'https://drive.google.com/file/d/1Sj91vNoBMlo_0ZPOAvLEJciPsjaWH4S9/view',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  CareerInfo(
    id: 'politica',
    nombre: 'Profesorado en Ciencia Política',
    assetHtml: 'assets/politica.html',
    downloadUrl:
        'https://drive.google.com/file/d/1UjXaF41TL5AKRpOaE9YJOIdtAguPUJ83/view?usp=sharing',
    categoria: 'profesorado',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  CareerInfo(
    id: 'artes_visuales',
    nombre: 'Profesorado en Artes Visuales',
    assetHtml: 'assets/Artes_visuales.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_artes_visuales',
    categoria: 'profesorado',
  ),
  CareerInfo(
    id: 'fisica',
    nombre: 'Profesorado en Física',
    assetHtml: 'assets/Fisica.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_fisica',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'musica',
    nombre: 'Profesorado en Música',
    assetHtml: 'assets/Musica.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_musica',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'lengua_literatura',
    nombre: 'Profesorado en Lengua y Literatura',
    assetHtml: 'assets/Lengua_Literatura.html',
    downloadUrl:
        'https://drive.google.com/tu_link_oficial_de_lengua_literatura',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'biologia',
    nombre: 'Profesorado en Biología',
    assetHtml: 'assets/Biologia.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_biologia',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'filosofia',
    nombre: 'Profesorado en Filosofía',
    assetHtml: 'assets/Filosofia.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_filosofia',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'psicologia',
    nombre: 'Profesorado en Psicología',
    assetHtml: 'assets/Psicologia.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_psicologia',
    categoria: 'profesorado',
    hidden: true,
  ),
  CareerInfo(
    id: 'contador',
    nombre: 'Contador Público',
    assetHtml: 'assets/contador_publico.html',
    downloadUrl: 'https://drive.google.com/tu_link_oficial_de_contador',
    categoria: 'grado',
    hidden: true,
  ),
];

const List<InstitutionInfo> kInstitutions = [
  InstitutionInfo(
    id: 'historia_pscs',
    careerId: 'historia',
    nombre: 'Profesorado Superior de Ciencias Sociales',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  InstitutionInfo(
    id: 'geografia_pscs',
    careerId: 'geografia',
    nombre: 'Profesorado Superior de Ciencias Sociales',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  InstitutionInfo(
    id: 'politica_pscs',
    careerId: 'politica',
    nombre: 'Profesorado Superior de Ciencias Sociales',
    iconAsset: 'assets/career_icons/career_logo.png',
  ),
  InstitutionInfo(
    id: 'artes_visuales_cesareo',
    careerId: 'artes_visuales',
    nombre:
        'Instituto Superior de Formación Docente N° 1 "Cesáreo Bernaldo de Quirós"',
    iconAsset: 'assets/career_icons/logo_artes.png',
  ),
];

// =================== THEME ===================

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.light);

void toggleTheme(WidgetRef ref) {
  final cur = ref.read(themeModeProvider);
  ref.read(themeModeProvider.notifier).state =
      cur == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
}

// =================== CAREERS ===================

final careersProvider = Provider<List<CareerInfo>>(
    (_) => kCareers.where((c) => !c.hidden).toList());

// 'todas' | 'profesorado' | 'grado'
final selectedCareerTypeProvider = StateProvider<String>((_) => 'todas');

final selectedCareerIdProvider = StateProvider<String?>((_) => null);
final selectedInstitutionIdProvider = StateProvider<String?>((_) => null);

// lista filtrada según tipo/categoría
final careersByTypeProvider = Provider<List<CareerInfo>>((ref) {
  final type = ref.watch(selectedCareerTypeProvider);
  final all = ref.watch(careersProvider);

  if (type == 'todas') return all;
  return all.where((c) => c.categoria == type).toList();
});

// carrera seleccionada (si el id no está en la lista filtrada, cae al primero)
final selectedCareerInfoOrNullProvider = Provider<CareerInfo?>((ref) {
  final id = ref.watch(selectedCareerIdProvider);
  if (id == null) return null;
  final all = ref.watch(careersProvider);
  for (final career in all) {
    if (career.id == id) return career;
  }
  return null;
});

final hasSelectedCareerProvider = Provider<bool>((ref) {
  return ref.watch(selectedCareerInfoOrNullProvider) != null;
});

// Compatibilidad para consumidores que todavía esperan una carrera no nula.
final selectedCareerInfoProvider = Provider<CareerInfo>((ref) {
  final selected = ref.watch(selectedCareerInfoOrNullProvider);
  if (selected != null) return selected;
  final available = ref.watch(careersByTypeProvider);
  return available.isNotEmpty ? available.first : kCareers.first;
});

final institutionsProvider = Provider<List<InstitutionInfo>>(
    (_) => kInstitutions.where((i) => !i.hidden).toList());

final institutionsForSelectedCareerProvider =
    Provider<List<InstitutionInfo>>((ref) {
  final careerId = ref.watch(selectedCareerInfoOrNullProvider)?.id;
  if (careerId == null) return const <InstitutionInfo>[];
  final all = ref.watch(institutionsProvider);
  return all.where((i) => i.careerId == careerId).toList();
});

final selectedInstitutionInfoProvider = Provider<InstitutionInfo?>((ref) {
  final selectedId = ref.watch(selectedInstitutionIdProvider);
  final available = ref.watch(institutionsForSelectedCareerProvider);
  if (available.isEmpty) return null;
  for (final institution in available) {
    if (institution.id == selectedId) return institution;
  }
  return available.first;
});

final careerDownloadUrlProvider = Provider<String>((ref) {
  final career = ref.watch(selectedCareerInfoOrNullProvider);
  if (career == null) return '';
  final institution = ref.watch(selectedInstitutionInfoProvider);
  if (institution?.downloadUrl != null &&
      institution!.downloadUrl!.isNotEmpty) {
    return institution.downloadUrl!;
  }
  return career.downloadUrl;
});

List<Materia> _applyInstitutionOverrides(
  List<Materia> materias,
  List<MateriaOverride> overrides,
) {
  if (overrides.isEmpty) return materias;

  final byId = <String, MateriaOverride>{
    for (final override in overrides) override.materiaId: override,
  };

  return materias.map((m) {
    final override = byId[m.id];
    if (override == null) return m;
    return Materia(
      id: m.id,
      codigo: override.codigo ?? m.codigo,
      nombre: override.nombre ?? m.nombre,
      anio: override.anio ?? m.anio,
      cuatri: override.cuatri ?? m.cuatri,
      tipo: override.tipo ?? m.tipo,
      formato: override.formato ?? m.formato,
      correlativas: m.correlativas,
      horas: override.horas ?? m.horas,
      correlativasDetalladas: m.correlativasDetalladas,
    );
  }).toList(growable: false);
}

// sin autoDispose para evitar recargas al navegar
final planProvider = FutureProvider<PlanData>((ref) async {
  final career = ref.watch(selectedCareerInfoOrNullProvider);
  if (career == null) {
    return PlanData(materias: const [], pdfUrl: null);
  }
  final institution = ref.watch(selectedInstitutionInfoProvider);
  final basePlan = await loadPlanFromHtmlAsset(career.assetHtml);
  final materias = _applyInstitutionOverrides(
    basePlan.materias,
    institution?.overrides ?? const [],
  );
  return PlanData(
    materias: materias,
    pdfUrl: Uri.tryParse(
          institution?.downloadUrl?.isNotEmpty == true
              ? institution!.downloadUrl!
              : career.downloadUrl,
        ) ??
        basePlan.pdfUrl,
  );
});

// =================== ROUTER ===================

final routerIndexProvider = StateProvider<int>((_) => 0);

// =================== MAP FILTERS ===================

final searchTermProvider = StateProvider<String>((_) => '');
final filtroTipoProvider = StateProvider<String>((_) => 'todos');
final filtroAnioProvider = StateProvider<int?>((_) => null);
final compactModeProvider = StateProvider<bool>((_) => false);

// =================== MAP ZOOM / TRANSFORM ===================

final zoomProvider = StateProvider<double>((_) => 1.0);

final transformationControllerProvider =
    Provider.autoDispose<TransformationController>((ref) {
  final c = TransformationController();
  ref.onDispose(c.dispose);
  return c;
});

// =================== SELECTION ===================

final selectedMateriaIdProvider = StateProvider<String?>((_) => null);

final filteredMateriasProvider = Provider<List<Materia>>(
  (ref) {
    final plan = ref.watch(planProvider).maybeWhen(
          data: (p) => p,
          orElse: () => null,
        );

    final term = ref.watch(searchTermProvider);
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);

    final list = plan?.materias ?? const <Materia>[];
    return list.where((m) {
      final t = term.trim().toLowerCase();
      final okTerm = t.isEmpty ||
          m.nombre.toLowerCase().contains(t) ||
          m.codigo.toLowerCase().contains(t);

      final okTipo = (tipo == 'todos') || (m.tipo == tipo);
      final okAnio = (anio == null) || (m.anio == anio);

      return okTerm && okTipo && okAnio;
    }).toList();
  },
  name: 'filteredMateriasProvider',
  dependencies: [
    planProvider,
    searchTermProvider,
    filtroTipoProvider,
    filtroAnioProvider,
  ],
);

List<Materia> getDependents(List<Materia> all, String materiaId) =>
    all.where((m) => m.correlativas.contains(materiaId)).toList();

List<String> getTodasCorrelativas(
  List<Materia> all,
  String materiaId, [
  Set<String>? acc,
]) {
  acc ??= <String>{};

  final hit = all.where((m) => m.id == materiaId);
  if (hit.isEmpty) return acc.toList();

  final materia = hit.first;
  if (materia.correlativas.isEmpty) return acc.toList();

  for (final corr in materia.correlativas) {
    if (acc.add(corr)) {
      getTodasCorrelativas(all, corr, acc);
    }
  }
  return acc.toList();
}

// =================== CALCULADORA ===================

final evalYearProvider = StateProvider<int>((_) => 2);
final selectedCalcMateriaIdProvider = StateProvider<String?>((_) => null);

final correlativaStatusMapProvider =
    StateNotifierProvider<CorrelativaStatusMap, Map<String, String>>(
  (ref) => CorrelativaStatusMap(),
);

class CorrelativaStatusMap extends StateNotifier<Map<String, String>> {
  CorrelativaStatusMap() : super({});

  void setStatus(String id, String status) {
    final newMap = Map<String, String>.from(state);
    newMap[id] = status;
    state = newMap;
  }

  void clear() => state = {};
}

final correlativasScrollOffsetProvider = StateProvider<double>((_) => 0.0);

// =================== EVALUATION ===================

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
