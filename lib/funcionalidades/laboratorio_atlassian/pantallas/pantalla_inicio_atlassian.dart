import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/datos/repositorio_trayectoria_sage_laboratorio.dart';
import '../../trayectoria_sage_laboratorio/modelos/modelos_trayectoria_sage_laboratorio.dart';
import '../../trayectoria_sage_laboratorio/sage/modelos_sincronizacion_sage_automatica.dart';
import '../../trayectoria_sage_laboratorio/sage/pantalla_sage_laboratorio.dart';
import '../busqueda/modelos_busqueda_atlassian.dart';
import '../componentes/componentes_atlassian.dart';
import '../componentes/inicio_trayectoria_atlassian.dart';
import '../tema/tema_atlassian.dart';
import 'pantalla_calendario_atlassian.dart';
import 'pantalla_centro_sage_atlassian.dart';
import 'pantalla_disenos_atlassian.dart';
import 'pantalla_materias_atlassian.dart';
import 'pantallas_herramientas_atlassian.dart';
import 'utilidades_atlassian.dart';

class PantallaInicioAtlassian extends StatefulWidget {
  const PantallaInicioAtlassian({
    super.key,
    required this.trajectoryListenable,
    required this.localLoadedListenable,
    required this.selectedCareerListenable,
    required this.resetListenable,
    required this.actionRequestListenable,
    required this.onTrajectoryChanged,
    required this.onNavigate,
    required this.onSearch,
    required this.onExit,
  });

  final ValueNotifier<TrayectoriaSageLaboratorio?> trajectoryListenable;
  final ValueNotifier<bool> localLoadedListenable;
  final ValueNotifier<int> selectedCareerListenable;
  final ValueNotifier<int> resetListenable;
  final ValueListenable<SolicitudInicioAtlassian?> actionRequestListenable;
  final ValueChanged<TrayectoriaSageLaboratorio?> onTrajectoryChanged;
  final ValueChanged<int> onNavigate;
  final VoidCallback onSearch;
  final VoidCallback onExit;

  @override
  State<PantallaInicioAtlassian> createState() =>
      _PantallaInicioAtlassianState();
}

class _PantallaInicioAtlassianState extends State<PantallaInicioAtlassian> {
  static const _repository = RepositorioTrayectoriaSageLaboratorio();

