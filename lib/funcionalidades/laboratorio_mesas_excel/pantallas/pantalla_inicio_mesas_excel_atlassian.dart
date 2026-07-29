import 'package:flutter/material.dart';

import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart';
import '../../laboratorio_atlassian/pantallas/utilidades_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../../laboratorio_biblioteca_drive/pantallas/pantalla_biblioteca_drive_atlassian.dart';
import '../controladores/controlador_mesas_excel.dart';
import 'pantalla_calendario_excel_atlassian.dart';
import 'pantalla_examenes_excel_atlassian.dart';

class PantallaInicioMesasExcelAtlassian extends StatefulWidget {
  const PantallaInicioMesasExcelAtlassian({
    super.key,
    required this.controller,
  });

  final ControladorMesasExcel controller;

  @override
  State<PantallaInicioMesasExcelAtlassian> createState() =>
      _PantallaInicioMesasExcelAtlassianState();
}

class _PantallaInicioMesasExcelAtlassianState
    extends State<PantallaInicioMesasExcelAtlassian> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant PantallaInicioMesasExcelAtlassian oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_onControllerChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _openExams() {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) =>
            PantallaExamenesExcelAtlassian(controller: widget.controller),
      ),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) => PantallaCalendarioExcelAtlassian(
          controller: widget.controller,
          careerId: 'historia',
        ),
      ),
    );
  }

  void _openLibrary() {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) => const PantallaBibliotecaDriveAtlassian(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: EncabezadoTrayectoriaAtlassian(
              scrollController: _scrollController,
              onSearch: () {},
              onExit: () => Navigator.of(context).pop(),
              nombreEstudiante: 'Estudiante de prueba',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final profile = _PanelPerfilExcelAtlassian(
                    onOpenExams: _openExams,
                    lastUpdate: widget.controller.metadatos?.validatedAt,
                  );
                  final progress = const _ResumenProgresoExcelAtlassian();
                  final shortcuts = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AtajoExamenesExcelAtlassian(onTap: _openExams),
                      const SizedBox(height: 10),
                      const _AtajoDeshabilitadoAtlassian(
                        label: 'Abrir SAGE',
                        icon: Icons.sync_rounded,
                      ),
                      const SizedBox(height: 10),
                      _AtajoBibliotecaDriveAtlassian(onTap: _openLibrary),
                    ],
                  );
                  final tools = Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SeparadorTituloAtlassian(
                        title: 'Herramientas',
                        subtitle: 'Profesorado de Historia',
                      ),
                      const SizedBox(height: 10),
                      _GrillaHerramientasExcelAtlassian(
                        onOpenCalendar: _openCalendar,
                      ),
                    ],
                  );
                  final recent = const _MateriasRecientesDeshabilitadas();

                  if (isWide) {
                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: profile),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      progress,
                                      const SizedBox(height: 12),
                                      shortcuts,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: tools),
                                const SizedBox(width: 24),
                                const Expanded(
                                  child: _MateriasRecientesDeshabilitadas(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      profile,
                      const SizedBox(height: 16),
                      progress,
                      const SizedBox(height: 12),
                      shortcuts,
                      const SizedBox(height: 20),
                      tools,
                      const SizedBox(height: 22),
                      recent,
                    ],
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 144)),
        ],
      ),
    );
  }
}

class _PanelPerfilExcelAtlassian extends StatelessWidget {
  const _PanelPerfilExcelAtlassian({
    required this.onOpenExams,
    required this.lastUpdate,
  });

