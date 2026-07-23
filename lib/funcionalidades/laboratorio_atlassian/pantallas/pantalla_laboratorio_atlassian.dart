import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../administrador/pantallas/acceso_administrador_pantalla.dart';
import '../../trayectoria_sage_laboratorio/datos/repositorio_estado_sincronizacion_sage.dart';
import '../../trayectoria_sage_laboratorio/datos/repositorio_trayectoria_sage_laboratorio.dart';
import '../../trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import '../busqueda/modelos_busqueda_atlassian.dart';
import '../busqueda/pantalla_busqueda_global_atlassian.dart';
import '../componentes/componentes_atlassian.dart';
import '../tema/tema_atlassian.dart';
import 'pantalla_calendario_atlassian.dart';
import 'pantalla_datos_atlassian.dart';
import 'pantalla_disenos_atlassian.dart';
import 'pantalla_examenes_atlassian.dart';
import 'pantalla_inicio_atlassian.dart';
import 'pantalla_materias_atlassian.dart';
import 'pantalla_plan_atlassian.dart';
import 'pantallas_herramientas_atlassian.dart';
import 'utilidades_atlassian.dart';

class PantallaLaboratorioAtlassian extends StatefulWidget {
  const PantallaLaboratorioAtlassian({super.key, this.hideExit = false});

  final bool hideExit;

  @override
  State<PantallaLaboratorioAtlassian> createState() =>
      _PantallaLaboratorioAtlassianState();
}

