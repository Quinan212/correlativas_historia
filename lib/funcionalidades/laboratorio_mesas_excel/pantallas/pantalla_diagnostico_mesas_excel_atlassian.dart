import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../componentes/componentes_mesas_excel_atlassian.dart';
import '../configuracion/configuracion_fuente_mesas_excel.dart';
import '../controladores/controlador_mesas_excel.dart';
import '../modelos/modelos_mesas_excel.dart';

class PantallaDiagnosticoMesasExcelAtlassian extends StatelessWidget {
  const PantallaDiagnosticoMesasExcelAtlassian({
    super.key,
    required this.controller,
  });

  final ControladorMesasExcel controller;

  Future<void> _openSource(BuildContext context) async {
    final uri = Uri.parse(
      ConfiguracionFuenteMesasExcel.current.sourcePageUrl,
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la fuente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final diagnostic = controller.diagnostico;
        final metadata = controller.metadatos;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              EncabezadoPaginaAtlassian(
                title: 'Diagnóstico XLSX',
                subtitle: 'Parser y controles de integridad',
                leading: IconButton(
                  tooltip: 'Volver',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Abrir fuente',
                    onPressed: () => _openSource(context),
                    icon: const Icon(Icons.open_in_new_rounded),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: controller.estaComprobando
                        ? null
                        : () => controller.actualizar(force: true),
                    icon: controller.estaComprobando
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.actualizar(force: true),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(EspacioAtlassian.md),
                    children: [
                      BannerEstadoFuenteMesasExcel(
                        estado: controller.estado,
                        metadatos: metadata,
                        mensaje: controller.mensajeError,
                      ),
                      const SizedBox(height: 14),
                      _TechnicalMetadata(
                        metadata: metadata,
                        diagnostic: diagnostic,
                      ),
                      const SizedBox(height: 18),
                      const SeparadorTituloAtlassian(
                        title: 'Resultado global',
                        subtitle: 'Validación previa a la publicación local',
                      ),
                      const SizedBox(height: 10),
                      _DiagnosticMetrics(
                        diagnostic: diagnostic,
                        events: controller.eventos.length,
                      ),
                      if (diagnostic == null) ...[
                        const SizedBox(height: 18),
                        const EstadoVacioAtlassian(
                          icon: Icons.rule_folder_outlined,
                          title: 'Sin diagnóstico',
                          message:
                              'La aplicación todavía no completó una lectura del archivo.',
                        ),
                      ] else ...[
                        if (diagnostic.erroresBloqueantes.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          MensajeSeccionAtlassian(
                            title: 'Errores bloqueantes',
                            message: diagnostic.erroresBloqueantes.join('\n'),
                            appearance: AparienciaLozengeAtlassian.danger,
                            icon: Icons.block_rounded,
                          ),
                        ],
                        if (diagnostic.advertencias.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          MensajeSeccionAtlassian(
                            title: 'Advertencias',
                            message: diagnostic.advertencias.join('\n'),
                            appearance: AparienciaLozengeAtlassian.warning,
                            icon: Icons.warning_amber_rounded,
                          ),
                        ],
                        const SizedBox(height: 18),
                        const SeparadorTituloAtlassian(
                          title: 'Hojas analizadas',
                          subtitle: 'Detalle por tabla reconocida',
                        ),
                        const SizedBox(height: 10),
                        for (
                          var index = 0;
                          index < diagnostic.hojas.length;
                          index++
                        ) ...[
                          _SheetDiagnosticCard(
                            diagnostic: diagnostic.hojas[index],
                          ),
                          if (index < diagnostic.hojas.length - 1)
                            const SizedBox(height: 8),
                        ],
                      ],
                      const SizedBox(height: 18),
                      BotonAtlassian(
                        label: 'Abrir archivo institucional',
                        icon: Icons.table_view_outlined,
                        expanded: true,
                        onPressed: () => _openSource(context),
                      ),
                      const SizedBox(height: 18),
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

class _TechnicalMetadata extends StatelessWidget {
  const _TechnicalMetadata({
    required this.metadata,
    required this.diagnostic,
  });

  final MetadatosFuenteMesasExcel? metadata;
  final DiagnosticoLibroExcel? diagnostic;

  @override
  Widget build(BuildContext context) {
    final hash = metadata?.sourceHash ?? '';
    final shortHash = hash.length > 16 ? '${hash.substring(0, 16)}…' : hash;
    return PanelAtlassian(
      child: Column(
        children: [
          _InfoRow(
            label: 'Versión del parser',
            value: '${diagnostic?.parserVersion ?? 1}',
          ),
          const _InfoDivider(),
          _InfoRow(
            label: 'Última comprobación',
            value: fechaHoraControlMesasExcel(metadata?.checkedAt),
          ),
          const _InfoDivider(),
          _InfoRow(
            label: 'Última validación',
            value: fechaHoraControlMesasExcel(metadata?.validatedAt),
          ),
          const _InfoDivider(),
          _InfoRow(
            label: 'Tamaño de origen',
            value: metadata == null
                ? '—'
                : '${(metadata!.sourceSize / 1024).toStringAsFixed(1)} KB',
          ),
          const _InfoDivider(),
          _InfoRow(label: 'SHA-256', value: shortHash.isEmpty ? '—' : shortHash),
        ],
      ),
    );
  }
}

class _DiagnosticMetrics extends StatelessWidget {
  const _DiagnosticMetrics({required this.diagnostic, required this.events});

  final DiagnosticoLibroExcel? diagnostic;
  final int events;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      MetricaAtlassian(
        label: 'Eventos activos',
        value: events.toString(),
        icon: Icons.event_note_outlined,
        appearance: AparienciaLozengeAtlassian.brand,
      ),
      MetricaAtlassian(
        label: 'Actas asociadas',
        value: '${diagnostic?.actasAsociadas ?? 0}',
        icon: Icons.link_rounded,
        appearance: AparienciaLozengeAtlassian.success,
      ),
      MetricaAtlassian(
        label: 'Coincidencias por alias',
        value: '${diagnostic?.coincidenciasPorAlias ?? 0}',
        icon: Icons.spellcheck_rounded,
        appearance: AparienciaLozengeAtlassian.discovery,
      ),
      MetricaAtlassian(
        label: 'Errores bloqueantes',
        value: '${diagnostic?.erroresBloqueantes.length ?? 0}',
        icon: Icons.gpp_bad_outlined,
        appearance: (diagnostic?.erroresBloqueantes.isEmpty ?? true)
            ? AparienciaLozengeAtlassian.success
            : AparienciaLozengeAtlassian.danger,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final width =
            (constraints.maxWidth - ((columns - 1) * 8)) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in items) SizedBox(width: width, child: item),
          ],
        );
      },
    );
  }
}

class _SheetDiagnosticCard extends StatelessWidget {
  const _SheetDiagnosticCard({required this.diagnostic});