  final VoidCallback onOpenExams;
  final DateTime? lastUpdate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                    Text(
                      'Estudiante de prueba',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Profesorado de Historia',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Profesorado Superior de Ciencias Sociales',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
              final actions = <Widget>[
                const _AccionPerfilExcelAtlassian(
                  label: 'Materias',
                  icon: Icons.grid_view_rounded,
                ),
                const _AccionPerfilExcelAtlassian(
                  label: 'Plan',
                  icon: Icons.assignment_outlined,
                ),
                _AccionPerfilExcelAtlassian(
                  label: 'Mesas',
                  icon: Icons.event_note_rounded,
                  onTap: onOpenExams,
                ),
                const _AccionPerfilExcelAtlassian(
                  label: 'Sincronizar',
                  icon: Icons.sync_disabled_rounded,
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
          if (lastUpdate != null) ...[
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
                  'Actualizado ${_formatLastSync(lastUpdate!)}',
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

class _AccionPerfilExcelAtlassian extends StatelessWidget {
  const _AccionPerfilExcelAtlassian({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      child: InkWell(
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
                      : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : scheme.primary),
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
      ),
    );
  }
}

class _ResumenProgresoExcelAtlassian extends StatelessWidget {
  const _ResumenProgresoExcelAtlassian();

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
            const metrics = <Widget>[
              MetricaAtlassian(
                label: 'Aprobadas',
                value: '—',
                icon: Icons.check_circle_outline_rounded,
                appearance: AparienciaLozengeAtlassian.neutral,
              ),
              MetricaAtlassian(
                label: 'Habilitadas',
                value: '—',
                icon: Icons.inventory_2_outlined,
                appearance: AparienciaLozengeAtlassian.neutral,
              ),
              MetricaAtlassian(
                label: 'Cursando',
                value: '—',
                icon: Icons.play_circle_outline_rounded,
                appearance: AparienciaLozengeAtlassian.neutral,
              ),
              MetricaAtlassian(
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

class _AtajoExamenesExcelAtlassian extends StatelessWidget {
  const _AtajoExamenesExcelAtlassian({required this.onTap});

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
          Icon(
            Icons.event_available_outlined,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : scheme.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mesas y fechas publicadas',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : scheme.onPrimaryContainer,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _AtajoBibliotecaDriveAtlassian extends StatelessWidget {
  const _AtajoBibliotecaDriveAtlassian({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PanelAtlassian(
      onTap: onTap,
      backgroundColor: scheme.surface,
      borderColor: scheme.primary.withValues(alpha: 0.28),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(RadioAtlassian.medium),
            ),
            child: Icon(
              Icons.local_library_outlined,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : scheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biblioteca académica',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'Materiales desde Google Drive',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: scheme.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _AtajoDeshabilitadoAtlassian extends StatelessWidget {
  const _AtajoDeshabilitadoAtlassian({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      enabled: false,
      child: PanelAtlassian(
        backgroundColor: scheme.surfaceContainerLow,
        borderColor: scheme.outlineVariant,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(
              icon,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.42),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
              ),
            ),
            Icon(
              Icons.lock_outline_rounded,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.42),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _GrillaHerramientasExcelAtlassian extends StatelessWidget {
  const _GrillaHerramientasExcelAtlassian({required this.onOpenCalendar});

  final VoidCallback onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    final actions = <_AccionExcelAtlassian>[
      const _AccionExcelAtlassian(
        label: 'Mi registro',
        description: 'Materias y estados',
        icon: Icons.edit_note_rounded,
      ),
      const _AccionExcelAtlassian(
        label: 'Plan completo',
        description: 'Mapa y requisitos',
        icon: Icons.account_tree_rounded,
      ),
      const _AccionExcelAtlassian(
        label: 'Escenarios',
        description: 'Qué podés cursar',
        icon: Icons.auto_graph_rounded,
      ),
      const _AccionExcelAtlassian(
        label: 'Ayuda',
        description: 'Normativa y consultas',
        icon: Icons.help_outline_rounded,
      ),
      const _AccionExcelAtlassian(
        label: 'Próximos pasos',
        description: 'Prioridades académicas',
        icon: Icons.flag_outlined,
      ),
      const _AccionExcelAtlassian(
        label: 'Mi avance',
        description: 'Progreso por año',
        icon: Icons.insights_outlined,
      ),
      _AccionExcelAtlassian(
        label: 'Calendario',
        description: 'Fechas y eventos',
        icon: Icons.calendar_month_outlined,
        onTap: onOpenCalendar,
      ),
      const _AccionExcelAtlassian(
        label: 'Diseños',
        description: 'Contenidos curriculares',
        icon: Icons.menu_book_rounded,
      ),
      const _AccionExcelAtlassian(
        label: 'Acceso developer',
        description: 'Versiones de la aplicación',
        icon: Icons.developer_mode_rounded,
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
                child: action.onTap == null
                    ? _TarjetaAccionDeshabilitadaAtlassian(action: action)
                    : TarjetaAccionAtlassian(
                        label: action.label,
                        description: action.description,
                        icon: action.icon,
                        onTap: action.onTap!,
                        compact: true,
                      ),
              ),
          ],
        );
      },
    );
  }
}

class _AccionExcelAtlassian {
  const _AccionExcelAtlassian({
    required this.label,
    required this.description,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
}

class _TarjetaAccionDeshabilitadaAtlassian extends StatelessWidget {
  const _TarjetaAccionDeshabilitadaAtlassian({required this.action});

  final _AccionExcelAtlassian action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = scheme.onSurfaceVariant.withValues(alpha: 0.48);
    return Semantics(
      enabled: false,
      label: '${action.label}. ${action.description}. Deshabilitado',
      child: SizedBox(
        height: 126,
        child: PanelAtlassian(
          backgroundColor: scheme.surfaceContainerLow,
          borderColor: scheme.outlineVariant,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        RadioAtlassian.medium,
                      ),
                    ),
                    child: Icon(action.icon, color: disabled, size: 19),
                  ),
                  const Spacer(),
                  Icon(Icons.lock_outline_rounded, size: 18, color: disabled),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: disabled),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  action.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: disabled),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MateriasRecientesDeshabilitadas extends StatelessWidget {
  const _MateriasRecientesDeshabilitadas();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final disabled = scheme.onSurfaceVariant.withValues(alpha: 0.48);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SeparadorTituloAtlassian(
          title: 'Materias recientes',
          subtitle: 'Profesorado de Historia',
          action: Text(
            'Ver todas',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: disabled),
          ),
        ),
        const SizedBox(height: 10),
        PanelAtlassian(
          padding: EdgeInsets.zero,
          backgroundColor: scheme.surfaceContainerLow,
          child: Column(
            children: [
              for (var index = 0; index < 3; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(
                            RadioAtlassian.medium,
                          ),
                        ),
                        child: Icon(
                          Icons.menu_book_outlined,
                          color: disabled,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 11,
                              decoration: BoxDecoration(
                                color: scheme.outlineVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              width: 92,
                              height: 9,
                              decoration: BoxDecoration(
                                color: scheme.outlineVariant.withValues(
                                  alpha: 0.7,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.lock_outline_rounded,
                        color: disabled,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                if (index != 2) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