class _PantallaLaboratorioAtlassianState
    extends State<PantallaLaboratorioAtlassian> {
  static const _repository = RepositorioTrayectoriaSageLaboratorio();
  static const _syncStateRepository = RepositorioEstadoSincronizacionSage();

  final List<GlobalKey<NavigatorState>> _navigatorKeys =
      List<GlobalKey<NavigatorState>>.generate(
        5,
        (_) => GlobalKey<NavigatorState>(),
      );
  final ValueNotifier<TrayectoriaSageLaboratorio?> _trajectory =
      ValueNotifier<TrayectoriaSageLaboratorio?>(null);
  final ValueNotifier<bool> _localLoaded = ValueNotifier<bool>(false);
  final ValueNotifier<int> _selectedCareer = ValueNotifier<int>(0);
  final ValueNotifier<int> _resetRevision = ValueNotifier<int>(0);
  final ValueNotifier<SolicitudExamenesAtlassian?> _examRequest =
      ValueNotifier<SolicitudExamenesAtlassian?>(null);
  final ValueNotifier<SolicitudPlanAtlassian?> _planRequest =
      ValueNotifier<SolicitudPlanAtlassian?>(null);
  final ValueNotifier<SolicitudMateriasAtlassian?> _subjectRequest =
      ValueNotifier<SolicitudMateriasAtlassian?>(null);
  final ValueNotifier<SolicitudInicioAtlassian?> _homeRequest =
      ValueNotifier<SolicitudInicioAtlassian?>(null);
  final Set<int> _builtSections = <int>{0};

  int _section = 0;
  bool _sidebarHidden = false;
  double _topBlurProgress = 0.0;

  void _handleSectionRouteChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocal());
  }

  Future<void> _loadLocal() async {
    final loaded = await _repository.cargar();
    if (!mounted) return;
    _trajectory.value = loaded;
    _selectedCareer.value = _safeCareerIndex(loaded, _selectedCareer.value);
    _localLoaded.value = true;
  }

  int _safeCareerIndex(TrayectoriaSageLaboratorio? trajectory, int requested) {
    final count = trajectory?.carreras.length ?? 0;
    if (count == 0) return 0;
    return requested.clamp(0, count - 1).toInt();
  }

  void _replaceTrajectory(TrayectoriaSageLaboratorio? trajectory) {
    _trajectory.value = trajectory;
    _selectedCareer.value = _safeCareerIndex(trajectory, _selectedCareer.value);
  }

  Future<void> _desynchronize() async {
    final atlassianTheme = temaLaboratorioAtlassian(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Theme(
        data: atlassianTheme,
        child: AlertDialog(
          backgroundColor: atlassianTheme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadioAtlassian.large),
            side: BorderSide(color: atlassianTheme.colorScheme.outlineVariant),
          ),
          title: Text(
            'Desincronizar trayectoria',
            style: atlassianTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Se borrarán los datos locales.',
            style: atlassianTheme.textTheme.bodyMedium?.copyWith(
              color: atlassianTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: PaletaAtlassian.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Desincronizar'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    await Future.wait<void>([
      _repository.borrar(),
      _syncStateRepository.borrarPreferencias(),
    ]);
    if (!mounted) return;
    _replaceTrajectory(null);
    _resetRevision.value++;
    setState(() => _section = 0);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trayectoria desincronizada')));
  }

  void _activateSection(int section) {
    if (_section == section && _builtSections.contains(section)) return;
    setState(() {
      _builtSections.add(section);
      _section = section;
      _topBlurProgress = 0.0;
    });
  }

  void _selectSection(int section) {
    if (_section == section) {
      _navigatorKeys[section].currentState?.popUntil((route) => route.isFirst);
      return;
    }
    _activateSection(section);
  }

  Future<void> _openGlobalSearch() async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      rutaAtlassian<void>(
        builder: (_) => PantallaBusquedaGlobalAtlassian(
          trajectoryListenable: _trajectory,
          selectedCareerListenable: _selectedCareer,
          onOpenDestination: _handleSearchDestination,
        ),
      ),
    );
  }

  void _pushInSection(int section, Widget page) {
    _activateSection(section);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigatorKeys[section].currentState?.push<void>(
        rutaAtlassian<void>(builder: (_) => page),
      );
    });
  }

  int? _trajectoryCareerIndex(String? careerId) {
    if (careerId == null || _trajectory.value == null) return null;
    final careers = _trajectory.value!.carreras;
    for (var index = 0; index < careers.length; index++) {
      if (idCarreraExamenAtlassian(careers[index].nombre) == careerId) {
        return index;
      }
    }
    return null;
  }

  Future<void> _handleSearchDestination(
    DestinoBusquedaAtlassian destination,
  ) async {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    if (rootNavigator.canPop()) rootNavigator.pop();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;

    switch (destination.tipo) {
      case TipoDestinoBusquedaAtlassian.seccion:
        final section = destination.seccion ?? 0;
        _activateSection(section);
        if (section == 1) {
          _examRequest.value = SolicitudExamenesAtlassian(
            careerId: destination.careerId,
            query: destination.query,
            year: destination.year,
            scope: destination.scope,
          );
        } else if (section == 2) {
          _planRequest.value = SolicitudPlanAtlassian(
            careerId: destination.careerId,
            query: destination.query,
            year: destination.year,
          );
        } else if (section == 3) {
          final careerIndex = _trajectoryCareerIndex(destination.careerId);
          if (careerIndex != null) _selectedCareer.value = careerIndex;
          _subjectRequest.value = SolicitudMateriasAtlassian(
            careerIndex: careerIndex,
            query: destination.query,
            year: destination.year,
            status: destination.status,
            focusSearch: (destination.query ?? '').trim().isNotEmpty,
          );
        }
        return;
      case TipoDestinoBusquedaAtlassian.calendario:
        _pushInSection(
          0,
          PantallaCalendarioAtlassian(
            careerId: destination.careerId ?? 'historia',
            initialDate: destination.fecha,
            trayectoria: _trajectory.value,
          ),
        );
        return;
      case TipoDestinoBusquedaAtlassian.disenos:
        _pushInSection(
          0,
          PantallaDisenosAtlassian(
            initialCareerId: destination.careerId,
            initialQuery: destination.query,
          ),
        );
        return;
      case TipoDestinoBusquedaAtlassian.escenarios:
        _pushInSection(
          0,
          PantallaEscenariosInicializadosAtlassian(
            careerId: destination.careerId,
            year: destination.year,
            subjectId: destination.materiaPlan?.id,
          ),
        );
        return;
      case TipoDestinoBusquedaAtlassian.ayuda:
        _pushInSection(0, const PantallaAyudaAtlassian());
        return;
      case TipoDestinoBusquedaAtlassian.proximosPasos:
        final career = _currentTrajectoryCareer();
        _pushInSection(0, PantallaProximosPasosAtlassian(career: career));
        return;
      case TipoDestinoBusquedaAtlassian.avance:
        final career = _currentTrajectoryCareer();
        _pushInSection(0, PantallaAvanceAtlassian(career: career));
        return;
      case TipoDestinoBusquedaAtlassian.sage:
        _activateSection(0);
        _homeRequest.value = SolicitudInicioAtlassian(
          AccionInicioAtlassian.abrirSage,
        );
        return;
      case TipoDestinoBusquedaAtlassian.sincronizar:
        _activateSection(0);
        _homeRequest.value = SolicitudInicioAtlassian(
          AccionInicioAtlassian.sincronizar,
        );
        return;
      case TipoDestinoBusquedaAtlassian.desincronizar:
        await _desynchronize();
        return;
      case TipoDestinoBusquedaAtlassian.cerrarSesionSage:
        _activateSection(0);
        _homeRequest.value = SolicitudInicioAtlassian(
          AccionInicioAtlassian.cerrarSesionSage,
        );
        return;
      case TipoDestinoBusquedaAtlassian.salir:
        if (mounted) Navigator.of(context).pop();
        return;
      case TipoDestinoBusquedaAtlassian.detalleExamen:
        final event = destination.evento;
        if (event != null) {
          _pushInSection(1, PantallaDetalleExamenAtlassian(event: event));
        }
        return;
      case TipoDestinoBusquedaAtlassian.detallePlan:
        final subject = destination.materiaPlan;
        final allSubjects = destination.materiasPlan;
        if (subject != null && allSubjects != null) {
          _pushInSection(
            2,
            PantallaDetallePlanAtlassian(
              subject: subject,
              allSubjects: allSubjects,
              careerName: destination.career?.nombre ?? 'Plan completo',
            ),
          );
        }
        return;
      case TipoDestinoBusquedaAtlassian.detalleDiseno:
        final subject = destination.materiaPlan;
        final content = destination.contenidoCurricular;
        if (subject != null) {
          _pushInSection(
            0,
            PantallaDetalleDisenoAtlassian(
              subject: subject,
              content: content,
              careerName: destination.career?.nombre ?? 'Diseño curricular',
            ),
          );
        }
        return;
      case TipoDestinoBusquedaAtlassian.detalleTrayectoria:
        final subject = destination.materiaTrayectoria;
        final career = destination.carreraTrayectoria;
        if (subject != null && career != null) {
          final careers =
              _trajectory.value?.carreras ??
              const <CarreraTrayectoriaSageLaboratorio>[];
          final index = careers.indexWhere(
            (item) => item.gridRowId == career.gridRowId,
          );
          if (index >= 0) _selectedCareer.value = index;
          _pushInSection(
            3,
            PantallaDetalleMateriaAtlassian(subject: subject, career: career),
          );
        }
        return;
    }
  }

  CarreraTrayectoriaSageLaboratorio? _currentTrajectoryCareer() {
    final trajectory = _trajectory.value;
    if (trajectory == null || trajectory.carreras.isEmpty) return null;
    final index = _selectedCareer.value
        .clamp(0, trajectory.carreras.length - 1)
        .toInt();
    return trajectory.carreras[index];
  }

  Future<bool> _handleBack() async {
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
    _selectedCareer.dispose();
    _resetRevision.dispose();
    _examRequest.dispose();
    _planRequest.dispose();
    _subjectRequest.dispose();
    _homeRequest.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = temaLaboratorioAtlassian(context);
    final dark = theme.brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final desktop = size.width >= 720 || size.width > size.height;

    final sectionChildren = <Widget>[
      PantallaInicioAtlassian(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
        selectedCareerListenable: _selectedCareer,
        resetListenable: _resetRevision,
        actionRequestListenable: _homeRequest,
        onTrajectoryChanged: _replaceTrajectory,
        onNavigate: _selectSection,
        onSearch: _openGlobalSearch,
        onExit: widget.hideExit
            ? null
            : () {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context).pop();
                }
              },
      ),
      PantallaExamenesAtlassian(
        onSearch: _openGlobalSearch,
        requestListenable: _examRequest,
      ),
      PantallaPlanAtlassian(
        onSearch: _openGlobalSearch,
        requestListenable: _planRequest,
      ),
      PantallaMateriasAtlassian(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
        selectedCareerListenable: _selectedCareer,
        requestListenable: _subjectRequest,
      ),
      PantallaDatosAtlassian(
        trajectoryListenable: _trajectory,
        localLoadedListenable: _localLoaded,
        selectedCareerListenable: _selectedCareer,
        onDesynchronize: _desynchronize,
        onNavigate: _selectSection,
        onSearch: _openGlobalSearch,
      ),
    ];

    final tabs = List<Widget>.generate(5, (index) {
      if (!_builtSections.contains(index)) {
        return KeyedSubtree(
          key: ValueKey<int>(index),
          child: const SizedBox.shrink(),
        );
      }
      return KeyedSubtree(
        key: ValueKey<int>(index),
        child: Navigator(
          key: _navigatorKeys[index],
          observers: <NavigatorObserver>[
            _SectionNavigatorObserver(_handleSectionRouteChanged),
          ],
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (_) => sectionChildren[index],
          ),
        ),
      );
    });

    final rawContent = IndexedStack(index: _section, children: tabs);
    final content = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == Axis.vertical) {
          final pixels = notification.metrics.pixels;
          final progress = (pixels / 48.0).clamp(0.0, 1.0);
          if ((progress - _topBlurProgress).abs() > 0.02) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && (progress - _topBlurProgress).abs() > 0.02) {
                setState(() {
                  _topBlurProgress = progress;
                });
              }
            });
          }
        }
        return false;
      },
      child: rawContent,
    );
    final isSubRoute =
        _navigatorKeys[_section].currentState?.canPop() ?? false;
    final allowBlursAndSearch = !desktop && !isSubRoute;
    final showFloatingSearch = allowBlursAndSearch;
    final body = desktop
        ? ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
            valueListenable: _trajectory,
            builder: (context, trajectory, _) {
              return Stack(
                children: [
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.only(
                      left: _sidebarHidden ? 0.0 : 180.0,
                    ),
                    child: content,
                  ),
                  NavegacionLateralAtlassian(
                    selectedIndex: _section,
                    onSelected: _selectSection,
                    onExit: widget.hideExit
                        ? null
                        : () {
                            if (Navigator.of(context, rootNavigator: true)
                                .canPop()) {
                              Navigator.of(context).pop();
                            }
                          },
                    nombreEstudiante: trajectory?.perfil.nombre,
                    hidden: _sidebarHidden,
                  ),
                  // Toggle button at the top-left corner of the screen
                  Positioned(
                    left: 16,
                    top: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => _sidebarHidden = !_sidebarHidden),
                        borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: theme.colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                            boxShadow: [
                              if (_sidebarHidden)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Icon(
                            _sidebarHidden ? Icons.menu_rounded : Icons.menu_open_rounded,
                            size: 26,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )
        : Stack(
            children: [
              content,
              // Efecto fade y difuminado progresivo superior: solo aparece progresivamente al hacer scroll
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: (!allowBlursAndSearch || _topBlurProgress <= 0.01)
                    ? const SizedBox.shrink()
                    : IgnorePointer(
                        child: Opacity(
                          opacity: _topBlurProgress,
                          child: ClipRect(
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black,
                                    Colors.black,
                                    Colors.black87,
                                    Colors.black45,
                                    Colors.transparent,
                                  ],
                                  stops: [0.0, 0.35, 0.60, 0.82, 1.0],
                                ).createShader(rect);
                              },
                              blendMode: BlendMode.dstIn,
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                child: Container(
                                  height: MediaQuery.paddingOf(context).top + 60,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        theme.scaffoldBackgroundColor.withValues(alpha: 0.98),
                                        theme.scaffoldBackgroundColor.withValues(alpha: 0.80),
                                        theme.scaffoldBackgroundColor.withValues(alpha: 0.40),
                                        theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                                      ],
                                      stops: const [0.0, 0.35, 0.70, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              // Efecto fade y difuminado progresivo inferior (BackdropFilter + ShaderMask)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: !showFloatingSearch
                    ? const SizedBox.shrink()
                    : IgnorePointer(
                        child: ClipRect(
                          child: ShaderMask(
                            shaderCallback: (rect) {
                              return const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black,
                                  Colors.black,
                                  Colors.black87,
                                  Colors.black45,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.35, 0.60, 0.82, 1.0],
                              ).createShader(rect);
                            },
                            blendMode: BlendMode.dstIn,
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      theme.scaffoldBackgroundColor.withValues(alpha: 0.98),
                                      theme.scaffoldBackgroundColor.withValues(alpha: 0.80),
                                      theme.scaffoldBackgroundColor.withValues(alpha: 0.40),
                                      theme.scaffoldBackgroundColor.withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.35, 0.70, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
              // Buscador flotante global: siempre presente en el Stack para mantener índices fijos
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: !showFloatingSearch
                    ? const SizedBox.shrink()
                    : SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: AccesoBusquedaAtlassian(
                              onTap: _openGlobalSearch,
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                left: 16,
                top: 16,
                child: SafeArea(
                  child: Builder(
                    builder: (btnContext) {
                      final canGoBack = _section != 0 ||
                          (_navigatorKeys[_section].currentState?.canPop() ?? false);
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (canGoBack) {
                              unawaited(_handleBack());
                            } else {
                              Scaffold.of(btnContext).openDrawer();
                            }
                          },
                          borderRadius: BorderRadius.circular(RadioAtlassian.pill),
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              canGoBack
                                  ? Icons.arrow_back_rounded
                                  : Icons.short_text_rounded,
                              size: 26,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );

    final overlayStyle = dark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: theme.scaffoldBackgroundColor,
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarDividerColor: theme.colorScheme.outlineVariant,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: theme.scaffoldBackgroundColor,
            systemNavigationBarColor: theme.colorScheme.surface,
            systemNavigationBarDividerColor: theme.colorScheme.outlineVariant,
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
            if (shouldExit && !widget.hideExit && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
            valueListenable: _trajectory,
            builder: (context, trajectory, _) {
              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                resizeToAvoidBottomInset: false,
                body: body,
                drawer: desktop
                    ? null
                    : DrawerMovilAtlassian(
                        selectedIndex: _section,
                        onSelected: _selectSection,
                        onSearch: _openGlobalSearch,
                        nombreEstudiante: trajectory?.perfil.nombre,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SectionNavigatorObserver extends NavigatorObserver {
  _SectionNavigatorObserver(this.onRouteChanged);

  final VoidCallback onRouteChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onRouteChanged();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onRouteChanged();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onRouteChanged();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    onRouteChanged();
  }
}

class DrawerMovilAtlassian extends StatelessWidget {
  const DrawerMovilAtlassian({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onSearch,
    this.nombreEstudiante,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onSearch;
  final String? nombreEstudiante;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final iniciales = _obtenerInicialesAtlassian(nombreEstudiante);

    final destinos = <(IconData, String, int)>[
      (Icons.grid_view_rounded, 'Materias', 3),
      (Icons.event_note_rounded, 'Exámenes', 1),
      (Icons.account_tree_rounded, 'Plan', 2),
      (Icons.person_outline_rounded, 'Datos', 4),
    ];

    final topPadding = MediaQuery.paddingOf(context).top;
    final width = (MediaQuery.sizeOf(context).width * 0.70).clamp(250.0, 280.0);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Drawer(
        backgroundColor: scheme.surface,
        width: width,
        shape: const RoundedRectangleBorder(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              right: BorderSide(
                color: scheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(0);
                      },
                      child: Text(
                        'Correlativas',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onSearch();
                      },
                      borderRadius: BorderRadius.circular(RadioAtlassian.pill),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search_rounded,
                          color: scheme.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                for (final item in destinos) ...[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(item.$3);
                    },
                    borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.$1,
                            color: selectedIndex == item.$3
                                ? scheme.primary
                                : scheme.onSurface,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.$2,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: selectedIndex == item.$3
                                  ? scheme.primary
                                  : scheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AccesoAdministradorPantalla(),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(RadioAtlassian.pill),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.admin_panel_settings_rounded,
                          color: scheme.onSurface,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        onSelected(4);
                      },
                      borderRadius: BorderRadius.circular(RadioAtlassian.pill),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          iniciales,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  static String _obtenerInicialesAtlassian(String? nombre) {
    if (nombre == null || nombre.trim().isEmpty) return 'US';
    final parts = nombre.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts[0].length >= 2) {
      return parts[0].substring(0, 2).toUpperCase();
    }
    return parts[0].toUpperCase();
  }
}
