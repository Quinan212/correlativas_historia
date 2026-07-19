import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            style: FilledButton.styleFrom(
              backgroundColor: PaletaAtlassian.danger,
            ),
            child: const Text('Desincronizar'),
          ),
        ],
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
    final desktop = MediaQuery.sizeOf(context).width >= 980;

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
      if (!_builtSections.contains(index)) return const SizedBox.shrink();
      return Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => sectionChildren[index]),
      );
    });

    final content = IndexedStack(index: _section, children: tabs);
    final body = desktop
        ? ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
            valueListenable: _trajectory,
            builder: (context, trajectory, _) {
              return Row(
                children: [
                  NavegacionLateralAtlassian(
                    selectedIndex: _section,
                    onSelected: _selectSection,
                    onExit: widget.hideExit
            ? null
            : () {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context).pop();
                }
              },
                    nombreEstudiante: trajectory?.perfil.nombre,
                  ),
                  Expanded(child: content),
                ],
              );
            },
          )
        : content;

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
            if (shouldExit && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: body,
            bottomNavigationBar: desktop
                ? null
                : BarraNavegacionAtlassian(
                    selectedIndex: _section,
                    onSelected: _selectSection,
                  ),
          ),
        ),
      ),
    );
  }
}
