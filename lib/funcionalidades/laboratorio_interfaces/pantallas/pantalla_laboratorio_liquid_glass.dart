import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../calculadora/pantalla/pantalla_calculadora.dart';
import '../../cascada/pantalla/pantalla_mapa_correlatividades.dart';
import '../../curriculum/pantalla/pantalla_disenos_curriculares.dart';
import '../../examenes/examenes_pantalla.dart';
import '../../preguntas_frecuentes/preguntas_frecuentes_pantalla.dart';
import '../../trayectoria_sage_laboratorio/datos/repositorio_trayectoria_sage_laboratorio.dart';
import '../../trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import '../../trayectoria_sage_laboratorio/pantallas/pantalla_laboratorio_sage.dart'
    show PantallaDatosSageLaboratorio, PantallaMateriasSageLaboratorio;
import '../../trayectoria_sage_laboratorio/sage/pantalla_sage_laboratorio.dart';
import '../componentes/componentes_liquid_glass.dart';
import '../tema/tema_liquid_glass.dart';

class PantallaLaboratorioLiquidGlass extends StatefulWidget {
  const PantallaLaboratorioLiquidGlass({super.key});

  @override
  State<PantallaLaboratorioLiquidGlass> createState() =>
      _PantallaLaboratorioLiquidGlassState();
}

class _PantallaLaboratorioLiquidGlassState
    extends State<PantallaLaboratorioLiquidGlass> {
  static const _repository = RepositorioTrayectoriaSageLaboratorio();

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List<GlobalKey<NavigatorState>>.generate(
        4,
        (_) => GlobalKey<NavigatorState>(),
      );
  final ValueNotifier<TrayectoriaSageLaboratorio?> _trajectory =
      ValueNotifier<TrayectoriaSageLaboratorio?>(null);
  final ValueNotifier<bool> _localLoaded = ValueNotifier<bool>(false);
  final ValueNotifier<int> _resetRevision = ValueNotifier<int>(0);
  final Set<int> _builtSections = <int>{0};

  int _section = 0;
  bool _planVisible = false;
  bool _reducedEffects = false;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocal());
  }

  Future<void> _loadLocal() async {
    final loaded = await _repository.cargar();
    if (!mounted) return;
    _trajectory.value = loaded;
    _localLoaded.value = true;
  }

  Future<void> _desincronizar() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desincronizar trayectoria'),
        content: const Text('Se borrará la copia local del laboratorio.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Desincronizar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await _repository.borrar();
    if (!mounted) return;
    _trajectory.value = null;
    _resetRevision.value++;
    setState(() {
      _planVisible = false;
      _section = 0;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trayectoria desincronizada')));
  }

  void _selectSection(int section) {
    if (!_planVisible && _section == section) {
      _navigatorKeys[section].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _builtSections.add(section);
      _planVisible = false;
      _section = section;
    });
  }

  void _openPlan() {
    setState(() => _planVisible = true);
  }

  void _handleDestination(int index) {
    switch (index) {
      case 0:
        _selectSection(0);
        break;
      case 1:
        _selectSection(1);
        break;
      case 2:
        _openPlan();
        break;
      case 3:
        _selectSection(2);
        break;
      case 4:
        _selectSection(3);
        break;
    }
  }

  int get _selectedDestination {
    if (_planVisible) return 2;
    return switch (_section) {
      0 => 0,
      1 => 1,
      2 => 3,
      _ => 4,
    };
  }

  Future<bool> _handleBack() async {
    if (_planVisible) {
      setState(() {
        _planVisible = false;
        _section = 0;
      });
      return false;
    }
    final navigator = _navigatorKeys[_section].currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
      return false;
    }
    if (_section != 0) {
      setState(() => _section = 0);
      return false;
    }
    return true;
  }

  Future<void> _showSettings() async {
    var reducedEffects = _reducedEffects;
    var reducedMotion = _reducedMotion;
    final result = await showModalBottomSheet<_PreferenciasLiquidGlass>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
            child: SuperficieLiquidGlass(
              reducedEffects: reducedEffects,
              radius: 30,
              blur: 28,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ajustes del laboratorio',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Efectos reducidos'),
                    value: reducedEffects,
                    onChanged: (value) =>
                        setSheetState(() => reducedEffects = value),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Reducir movimiento'),
                    value: reducedMotion,
                    onChanged: (value) =>
                        setSheetState(() => reducedMotion = value),
                  ),
                  const SizedBox(height: 8),
                  BotonLiquidGlass(
                    label: 'Aplicar',
                    icon: Icons.check_rounded,
                    primary: true,
                    expanded: true,
                    reducedEffects: reducedEffects,
                    onTap: () => Navigator.of(sheetContext).pop(
                      _PreferenciasLiquidGlass(
                        reducedEffects: reducedEffects,
                        reducedMotion: reducedMotion,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _reducedEffects = result.reducedEffects;
      _reducedMotion = result.reducedMotion;
    });
  }

  @override
  void dispose() {
    _trajectory.dispose();
    _localLoaded.dispose();
    _resetRevision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = temaLaboratorioLiquidGlass(context);
    final dark = theme.brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 980;

    final sectionChildren = <Widget>[
      PantallaInicioLiquidGlass(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
        resetListenable: _resetRevision,
        reducedEffects: _reducedEffects,
        reducedMotion: _reducedMotion,
        onExit: () => Navigator.of(context).pop(),
        onOpenSettings: _showSettings,
        onOpenPlan: _openPlan,
        onOpenExams: () => _selectSection(1),
        onOpenSubjects: () => _selectSection(2),
      ),
      const ExamenesPantalla(),
      PantallaMateriasSageLaboratorio(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
      ),
      PantallaDatosSageLaboratorio(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
        onDesincronizar: _desincronizar,
      ),
    ];

    final tabs = List<Widget>.generate(4, (index) {
      if (!_builtSections.contains(index)) return const SizedBox.shrink();
      return _NavegadorLiquidGlass(
        navigatorKey: _navigatorKeys[index],
        child: sectionChildren[index],
      );
    });

    Widget content = _planVisible
        ? const PantallaMapaCorrelatividades(
            key: ValueKey('liquid-glass-plan-completo'),
          )
        : IndexedStack(index: _section, children: tabs);

    if (desktop) {
      content = Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
            child: _NavegacionLateralLiquidGlass(
              selectedIndex: _selectedDestination,
              onSelected: _handleDestination,
              onExit: () => Navigator.of(context).pop(),
              onSettings: _showSettings,
              reducedEffects: _reducedEffects,
              reducedMotion: _reducedMotion,
            ),
          ),
          Expanded(child: content),
        ],
      );
    }

    final overlayStyle = dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: PopScope<void>(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldExit = await _handleBack();
            if (shouldExit && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: FondoLiquidGlass(
              motionEnabled: !_reducedMotion,
              child: content,
            ),
            bottomNavigationBar: desktop
                ? null
                : BarraNavegacionLiquidGlass(
                    selectedIndex: _selectedDestination,
                    onSelected: _handleDestination,
                    reducedEffects: _reducedEffects,
                    reducedMotion: _reducedMotion,
                  ),
          ),
        ),
      ),
    );
  }
}

