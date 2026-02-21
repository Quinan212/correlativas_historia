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
  final bool hidden;

  const CareerInfo({
    required this.id,
    required this.nombre,
    required this.assetHtml,
    required this.downloadUrl,
    required this.categoria,
    this.hidden = false,
  });
}

const List<CareerInfo> kCareers = [
  CareerInfo(
    id: 'historia',
    nombre: 'Profesorado de Historia',
    assetHtml: 'assets/historia.html',
    downloadUrl:
    'https://drive.google.com/file/d/13znCaPZBl00OHVRLZhJ6Fh8CQaGIKi63/view?usp=sharing',
    categoria: 'profesorado',
  ),
  CareerInfo(
    id: 'geografia',
    nombre: 'Profesorado en Geografía',
    assetHtml: 'assets/geografia.html',
    downloadUrl:
    'https://drive.google.com/file/d/1Sj91vNoBMlo_0ZPOAvLEJciPsjaWH4S9/view',
    categoria: 'profesorado',
  ),
  CareerInfo(
    id: 'politica',
    nombre: 'Profesorado en Ciencia Política',
    assetHtml: 'assets/politica.html',
    downloadUrl:
    'https://drive.google.com/file/d/1UjXaF41TL5AKRpOaE9YJOIdtAguPUJ83/view?usp=sharing',
    categoria: 'profesorado',
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

final careersProvider = Provider<List<CareerInfo>>((_) =>
    kCareers.where((c) => !c.hidden).toList());

// 'todas' | 'profesorado' | 'grado'
final selectedCareerTypeProvider = StateProvider<String>((_) => 'todas');

final selectedCareerIdProvider = StateProvider<String>((_) => 'historia');

// lista filtrada según tipo/categoría
final careersByTypeProvider = Provider<List<CareerInfo>>((ref) {
  final type = ref.watch(selectedCareerTypeProvider);
  final all = ref.watch(careersProvider);

  if (type == 'todas') return all;
  return all.where((c) => c.categoria == type).toList();
});

// carrera seleccionada (si el id no está en la lista filtrada, cae al primero)
final selectedCareerInfoProvider = Provider<CareerInfo>((ref) {
  final id = ref.watch(selectedCareerIdProvider);
  final available = ref.watch(careersByTypeProvider);

  return available.firstWhere(
        (c) => c.id == id,
    orElse: () => available.isNotEmpty ? available.first : kCareers.first,
  );
});

final careerDownloadUrlProvider =
Provider<String>((ref) => ref.watch(selectedCareerInfoProvider).downloadUrl);

// sin autoDispose para evitar recargas al navegar
final planProvider = FutureProvider<PlanData>((ref) async {
  final career = ref.watch(selectedCareerInfoProvider);
  return loadPlanFromHtmlAsset(career.assetHtml);
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

const _NO_PUEDE = 'No puede cursar';
const _CONDICIONAL = 'Cursada condicional';
const _RESTRICCIONES = 'Cursa con restricciones';
const _SIN_RESTRICCIONES = 'Puede cursar sin restricciones';

const _NOTA_NO_PUEDE = [
  'Debes, como mínimo, regularizar o aprobar las correlativas pendientes para habilitar la cursada.'
];

const _NOTAS_CONDICIONAL = [
  'Puedes cursar y realizar actividades y trabajos prácticos solo si el/la docente lo permite.',
  'Parciales y promoción no habilitados hasta aprobar previamente las correlativas pendientes en mesa extraordinaria (u otra habilitada).',
];

const _NOTAS_SIN_RESTR = [
  'Puedes hacer actividades, rendir parciales y promocionar directamente.',
  'Si cumples asistencia y notas mínimas, no necesitas rendir final.',
];

const _NOTAS_RESTR = [
  'Puedes cursar y realizar actividades y trabajos prácticos.',
  'Para rendir parciales o promocionar, primero debes APROBAR las correlativas que tienes regularizadas.',
  'Si no las apruebas a tiempo en una mesa de examen, no podrás promocionar y quedarás en condición "Regular" (si cumples los requisitos de la cursada).',
  'Podrás rendir el examen final de esta materia una vez que hayas aprobado todas las correlativas pendientes.',
];

EvalResult evaluateCourse(
    Materia? course,
    Map<String, String> map,
    List<Materia> all,
    ) {
  if (course == null) {
    return const EvalResult(
      canEnroll: false,
      overallLabel: 'Selecciona una materia',
      activities: false,
      activitiesRestricted: false,
      exams: false,
      examsRestricted: false,
      promotion: false,
      notes: ['Selecciona una materia para comenzar.'],
    );
  }

  final aItems = course.correlativasDetalladas.where((c) => c.type == 'A').toList();
  final rItems = course.correlativasDetalladas.where((c) => c.type == 'R').toList();

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
      overallLabel: 'Selecciona estados',
      activities: false,
      activitiesRestricted: false,
      exams: false,
      examsRestricted: false,
      promotion: false,
      notes: [
        'Debes seleccionar el estado de las correlativas: $nombresPend.',
        'Marca para cada una si está no-regularizada, regularizada o aprobada.',
      ],
      strategy: 'Completa los estados y vuelve a evaluar.',
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
      overallLabel: _NO_PUEDE,
      activities: false,
      activitiesRestricted: false,
      exams: false,
      examsRestricted: false,
      promotion: false,
      notes: _NOTA_NO_PUEDE,
      strategy: 'Regulariza/aprueba las correlativas faltantes antes de inscribirte.',
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
      overallLabel: _CONDICIONAL,
      activities: true,
      activitiesRestricted: true,
      exams: true,
      examsRestricted: true,
      promotion: false,
      notes: _NOTAS_CONDICIONAL,
      detailedExplanation:
      'Según el reglamento, no deberías poder cursar hasta aprobar todas las (A) pendientes: $missingNames. Algunxs docentes pueden permitir cursada condicional si te comprometés a aprobar pronto en mesa/instancia habilitada.',
      strategy: 'Gestiona autorización y prioriza aprobar las (A) en la próxima mesa.',
    );
  }

  if (rAllAtLeastReg) {
    if (allApproved) {
      return const EvalResult(
        canEnroll: true,
        overallLabel: _SIN_RESTRICCIONES,
        activities: true,
        activitiesRestricted: false,
        exams: true,
        examsRestricted: false,
        promotion: true,
        notes: _NOTAS_SIN_RESTR,
        strategy: 'Mantén calificaciones y asistencia para promocionar.',
      );
    } else {
      return const EvalResult(
        canEnroll: true,
        overallLabel: _RESTRICCIONES,
        activities: true,
        activitiesRestricted: false,
        exams: true,
        examsRestricted: true,
        promotion: false,
        notes: _NOTAS_RESTR,
        strategy:
        'Aprobá las (R) cuanto antes para habilitar evaluación completa y la posibilidad de promocionar.',
      );
    }
  }

  return const EvalResult(
    canEnroll: false,
    overallLabel: _NO_PUEDE,
    activities: false,
    activitiesRestricted: false,
    exams: false,
    examsRestricted: false,
    promotion: false,
    notes: ['Debes revisar y completar el estado de las correlativas.'],
  );
}