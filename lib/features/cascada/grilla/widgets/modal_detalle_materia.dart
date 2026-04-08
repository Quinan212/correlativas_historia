import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/performance/app_performance.dart';
import '../../../../shared/providers/app_state.dart';
import '../../panel_detalle/componentes/controles_superiores.dart';
import '../../panel_detalle/panel_detalle_materia.dart';

Future<void> mostrarModalDetalleMateria({
  required BuildContext context,
  required WidgetRef ref,
  required String heroId,
}) async {
  await Navigator.of(context).push(_DetalleMateriaRoute(heroId: heroId));
  ref.read(selectedMateriaIdProvider.notifier).state = null;
}

class _DetalleMateriaRoute extends PageRoute<void> {
  _DetalleMateriaRoute({required this.heroId});

  final String heroId;

  @override
  bool get opaque => true;

  @override
  bool get maintainState => true;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 240);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 200);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _DetalleMateriaPage(
      key: ValueKey('det_$heroId'),
      initialMateriaId: heroId,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.025, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
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

  @override
  Widget build(BuildContext context) {
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