class _PreferenciasLiquidGlass {
  const _PreferenciasLiquidGlass({
    required this.reducedEffects,
    required this.reducedMotion,
  });

  final bool reducedEffects;
  final bool reducedMotion;
}

class _NavegadorLiquidGlass extends StatelessWidget {
  const _NavegadorLiquidGlass({
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => child),
    );
  }
}

class _NavegacionLateralLiquidGlass extends StatelessWidget {
  const _NavegacionLateralLiquidGlass({
    required this.selectedIndex,
    required this.onSelected,
    required this.onExit,
    required this.onSettings,
    required this.reducedEffects,
    required this.reducedMotion,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onExit;
  final VoidCallback onSettings;
  final bool reducedEffects;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    const destinations = <(IconData, String)>[
      (Icons.school_rounded, 'Inicio'),
      (Icons.assignment_rounded, 'Exámenes'),
      (Icons.account_tree_rounded, 'Plan'),
      (Icons.list_alt_rounded, 'Materias'),
      (Icons.person_rounded, 'Datos'),
    ];
    return SizedBox(
      width: 104,
      child: SuperficieLiquidGlass(
        reducedEffects: reducedEffects,
        radius: 30,
        blur: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            BotonIconoLiquidGlass(
              icon: Icons.close_rounded,
              tooltip: 'Salir',
              onTap: onExit,
              reducedEffects: reducedEffects,
            ),
            const SizedBox(height: 20),
            for (var index = 0; index < destinations.length; index++) ...[
              _BotonDestinoLateral(
                icon: destinations[index].$1,
                label: destinations[index].$2,
                selected: selectedIndex == index,
                reducedMotion: reducedMotion,
                onTap: () => onSelected(index),
              ),
              if (index != destinations.length - 1) const SizedBox(height: 8),
            ],
            const Spacer(),
            BotonIconoLiquidGlass(
              icon: Icons.tune_rounded,
              tooltip: 'Ajustes',
              onTap: onSettings,
              reducedEffects: reducedEffects,
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonDestinoLateral extends StatelessWidget {
  const _BotonDestinoLateral({
    required this.icon,
    required this.label,
    required this.selected,
    required this.reducedMotion,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool reducedMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.92),
                    PaletaLiquidGlass.violeta.withValues(alpha: 0.82),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : scheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: selected ? Colors.white : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaInicioLiquidGlass extends StatefulWidget {
  const PantallaInicioLiquidGlass({
    super.key,
    required this.trajectoryListenable,
    required this.localLoadedListenable,
    required this.resetListenable,
    required this.reducedEffects,
    required this.reducedMotion,
    required this.onExit,
    required this.onOpenSettings,
    required this.onOpenPlan,
    required this.onOpenExams,
    required this.onOpenSubjects,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final ValueNotifier<bool> localLoadedListenable;
  final ValueNotifier<int> resetListenable;
  final bool reducedEffects;
  final bool reducedMotion;
  final VoidCallback onExit;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenExams;
  final VoidCallback onOpenSubjects;

  @override
  State<PantallaInicioLiquidGlass> createState() =>
      _PantallaInicioLiquidGlassState();
}

class _PantallaInicioLiquidGlassState extends State<PantallaInicioLiquidGlass> {
  static const _repository = RepositorioTrayectoriaSageLaboratorio();

  TrayectoriaSageLaboratorio? _draft;
  EstadoPreparacionSageLaboratorio _preparation =
      const EstadoPreparacionSageLaboratorio(mensaje: 'Pendiente');
  bool _saving = false;
  int _selectedCareer = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.resetListenable.addListener(_resetState);
  }

  @override
  void didUpdateWidget(covariant PantallaInicioLiquidGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetListenable == widget.resetListenable) return;
    oldWidget.resetListenable.removeListener(_resetState);
    widget.resetListenable.addListener(_resetState);
  }

  void _resetState() {
    if (!mounted) return;
    setState(() {
      _draft = null;
      _preparation = const EstadoPreparacionSageLaboratorio(
        mensaje: 'Pendiente',
      );
      _saving = false;
      _selectedCareer = 0;
    });
  }

  @override
  void dispose() {
    widget.resetListenable.removeListener(_resetState);
    _scrollController.dispose();
    super.dispose();
  }

  CarreraTrayectoriaSageLaboratorio? _currentCareer(
    TrayectoriaSageLaboratorio? trajectory,
  ) {
    if (trajectory == null || trajectory.carreras.isEmpty) return null;
    final index = _selectedCareer
        .clamp(0, trajectory.carreras.length - 1)
        .toInt();
    return trajectory.carreras[index];
  }

  Future<void> _openSage() async {
    setState(() {
      _draft = null;
      _preparation = const EstadoPreparacionSageLaboratorio(
        mensaje: 'Esperando Historial',
      );
    });
    await Navigator.of(context, rootNavigator: true).push<void>(
      rutaLiquidGlass<void>(
        reducedMotion: widget.reducedMotion,
        builder: (sageContext) => PantallaSageLaboratorio(
          onClose: () => Navigator.of(sageContext).pop(),
          onTrayectoriaLista: (trajectory) {
            if (!mounted) return;
            setState(() {
              _draft = trajectory;
              _preparation = EstadoPreparacionSageLaboratorio(
                mensaje:
                    '${trajectory.totalMaterias} materias listas para sincronizar.',
                progreso: 1,
              );
            });
          },
          onEstadoPreparacion: (status) {
            if (!mounted) return;
            setState(() => _preparation = status);
          },
        ),
      ),
    );
  }

  Future<void> _sync() async {
    final draft = _draft;
    if (draft == null || !draft.listaParaSincronizar || _saving) return;
    final current = widget.trajectoryListenable.value;
    if (current != null && !_sameProfile(current.perfil, draft.perfil)) {
      final replace = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Reemplazar trayectoria'),
          content: Text('${current.perfil.nombre} → ${draft.perfil.nombre}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reemplazar'),
            ),
          ],
        ),
      );
      if (replace != true || !mounted) return;
    }

    setState(() => _saving = true);
    try {
      final stored = await _repository.guardar(draft);
      if (!mounted) return;
      widget.trajectoryListenable.value = stored;
      setState(() {
        _selectedCareer = 0;
        _preparation = const EstadoPreparacionSageLaboratorio(
          mensaje: 'Sincronización completada',
          progreso: 1,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${stored.totalMaterias} materias sincronizadas'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la trayectoria local.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _chooseCareer(TrayectoriaSageLaboratorio trajectory) async {
    if (trajectory.carreras.length < 2) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        child: SuperficieLiquidGlass(
          reducedEffects: widget.reducedEffects,
          radius: 30,
          blur: 28,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < trajectory.carreras.length; index++)
                ListTile(
                  leading: Icon(
                    index == _selectedCareer
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                  ),
                  title: Text(
                    _careerName(trajectory.carreras[index].nombre),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle:
                      trajectory.carreras[index].institucion.trim().isEmpty
                      ? null
                      : Text(
                          trajectory.carreras[index].institucion,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(index),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedCareer = selected);
  }

  void _openCalculator() {
    Navigator.of(context).push<void>(
      rutaLiquidGlass<void>(
        reducedMotion: widget.reducedMotion,
        builder: (_) => const PantallaCalculadora(),
      ),
    );
  }

  void _openCurriculum() {
    Navigator.of(context).push<void>(
      rutaLiquidGlass<void>(
        reducedMotion: widget.reducedMotion,
        builder: (_) => const PantallaDisenosCurriculares(),
      ),
    );
  }

  void _openFaq() {
    Navigator.of(context).push<void>(
      rutaLiquidGlass<void>(
        reducedMotion: widget.reducedMotion,
        builder: (_) => const PantallaPreguntasFrecuentes(),
      ),
    );
  }

  void _openDetail() {
    Navigator.of(context).push<void>(
      rutaLiquidGlass<void>(
        reducedMotion: widget.reducedMotion,
        builder: (_) => PantallaDetalleTrayectoriaLiquidGlass(
          trajectoryListenable: widget.trajectoryListenable,
          initialCareerIndex: _selectedCareer,
          reducedEffects: widget.reducedEffects,
          reducedMotion: widget.reducedMotion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.localLoadedListenable,
      builder: (context, loaded, _) {
        return ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
          valueListenable: widget.trajectoryListenable,
          builder: (context, trajectory, _) {
            final career = _currentCareer(trajectory);
            final topInset = MediaQuery.paddingOf(context).top;
            final width = MediaQuery.sizeOf(context).width;
            final maxWidth = width >= 900 ? 1180.0 : 720.0;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(height: topInset + 82),
                      ),
                      SliverToBoxAdapter(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                6,
                                16,
                                150,
                              ),
                              child: AnimatedSwitcher(
                                duration: widget.reducedMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 360),
                                child: !loaded
                                    ? _EstadoCargandoLiquidGlass(
                                        reducedEffects: widget.reducedEffects,
                                      )
                                    : Column(
                                        key: ValueKey<String>(
                                          'dashboard-${trajectory?.sincronizadaEn?.millisecondsSinceEpoch ?? 0}-${career?.gridRowId ?? 'empty'}',
                                        ),
                                        children: [
                                          _TarjetaPerfilLiquidGlass(
                                            trajectory: trajectory,
                                            career: career,
                                            reducedEffects:
                                                widget.reducedEffects,
                                            onChooseCareer: trajectory == null
                                                ? null
                                                : () =>
                                                      _chooseCareer(trajectory),
                                            onOpenDetail: trajectory == null
                                                ? null
                                                : _openDetail,
                                            onOpenSage: _openSage,
                                          ),
                                          const SizedBox(height: 16),
                                          if (trajectory == null ||
                                              career == null)
                                            _TarjetaConexionSageLiquidGlass(
                                              draft: _draft,
                                              preparation: _preparation,
                                              saving: _saving,
                                              reducedEffects:
                                                  widget.reducedEffects,
                                              onOpenSage: _openSage,
                                              onSync: _sync,
                                            )
                                          else ...[
                                            _ResumenAcademicoLiquidGlass(
                                              career: career,
                                              reducedEffects:
                                                  widget.reducedEffects,
                                              onOpenDetail: _openDetail,
                                            ),
                                            const SizedBox(height: 16),
                                            _GrillaAccionesLiquidGlass(
                                              reducedEffects:
                                                  widget.reducedEffects,
                                              onOpenSubjects:
                                                  widget.onOpenSubjects,
                                              onOpenExams: widget.onOpenExams,
                                              onOpenPlan: widget.onOpenPlan,
                                              onOpenCalculator: _openCalculator,
                                              onOpenCurriculum: _openCurriculum,
                                              onOpenFaq: _openFaq,
                                            ),
                                            const SizedBox(height: 16),
                                            _PanelMateriasRecientesLiquidGlass(
                                              career: career,
                                              reducedEffects:
                                                  widget.reducedEffects,
                                              onOpenDetail: _openDetail,
                                            ),
                                            if (_draft != null ||
                                                _preparation.mensaje !=
                                                    'Pendiente') ...[
                                              const SizedBox(height: 16),
                                              _TarjetaConexionSageLiquidGlass(
                                                draft: _draft,
                                                preparation: _preparation,
                                                saving: _saving,
                                                reducedEffects:
                                                    widget.reducedEffects,
                                                onOpenSage: _openSage,
                                                onSync: _sync,
                                                compact: true,
                                              ),
                                            ],
                                          ],
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: topInset + 8,
                    left: 12,
                    right: 12,
                    child: _BarraSuperiorLiquidGlass(
                      trajectory: trajectory,
                      reducedEffects: widget.reducedEffects,
                      onExit: widget.onExit,
                      onSettings: widget.onOpenSettings,
                      onRefresh: _openSage,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BarraSuperiorLiquidGlass extends StatelessWidget {
  const _BarraSuperiorLiquidGlass({
    required this.trajectory,
    required this.reducedEffects,
    required this.onExit,
    required this.onSettings,
    required this.onRefresh,
  });

  final TrayectoriaSageLaboratorio? trajectory;
  final bool reducedEffects;
  final VoidCallback onExit;
  final VoidCallback onSettings;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final firstName = _firstName(trajectory?.perfil.nombre);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: SuperficieLiquidGlass(
          reducedEffects: reducedEffects,
          radius: 24,
          blur: 24,
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
          child: Row(
            children: [
              BotonIconoLiquidGlass(
                icon: Icons.close_rounded,
                tooltip: 'Salir',
                onTap: onExit,
                reducedEffects: reducedEffects,
                size: 40,
              ),
              const SizedBox(width: 9),
              Container(
                width: 38,
                height: 38,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                child: Image.asset(
                  'assets/icon_fore.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.school_rounded,
                    color: PaletaLiquidGlass.azulProfundo,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      firstName == null
                          ? 'Laboratorio Glass'
                          : 'Hola, $firstName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Interfaz experimental',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              BotonIconoLiquidGlass(
                icon: Icons.refresh_rounded,
                tooltip: 'Actualizar SAGE',
                onTap: onRefresh,
                reducedEffects: reducedEffects,
                size: 40,
              ),
              const SizedBox(width: 6),
              BotonIconoLiquidGlass(
                icon: Icons.tune_rounded,
                tooltip: 'Ajustes del laboratorio',
                onTap: onSettings,
                reducedEffects: reducedEffects,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoCargandoLiquidGlass extends StatelessWidget {
  const _EstadoCargandoLiquidGlass({required this.reducedEffects});

  final bool reducedEffects;

  @override
  Widget build(BuildContext context) {
    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      child: const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _TarjetaPerfilLiquidGlass extends StatelessWidget {
  const _TarjetaPerfilLiquidGlass({
    required this.trajectory,
    required this.career,
    required this.reducedEffects,
    required this.onChooseCareer,
    required this.onOpenDetail,
    required this.onOpenSage,
  });

  final TrayectoriaSageLaboratorio? trajectory;
  final CarreraTrayectoriaSageLaboratorio? career;
  final bool reducedEffects;
  final VoidCallback? onChooseCareer;
  final VoidCallback? onOpenDetail;
  final VoidCallback onOpenSage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = _profileName(trajectory?.perfil);
    final initials = _initials(name);
    final total = career?.materias.length ?? 0;
    final approved = career?.aprobadas ?? 0;
    final progress = total == 0 ? 0.0 : approved / total;

    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      radius: 32,
      blur: 26,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.primary.withValues(alpha: 0.22),
          PaletaLiquidGlass.violeta.withValues(alpha: 0.14),
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xC9182438)
              : Colors.white.withValues(alpha: 0.56),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;
          final identity = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PaletaLiquidGlass.azul, PaletaLiquidGlass.violeta],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1.05),
                    ),
                    const SizedBox(height: 7),
                    if (career != null)
                      InkWell(
                        onTap: onChooseCareer,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _careerName(career!.nombre),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ),
                              if ((trajectory?.carreras.length ?? 0) > 1) ...[
                                const SizedBox(width: 5),
                                Icon(
                                  Icons.unfold_more_rounded,
                                  size: 17,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      Text(
                        'Sin trayectoria sincronizada',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    if (career != null &&
                        career!.institucion.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        career!.institucion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (onOpenDetail != null)
                BotonLiquidGlass(
                  label: 'Ver trayectoria',
                  icon: Icons.auto_graph_rounded,
                  primary: true,
                  reducedEffects: reducedEffects,
                  onTap: onOpenDetail!,
                ),
              BotonLiquidGlass(
                label: 'Actualizar SAGE',
                icon: Icons.sync_rounded,
                reducedEffects: reducedEffects,
                onTap: onOpenSage,
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 18),
                Row(
                  children: [
                    IndicadorProgresoLiquidGlass(
                      progress: progress,
                      label: 'aprobado',
                      size: 96,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ResumenMiniPerfil(
                        approved: approved,
                        regular: career?.regulares ?? 0,
                        inProgress: career?.cursando ?? 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                actions,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [identity, const SizedBox(height: 20), actions],
                ),
              ),
              const SizedBox(width: 20),
              IndicadorProgresoLiquidGlass(
                progress: progress,
                label: 'aprobado',
                size: 116,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 155,
                child: _ResumenMiniPerfil(
                  approved: approved,
                  regular: career?.regulares ?? 0,
                  inProgress: career?.cursando ?? 0,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResumenMiniPerfil extends StatelessWidget {
  const _ResumenMiniPerfil({
    required this.approved,
    required this.regular,
    required this.inProgress,
  });

  final int approved;
  final int regular;
  final int inProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FilaDatoMini(
          color: PaletaLiquidGlass.verde,
          label: 'Aprobadas',
          value: approved,
        ),
        const SizedBox(height: 7),
        _FilaDatoMini(
          color: PaletaLiquidGlass.amarillo,
          label: 'Regulares',
          value: regular,
        ),
        const SizedBox(height: 7),
        _FilaDatoMini(
          color: PaletaLiquidGlass.azul,
          label: 'Cursando',
          value: inProgress,
        ),
      ],
    );
  }
}

class _FilaDatoMini extends StatelessWidget {
  const _FilaDatoMini({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$value',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _ResumenAcademicoLiquidGlass extends StatelessWidget {
  const _ResumenAcademicoLiquidGlass({
    required this.career,
    required this.reducedEffects,
    required this.onOpenDetail,
  });

  final CarreraTrayectoriaSageLaboratorio career;
  final bool reducedEffects;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final total = career.materias.length;
    final unresolved = math
        .max(0, total - career.aprobadas - career.regulares - career.cursando)
        .toInt();
    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      radius: 28,
      blur: 18,
      onTap: onOpenDetail,
      semanticLabel: 'Abrir detalle de trayectoria',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resumen académico',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 720 ? 5 : 2;
              final width =
                  (constraints.maxWidth - (columns - 1) * 10) / columns;
              final stats = <(String, int, Color, IconData)>[
                (
                  'Total',
                  total,
                  PaletaLiquidGlass.azul,
                  Icons.grid_view_rounded,
                ),
                (
                  'Aprobadas',
                  career.aprobadas,
                  PaletaLiquidGlass.verde,
                  Icons.check_circle_rounded,
                ),
                (
                  'Regulares',
                  career.regulares,
                  PaletaLiquidGlass.amarillo,
                  Icons.bookmark_added_rounded,
                ),
                (
                  'Cursando',
                  career.cursando,
                  PaletaLiquidGlass.turquesa,
                  Icons.play_circle_rounded,
                ),
                (
                  'Pendientes',
                  unresolved,
                  PaletaLiquidGlass.rojo,
                  Icons.pending_actions_rounded,
                ),
              ];
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final stat in stats)
                    SizedBox(
                      width: columns == 2 && stat == stats.last
                          ? constraints.maxWidth
                          : width,
                      child: _MetricaLiquidGlass(
                        label: stat.$1,
                        value: stat.$2,
                        color: stat.$3,
                        icon: stat.$4,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricaLiquidGlass extends StatelessWidget {
  const _MetricaLiquidGlass({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GrillaAccionesLiquidGlass extends StatelessWidget {
  const _GrillaAccionesLiquidGlass({
    required this.reducedEffects,
    required this.onOpenSubjects,
    required this.onOpenExams,
    required this.onOpenPlan,
    required this.onOpenCalculator,
    required this.onOpenCurriculum,
    required this.onOpenFaq,
  });

  final bool reducedEffects;
  final VoidCallback onOpenSubjects;
  final VoidCallback onOpenExams;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenCalculator;
  final VoidCallback onOpenCurriculum;
  final VoidCallback onOpenFaq;

  @override
  Widget build(BuildContext context) {
    final actions = <_AccionLiquidGlass>[
      _AccionLiquidGlass(
        'Materias',
        Icons.list_alt_rounded,
        PaletaLiquidGlass.azul,
        onOpenSubjects,
      ),
      _AccionLiquidGlass(
        'Exámenes',
        Icons.assignment_rounded,
        PaletaLiquidGlass.violeta,
        onOpenExams,
      ),
      _AccionLiquidGlass(
        'Plan completo',
        Icons.account_tree_rounded,
        PaletaLiquidGlass.turquesa,
        onOpenPlan,
      ),
      _AccionLiquidGlass(
        'Calculadora',
        Icons.calculate_rounded,
        PaletaLiquidGlass.amarillo,
        onOpenCalculator,
      ),
      _AccionLiquidGlass(
        'Diseños',
        Icons.menu_book_rounded,
        PaletaLiquidGlass.verde,
        onOpenCurriculum,
      ),
      _AccionLiquidGlass(
        'Preguntas',
        Icons.help_rounded,
        PaletaLiquidGlass.rojo,
        onOpenFaq,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 520
            ? 3
            : 2;
        const gap = 10.0;
        final itemWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final action in actions)
              SizedBox(
                width: itemWidth,
                child: _TarjetaAccionLiquidGlass(
                  action: action,
                  reducedEffects: reducedEffects,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AccionLiquidGlass {
  const _AccionLiquidGlass(this.label, this.icon, this.color, this.onTap);

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _TarjetaAccionLiquidGlass extends StatelessWidget {
  const _TarjetaAccionLiquidGlass({
    required this.action,
    required this.reducedEffects,
  });

  final _AccionLiquidGlass action;
  final bool reducedEffects;

  @override
  Widget build(BuildContext context) {
    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      radius: 24,
      blur: 14,
      padding: const EdgeInsets.all(14),
      onTap: action.onTap,
      semanticLabel: action.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: action.color.withValues(alpha: 0.24)),
            ),
            child: Icon(action.icon, color: action.color, size: 22),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  action.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                size: 17,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelMateriasRecientesLiquidGlass extends StatelessWidget {
  const _PanelMateriasRecientesLiquidGlass({
    required this.career,
    required this.reducedEffects,
    required this.onOpenDetail,
  });

  final CarreraTrayectoriaSageLaboratorio career;
  final bool reducedEffects;
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final subjects = [...career.materias]
      ..sort((a, b) {
        final priority = _statusPriority(
          a.estado,
        ).compareTo(_statusPriority(b.estado));
        if (priority != 0) return priority;
        final year = (a.anio ?? 999).compareTo(b.anio ?? 999);
        if (year != 0) return year;
        return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
      });
    final visible = subjects.take(5).toList(growable: false);

    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      radius: 28,
      blur: 18,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Tu trayectoria',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              TextButton.icon(
                onPressed: onOpenDetail,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Ver todo'),
              ),
            ],
          ),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text('Sin materias detectadas'),
            )
          else
            for (var index = 0; index < visible.length; index++) ...[
              _FilaMateriaLiquidGlass(subject: visible[index]),
              if (index != visible.length - 1)
                Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.45),
                ),
            ],
        ],
      ),
    );
  }
}

class _FilaMateriaLiquidGlass extends StatelessWidget {
  const _FilaMateriaLiquidGlass({required this.subject});

  final MateriaTrayectoriaSageLaboratorio subject;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(subject.estado);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  subject.anio == null ? 'Sin año' : '${subject.anio}° año',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              subject.estado.etiqueta,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaConexionSageLiquidGlass extends StatelessWidget {
  const _TarjetaConexionSageLiquidGlass({
    required this.draft,
    required this.preparation,
    required this.saving,
    required this.reducedEffects,
    required this.onOpenSage,
    required this.onSync,
    this.compact = false,
  });

  final TrayectoriaSageLaboratorio? draft;
  final EstadoPreparacionSageLaboratorio preparation;
  final bool saving;
  final bool reducedEffects;
  final VoidCallback onOpenSage;
  final VoidCallback onSync;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ready = draft?.listaParaSincronizar == true;
    final progress = preparation.progreso;
    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      radius: 28,
      blur: 20,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PaletaLiquidGlass.azul.withValues(alpha: 0.18),
          PaletaLiquidGlass.violeta.withValues(alpha: 0.10),
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xC9152136)
              : Colors.white.withValues(alpha: 0.58),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PaletaLiquidGlass.azul, PaletaLiquidGlass.violeta],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(Icons.sync_rounded, color: Colors.white),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      compact ? 'Actualizar trayectoria' : 'Conectar con SAGE',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      preparation.mensaje,
                      maxLines: compact ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BotonLiquidGlass(
                  label: 'Abrir SAGE',
                  icon: Icons.open_in_browser_rounded,
                  expanded: true,
                  reducedEffects: reducedEffects,
                  onTap: onOpenSage,
                ),
              ),
              if (ready) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: BotonLiquidGlass(
                    label: saving ? 'Guardando' : 'Sincronizar',
                    icon: saving
                        ? Icons.hourglass_top_rounded
                        : Icons.sync_rounded,
                    primary: true,
                    expanded: true,
                    reducedEffects: reducedEffects,
                    enabled: !saving,
                    onTap: onSync,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class PantallaDetalleTrayectoriaLiquidGlass extends StatefulWidget {
  const PantallaDetalleTrayectoriaLiquidGlass({
    super.key,
    required this.trajectoryListenable,
    required this.initialCareerIndex,
    required this.reducedEffects,
    required this.reducedMotion,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final int initialCareerIndex;
  final bool reducedEffects;
  final bool reducedMotion;

  @override
  State<PantallaDetalleTrayectoriaLiquidGlass> createState() =>
      _PantallaDetalleTrayectoriaLiquidGlassState();
}

class _PantallaDetalleTrayectoriaLiquidGlassState
    extends State<PantallaDetalleTrayectoriaLiquidGlass> {
  late int _careerIndex;
  int? _year;
  EstadoMateriaSageLaboratorio? _status;
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _careerIndex = widget.initialCareerIndex;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _showSubject(MateriaTrayectoriaSageLaboratorio subject) async {
    final color = _statusColor(subject.estado);
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
        child: SuperficieLiquidGlass(
          reducedEffects: widget.reducedEffects,
          radius: 30,
          blur: 28,
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 4,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      subject.nombre,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DatoDetalleLiquidGlass(
                label: 'Estado',
                value: subject.estado.etiqueta,
              ),
              _DatoDetalleLiquidGlass(
                label: 'Año',
                value: subject.anio == null
                    ? 'Sin clasificar'
                    : '${subject.anio}°',
              ),
              if (subject.estadoOriginal.trim().isNotEmpty)
                _DatoDetalleLiquidGlass(
                  label: 'Registro SAGE',
                  value: subject.estadoOriginal,
                ),
              const SizedBox(height: 14),
              BotonLiquidGlass(
                label: 'Cerrar',
                icon: Icons.close_rounded,
                primary: true,
                expanded: true,
                reducedEffects: widget.reducedEffects,
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
      valueListenable: widget.trajectoryListenable,
      builder: (context, trajectory, _) {
        final careers =
            trajectory?.carreras ?? const <CarreraTrayectoriaSageLaboratorio>[];
        if (careers.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SuperficieLiquidGlass(
                  reducedEffects: widget.reducedEffects,
                  child: const Text('No hay trayectoria sincronizada'),
                ),
              ),
            ),
          );
        }

        final safeIndex = _careerIndex.clamp(0, careers.length - 1).toInt();
        final career = careers[safeIndex];
        final years =
            career.materias
                .map((subject) => subject.anio)
                .whereType<int>()
                .toSet()
                .toList()
              ..sort();
        final query = _query.trim().toLowerCase();
        final subjects =
            career.materias
                .where((subject) {
                  if (_year != null && subject.anio != _year) return false;
                  if (_status != null && subject.estado != _status)
                    return false;
                  if (query.isNotEmpty &&
                      !subject.nombre.toLowerCase().contains(query)) {
                    return false;
                  }
                  return true;
                })
                .toList(growable: false)
              ..sort((a, b) {
                final year = (a.anio ?? 999).compareTo(b.anio ?? 999);
                if (year != 0) return year;
                return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
              });
        final grouped = <int?, List<MateriaTrayectoriaSageLaboratorio>>{};
        for (final subject in subjects) {
          grouped.putIfAbsent(subject.anio, () => []).add(subject);
        }
        final topInset = MediaQuery.paddingOf(context).top;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              ListView(
                padding: EdgeInsets.fromLTRB(16, topInset + 82, 16, 138),
                children: [
                  _ResumenDetalleTrayectoria(
                    career: career,
                    reducedEffects: widget.reducedEffects,
                    onChooseCareer: careers.length > 1
                        ? () async {
                            final selected = await _showCareerPicker(
                              context,
                              careers,
                              safeIndex,
                              widget.reducedEffects,
                            );
                            if (selected == null || !mounted) return;
                            setState(() {
                              _careerIndex = selected;
                              _year = null;
                              _status = null;
                            });
                          }
                        : null,
                  ),
                  const SizedBox(height: 14),
                  SuperficieLiquidGlass(
                    reducedEffects: widget.reducedEffects,
                    radius: 24,
                    blur: 18,
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _queryController,
                      onChanged: (value) => setState(() => _query = value),
                      decoration: InputDecoration(
                        hintText: 'Buscar materia',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _queryController.clear();
                                  setState(() => _query = '');
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FiltrosTrayectoriaLiquidGlass(
                    years: years,
                    selectedYear: _year,
                    selectedStatus: _status,
                    onYearSelected: (value) => setState(() => _year = value),
                    onStatusSelected: (value) =>
                        setState(() => _status = value),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${subjects.length} materia${subjects.length == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (_year != null || _status != null || _query.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _queryController.clear();
                            setState(() {
                              _year = null;
                              _status = null;
                              _query = '';
                            });
                          },
                          child: const Text('Limpiar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (subjects.isEmpty)
                    SuperficieLiquidGlass(
                      reducedEffects: widget.reducedEffects,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: Text('Sin resultados')),
                      ),
                    )
                  else
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                        child: Text(
                          entry.key == null ? 'Sin año' : '${entry.key}° año',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      SuperficieLiquidGlass(
                        reducedEffects: widget.reducedEffects,
                        radius: 26,
                        blur: 16,
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                        child: Column(
                          children: [
                            for (
                              var index = 0;
                              index < entry.value.length;
                              index++
                            ) ...[
                              _TarjetaMateriaDetalleLiquidGlass(
                                subject: entry.value[index],
                                onTap: () => _showSubject(entry.value[index]),
                              ),
                              if (index != entry.value.length - 1)
                                Divider(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant
                                      .withValues(alpha: 0.45),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ],
                ],
              ),
              Positioned(
                top: topInset + 8,
                left: 12,
                right: 12,
                child: SuperficieLiquidGlass(
                  reducedEffects: widget.reducedEffects,
                  radius: 24,
                  blur: 24,
                  padding: const EdgeInsets.fromLTRB(7, 7, 14, 7),
                  child: Row(
                    children: [
                      BotonIconoLiquidGlass(
                        icon: Icons.arrow_back_rounded,
                        tooltip: 'Volver',
                        onTap: () => Navigator.of(context).pop(),
                        reducedEffects: widget.reducedEffects,
                        size: 40,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Trayectoria',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PaletaLiquidGlass.azul.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${career.materias.length}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: PaletaLiquidGlass.azul,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ResumenDetalleTrayectoria extends StatelessWidget {
  const _ResumenDetalleTrayectoria({
    required this.career,
    required this.reducedEffects,
    required this.onChooseCareer,
  });

  final CarreraTrayectoriaSageLaboratorio career;
  final bool reducedEffects;
  final VoidCallback? onChooseCareer;

  @override
  Widget build(BuildContext context) {
    final total = career.materias.length;
    final progress = total == 0 ? 0.0 : career.aprobadas / total;
    return SuperficieLiquidGlass(
      reducedEffects: reducedEffects,
      radius: 30,
      blur: 24,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          PaletaLiquidGlass.azul.withValues(alpha: 0.18),
          PaletaLiquidGlass.violeta.withValues(alpha: 0.11),
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xC9162033)
              : Colors.white.withValues(alpha: 0.58),
        ],
      ),
      child: Row(
        children: [
          IndicadorProgresoLiquidGlass(
            progress: progress,
            label: 'aprobado',
            size: 100,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onChooseCareer,
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _careerName(career.nombre),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      if (onChooseCareer != null)
                        const Icon(Icons.unfold_more_rounded, size: 19),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipMetricaDetalle(
                      label: '${career.aprobadas} aprobadas',
                      color: PaletaLiquidGlass.verde,
                    ),
                    _ChipMetricaDetalle(
                      label: '${career.regulares} regulares',
                      color: PaletaLiquidGlass.amarillo,
                    ),
                    _ChipMetricaDetalle(
                      label: '${career.cursando} cursando',
                      color: PaletaLiquidGlass.turquesa,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipMetricaDetalle extends StatelessWidget {
  const _ChipMetricaDetalle({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FiltrosTrayectoriaLiquidGlass extends StatelessWidget {
  const _FiltrosTrayectoriaLiquidGlass({
    required this.years,
    required this.selectedYear,
    required this.selectedStatus,
    required this.onYearSelected,
    required this.onStatusSelected,
  });

  final List<int> years;
  final int? selectedYear;
  final EstadoMateriaSageLaboratorio? selectedStatus;
  final ValueChanged<int?> onYearSelected;
  final ValueChanged<EstadoMateriaSageLaboratorio?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    const states = <EstadoMateriaSageLaboratorio>[
      EstadoMateriaSageLaboratorio.aprobada,
      EstadoMateriaSageLaboratorio.regular,
      EstadoMateriaSageLaboratorio.cursando,
      EstadoMateriaSageLaboratorio.noRegularizada,
      EstadoMateriaSageLaboratorio.desconocida,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('Todas'),
                selected: selectedStatus == null,
                onSelected: (_) => onStatusSelected(null),
              ),
              for (final state in states) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(state.etiqueta),
                  selected: selectedStatus == state,
                  onSelected: (_) => onStatusSelected(state),
                ),
              ],
            ],
          ),
        ),
        if (years.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Todos los años'),
                  selected: selectedYear == null,
                  onSelected: (_) => onYearSelected(null),
                ),
                for (final year in years) ...[
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text('$year°'),
                    selected: selectedYear == year,
                    onSelected: (_) => onYearSelected(year),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TarjetaMateriaDetalleLiquidGlass extends StatelessWidget {
  const _TarjetaMateriaDetalleLiquidGlass({
    required this.subject,
    required this.onTap,
  });

  final MateriaTrayectoriaSageLaboratorio subject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(subject.estado);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.menu_book_rounded, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject.estado.etiqueta,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _DatoDetalleLiquidGlass extends StatelessWidget {
  const _DatoDetalleLiquidGlass({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

Future<int?> _showCareerPicker(
  BuildContext context,
  List<CarreraTrayectoriaSageLaboratorio> careers,
  int selectedIndex,
  bool reducedEffects,
) {
  return showModalBottomSheet<int>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
      child: SuperficieLiquidGlass(
        reducedEffects: reducedEffects,
        radius: 30,
        blur: 28,
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < careers.length; index++)
              ListTile(
                leading: Icon(
                  index == selectedIndex
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                ),
                title: Text(
                  _careerName(careers[index].nombre),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: careers[index].institucion.trim().isEmpty
                    ? null
                    : Text(
                        careers[index].institucion,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                onTap: () => Navigator.of(sheetContext).pop(index),
              ),
          ],
        ),
      ),
    ),
  );
}

bool _sameProfile(
  PerfilTrayectoriaSageLaboratorio left,
  PerfilTrayectoriaSageLaboratorio right,
) {
  final leftDni = left.dni?.replaceAll(RegExp(r'\D'), '') ?? '';
  final rightDni = right.dni?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (leftDni.isNotEmpty && rightDni.isNotEmpty) return leftDni == rightDni;
  return left.nombre.trim().toLowerCase() == right.nombre.trim().toLowerCase();
}

String _profileName(PerfilTrayectoriaSageLaboratorio? profile) {
  final value = profile?.nombre.trim() ?? '';
  return value.isEmpty ? 'Estudiante SAGE' : value;
}

String? _firstName(String? value) {
  final clean = value?.trim() ?? '';
  if (clean.isEmpty || clean.toLowerCase() == 'estudiante sage') return null;
  return clean.split(RegExp(r'\s+')).first;
}

String _initials(String value) {
  final words = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);
  if (words.isEmpty) return 'S';
  if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
  return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
      .toUpperCase();
}

String _careerName(String raw) {
  final clean = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  return clean.isEmpty ? 'Carrera SAGE' : clean;
}

int _statusPriority(EstadoMateriaSageLaboratorio status) {
  return switch (status) {
    EstadoMateriaSageLaboratorio.cursando => 0,
    EstadoMateriaSageLaboratorio.regular => 1,
    EstadoMateriaSageLaboratorio.noRegularizada => 2,
    EstadoMateriaSageLaboratorio.desconocida => 3,
    EstadoMateriaSageLaboratorio.aprobada => 4,
  };
}

Color _statusColor(EstadoMateriaSageLaboratorio status) {
  return switch (status) {
    EstadoMateriaSageLaboratorio.aprobada => PaletaLiquidGlass.verde,
    EstadoMateriaSageLaboratorio.regular => PaletaLiquidGlass.amarillo,
    EstadoMateriaSageLaboratorio.cursando => PaletaLiquidGlass.turquesa,
    EstadoMateriaSageLaboratorio.noRegularizada => PaletaLiquidGlass.rojo,
    EstadoMateriaSageLaboratorio.desconocida => const Color(0xFF9AA7BD),
  };
}