  final DiagnosticoHojaExcel diagnostic;

  @override
  Widget build(BuildContext context) {
    return PanelAtlassian(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                diagnostic.valida
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: diagnostic.valida
                    ? PaletaAtlassian.success
                    : PaletaAtlassian.danger,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnostic.nombre,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      diagnostic.tipo,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              LozengeAtlassian(
                label: diagnostic.valida ? 'VÁLIDA' : 'BLOQUEADA',
                appearance: diagnostic.valida
                    ? AparienciaLozengeAtlassian.success
                    : AparienciaLozengeAtlassian.danger,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              LozengeAtlassian(
                label: '${diagnostic.filasLeidas} FILAS',
                appearance: AparienciaLozengeAtlassian.neutral,
              ),
              LozengeAtlassian(
                label: '${diagnostic.eventosGenerados} EVENTOS',
                appearance: AparienciaLozengeAtlassian.brand,
              ),
              LozengeAtlassian(
                label: '${diagnostic.actasAsociadas} ACTAS',
                appearance: AparienciaLozengeAtlassian.success,
              ),
              if (diagnostic.filasFusionadas > 0)
                LozengeAtlassian(
                  label: '${diagnostic.filasFusionadas} CONTINUACIONES',
                  appearance: AparienciaLozengeAtlassian.discovery,
                ),
              if (diagnostic.duplicadosFusionados > 0)
                LozengeAtlassian(
                  label: '${diagnostic.duplicadosFusionados} DUPLICADOS',
                  appearance: AparienciaLozengeAtlassian.warning,
                ),
            ],
          ),
          if (diagnostic.advertencias.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              diagnostic.advertencias.join('\n'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (diagnostic.errores.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              diagnostic.errores.join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PaletaAtlassian.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 18, color: Theme.of(context).colorScheme.outlineVariant);
  }
}
