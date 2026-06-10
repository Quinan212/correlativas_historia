import 'dart:async';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../models/materia.dart';
import '../../../../shared/device_identity/device_identity.dart';
import '../../../../shared/nav/smooth_route.dart';
import '../../../../shared/performance/app_performance.dart';
import '../../../../shared/providers/app_state.dart';
import '../../../../shared/supabase/supabase.dart';
import '../../panel_detalle/componentes/controles_superiores.dart';
import '../../panel_detalle/panel_detalle_materia.dart';
import '../../providers/matter_navigation_analytics_repository.dart';

Future<void> mostrarModalDetalleMateria({
  required BuildContext context,
  required WidgetRef ref,
  required String heroId,
}) async {
  await Navigator.of(context).push(
    smoothRoute<void>(
      _DetalleMateriaPage(
        key: ValueKey('det_$heroId'),
        initialMateriaId: heroId,
      ),
    ),
  );
  ref.read(selectedMateriaIdProvider.notifier).state = null;
}

class _DetalleMateriaPage extends ConsumerStatefulWidget {
  const _DetalleMateriaPage({
    super.key,
    required this.initialMateriaId,
  });

  final String initialMateriaId;

  @override
  ConsumerState<_DetalleMateriaPage> createState() =>
      _DetalleMateriaPageState();
}

class _DetalleMateriaPageState extends ConsumerState<_DetalleMateriaPage> {
  final ScrollController _scrollCtrl = ScrollController();
  ProviderSubscription<String?>? _selectedMateriaSubscription;
  late final Future<Trace?> _detailOpenTrace;
  final MatterNavigationAnalyticsRepository _analytics =
      const MatterNavigationAnalyticsRepository();
  bool _initialViewTracked = false;

  @override
  void initState() {
    super.initState();
    ref.read(selectedMateriaIdProvider.notifier).state =
        widget.initialMateriaId;
    _detailOpenTrace = AppPerformance.startTrace(
      'detail_sheet_open',
      attributes: const {'surface': 'matter_detail_page'},
    );
    _selectedMateriaSubscription = ref.listenManual<String?>(
      selectedMateriaIdProvider,
      (prev, next) {
        if (prev == next) return;
        if (prev != null && next != null) {
          unawaited(_trackTransition(prev: prev, next: next));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollCtrl.hasClients) return;
          _scrollCtrl.animateTo(
            0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
          );
        });
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppPerformance.stopTrace(await _detailOpenTrace);
    });
  }

  @override
  void dispose() {
    _selectedMateriaSubscription?.close();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _close() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _trackInitialView() async {
    final matterId = widget.initialMateriaId;
    final matter = _findMatterById(matterId);
    if (matter == null) return;
    final client = ref.read(supabaseClientProvider);
    final deviceId = await ref.read(deviceIdProvider.future);
    await _analytics.trackDetailView(
      client: client,
      deviceId: deviceId,
      careerId: ref.read(selectedCareerInfoProvider).id,
      matterId: matter.id,
      matterName: matter.nombre,
    );
  }

  Future<void> _trackTransition({
    required String prev,
    required String next,
  }) async {
    final source = _findMatterById(prev);
    final target = _findMatterById(next);
    if (source == null || target == null) return;

    final client = ref.read(supabaseClientProvider);
    final deviceId = await ref.read(deviceIdProvider.future);
    await _analytics.trackTransition(
      client: client,
      deviceId: deviceId,
      sourceCareerId: ref.read(selectedCareerInfoProvider).id,
      sourceMatterId: source.id,
      sourceMatterName: source.nombre,
      targetCareerId: ref.read(selectedCareerInfoProvider).id,
      targetMatterId: target.id,
      targetMatterName: target.nombre,
    );
  }

  Materia? _findMatterById(String id) {
    final plan = ref.read(planProvider).valueOrNull;
    if (plan == null) return null;
    for (final matter in plan.materias) {
      if (matter.id == id) return matter;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final planReady = ref.watch(planProvider).valueOrNull != null;
    if (planReady && !_initialViewTracked) {
      _initialViewTracked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_trackInitialView());
      });
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundTop =
        isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FB);
    final backgroundBottom =
        isDark ? const Color(0xFF111827) : const Color(0xFFE9EEF5);
    return Scaffold(
      backgroundColor: backgroundTop,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundTop,
              Color.lerp(backgroundTop, backgroundBottom, 0.65) ??
                  backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: RepaintBoundary(
                        child: DetailPanel(
                          showHeaderCloseButton: false,
                          initialMateriaId: widget.initialMateriaId,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: BarraInferiorDetalle(
                    onTap: _close,
                    label: 'Cerrar y volver',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