  TrayectoriaSageLaboratorio? _draft;
  EstadoPreparacionSageLaboratorio _preparation =
      const EstadoPreparacionSageLaboratorio(mensaje: 'Pendiente');
  bool _saving = false;
  bool _sageFlowOpen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.resetListenable.addListener(_resetLocalState);
    widget.actionRequestListenable.addListener(_handleActionRequest);
  }

  @override
  void didUpdateWidget(covariant PantallaInicioAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetListenable != widget.resetListenable) {
      oldWidget.resetListenable.removeListener(_resetLocalState);
      widget.resetListenable.addListener(_resetLocalState);
    }
    if (oldWidget.actionRequestListenable != widget.actionRequestListenable) {
      oldWidget.actionRequestListenable.removeListener(_handleActionRequest);
      widget.actionRequestListenable.addListener(_handleActionRequest);
    }
  }

  @override
  void dispose() {
    widget.resetListenable.removeListener(_resetLocalState);
    widget.actionRequestListenable.removeListener(_handleActionRequest);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleActionRequest() {
    final request = widget.actionRequestListenable.value;
    if (request == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (request.accion) {
        case AccionInicioAtlassian.abrirSage:
          unawaited(_openSagePortal());
          return;
        case AccionInicioAtlassian.sincronizar:
          unawaited(_sync());
          return;
        case AccionInicioAtlassian.cerrarSesionSage:
          unawaited(_openSage(logoutOnOpen: true));
          return;
      }
    });
  }

  void _resetLocalState() {
    if (!mounted) return;
    setState(() {
      _draft = null;
      _preparation = const EstadoPreparacionSageLaboratorio(
        mensaje: 'Pendiente',
      );
      _saving = false;
      _sageFlowOpen = false;
    });
  }

  CarreraTrayectoriaSageLaboratorio? _currentCareer(
    TrayectoriaSageLaboratorio? trajectory,
    int selectedIndex,
  ) {
    if (trajectory == null || trajectory.carreras.isEmpty) return null;
    final index = selectedIndex
        .clamp(0, trajectory.carreras.length - 1)
        .toInt();
    return trajectory.carreras[index];
  }

  void _pushAtlassian(WidgetBuilder builder) {
    Navigator.of(context).push<void>(rutaAtlassian<void>(builder: builder));
  }

  CarreraTrayectoriaSageLaboratorio? _selectedCareerNow() {
    return _currentCareer(
      widget.trajectoryListenable.value,
      widget.selectedCareerListenable.value,
    );
  }

  void _openScenarios() {
    _pushAtlassian((_) => const PantallaEscenariosAtlassian());
  }

  void _openHelp() {
    _pushAtlassian((_) => const PantallaAyudaAtlassian());
  }

  void _openNextSteps() {
    final career = _selectedCareerNow();
    _pushAtlassian((_) => PantallaProximosPasosAtlassian(career: career));
  }

  void _openProgress() {
    final career = _selectedCareerNow();
    _pushAtlassian((_) => PantallaAvanceAtlassian(career: career));
  }

  void _openCalendar() {
    final career = _selectedCareerNow();
    _pushAtlassian(
      (_) => PantallaCalendarioAtlassian(
        careerId: idCarreraExamenAtlassian(career?.nombre ?? 'historia'),
      ),
    );
  }

  void _openDesigns() {
    _pushAtlassian((_) => const PantallaDisenosAtlassian());
  }

  Future<TrayectoriaSageLaboratorio> _saveAutomaticTrajectory(
    TrayectoriaSageLaboratorio draft,
  ) async {
    if (!draft.listaParaSincronizar) {
      throw const ErrorSincronizacionSageAutomatica(
        'SAGE no entregó una trayectoria válida para guardar.',
      );
    }

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
      if (replace != true) {
        throw const ErrorSincronizacionSageAutomatica(
          'La sincronización fue cancelada.',
        );
      }
    }

    if (mounted) setState(() => _saving = true);
    final previousCareer = _currentCareer(
      current,
      widget.selectedCareerListenable.value,
    );
    try {
      final stored = await _repository.guardarIdempotente(draft);
      if (!mounted) return stored;
      widget.onTrajectoryChanged(stored);
      widget.selectedCareerListenable.value = _matchingCareerIndex(
        stored,
        previousCareer,
      );
      setState(() {
        _draft = null;
        _preparation = EstadoPreparacionSageLaboratorio(
          mensaje: '${stored.totalMaterias} materias sincronizadas',
          progreso: 1,
        );
      });
      return stored;
    } catch (error) {
      if (error is ErrorSincronizacionSageAutomatica) rethrow;
      throw const ErrorSincronizacionSageAutomatica(
        'No se pudo guardar la trayectoria en el dispositivo.',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openSage({bool logoutOnOpen = false}) async {
    if (_saving || _sageFlowOpen) return;
    setState(() {
      _sageFlowOpen = true;
      _draft = null;
      _preparation = EstadoPreparacionSageLaboratorio(
        mensaje: logoutOnOpen
            ? 'Cerrando sesión de SAGE'
            : 'Preparando sincronización',
      );
    });
    try {
      await _runSageScreen(
        automatic: !logoutOnOpen,
        logoutOnOpen: logoutOnOpen,
      );
    } finally {
      if (mounted) setState(() => _sageFlowOpen = false);
    }
  }

  Future<void> _openSagePortal() async {
    if (_saving || _sageFlowOpen) return;
    setState(() {
      _sageFlowOpen = true;
      _draft = null;
      _preparation = const EstadoPreparacionSageLaboratorio(
        mensaje: 'Conectando con SAGE',
      );
    });
    final atlassianTheme = temaLaboratorioAtlassian(context);
    try {
      final authenticated = await Navigator.of(context, rootNavigator: true)
          .push<bool>(
            rutaAtlassian<bool>(
              builder: (sageContext) => PantallaSageLaboratorio(
                onClose: () => Navigator.of(sageContext).pop(false),
                onSesionAutenticada: () {
                  if (Navigator.of(sageContext).canPop()) {
                    Navigator.of(sageContext).pop(true);
                  }
                },
                themeOverride: atlassianTheme,
                appBarBackground: atlassianTheme.colorScheme.surface,
                appBarForeground: atlassianTheme.colorScheme.onSurface,
                title: 'Conectar con SAGE',
                modo: ModoPantallaSageLaboratorio.autenticacion,
                perfilEsperado: widget.trajectoryListenable.value?.perfil,
                onEstadoPreparacion: (status) {
                  if (!mounted) return;
                  setState(() => _preparation = status);
                },
              ),
            ),
          );
      if (!mounted || authenticated != true) return;

      final action = await Navigator.of(context, rootNavigator: true)
          .push<AccionCentroSageAtlassian>(
            rutaAtlassian<AccionCentroSageAtlassian>(
              builder: (_) => PantallaCentroSageAtlassian(
                ultimaSincronizacion:
                    widget.trajectoryListenable.value?.sincronizadaEn,
              ),
            ),
          );
      if (!mounted || action == null) return;

      switch (action) {
        case AccionCentroSageAtlassian.sincronizar:
          await _runSageScreen(automatic: true);
          return;
        case AccionCentroSageAtlassian.abrirSage:
          await _runSageScreen(automatic: false);
          return;
      }
    } finally {
      if (mounted) setState(() => _sageFlowOpen = false);
    }
  }

  Future<void> _runSageScreen({
    required bool automatic,
    bool logoutOnOpen = false,
  }) async {
    final atlassianTheme = temaLaboratorioAtlassian(context);
    await Navigator.of(context, rootNavigator: true).push<void>(
      rutaAtlassian<void>(
        builder: (sageContext) => PantallaSageLaboratorio(
          onClose: () => Navigator.of(sageContext).pop(),
          themeOverride: atlassianTheme,
          appBarBackground: atlassianTheme.colorScheme.surface,
          appBarForeground: atlassianTheme.colorScheme.onSurface,
          title: logoutOnOpen
              ? 'Cerrar sesión de SAGE'
              : automatic
              ? 'Sincronizar con SAGE'
              : 'SAGE',
          logoutOnOpen: logoutOnOpen,
          modo: automatic
              ? ModoPantallaSageLaboratorio.sincronizacionAutomatica
              : ModoPantallaSageLaboratorio.manual,
          onGuardarTrayectoriaAutomatica: automatic
              ? _saveAutomaticTrajectory
              : null,
          perfilEsperado: widget.trajectoryListenable.value?.perfil,
          onSesionCerrada: () {
            if (!mounted) return;
            setState(() {
              _preparation = const EstadoPreparacionSageLaboratorio(
                mensaje: 'Sesión de SAGE cerrada',
              );
            });
          },
          onTrayectoriaLista: automatic
              ? null
              : (trajectory) {
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

  Future<void> _openAcademicDocument(DocumentoAcademicoSage document) async {
    if (_saving || _sageFlowOpen) return;
    setState(() {
      _sageFlowOpen = true;
      _preparation = EstadoPreparacionSageLaboratorio(
        mensaje: 'Preparando ${document.tipo.etiqueta}',
      );
    });
    final atlassianTheme = temaLaboratorioAtlassian(context);
    try {
      await Navigator.of(context, rootNavigator: true).push<void>(
        rutaAtlassian<void>(
          builder: (sageContext) => PantallaSageLaboratorio(
            onClose: () => Navigator.of(sageContext).pop(),
            themeOverride: atlassianTheme,
            appBarBackground: atlassianTheme.colorScheme.surface,
            appBarForeground: atlassianTheme.colorScheme.onSurface,
            title: document.tipo.etiqueta,
            modo: ModoPantallaSageLaboratorio.descargaDocumento,
            documentoSolicitado: document,
            perfilEsperado: widget.trajectoryListenable.value?.perfil,
            onDocumentoDescargado: (_) {
              if (!mounted) return;
              setState(() {
                _preparation = EstadoPreparacionSageLaboratorio(
                  mensaje: '${document.tipo.etiqueta} descargado',
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
    } finally {
      if (mounted) setState(() => _sageFlowOpen = false);
    }
  }

  Future<void> _sync() async {
    if (_saving || _sageFlowOpen) return;
    final draft = _draft;
    if (draft == null || !draft.listaParaSincronizar) {
      await _openSage();
      return;
    }
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
      final previousCareer = _currentCareer(
        current,
        widget.selectedCareerListenable.value,
      );
      final stored = await _repository.guardarIdempotente(draft);
      if (!mounted) return;
      widget.onTrajectoryChanged(stored);
      widget.selectedCareerListenable.value = _matchingCareerIndex(
        stored,
        previousCareer,
      );
      setState(() {
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

  int _matchingCareerIndex(
    TrayectoriaSageLaboratorio trajectory,
    CarreraTrayectoriaSageLaboratorio? previous,
  ) {
    if (trajectory.carreras.isEmpty || previous == null) return 0;
    final previousKey = _careerIdentity(previous);
    final index = trajectory.carreras.indexWhere(
      (career) => _careerIdentity(career) == previousKey,
    );
    return index < 0 ? 0 : index;
  }

  String _careerIdentity(CarreraTrayectoriaSageLaboratorio career) {
    final structural = career.careerKey.trim();
    if (structural.isNotEmpty) return structural.toLowerCase();
    return <String>[
      career.nombre.trim().toLowerCase(),
      career.institucion.trim().toLowerCase(),
      career.anioInicio?.toString() ?? '',
    ].join('|');
  }

  Future<void> _chooseCareer(TrayectoriaSageLaboratorio trajectory) async {
    if (trajectory.carreras.length < 2) return;
    final selected = await mostrarHojaAtlassian<int>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Seleccionar carrera',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (var index = 0; index < trajectory.carreras.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: PanelAtlassian(
                    selected: index == widget.selectedCareerListenable.value,
                    onTap: () => Navigator.of(sheetContext).pop(index),
                    child: Row(
                      children: [
                        Icon(
                          index == widget.selectedCareerListenable.value
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: index == widget.selectedCareerListenable.value
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreCarreraAtlassian(
                                  trajectory.carreras[index].nombre,
                                ),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              if (trajectory.carreras[index].institucion
                                  .trim()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  trajectory.carreras[index].institucion,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected == null) return;
    widget.selectedCareerListenable.value = selected;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.localLoadedListenable,
      builder: (context, loaded, _) {
        return ValueListenableBuilder<TrayectoriaSageLaboratorio?>(
          valueListenable: widget.trajectoryListenable,
          builder: (context, trajectory, _) {
            return ValueListenableBuilder<int>(
              valueListenable: widget.selectedCareerListenable,
              builder: (context, selectedCareer, _) {
                final career = _currentCareer(trajectory, selectedCareer);
                final headerHeight = MediaQuery.paddingOf(context).top + 72;

                final mainContent = Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PanelPerfilAtlassian(
                        trajectory: trajectory,
                        career: career,
                        onChooseCareer: trajectory == null
                            ? null
                            : () => _chooseCareer(trajectory),
                        onOpenMaterias: trajectory == null
                            ? null
                            : () => widget.onNavigate(3),
                        onOpenProgress: trajectory == null
                            ? null
                            : _openProgress,
                        onOpenExams: () => widget.onNavigate(1),
                        ultimaSincronizacion: trajectory?.sincronizadaEn,
                        syncAvailable: !_saving && !_sageFlowOpen,
                        syncing: _saving || _sageFlowOpen,
                        onSync: _sync,
                      ),
                      const SizedBox(height: 16),
                      if (trajectory == null || career == null)
                        _PanelConexionAtlassian(
                          draft: _draft,
                          preparation: _preparation,
                          saving: _saving || _sageFlowOpen,
                          onSync: _sync,
                        )
                      else ...[
                        _ResumenProgresoAtlassian(career: career),
                        const SizedBox(height: 12),
                        _AtajoExamenesAtlassian(
                          onTap: () => widget.onNavigate(1),
                        ),
                        const SizedBox(height: 10),
                        _AtajoSageAtlassian(onTap: _openSagePortal),
                        const SizedBox(height: 20),
                        SeparadorTituloAtlassian(
                          title: 'Herramientas',
                          subtitle: nombreCarreraAtlassian(career.nombre),
                        ),
                        const SizedBox(height: 10),
                        _GrillaAccionesAtlassian(
                          onOpenRecord: () => widget.onNavigate(3),
                          onOpenPlan: () => widget.onNavigate(2),
                          onOpenScenarios: _openScenarios,
                          onOpenHelp: _openHelp,
                          onOpenNextSteps: _openNextSteps,
                          onOpenProgress: _openProgress,
                          onOpenCalendar: _openCalendar,
                          onOpenDesigns: _openDesigns,
                        ),
                        const SizedBox(height: 22),
                        _MateriasRecientesAtlassian(
                          career: career,
                          onOpenAll: () => widget.onNavigate(3),
                        ),
                        if (trajectory
                            .documentosDeCarrera(career)
                            .isNotEmpty) ...[
                          const SizedBox(height: 22),
                          _DocumentosAcademicosAtlassian(
                            documentos: trajectory.documentosDeCarrera(career),
                            busy: _sageFlowOpen || _saving,
                            onOpen: _openAcademicDocument,
                          ),
                        ],
                      ],
                    ],
                  ),
                );

                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: headerHeight),
                        child: RefreshIndicator(
                          onRefresh: _sync,
                          child: CustomScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverToBoxAdapter(child: mainContent),
                              if (trajectory != null && career != null)
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate:
                                      SugerenciasApiladasAtlassianDelegate(
                                        viewportHeight:
                                            MediaQuery.sizeOf(context).height -
                                            headerHeight,
                                        onOpenExams: () => widget.onNavigate(1),
                                        onOpenScenarios: _openScenarios,
                                        onOpenSubjects: () =>
                                            widget.onNavigate(3),
                                        onOpenCalendar: _openCalendar,
                                      ),
                                ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 144),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: EncabezadoTrayectoriaAtlassian(
                          scrollController: _scrollController,
                          onSearch: widget.onSearch,
                          onExit: widget.onExit,
                          nombreEstudiante: trajectory?.perfil.nombre,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _PanelPerfilAtlassian extends StatelessWidget {
  const _PanelPerfilAtlassian({
    required this.trajectory,
    required this.career,
    required this.onChooseCareer,
    required this.onOpenMaterias,
    required this.onOpenProgress,
    required this.onOpenExams,
    required this.ultimaSincronizacion,
    required this.syncAvailable,
    required this.syncing,
    required this.onSync,
  });

  final TrayectoriaSageLaboratorio? trajectory;
  final CarreraTrayectoriaSageLaboratorio? career;
  final VoidCallback? onChooseCareer;
  final VoidCallback? onOpenMaterias;
  final VoidCallback? onOpenProgress;
  final VoidCallback onOpenExams;
  final DateTime? ultimaSincronizacion;
  final bool syncAvailable;
  final bool syncing;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = nombrePerfilAtlassian(trajectory?.perfil);
    return PanelAtlassian(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(RadioAtlassian.large),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Image.asset(
                  'assets/icon_fore.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      Icon(Icons.school_rounded, color: scheme.onPrimary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 5),
                    if (career == null)
                      Text(
                        'Sin trayectoria sincronizada',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    else
                      InkWell(
                        onTap: onChooseCareer,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  nombreCarreraAtlassian(career!.nombre),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              if ((trajectory?.carreras.length ?? 0) > 1) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.expand_more_rounded,
                                  color: scheme.onSurfaceVariant,
                                  size: 18,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    if (career != null &&
                        career!.institucion.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        career!.institucion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 8.0;
              final width = (constraints.maxWidth - gap * 3) / 4;
              final actions = <_AccionPerfilAtlassian>[
                _AccionPerfilAtlassian(
                  label: 'Materias',
                  icon: Icons.grid_view_rounded,
                  onTap: onOpenMaterias,
                ),
                _AccionPerfilAtlassian(
                  label: 'Historial',
                  icon: Icons.history_rounded,
                  onTap: onOpenProgress,
                ),
                _AccionPerfilAtlassian(
                  label: 'Mesas',
                  icon: Icons.event_note_rounded,
                  onTap: onOpenExams,
                ),
                _AccionPerfilAtlassian(
                  label: syncing ? 'Sincronizando' : 'Sincronizar',
                  icon: syncing
                      ? Icons.hourglass_top_rounded
                      : syncAvailable
                      ? Icons.sync_rounded
                      : Icons.sync_disabled_rounded,
                  onTap: syncAvailable ? onSync : null,
                ),
              ];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < actions.length; index++) ...[
                    if (index > 0) const SizedBox(width: gap),
                    SizedBox(width: width, child: actions[index]),
                  ],
                ],
              );
            },
          ),
          if (ultimaSincronizacion != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 15,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Actualizado ${_formatLastSync(ultimaSincronizacion!)}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatLastSync(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    if (sameDay) return 'hoy $hour:$minute';
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _AccionPerfilAtlassian extends StatelessWidget {
  const _AccionPerfilAtlassian({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadioAtlassian.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: onTap == null
                    ? scheme.surfaceContainerLow
                    : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Icon(
                icon,
                size: 21,
                color: onTap == null
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.45)
                    : scheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: onTap == null
                    ? scheme.onSurfaceVariant.withValues(alpha: 0.55)
                    : scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumenProgresoAtlassian extends StatelessWidget {
  const _ResumenProgresoAtlassian({required this.career});

  final CarreraTrayectoriaSageLaboratorio career;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelAtlassian(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Progreso general',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '—',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(RadioAtlassian.pill),
                child: LinearProgressIndicator(
                  value: 0,
                  minHeight: 8,
                  color: scheme.outlineVariant,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 4 : 2;
            final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
            final metrics = <Widget>[
              MetricaAtlassian(
                label: 'Aprobadas',
                value: '${career.aprobadas}',
                icon: Icons.check_circle_outline_rounded,
                appearance: AparienciaLozengeAtlassian.success,
              ),
              const MetricaAtlassian(
                label: 'Habilitadas',
                value: '—',
                icon: Icons.inventory_2_outlined,
                appearance: AparienciaLozengeAtlassian.neutral,
              ),
              MetricaAtlassian(
                label: 'Cursando',
                value: '${career.cursando}',
                icon: Icons.play_circle_outline_rounded,
                appearance: AparienciaLozengeAtlassian.brand,
              ),
              const MetricaAtlassian(
                label: 'Plan total',
                value: '—',
                icon: Icons.inventory_2_outlined,
                appearance: AparienciaLozengeAtlassian.neutral,
              ),
            ];
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final metric in metrics)
                  SizedBox(width: width, child: metric),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _GrillaAccionesAtlassian extends StatelessWidget {
  const _GrillaAccionesAtlassian({
    required this.onOpenRecord,
    required this.onOpenPlan,
    required this.onOpenScenarios,
    required this.onOpenHelp,
    required this.onOpenNextSteps,
    required this.onOpenProgress,
    required this.onOpenCalendar,
    required this.onOpenDesigns,
  });

  final VoidCallback onOpenRecord;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenScenarios;
  final VoidCallback onOpenHelp;
  final VoidCallback onOpenNextSteps;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenDesigns;

  @override
  Widget build(BuildContext context) {
    final actions = <_AccionAtlassian>[
      _AccionAtlassian(
        label: 'Mi registro',
        description: 'Materias y estados',
        icon: Icons.edit_note_rounded,
        onTap: onOpenRecord,
      ),
      _AccionAtlassian(
        label: 'Plan completo',
        description: 'Mapa y requisitos',
        icon: Icons.account_tree_rounded,
        onTap: onOpenPlan,
      ),
      _AccionAtlassian(
        label: 'Escenarios',
        description: 'Qué podés cursar',
        icon: Icons.auto_graph_rounded,
        onTap: onOpenScenarios,
      ),
      _AccionAtlassian(
        label: 'Ayuda',
        description: 'Normativa y consultas',
        icon: Icons.help_outline_rounded,
        onTap: onOpenHelp,
      ),
      _AccionAtlassian(
        label: 'Próximos pasos',
        description: 'Prioridades académicas',
        icon: Icons.flag_outlined,
        onTap: onOpenNextSteps,
      ),
      _AccionAtlassian(
        label: 'Mi avance',
        description: 'Progreso por año',
        icon: Icons.insights_outlined,
        onTap: onOpenProgress,
      ),
      _AccionAtlassian(
        label: 'Calendario',
        description: 'Fechas y eventos',
        icon: Icons.calendar_month_outlined,
        onTap: onOpenCalendar,
      ),
      _AccionAtlassian(
        label: 'Diseños',
        description: 'Contenidos curriculares',
        icon: Icons.menu_book_rounded,
        onTap: onOpenDesigns,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 920
            ? 4
            : constraints.maxWidth >= 620
            ? 3
            : 2;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final action in actions)
              SizedBox(
                width: width,
                child: TarjetaAccionAtlassian(
                  label: action.label,
                  description: action.description,
                  icon: action.icon,
                  onTap: action.onTap,
                  compact: true,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AccionAtlassian {
  const _AccionAtlassian({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
}

class _AtajoExamenesAtlassian extends StatelessWidget {
  const _AtajoExamenesAtlassian({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PanelAtlassian(
      onTap: onTap,
      backgroundColor: scheme.primaryContainer,
      borderColor: scheme.primary.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: scheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mesas y fechas publicadas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: scheme.onPrimaryContainer,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _AtajoSageAtlassian extends StatelessWidget {
  const _AtajoSageAtlassian({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadioAtlassian.large),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF0C66E4),
            borderRadius: BorderRadius.circular(RadioAtlassian.large),
          ),
          child: Row(
            children: [
              Image.asset(
                'assets/sage_banner.png',
                height: 22,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text(
                  'SAGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 1, height: 24, color: Colors.white54),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Abrir SAGE',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: Colors.white),
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MateriasRecientesAtlassian extends StatelessWidget {
  const _MateriasRecientesAtlassian({
    required this.career,
    required this.onOpenAll,
  });

  final CarreraTrayectoriaSageLaboratorio career;
  final VoidCallback onOpenAll;

  @override
  Widget build(BuildContext context) {
    final subjects = career.materias.reversed.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeparadorTituloAtlassian(
          title: 'Actividad académica',
          action: TextButton(
            onPressed: onOpenAll,
            child: const Text('Ver todas'),
          ),
        ),
        const SizedBox(height: 8),
        PanelAtlassian(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < subjects.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subjects[index].nombre,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            if (subjects[index].anio != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                '${subjects[index].anio}° año',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      LozengeAtlassian(
                        label: subjects[index].estado.etiqueta,
                        appearance: aparienciaEstadoAtlassian(
                          subjects[index].estado,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != subjects.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DocumentosAcademicosAtlassian extends StatelessWidget {
  const _DocumentosAcademicosAtlassian({
    required this.documentos,
    required this.busy,
    required this.onOpen,
  });

  final List<DocumentoAcademicoSage> documentos;
  final bool busy;
  final ValueChanged<DocumentoAcademicoSage> onOpen;

  @override
  Widget build(BuildContext context) {
    final ordered = <DocumentoAcademicoSage>[
      for (final type in TipoDocumentoAcademicoSage.values)
        ...documentos.where((documento) => documento.tipo == type),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SeparadorTituloAtlassian(title: 'Documentos académicos'),
        const SizedBox(height: 8),
        PanelAtlassian(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < ordered.length; index++) ...[
                ListTile(
                  enabled: !busy,
                  leading: Icon(
                    _documentIcon(ordered[index].tipo),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(ordered[index].tipo.etiqueta),
                  trailing: busy
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download_rounded),
                  onTap: busy ? null : () => onOpen(ordered[index]),
                ),
                if (index != ordered.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _documentIcon(TipoDocumentoAcademicoSage type) => switch (type) {
    TipoDocumentoAcademicoSage.situacionAcademica =>
      Icons.assignment_ind_outlined,
    TipoDocumentoAcademicoSage.analitico => Icons.fact_check_outlined,
    TipoDocumentoAcademicoSage.libreta => Icons.menu_book_outlined,
  };
}

class _PanelConexionAtlassian extends StatelessWidget {
  const _PanelConexionAtlassian({
    required this.draft,
    required this.preparation,
    required this.saving,
    required this.onSync,
  });

  final TrayectoriaSageLaboratorio? draft;
  final EstadoPreparacionSageLaboratorio preparation;
  final bool saving;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return PanelAtlassian(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                ),
                child: Icon(
                  Icons.sync_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conectar trayectoria',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preparation.mensaje,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (preparation.progreso != null) ...[
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: preparation.progreso!.clamp(0, 1).toDouble(),
              minHeight: 6,
            ),
          ],
          if (draft != null) ...[
            const SizedBox(height: 14),
            MensajeSeccionAtlassian(
              title: 'Trayectoria preparada',
              message:
                  '${draft!.carreras.length} carreras · ${draft!.totalMaterias} materias',
              appearance: AparienciaLozengeAtlassian.success,
              icon: Icons.check_circle_outline_rounded,
            ),
          ],
          const SizedBox(height: 16),
          BotonAtlassian(
            label: saving ? 'Sincronizando…' : 'Iniciar y sincronizar',
            icon: saving ? Icons.hourglass_top_rounded : Icons.sync_rounded,
            primary: true,
            onPressed: saving ? null : onSync,
          ),
        ],
      ),
    );
  }
}

bool _sameProfile(
  PerfilTrayectoriaSageLaboratorio first,
  PerfilTrayectoriaSageLaboratorio second,
) {
  final firstDni = first.dni?.replaceAll(RegExp(r'\D'), '') ?? '';
  final secondDni = second.dni?.replaceAll(RegExp(r'\D'), '') ?? '';
  if (firstDni.isNotEmpty && secondDni.isNotEmpty) return firstDni == secondDni;
  return first.nombre.trim().toLowerCase() ==
      second.nombre.trim().toLowerCase();
}
