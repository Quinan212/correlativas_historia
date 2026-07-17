import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../compartido/componentes/navegacion_inferior.dart';
import '../../../compartido/componentes/tarjetas_metricas.dart';
import '../../../compartido/media/widgets_media_remota.dart';
import '../../calculadora/pantalla/pantalla_calculadora.dart';
import '../../cascada/pantalla/pantalla_mapa_correlatividades.dart';
import '../../curriculum/pantalla/pantalla_disenos_curriculares.dart';
import '../../examenes/examenes_pantalla.dart';
import '../../preguntas_frecuentes/preguntas_frecuentes_pantalla.dart';
import '../componentes/tema_mensajes_laboratorio_sage.dart';
import '../datos/repositorio_trayectoria_sage_laboratorio.dart';
import '../modelos/modelos_trayectoria_sage_laboratorio.dart';
import '../sage/pantalla_sage_laboratorio.dart';

class PantallaLaboratorioSage extends StatefulWidget {
  const PantallaLaboratorioSage({super.key});

  @override
  State<PantallaLaboratorioSage> createState() =>
      _PantallaLaboratorioSageState();
}

class _PantallaLaboratorioSageState extends State<PantallaLaboratorioSage> {
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
    await _repository.borrar();
    if (!mounted) return;
    _trajectory.value = null;
    _resetRevision.value++;
    setState(() {
      _planVisible = false;
      _section = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trayectoria desincronizada'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  @override
  void dispose() {
    _trajectory.dispose();
    _localLoaded.dispose();
    _resetRevision.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sectionChildren = <Widget>[
      PantallaInicioTrayectoriaSageLaboratorio(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
        resetListenable: _resetRevision,
        onExit: () => Navigator.of(context).pop(),
        onOpenPlan: _openPlan,
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
      return _NavegadorLaboratorio(
        navigatorKey: _navigatorKeys[index],
        child: sectionChildren[index],
      );
    });

    Widget content = _planVisible
        ? const PantallaMapaCorrelatividades(
            key: ValueKey('sage-lab-plan-completo'),
          )
        : IndexedStack(index: _section, children: tabs);

    if (desktop) {
      final selected = _planVisible
          ? 2
          : switch (_section) {
              0 => 0,
              1 => 1,
              2 => 3,
              _ => 4,
            };
      content = Row(
        children: [
          NavigationRail(
            selectedIndex: selected,
            onDestinationSelected: (index) {
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
            },
            extended: width >= 1300,
            minExtendedWidth: 190,
            labelType: width >= 1300
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
            indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            leading: Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Tooltip(
                message: 'Salir de la zona de pruebas',
                child: IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.school_outlined),
                selectedIcon: Icon(Icons.school_rounded),
                label: Text('Inicio'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment_rounded),
                label: Text('Exámenes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree_rounded),
                label: Text('Plan completo'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt_rounded),
                label: Text('Materias'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Datos'),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
          Expanded(child: content),
        ],
      );
    }

    return Theme(
      data: temaMensajesLaboratorioSage(context),
      child: PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final shouldExit = await _handleBack();
          if (shouldExit && context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          body: content,
          bottomNavigationBar: desktop
              ? null
              : NavegacionInferiorApp(
                  current: _section,
                  onTapTrayectorias: () => _selectSection(0),
                  onTapHome: () => _selectSection(1),
                  onTapCenter: _openPlan,
                  onTapMap: () => _selectSection(2),
                  onTapCalc: () => _selectSection(3),
                ),
        ),
      ),
    );
  }
}

class _NavegadorLaboratorio extends StatelessWidget {
  const _NavegadorLaboratorio({
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

class PantallaInicioTrayectoriaSageLaboratorio extends StatefulWidget {
  const PantallaInicioTrayectoriaSageLaboratorio({
    super.key,
    required this.trajectoryListenable,
    required this.localLoadedListenable,
    required this.resetListenable,
    required this.onExit,
    required this.onOpenPlan,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final ValueNotifier<bool> localLoadedListenable;
  final ValueNotifier<int> resetListenable;
  final VoidCallback onExit;
  final VoidCallback onOpenPlan;

  @override
  State<PantallaInicioTrayectoriaSageLaboratorio> createState() =>
      _PantallaInicioTrayectoriaSageLaboratorioState();
}

class _PantallaInicioTrayectoriaSageLaboratorioState
    extends State<PantallaInicioTrayectoriaSageLaboratorio> {
  static const _repository = RepositorioTrayectoriaSageLaboratorio();

  TrayectoriaSageLaboratorio? _draft;
  EstadoPreparacionSageLaboratorio _preparation =
      const EstadoPreparacionSageLaboratorio(mensaje: 'Pendiente');
  bool _saving = false;
  int _selectedCareer = 0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _bannerKey = GlobalKey();
  double _bannerHeight = 280;
  bool _bannerMeasurementScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.resetListenable.addListener(_resetState);
  }

  @override
  void didUpdateWidget(
    covariant PantallaInicioTrayectoriaSageLaboratorio oldWidget,
  ) {
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

  void _scheduleBannerMeasurement() {
    if (_bannerMeasurementScheduled) return;
    _bannerMeasurementScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bannerMeasurementScheduled = false;
      if (!mounted) return;
      final renderObject = _bannerKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) return;
      final height = renderObject.size.height;
      if ((height - _bannerHeight).abs() < 0.5) return;
      setState(() => _bannerHeight = height);
    });
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

  void _openMaterials({bool focusSearch = false}) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PantallaMateriasSageLaboratorio(
          trajectoryListenable: widget.trajectoryListenable,
          localLoadedListenable: widget.localLoadedListenable,
          initialSearchFocus: focusSearch,
        ),
      ),
    );
  }

  void _openExams() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ExamenesPantalla()),
    );
  }

  void _openCurriculum() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const PantallaDisenosCurriculares(),
      ),
    );
  }

  void _showSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Próximamente'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSearch() {
    final trajectory = widget.trajectoryListenable.value;
    if (trajectory == null || trajectory.totalMaterias == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sin materias sincronizadas'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _openMaterials(focusSearch: true);
  }

  Future<void> _chooseCareer(TrayectoriaSageLaboratorio trajectory) async {
    if (trajectory.carreras.length < 2) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: trajectory.carreras.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final career = trajectory.carreras[index];
          return ListTile(
            leading: Icon(
              index == _selectedCareer
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
            ),
            title: Text(_nombreCarreraPresentableLaboratorio(career.nombre)),
            subtitle: career.institucion.trim().isEmpty
                ? null
                : Text(career.institucion),
            onTap: () => Navigator.of(sheetContext).pop(index),
          );
        },
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedCareer = selected);
  }

  Future<void> _openSage() async {
    setState(() {
      _draft = null;
      _preparation = const EstadoPreparacionSageLaboratorio(
        mensaje: 'Esperando Historial',
      );
    });
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
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
    if (current != null && !_sameSageProfile(current.perfil, draft.perfil)) {
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
    final stats = _calculateSyncStats(current, draft);
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
          content: Text(stats.message(stored.totalMaterias)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la trayectoria local.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openCalculator() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const PantallaCalculadora()),
    );
  }

  void _openFaq() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const PantallaPreguntasFrecuentes(),
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
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final career = _currentCareer(trajectory);
            final fixedHeaderHeight = MediaQuery.paddingOf(context).top + 62.0;
            const cornerBandHeight = 24.0;
            _scheduleBannerMeasurement();

            return Scaffold(
              backgroundColor: isDark
                  ? const Color(0xFF050816)
                  : const Color(0xFFF6F8FC),
              body: Stack(
                children: [
                  Positioned(
                    top: fixedHeaderHeight - cornerBandHeight,
                    left: 0,
                    right: 0,
                    height: cornerBandHeight,
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _scrollController,
                        builder: (context, child) {
                          final offset = _scrollController.hasClients
                              ? math.max(_scrollController.offset, 0.0)
                              : 0.0;
                          return CustomPaint(
                            painter: _FondoEsquinasInicioLaboratorioPainter(
                              scrollOffset: offset,
                              gradientTopExtension: fixedHeaderHeight,
                              bannerHeight: _bannerHeight,
                            ),
                            child: const SizedBox.expand(),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: fixedHeaderHeight),
                    child: CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            key: _bannerKey,
                            child: _BannerPerfilInicioLaboratorio(
                              loaded: loaded,
                              trajectory: trajectory,
                              career: career,
                              onTapProfile: trajectory == null
                                  ? null
                                  : () {
                                      unawaited(_chooseCareer(trajectory));
                                    },
                              onOpenSubjects: trajectory == null
                                  ? null
                                  : () => _openMaterials(),
                              onOpenHistory: _showSoon,
                              onOpenExams: _openExams,
                              preparation: _preparation,
                              draft: _draft,
                              saving: _saving,
                              onSync: () => unawaited(_sync()),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Column(
                              children: [
                                _FranjaResumenInicioLaboratorio(
                                  loaded: loaded,
                                  career: career,
                                  onOpenSubjects: trajectory == null
                                      ? null
                                      : () => _openMaterials(),
                                ),
                                const SizedBox(height: 12),
                                _ExamShortcutLaboratorio(onTap: _openExams),
                                const SizedBox(height: 14),
                                _SageAccessLaboratorio(
                                  onTap: () => unawaited(_openSage()),
                                ),
                                const SizedBox(height: 14),
                                _GrillaAccionesInicioLaboratorio(
                                  onOpenSelfSubjects: () => _openMaterials(),
                                  onOpenPlan: widget.onOpenPlan,
                                  onOpenScenarios: _openCalculator,
                                  onOpenHelp: _openFaq,
                                  onOpenNextSteps: _showSoon,
                                  onOpenProgress: _showSoon,
                                  onOpenCalendar: _showSoon,
                                  onOpenCurriculum: _openCurriculum,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PromocionalInicioLaboratorioDelegate(
                            viewportHeight:
                                MediaQuery.sizeOf(context).height -
                                fixedHeaderHeight,
                            onOpenExams: _openExams,
                            onOpenScenarios: _openCalculator,
                            onOpenSubjects: () => _openMaterials(),
                            onOpenCalendar: _showSoon,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 144)),
                      ],
                    ),
                  ),
                  _EncabezadoInicioLaboratorio(
                    trajectory: trajectory,
                    scrollController: _scrollController,
                    onOpenApp: widget.onExit,
                    onOpenSearch: _openSearch,
                    onOpenNotifications: _showSoon,
                    onRefresh: _openSage,
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

class PantallaMateriasSageLaboratorio extends StatefulWidget {
  const PantallaMateriasSageLaboratorio({
    super.key,
    required this.trajectoryListenable,
    required this.localLoadedListenable,
    this.initialSearchFocus = false,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final ValueNotifier<bool> localLoadedListenable;
  final bool initialSearchFocus;

  @override
  State<PantallaMateriasSageLaboratorio> createState() =>
      _PantallaMateriasSageLaboratorioState();
}

class _PantallaMateriasSageLaboratorioState
    extends State<PantallaMateriasSageLaboratorio> {
  int _careerIndex = 0;
  int? _year;
  EstadoMateriaSageLaboratorio? _status;
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Materias desde SAGE')),
      body: ValueListenableBuilder<bool>(
        valueListenable: widget.localLoadedListenable,
        builder: (context, loaded, _) {
          if (!loaded) return const Center(child: CircularProgressIndicator());
          return ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
            valueListenable: widget.trajectoryListenable,
            builder: (context, trajectory, _) {
              if (trajectory == null || trajectory.carreras.isEmpty) {
                return const _EstadoVacioSeccionLaboratorio(
                  icon: Icons.list_alt_rounded,
                  title: 'No hay materias sincronizadas',
                );
              }
              final safeIndex = _careerIndex
                  .clamp(0, trajectory.carreras.length - 1)
                  .toInt();
              final career = trajectory.carreras[safeIndex];
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
                        if (_year != null && subject.anio != _year)
                          return false;
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
                      return a.nombre.toLowerCase().compareTo(
                        b.nombre.toLowerCase(),
                      );
                    });

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                children: [
                  if (trajectory.carreras.length > 1)
                    DropdownButtonFormField<int>(
                      key: ValueKey<String>(
                        'materias-carrera-$safeIndex-${trajectory.sincronizadaEn?.millisecondsSinceEpoch ?? 0}',
                      ),
                      initialValue: safeIndex,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Carrera',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (
                          var index = 0;
                          index < trajectory.carreras.length;
                          index++
                        )
                          DropdownMenuItem<int>(
                            value: index,
                            child: Text(
                              trajectory.carreras[index].nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _careerIndex = value;
                          _year = null;
                          _status = null;
                        });
                      },
                    )
                  else
                    _TituloCarreraLaboratorio(career: career),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _queryController,
                    autofocus: widget.initialSearchFocus,
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
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FiltroEstado(
                          label: 'Todas',
                          selected: _status == null,
                          onTap: () => setState(() => _status = null),
                        ),
                        for (final state in const [
                          EstadoMateriaSageLaboratorio.aprobada,
                          EstadoMateriaSageLaboratorio.regular,
                          EstadoMateriaSageLaboratorio.cursando,
                          EstadoMateriaSageLaboratorio.noRegularizada,
                          EstadoMateriaSageLaboratorio.desconocida,
                        ]) ...[
                          const SizedBox(width: 8),
                          _FiltroEstado(
                            label: state.etiqueta,
                            selected: _status == state,
                            onTap: () => setState(() => _status = state),
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
                          FilterChip(
                            label: const Text('Todos los años'),
                            selected: _year == null,
                            onSelected: (_) => setState(() => _year = null),
                          ),
                          for (final year in years) ...[
                            const SizedBox(width: 8),
                            FilterChip(
                              label: Text('$year° año'),
                              selected: _year == year,
                              onSelected: (_) => setState(() => _year = year),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Text(
                    '${subjects.length} materia${subjects.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (subjects.isEmpty)
                    const _EstadoVacioSeccionLaboratorio(
                      icon: Icons.search_off_rounded,
                      title: 'Sin resultados',
                      compact: true,
                    )
                  else
                    for (final subject in subjects) ...[
                      _TarjetaMateriaSage(subject: subject),
                      const SizedBox(height: 8),
                    ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class PantallaDatosSageLaboratorio extends StatelessWidget {
  const PantallaDatosSageLaboratorio({
    super.key,
    required this.trajectoryListenable,
    required this.localLoadedListenable,
    required this.onDesincronizar,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final ValueNotifier<bool> localLoadedListenable;
  final Future<void> Function() onDesincronizar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos de SAGE'),
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
            valueListenable: trajectoryListenable,
            builder: (context, trajectory, _) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: _ChipDesincronizarLaboratorio(
                  enabled: trajectory != null,
                  onTap: () async {
                    if (trajectory == null) return;
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Desincronizar trayectoria'),
                        content: const Text('¿Desincronizar trayectoria?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Desincronizar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await onDesincronizar();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: localLoadedListenable,
        builder: (context, loaded, _) {
          if (!loaded) return const Center(child: CircularProgressIndicator());
          return ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
            valueListenable: trajectoryListenable,
            builder: (context, trajectory, _) {
              if (trajectory == null) {
                return const _EstadoVacioSeccionLaboratorio(
                  icon: Icons.person_outline_rounded,
                  title: 'No hay datos sincronizados',
                );
              }
              final theme = Theme.of(context);
              final scheme = theme.colorScheme;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: scheme.primaryContainer,
                          foregroundColor: scheme.onPrimaryContainer,
                          child: const Icon(Icons.person_rounded, size: 34),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _nombrePerfilPresentableLaboratorio(
                            trajectory.perfil,
                          ),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (trajectory.perfil.dni != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            'DNI ${trajectory.perfil.dni}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SeccionDatosLaboratorio(
                    title: 'Trayectoria',
                    rows: [
                      _DatoLaboratorio(
                        label: 'Carreras',
                        value: '${trajectory.carreras.length}',
                      ),
                      _DatoLaboratorio(
                        label: 'Materias',
                        value: '${trajectory.totalMaterias}',
                      ),
                      _DatoLaboratorio(
                        label: 'Última sincronización',
                        value: _formatDateTime(
                          trajectory.sincronizadaEn ?? trajectory.capturadaEn,
                        ),
                      ),
                      const _DatoLaboratorio(label: 'Origen', value: 'SAGE'),
                    ],
                  ),
                  if (_camposPerfilPresentablesLaboratorio(
                    trajectory.perfil,
                  ).isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _SeccionDatosLaboratorio(
                      title: 'Datos encontrados en SAGE',
                      rows: [
                        for (final entry
                            in _camposPerfilPresentablesLaboratorio(
                              trajectory.perfil,
                            ))
                          _DatoLaboratorio(
                            label: entry.key,
                            value: entry.value,
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  for (final career in trajectory.carreras) ...[
                    _SeccionDatosLaboratorio(
                      title: _nombreCarreraPresentableLaboratorio(
                        career.nombre,
                      ),
                      rows: [
                        _DatoLaboratorio(
                          label: 'Institución',
                          value: career.institucion,
                        ),
                        if (career.anioInicio != null)
                          _DatoLaboratorio(
                            label: 'Año de inicio',
                            value: '${career.anioInicio}',
                          ),
                        if (career.estadoInscripcion != null)
                          _DatoLaboratorio(
                            label: 'Inscripción',
                            value: career.estadoInscripcion!,
                          ),
                        _DatoLaboratorio(
                          label: 'Materias detectadas',
                          value: '${career.materias.length}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _IconoAplicacionLaboratorio extends StatelessWidget {
  const _IconoAplicacionLaboratorio({this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Transform.scale(
        scale: 1.15,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/icon_fore.png',
          fit: BoxFit.cover,
          cacheWidth: 112,
          cacheHeight: 112,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.school_rounded, color: Color(0xFF0E5E86)),
        ),
      ),
    );
  }
}

class _EncabezadoInicioLaboratorio extends StatefulWidget {
  const _EncabezadoInicioLaboratorio({
    required this.trajectory,
    required this.scrollController,
    required this.onOpenApp,
    required this.onOpenSearch,
    required this.onOpenNotifications,
    required this.onRefresh,
  });

  final TrayectoriaSageLaboratorio? trajectory;
  final ScrollController scrollController;
  final VoidCallback onOpenApp;
  final VoidCallback onOpenSearch;
  final VoidCallback onOpenNotifications;
  final Future<void> Function() onRefresh;

  @override
  State<_EncabezadoInicioLaboratorio> createState() =>
      _EncabezadoInicioLaboratorioState();
}

class _EncabezadoInicioLaboratorioState
    extends State<_EncabezadoInicioLaboratorio> {
  bool _compact = false;
  double _searchProgress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _EncabezadoInicioLaboratorio oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController == widget.scrollController) return;
    oldWidget.scrollController.removeListener(_onScroll);
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;
    final compact = offset > 180;
    final searchProgress = (offset / 60).clamp(0.0, 1.0).toDouble();
    if ((compact != _compact ||
            (searchProgress - _searchProgress).abs() > 0.01) &&
        mounted) {
      setState(() {
        _compact = compact;
        _searchProgress = searchProgress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = _primerNombreLaboratorio(
      _nombrePerfilPresentableLaboratorio(widget.trajectory?.perfil),
    );
    final title = firstName == null ? 'Hola' : 'Hola, $firstName';
    final compact = _compact;
    final titleWidth = compact ? 64.0 : 104.0;
    final searchProgress = _searchProgress;
    final titleOpacity = (1 - searchProgress * 1.25).clamp(0.0, 1.0).toDouble();
    final titleOffset = -52 * searchProgress;
    final actionsOpacity = (1 - searchProgress * 1.15)
        .clamp(0.0, 1.0)
        .toDouble();
    final topInset = MediaQuery.paddingOf(context).top;
    const headerBlue = Color(0xFF0E5E86);
    final headerRadius = 24 * searchProgress;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: Colors.white,
      fontSize: 17,
    );

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.fromLTRB(10, topInset + 6, 10, 14),
        decoration: BoxDecoration(
          color: headerBlue,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(headerRadius),
          ),
        ),
        child: SizedBox(
          height: 42,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: widget.onOpenApp,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Transform.translate(
                          offset: Offset(titleOffset, 0),
                          child: Opacity(
                            opacity: titleOpacity,
                            child: Row(
                              children: [
                                const _IconoAplicacionLaboratorio(size: 36),
                                const SizedBox(width: 8),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: titleWidth,
                                  height: 24,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 140,
                                        ),
                                        opacity: compact ? 0 : 1,
                                        child: Text(
                                          title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: titleStyle,
                                        ),
                                      ),
                                      AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 140,
                                        ),
                                        opacity: compact ? 1 : 0,
                                        child: Text(
                                          firstName ?? 'Hola',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: titleStyle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 1 - searchProgress,
                    child: _BotonIconoInicioLaboratorio(
                      icon: Icons.search_rounded,
                      tooltip: 'Buscar',
                      onTap: widget.onOpenSearch,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Opacity(
                    opacity: actionsOpacity,
                    child: Transform.translate(
                      offset: Offset(68 * searchProgress, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BotonIconoInicioLaboratorio(
                            icon: Icons.notifications_none_rounded,
                            tooltip: 'Notificaciones',
                            onTap: widget.onOpenNotifications,
                          ),
                          const SizedBox(width: 2),
                          _BotonIconoInicioLaboratorio(
                            icon: Icons.refresh_rounded,
                            tooltip: 'Actualizar',
                            onTap: widget.onRefresh,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 78 * (1 - searchProgress),
                top: 0,
                bottom: 0,
                child: _BarraBusquedaInicioLaboratorio(
                  progress: searchProgress,
                  onTap: widget.onOpenSearch,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonIconoInicioLaboratorio extends StatelessWidget {
  const _BotonIconoInicioLaboratorio({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

class _BarraBusquedaInicioLaboratorio extends StatelessWidget {
  const _BarraBusquedaInicioLaboratorio({
    required this.progress,
    required this.onTap,
  });

  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final normalized = progress.clamp(0.0, 1.0).toDouble();
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final width = 42 + (maxWidth - 42) * normalized;
        final background = Color.lerp(
          Colors.white.withValues(alpha: 0.10),
          Colors.white,
          normalized,
        );
        final border = Color.lerp(
          Colors.white.withValues(alpha: 0.28),
          const Color(0xFFEAF1F7),
          normalized,
        );
        final labelOpacity = ((normalized - 0.18) / 0.82)
            .clamp(0.0, 1.0)
            .toDouble();
        final contentWidth = (width - 2).clamp(0.0, double.infinity).toDouble();
        final showLabel = normalized > 0.18 && contentWidth > 58;
        return Align(
          child: Opacity(
            opacity: normalized,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: width,
                  height: 42,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: border!),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 42,
                        child: Icon(
                          Icons.search_rounded,
                          color: Color(0xFF0E5E86),
                          size: 20,
                        ),
                      ),
                      if (showLabel)
                        Expanded(
                          child: Opacity(
                            opacity: labelOpacity,
                            child: Text(
                              'Buscar materias y carreras...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      if (showLabel) const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FondoEsquinasInicioLaboratorioPainter extends CustomPainter {
  const _FondoEsquinasInicioLaboratorioPainter({
    required this.scrollOffset,
    required this.gradientTopExtension,
    required this.bannerHeight,
  });

  final double scrollOffset;
  final double gradientTopExtension;
  final double bannerHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final totalHeight = math.max(gradientTopExtension + bannerHeight, 1.0);
    final bandTop = gradientTopExtension - size.height + scrollOffset;
    final shaderRect = Rect.fromLTWH(0, -bandTop, size.width, totalHeight);
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF0E5E86),
        Color(0xFF0E5E86),
        Color(0xFF0E5E86),
        Color(0xD10E5E86),
        Color(0xFFEAF1F7),
        Color(0xFFF6F8FC),
      ],
      stops: [0, 0.40, 0.52, 0.70, 0.88, 1],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = gradient.createShader(shaderRect),
    );
  }

  @override
  bool shouldRepaint(
    covariant _FondoEsquinasInicioLaboratorioPainter oldDelegate,
  ) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.gradientTopExtension != gradientTopExtension ||
        oldDelegate.bannerHeight != bannerHeight;
  }
}

class _BannerPerfilInicioLaboratorio extends StatelessWidget {
  const _BannerPerfilInicioLaboratorio({
    required this.loaded,
    required this.trajectory,
    required this.career,
    required this.onTapProfile,
    required this.onOpenSubjects,
    required this.onOpenHistory,
    required this.onOpenExams,
    required this.preparation,
    required this.draft,
    required this.saving,
    required this.onSync,
  });

  final bool loaded;
  final TrayectoriaSageLaboratorio? trajectory;
  final CarreraTrayectoriaSageLaboratorio? career;
  final VoidCallback? onTapProfile;
  final VoidCallback? onOpenSubjects;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenExams;
  final EstadoPreparacionSageLaboratorio preparation;
  final TrayectoriaSageLaboratorio? draft;
  final bool saving;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const headerBlue = Color(0xFF0E5E86);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  headerBlue,
                  headerBlue,
                  Color(0xD10E5E86),
                  Color(0xFFEAF1F7),
                  Color(0xFFF6F8FC),
                ],
                stops: [0, 0.42, 0.70, 0.90, 1],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: InkWell(
            onTap: onTapProfile,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estudiante',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!loaded)
                    const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    )
                  else if (trajectory == null || career == null)
                    Text(
                      'Sincronizá para ver tus datos',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.04,
                      ),
                    )
                  else ...[
                    Text(
                      _nombrePerfilPresentableLaboratorio(trajectory!.perfil),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.04,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _lineaPerfilLaboratorio(trajectory!, career!),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _AccionesRapidasInicioLaboratorio(
                    onOpenSubjects: onOpenSubjects,
                    onOpenHistory: onOpenHistory,
                    onOpenExams: onOpenExams,
                    preparation: preparation,
                    draft: draft,
                    saving: saving,
                    onSync: onSync,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccionesRapidasInicioLaboratorio extends StatelessWidget {
  const _AccionesRapidasInicioLaboratorio({
    required this.onOpenSubjects,
    required this.onOpenHistory,
    required this.onOpenExams,
    required this.preparation,
    required this.draft,
    required this.saving,
    required this.onSync,
  });

  final VoidCallback? onOpenSubjects;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenExams;
  final EstadoPreparacionSageLaboratorio preparation;
  final TrayectoriaSageLaboratorio? draft;
  final bool saving;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final canSync =
        draft?.listaParaSincronizar == true &&
        !saving &&
        !preparation.bloqueado;
    final preparing =
        !canSync &&
        !preparation.bloqueado &&
        preparation.progreso != null &&
        preparation.progreso! < 1;

    return Row(
      children: [
        Expanded(
          child: _AccionCircularInicioLaboratorio(
            icon: Icons.grid_view_rounded,
            label: 'Materias',
            onTap: onOpenSubjects,
          ),
        ),
        Expanded(
          child: _AccionCircularInicioLaboratorio(
            icon: Icons.history_rounded,
            label: 'Historial',
            onTap: onOpenHistory,
          ),
        ),
        Expanded(
          child: _AccionCircularInicioLaboratorio(
            icon: Icons.event_note_rounded,
            label: 'Mesas',
            onTap: onOpenExams,
          ),
        ),
        Expanded(
          child: _AccionCircularInicioLaboratorio(
            icon: saving || preparing
                ? Icons.hourglass_top_rounded
                : canSync
                ? Icons.sync_rounded
                : Icons.sync_disabled_rounded,
            label: 'Sincronizar',
            onTap: canSync ? onSync : null,
          ),
        ),
      ],
    );
  }
}

class _AccionCircularInicioLaboratorio extends StatelessWidget {
  const _AccionCircularInicioLaboratorio({
    required this.icon,
    required this.label,
    required this.onTap,
    this.circleColor,
    this.circleBorderColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? circleColor;
  final Color? circleBorderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Opacity(
      opacity: onTap == null ? 0.55 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor ?? scheme.primary.withValues(alpha: 0.10),
                  border: Border.all(
                    color:
                        circleBorderColor ??
                        scheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FranjaResumenInicioLaboratorio extends StatelessWidget {
  const _FranjaResumenInicioLaboratorio({
    required this.loaded,
    required this.career,
    required this.onOpenSubjects,
  });

  final bool loaded;
  final CarreraTrayectoriaSageLaboratorio? career;
  final VoidCallback? onOpenSubjects;

  @override
  Widget build(BuildContext context) {
    final approved = career?.aprobadas;
    final inProgress = career?.cursando;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final thirdWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        final tileHeight = math.max(thirdWidth * 0.72, 104.0);
        final largeWidth = (thirdWidth * 2) + spacing;
        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: largeWidth,
                  height: tileHeight,
                  child: GestureDetector(
                    onTap: onOpenSubjects,
                    child: _TarjetaProgresoInicioLaboratorio(loaded: loaded),
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(
                  child: SizedBox(
                    height: tileHeight,
                    child: GestureDetector(
                      onTap: onOpenSubjects,
                      child: TarjetaMetrica(
                        icon: Icons.check_circle_rounded,
                        label: 'Aprobadas',
                        value: loaded ? '${approved ?? '—'}' : '…',
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              children: [
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: const _TarjetaProximamenteLaboratorio(
                    label: 'Habilitadas',
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: GestureDetector(
                    onTap: onOpenSubjects,
                    child: TarjetaMetrica(
                      icon: Icons.play_circle_rounded,
                      label: 'Cursando',
                      value: loaded ? '${inProgress ?? '—'}' : '…',
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: const _TarjetaProximamenteLaboratorio(
                    label: 'Plan total',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaProgresoInicioLaboratorio extends StatelessWidget {
  const _TarjetaProgresoInicioLaboratorio({required this.loaded});

  final bool loaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant.withValues(alpha: 0.58);
    return TarjetaMetricaVidrio(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: muted, width: 6),
            ),
            child: Text(
              loaded ? '—' : '…',
              style: theme.textTheme.labelLarge?.copyWith(
                color: muted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso general',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loaded ? '—' : '…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
                    fontSize: 11,
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

class _TarjetaProximamenteLaboratorio extends StatelessWidget {
  const _TarjetaProximamenteLaboratorio({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant.withValues(alpha: 0.58);
    return TarjetaMetricaVidrio(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.broken_image_rounded, color: muted, size: 24),
          const SizedBox(height: 8),
          Text(
            '—',
            maxLines: 1,
            style: theme.textTheme.titleLarge?.copyWith(
              color: muted,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamShortcutLaboratorio extends StatelessWidget {
  const _ExamShortcutLaboratorio({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: scheme.secondary.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                color: scheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mesas y fechas publicadas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.north_east_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SageAccessLaboratorio extends StatelessWidget {
  const _SageAccessLaboratorio({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A3D5C), Color(0xFF0E5E86)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0E5E86).withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(3, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/sage_banner.png',
                height: 19,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Accede a tu estado',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _GrillaAccionesInicioLaboratorio extends StatelessWidget {
  const _GrillaAccionesInicioLaboratorio({
    required this.onOpenSelfSubjects,
    required this.onOpenPlan,
    required this.onOpenScenarios,
    required this.onOpenHelp,
    required this.onOpenNextSteps,
    required this.onOpenProgress,
    required this.onOpenCalendar,
    required this.onOpenCurriculum,
  });

  final VoidCallback onOpenSelfSubjects;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenScenarios;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenNextSteps;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenCurriculum;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.12);
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - (spacing * 3)) / 4;
        final actions = <Widget>[
          _AccionCircularInicioLaboratorio(
            icon: Icons.edit_note_rounded,
            label: 'Mi registro',
            onTap: onOpenSelfSubjects,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.account_tree_rounded,
            label: 'Plan completo',
            onTap: onOpenPlan,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.auto_graph_rounded,
            label: 'Escenarios',
            onTap: onOpenScenarios,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.help_rounded,
            label: 'Ayuda',
            onTap: onOpenHelp,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.flag_outlined,
            label: 'Próximos pasos',
            onTap: onOpenNextSteps,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.insights_outlined,
            label: 'Mi avance',
            onTap: onOpenProgress,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.calendar_month_outlined,
            label: 'Calendario',
            onTap: onOpenCalendar,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularInicioLaboratorio(
            icon: Icons.menu_book_rounded,
            label: 'Diseños',
            onTap: onOpenCurriculum,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ];
        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: actions
              .map((action) => SizedBox(width: itemWidth, child: action))
              .toList(growable: false),
        );
      },
    );
  }
}

enum _AccionPromocionalInicioLaboratorio {
  exams,
  scenarios,
  subjects,
  calendar,
}

class _PromocionalInicioLaboratorioDelegate
    extends SliverPersistentHeaderDelegate {
  static const _items = <_CardPromocionalInicioLaboratorio>[
    _CardPromocionalInicioLaboratorio(
      assetPath: 'assets/banners/historia/recorrido/01.jpg',
      title: 'Prepará tus finales y revisá las fechas de cada mesa',
      cta: 'Ver mesas',
      alignment: Alignment.center,
      action: _AccionPromocionalInicioLaboratorio.exams,
    ),
    _CardPromocionalInicioLaboratorio(
      assetPath: 'assets/banners/historia/recorrido/02.jpg',
      title: 'Comprobá qué materias se habilitan para tu próximo año',
      cta: 'Consultar correlativas',
      alignment: Alignment.center,
      action: _AccionPromocionalInicioLaboratorio.scenarios,
    ),
    _CardPromocionalInicioLaboratorio(
      assetPath: 'assets/banners/historia/recorrido/03.jpg',
      title: 'Revisá las materias registradas en tu trayectoria',
      cta: 'Ver materias',
      alignment: Alignment.center,
      action: _AccionPromocionalInicioLaboratorio.subjects,
    ),
    _CardPromocionalInicioLaboratorio(
      assetPath: 'assets/banners/historia/recorrido/04.jpg',
      title: 'Consultá fechas, eventos y próximos vencimientos',
      cta: 'Ver calendario',
      alignment: Alignment.topCenter,
      action: _AccionPromocionalInicioLaboratorio.calendar,
    ),
  ];

  _PromocionalInicioLaboratorioDelegate({
    required this.viewportHeight,
    required this.onOpenExams,
    required this.onOpenScenarios,
    required this.onOpenSubjects,
    required this.onOpenCalendar,
  });

  final double viewportHeight;
  final VoidCallback onOpenExams;
  final VoidCallback onOpenScenarios;
  final VoidCallback onOpenSubjects;
  final VoidCallback onOpenCalendar;

  static const double _cardHeight = 340;
  static const double _cardGap = 28;
  static const double _stackedSpread = 5;
  static const double _horizontalPadding = 16;
  static const double _sectionTopPadding = 16;
  static const double _sectionHeaderHeight = 72;
  static const double _sectionHeaderGap = 24;
  static const double _bottomPadding = 16;
  static const double _pinTravel = 24;
  static const double _fullSpread = _cardHeight + _cardGap;

  double get _cardsStartTop =>
      _sectionTopPadding + _sectionHeaderHeight + _sectionHeaderGap;
  double get _stackScrollExtent =>
      (_items.length - 1) * (_fullSpread - _stackedSpread);
  double get _stackedHeight =>
      _cardsStartTop +
      _cardHeight +
      ((_items.length - 1) * _stackedSpread) +
      _bottomPadding;

  @override
  double get maxExtent => _stackedHeight + _pinTravel + _stackScrollExtent;

  @override
  double get minExtent => _stackedHeight;

  double _naturalTop(int index) => _cardsStartTop + (index * _fullSpread);
  double _stackedTop(int index) => _cardsStartTop + (index * _stackedSpread);

  double _topFor(int index, double scroll) {
    return math.max(_stackedTop(index), _naturalTop(index) - scroll);
  }

  double _collision(int index, double scroll) {
    if (index >= _items.length - 1) return 0;
    final distance = _topFor(index + 1, scroll) - _topFor(index, scroll);
    return (1 - (distance / _cardHeight)).clamp(0.0, 1.0).toDouble();
  }

  double _depth(int index, double scroll) {
    if (index == _items.length - 1) return 0;
    final travel = _naturalTop(index) - _stackedTop(index);
    if (travel <= 0) return 0;
    return ((_topFor(index, scroll) - _stackedTop(index)) / travel)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  VoidCallback _callback(_AccionPromocionalInicioLaboratorio action) {
    return switch (action) {
      _AccionPromocionalInicioLaboratorio.exams => onOpenExams,
      _AccionPromocionalInicioLaboratorio.scenarios => onOpenScenarios,
      _AccionPromocionalInicioLaboratorio.subjects => onOpenSubjects,
      _AccionPromocionalInicioLaboratorio.calendar => onOpenCalendar,
    };
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double scroll = math
        .max(shrinkOffset - _pinTravel, 0.0)
        .clamp(0.0, _stackScrollExtent)
        .toDouble();
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ColoredBox(color: theme.scaffoldBackgroundColor),
        ),
        ...List.generate(_items.length, (index) {
          final item = _items[index];
          return Positioned(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: _topFor(index, scroll),
            child: _CardPromocionalInicioLaboratorioWidget(
              item: item,
              collisionProgress: _collision(index, scroll),
              depthProgress: _depth(index, scroll),
              cardHeight: _cardHeight,
              onTap: _callback(item.action),
            ),
          );
        }),
        const Positioned(
          left: _horizontalPadding,
          right: _horizontalPadding,
          top: _sectionTopPadding,
          child: _InicioSugerenciasLaboratorio(height: _sectionHeaderHeight),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(
    covariant _PromocionalInicioLaboratorioDelegate oldDelegate,
  ) {
    return oldDelegate.viewportHeight != viewportHeight ||
        oldDelegate.onOpenExams != onOpenExams ||
        oldDelegate.onOpenScenarios != onOpenScenarios ||
        oldDelegate.onOpenSubjects != onOpenSubjects ||
        oldDelegate.onOpenCalendar != onOpenCalendar;
  }
}

class _InicioSugerenciasLaboratorio extends StatelessWidget {
  const _InicioSugerenciasLaboratorio({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.10),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          'Sugerencias',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CardPromocionalInicioLaboratorioWidget extends StatelessWidget {
  const _CardPromocionalInicioLaboratorioWidget({
    required this.item,
    required this.collisionProgress,
    required this.depthProgress,
    required this.cardHeight,
    required this.onTap,
  });

  final _CardPromocionalInicioLaboratorio item;
  final double collisionProgress;
  final double depthProgress;
  final double cardHeight;
  final VoidCallback onTap;

  ColorFilter _brightnessFilter(double brightness) {
    return ColorFilter.matrix(<double>[
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stackProgress = Curves.easeOutCubic.transform(
      collisionProgress.clamp(0.0, 1.0).toDouble(),
    );
    final scale = 1 - (stackProgress * 0.06);
    final brightness = 1 - (stackProgress * 0.40);
    final translateY = stackProgress * -6;
    final shadowOpacity = 0.12 + (depthProgress * 0.10);
    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: ColorFiltered(
          colorFilter: _brightnessFilter(brightness),
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowOpacity),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Transform.scale(
                    scale: 1.08,
                    child: ImagenMediaRemota(
                      source: item.assetPath,
                      fit: BoxFit.cover,
                      alignment: item.alignment,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0, 0.35, 0.75, 1],
                        colors: [
                          Colors.black.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.06),
                          Colors.black.withValues(alpha: 0.26),
                          Colors.black.withValues(alpha: 0.64),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onTap,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.cta,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPromocionalInicioLaboratorio {
  const _CardPromocionalInicioLaboratorio({
    required this.assetPath,
    required this.title,
    required this.cta,
    required this.alignment,
    required this.action,
  });

  final String assetPath;
  final String title;
  final String cta;
  final Alignment alignment;
  final _AccionPromocionalInicioLaboratorio action;
}

String _nombrePerfilPresentableLaboratorio(
  PerfilTrayectoriaSageLaboratorio? perfil,
) {
  if (perfil == null) return 'Estudiante SAGE';

  final entries = perfil.campos.entries.toList(growable: false);
  String? findField(Iterable<String> tokens, {bool allowSingleWord = false}) {
    for (final entry in entries) {
      final key = _normalizarTextoLaboratorio(entry.key);
      if (!tokens.any(key.contains)) continue;
      final value = allowSingleWord
          ? _candidatoTextoNombreLaboratorio(entry.value)
          : _candidatoNombreLaboratorio(entry.value);
      if (value != null) return value;
    }
    return null;
  }

  final givenNames = findField(const ['nombres', 'nombre']);
  final surname = findField(const [
    'apellidos',
    'apellido',
  ], allowSingleWord: true);
  if (givenNames != null && surname != null && givenNames != surname) {
    return _capitalizarNombreLaboratorio('$givenNames $surname');
  }

  final direct = _candidatoNombreLaboratorio(perfil.nombre);
  if (direct != null) return _ordenarNombreSageLaboratorio(direct);

  final priority = <MapEntry<String, String>>[
    ...entries.where((entry) {
      final key = _normalizarTextoLaboratorio(entry.key);
      return key.contains('alumno') ||
          key.contains('estudiante') ||
          key.contains('persona') ||
          key.contains('titular');
    }),
    ...entries,
  ];
  for (final entry in priority) {
    for (final segment in entry.value.split(RegExp(r'[·|;]'))) {
      final candidate = _candidatoNombreLaboratorio(segment);
      if (candidate != null) return _ordenarNombreSageLaboratorio(candidate);
    }
  }
  return 'Estudiante SAGE';
}

String? _candidatoNombreLaboratorio(String value) {
  final clean = _candidatoTextoNombreLaboratorio(value);
  if (clean == null) return null;
  final words = clean
      .split(RegExp(r'\s+'))
      .where((word) => RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(word))
      .toList(growable: false);
  return words.length < 2 ? null : clean;
}

String? _candidatoTextoNombreLaboratorio(String value) {
  final clean = value
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (clean.isEmpty || clean.length > 90) return null;
  final normalized = _normalizarTextoLaboratorio(clean);
  const rejected = <String>{
    'dni',
    'perfil',
    'estudiante',
    'estudiante sage',
    'alumno',
    'alumna',
    'legajo',
  };
  if (rejected.contains(normalized)) return null;
  if (RegExp(r'\d').hasMatch(clean)) return null;
  final generic = RegExp(
    r'\b(carrera|resolucion|profesorado|institucion|telefono|celular|correo|domicilio)\b',
  );
  if (generic.hasMatch(normalized)) return null;
  return RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(clean) ? clean : null;
}

String _ordenarNombreSageLaboratorio(String value) {
  final clean = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (clean.contains(',')) {
    final parts = clean.split(',');
    if (parts.length >= 2) {
      final surname = parts.first.trim();
      final names = parts.sublist(1).join(' ').trim();
      return _capitalizarNombreLaboratorio('$names $surname');
    }
  }
  final words = clean.split(' ');
  final uppercase =
      clean == clean.toUpperCase() && clean != clean.toLowerCase();
  if (uppercase && words.length >= 2) {
    return _capitalizarNombreLaboratorio(
      '${words.sublist(1).join(' ')} ${words.first}',
    );
  }
  return _capitalizarNombreLaboratorio(clean);
}

String _capitalizarNombreLaboratorio(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) {
        final lower = word.toLowerCase();
        return '${lower[0].toUpperCase()}${lower.substring(1)}';
      })
      .join(' ');
}

String _nombreCarreraPresentableLaboratorio(String raw) {
  var value = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (value.isEmpty) return value;
  final sourceWasUppercase =
      value == value.toUpperCase() && value != value.toLowerCase();
  value = value.replaceFirst(
    RegExp(
      r'^res(?:oluci[oó]n)?\.?\s*(?:n[°º]?\s*)?\d+(?:[./-]\d+)*(?:\s*c\.?\s*g\.?\s*e\.?)?\s*[-–—.:]*\s*',
      caseSensitive: false,
    ),
    '',
  );
  value = value.replaceFirst(
    RegExp(r'^prof\.?\s+de\s+', caseSensitive: false),
    'Profesorado de ',
  );
  if (sourceWasUppercase) {
    const lowercaseWords = <String>{'de', 'del', 'la', 'las', 'los', 'en', 'y'};
    final words = value.toLowerCase().split(' ');
    value = [
      for (var index = 0; index < words.length; index++)
        if (index > 0 && lowercaseWords.contains(words[index]))
          words[index]
        else
          '${words[index][0].toUpperCase()}${words[index].substring(1)}',
    ].join(' ');
  }
  return value.trim().isEmpty ? raw.trim() : value.trim();
}

String _etiquetaAnioLaboratorio(int year) => switch (year) {
  1 => 'Primer año',
  2 => 'Segundo año',
  3 => 'Tercer año',
  4 => 'Cuarto año',
  5 => 'Quinto año',
  6 => 'Sexto año',
  _ => '$year.º año',
};

List<MapEntry<String, String>> _camposPerfilPresentablesLaboratorio(
  PerfilTrayectoriaSageLaboratorio perfil,
) {
  final result = <MapEntry<String, String>>[];
  final seen = <String>{};
  for (final entry in perfil.campos.entries) {
    final value = entry.value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (value.isEmpty) continue;
    final label = _etiquetaCampoSageLaboratorio(entry.key);
    final normalizedValue = _normalizarTextoLaboratorio(value);
    if (label == 'Estudiante' &&
        const {
          'dni',
          'alumno',
          'estudiante',
          'perfil',
        }.contains(normalizedValue)) {
      continue;
    }
    final signature = '${label.toLowerCase()}|${value.toLowerCase()}';
    if (!seen.add(signature)) continue;
    result.add(MapEntry<String, String>(label, value));
  }
  return result;
}

String _etiquetaCampoSageLaboratorio(String raw) {
  final segments = raw
      .split(RegExp(r'[.:/]+'))
      .where((segment) => segment.trim().isNotEmpty)
      .toList();
  final source = segments.isEmpty ? raw : segments.last;
  var key = _normalizarTextoLaboratorio(source)
      .replaceAll(RegExp(r'^(tv|txt|lbl|label|col|campo|dato|ctl|td|th)_+'), '')
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  const labels = <String, String>{
    'tipo': 'Tipo',
    'alumno': 'Estudiante',
    'alumnos': 'Estudiante',
    'estudiante': 'Estudiante',
    'nombre': 'Nombre',
    'nombres': 'Nombre',
    'apellido': 'Apellido',
    'apellidos': 'Apellido',
    'apenom': 'Nombre completo',
    'apenom 2': 'Nombre completo',
    'apenom2': 'Nombre completo',
    'dni': 'DNI',
    'nro doc': 'DNI',
    'numero documento': 'DNI',
    'documento': 'Documento',
    'cuil': 'CUIL',
    'telefono': 'Teléfono',
    'telefono celular': 'Celular',
    'celular': 'Celular',
    'mail': 'Correo electrónico',
    'email': 'Correo electrónico',
    'correo': 'Correo electrónico',
    'correo electronico': 'Correo electrónico',
    'fecha nacimiento': 'Fecha de nacimiento',
    'nacimiento': 'Fecha de nacimiento',
    'domicilio': 'Domicilio',
    'direccion': 'Dirección',
    'localidad': 'Localidad',
    'provincia': 'Provincia',
    'legajo': 'Legajo',
    'sexo': 'Sexo',
  };
  final mapped = labels[key];
  if (mapped != null) return mapped;
  if (key.isEmpty) return 'Dato';
  return key
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _normalizarTextoLaboratorio(String value) {
  return value
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String? _primerNombreLaboratorio(String? fullName) {
  final value = fullName?.trim() ?? '';
  if (value.isEmpty || value.toLowerCase() == 'estudiante sage') return null;
  return value.split(RegExp(r'\s+')).first;
}

String _lineaPerfilLaboratorio(
  TrayectoriaSageLaboratorio trajectory,
  CarreraTrayectoriaSageLaboratorio career,
) {
  final parts = <String>[];
  if (trajectory.perfil.dni != null) {
    parts.add('DNI ${trajectory.perfil.dni}');
  }
  final careerName = _nombreCarreraPresentableLaboratorio(career.nombre);
  if (careerName.isNotEmpty) parts.add(careerName);
  final year = _anioActualLaboratorio(career);
  if (year != null) parts.add(_etiquetaAnioLaboratorio(year));
  if (career.anioInicio != null) parts.add('Cohorte ${career.anioInicio}');
  return parts.join(' · ');
}

int? _anioActualLaboratorio(CarreraTrayectoriaSageLaboratorio career) {
  final current = career.materias
      .where(
        (subject) => subject.estado == EstadoMateriaSageLaboratorio.cursando,
      )
      .map((subject) => subject.anio)
      .whereType<int>()
      .toList();
  if (current.isNotEmpty) return current.reduce((a, b) => a > b ? a : b);
  final all = career.materias
      .map((subject) => subject.anio)
      .whereType<int>()
      .toList();
  return all.isEmpty ? null : all.reduce((a, b) => a > b ? a : b);
}

class _ChipDesincronizarLaboratorio extends StatelessWidget {
  const _ChipDesincronizarLaboratorio({
    required this.enabled,
    required this.onTap,
  });

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD9363E),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFFF9499)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD9363E).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.link_off_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'DESINCRONIZAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgePruebas extends StatelessWidget {
  const _BadgePruebas({this.inverted = false});

  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: inverted
            ? Colors.white.withValues(alpha: 0.16)
            : scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: inverted
            ? Border.all(color: Colors.white.withValues(alpha: 0.28))
            : null,
      ),
      child: Text(
        'EN PRUEBAS',
        style: TextStyle(
          color: inverted ? Colors.white : scheme.onTertiaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _FiltroEstado extends StatelessWidget {
  const _FiltroEstado({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _TarjetaMateriaSage extends StatelessWidget {
  const _TarjetaMateriaSage({required this.subject});

  final MateriaTrayectoriaSageLaboratorio subject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _stateColor(subject.estado);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_stateIcon(subject.estado), color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.nombre,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subject.estadoOriginal.trim().isEmpty
                      ? subject.estado.etiqueta
                      : subject.estadoOriginal,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              subject.estado.etiqueta,
              style: theme.textTheme.labelSmall?.copyWith(
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

class _TituloCarreraLaboratorio extends StatelessWidget {
  const _TituloCarreraLaboratorio({required this.career});

  final CarreraTrayectoriaSageLaboratorio career;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _nombreCarreraPresentableLaboratorio(career.nombre),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          career.institucion,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EstadoVacioSeccionLaboratorio extends StatelessWidget {
  const _EstadoVacioSeccionLaboratorio({
    required this.icon,
    required this.title,
    this.message,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 28),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 18 : 24),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 36 : 48, color: scheme.primary),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (message != null && message!.trim().isNotEmpty) ...[
                const SizedBox(height: 7),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SeccionDatosLaboratorio extends StatelessWidget {
  const _SeccionDatosLaboratorio({required this.title, required this.rows});

  final String title;
  final List<_DatoLaboratorio> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0) Divider(color: scheme.outlineVariant),
            rows[index],
          ],
        ],
      ),
    );
  }
}

class _DatoLaboratorio extends StatelessWidget {
  const _DatoLaboratorio({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncStats {
  const _SyncStats({
    required this.created,
    required this.updated,
    required this.unchanged,
    required this.removed,
  });

  final int created;
  final int updated;
  final int unchanged;
  final int removed;

  String message(int total) {
    if (created == total && updated == 0 && unchanged == 0 && removed == 0) {
      return 'Se guardaron $total materias desde SAGE.';
    }
    final parts = <String>[
      if (created > 0) '$created nueva${created == 1 ? '' : 's'}',
      if (updated > 0) '$updated actualizada${updated == 1 ? '' : 's'}',
      if (unchanged > 0) '$unchanged sin cambios',
      if (removed > 0) '$removed retirada${removed == 1 ? '' : 's'}',
    ];
    return 'Sincronización completa: ${parts.join(', ')}.';
  }
}

_SyncStats _calculateSyncStats(
  TrayectoriaSageLaboratorio? previous,
  TrayectoriaSageLaboratorio next,
) {
  final oldSubjects = previous == null
      ? const <String, MateriaTrayectoriaSageLaboratorio>{}
      : _indexSubjects(previous);
  final newSubjects = _indexSubjects(next);
  var created = 0;
  var updated = 0;
  var unchanged = 0;
  for (final entry in newSubjects.entries) {
    final old = oldSubjects[entry.key];
    if (old == null) {
      created++;
      continue;
    }
    final current = entry.value;
    if (old.estadoOriginal != current.estadoOriginal ||
        old.estado != current.estado ||
        old.anio != current.anio ||
        old.nombre != current.nombre) {
      updated++;
    } else {
      unchanged++;
    }
  }
  final removed = oldSubjects.keys
      .where((key) => !newSubjects.containsKey(key))
      .length;
  return _SyncStats(
    created: created,
    updated: updated,
    unchanged: unchanged,
    removed: removed,
  );
}

Map<String, MateriaTrayectoriaSageLaboratorio> _indexSubjects(
  TrayectoriaSageLaboratorio trajectory,
) {
  final result = <String, MateriaTrayectoriaSageLaboratorio>{};
  for (final career in trajectory.carreras) {
    final careerKey = _careerIdentityKey(career);
    for (final subject in career.materias) {
      final subjectKey = subject.idSage.trim().isNotEmpty
          ? subject.idSage.trim()
          : '${subject.anio ?? ''}|${subject.nombre.trim().toLowerCase()}';
      result['$careerKey|$subjectKey'] = subject;
    }
  }
  return result;
}

String _careerIdentityKey(CarreraTrayectoriaSageLaboratorio career) {
  final candidates = <String?>[
    career.careerKey,
    career.careerContextId,
    career.internalId,
  ];
  for (final candidate in candidates) {
    final value = candidate?.trim() ?? '';
    if (value.isNotEmpty) return value;
  }
  return '${career.nombre.trim().toLowerCase()}|'
      '${career.institucion.trim().toLowerCase()}';
}

bool _sameSageProfile(
  PerfilTrayectoriaSageLaboratorio first,
  PerfilTrayectoriaSageLaboratorio second,
) {
  final firstDni = first.dni?.replaceAll(RegExp(r'\D'), '') ?? '';
  final secondDni = second.dni?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (firstDni.isNotEmpty && secondDni.isNotEmpty) {
    return firstDni == secondDni;
  }
  String normalize(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  return normalize(first.nombre) == normalize(second.nombre);
}

Color _stateColor(EstadoMateriaSageLaboratorio state) => switch (state) {
  EstadoMateriaSageLaboratorio.aprobada => const Color(0xFF2EAD57),
  EstadoMateriaSageLaboratorio.regular => const Color(0xFFD97706),
  EstadoMateriaSageLaboratorio.cursando => const Color(0xFF1E6FDB),
  EstadoMateriaSageLaboratorio.noRegularizada => const Color(0xFFDC2626),
  EstadoMateriaSageLaboratorio.desconocida => const Color(0xFF64748B),
};

IconData _stateIcon(EstadoMateriaSageLaboratorio state) => switch (state) {
  EstadoMateriaSageLaboratorio.aprobada => Icons.check_circle_rounded,
  EstadoMateriaSageLaboratorio.regular => Icons.assignment_turned_in_rounded,
  EstadoMateriaSageLaboratorio.cursando => Icons.play_circle_rounded,
  EstadoMateriaSageLaboratorio.noRegularizada => Icons.cancel_rounded,
  EstadoMateriaSageLaboratorio.desconocida => Icons.help_outline_rounded,
};

String _formatDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} · '
      '${two(value.hour)}:${two(value.minute)}';
}
