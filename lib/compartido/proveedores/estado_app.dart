// lib/compartido/proveedores/estado_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../datos/cargador_fuente_html.dart';
import '../../modelos/materia.dart';
import 'datos_catalogo.dart';

export 'datos_catalogo.dart';
export 'logica_evaluacion.dart';

// =================== THEME ===================

final proveedorModoTema = StateProvider<ThemeMode>((_) => ThemeMode.system);

ThemeMode modoTemaOpuestoPara(Brightness brightness) {
  return brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
}

void toggleTheme(WidgetRef ref, {Brightness? brightnessActual}) {
  final modoSeleccionado = ref.read(proveedorModoTema);
  final brightnessEfectivo =
      brightnessActual ??
      switch (modoSeleccionado) {
        ThemeMode.dark => Brightness.dark,
        ThemeMode.light => Brightness.light,
        ThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
      };

  ref.read(proveedorModoTema.notifier).state = modoTemaOpuestoPara(
    brightnessEfectivo,
  );
}

// =================== CAREERS ===================

final proveedorCarreras = Provider<List<CareerInfo>>(
  (_) => kCareers.where((c) => !c.hidden).toList(),
);

// 'todas' | 'profesorado' | 'grado'
final proveedorTipoCarreraSeleccionada = StateProvider<String>((_) => 'todas');

final proveedorIdCarreraSeleccionada = StateProvider<String?>((_) => null);
final proveedorIdInstitucionSeleccionada = StateProvider<String?>((_) => null);

// lista filtrada según tipo/categoría
final proveedorCarrerasPorTipo = Provider<List<CareerInfo>>((ref) {
  final type = ref.watch(proveedorTipoCarreraSeleccionada);
  final all = ref.watch(proveedorCarreras);

  if (type == 'todas') return all;
  return all.where((c) => c.categoria == type).toList();
});

// carrera seleccionada (si el id no está en la lista filtrada, cae al primero)
final proveedorCarreraSeleccionadaONula = Provider<CareerInfo?>((ref) {
  final id = ref.watch(proveedorIdCarreraSeleccionada);
  if (id == null) return null;
  final all = ref.watch(proveedorCarreras);
  for (final career in all) {
    if (career.id == id) return career;
  }
  return null;
});

final proveedorTieneCarreraSeleccionada = Provider<bool>((ref) {
  return ref.watch(proveedorCarreraSeleccionadaONula) != null;
});

// Compatibilidad para consumidores que todavía esperan una carrera no nula.
final proveedorCarreraSeleccionada = Provider<CareerInfo>((ref) {
  final selected = ref.watch(proveedorCarreraSeleccionadaONula);
  if (selected != null) return selected;
  final available = ref.watch(proveedorCarrerasPorTipo);
  return available.isNotEmpty ? available.first : kCareers.first;
});

final proveedorInstituciones = Provider<List<InstitutionInfo>>(
  (_) => kInstitutions.where((i) => !i.hidden).toList(),
);

final proveedorInstitucionesCarreraSeleccionada =
    Provider<List<InstitutionInfo>>((ref) {
      final careerId = ref.watch(proveedorCarreraSeleccionadaONula)?.id;
      if (careerId == null) return const <InstitutionInfo>[];
      final all = ref.watch(proveedorInstituciones);
      return all.where((i) => i.careerId == careerId).toList();
    });

final proveedorInstitucionSeleccionada = Provider<InstitutionInfo?>((ref) {
  final selectedId = ref.watch(proveedorIdInstitucionSeleccionada);
  final available = ref.watch(proveedorInstitucionesCarreraSeleccionada);
  if (available.isEmpty) return null;
  for (final institution in available) {
    if (institution.id == selectedId) return institution;
  }
  return available.first;
});

final proveedorUrlDescargaCarrera = Provider<String>((ref) {
  final career = ref.watch(proveedorCarreraSeleccionadaONula);
  if (career == null) return '';
  final institution = ref.watch(proveedorInstitucionSeleccionada);
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

  return materias
      .map((m) {
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
      })
      .toList(growable: false);
}

// sin autoDispose para evitar recargas al navegar
final proveedorPlan = FutureProvider<DatosPlan>((ref) async {
  final career = ref.watch(proveedorCarreraSeleccionadaONula);
  if (career == null) {
    return DatosPlan(materias: const [], pdfUrl: null);
  }
  final institution = ref.watch(proveedorInstitucionSeleccionada);
  final basePlan = await cargarPlanDesdeAssetHtml(career.assetHtml);
  final materias = _applyInstitutionOverrides(
    basePlan.materias,
    institution?.overrides ?? const [],
  );
  return DatosPlan(
    materias: materias,
    pdfUrl:
        Uri.tryParse(
          institution?.downloadUrl?.isNotEmpty == true
              ? institution!.downloadUrl!
              : career.downloadUrl,
        ) ??
        basePlan.pdfUrl,
  );
});

// =================== ROUTER ===================

final proveedorIndiceRouter = StateProvider<int>((_) => 0);

/// Sección activa de la barra de navegación inferior móvil.
/// 0 = Trayectorias, 1 = Exámenes, 2 = Materias, 3 = Datos.
final proveedorSeccionNav = StateProvider<int>((_) => 0);

final proveedorSageActivo = StateProvider<bool>((_) => false);

// =================== MAP FILTERS ===================

final proveedorTerminoBusqueda = StateProvider<String>((_) => '');
final filtroTipoProvider = StateProvider<String>((_) => 'todos');
final filtroAnioProvider = StateProvider<int?>((_) => null);
final proveedorModoCompacto = StateProvider<bool>((_) => false);

// =================== MAP ZOOM / TRANSFORM ===================

final proveedorZoom = StateProvider<double>((_) => 1.0);

final proveedorControladorTransformacion = Provider<TransformationController>((
  ref,
) {
  final c = TransformationController();
  ref.onDispose(c.dispose);
  return c;
}, isAutoDispose: true);

// =================== SELECTION ===================

final proveedorIdMateriaSeleccionada = StateProvider<String?>((_) => null);

final proveedorMateriasFiltradas = Provider<List<Materia>>(
  (ref) {
    final plan = ref
        .watch(proveedorPlan)
        .maybeWhen(data: (p) => p, orElse: () => null);

    final term = ref.watch(proveedorTerminoBusqueda);
    final tipo = ref.watch(filtroTipoProvider);
    final anio = ref.watch(filtroAnioProvider);

    final list = plan?.materias ?? const <Materia>[];
    return list.where((m) {
      final t = term.trim().toLowerCase();
      final okTerm =
          t.isEmpty ||
          m.nombre.toLowerCase().contains(t) ||
          m.codigo.toLowerCase().contains(t);

      final okTipo = (tipo == 'todos') || (m.tipo == tipo);
      final okAnio = (anio == null) || (m.anio == anio);

      return okTerm && okTipo && okAnio;
    }).toList();
  },
  name: 'proveedorMateriasFiltradas',
  dependencies: [
    proveedorPlan,
    proveedorTerminoBusqueda,
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

final proveedorAnioEvaluacion = StateProvider<int>((_) => 2);
final proveedorIdMateriaCalculadoraSeleccionada = StateProvider<String?>(
  (_) => null,
);

final proveedorMapaEstadosCorrelativas =
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

final proveedorDesplazamientoCorrelativas = StateProvider<double>((_) => 0.0);
