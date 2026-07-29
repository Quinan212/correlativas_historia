import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../examenes/modelos/evento_examen.dart';
import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../../laboratorio_atlassian/pantallas/utilidades_atlassian.dart';

class PantallaDetalleExamenExcelAtlassian extends StatelessWidget {
  const PantallaDetalleExamenExcelAtlassian({super.key, required this.event});

  final EventoExamen event;

  Future<void> _openAct(BuildContext context) async {
    if (!event.puedeAbrirActa) return;
    final raw = event.actaUrl?.trim() ?? '';
    final uri = Uri.tryParse(raw);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el acta.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          EncabezadoPaginaAtlassian(
            title: 'Detalle del examen',
            subtitle: _instanceLabel(event.instancia),
            centerTitle: true,
            leading: BotonIconoAtlassian(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Volver',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                120 + MediaQuery.paddingOf(context).bottom,
              ),
              children: [
                PanelAtlassian(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          if (event.mostrarAvisoEstado)
                            LozengeAtlassian(
                              label: event.estado.etiqueta,
                              appearance: _statusAppearance(event.estado),
                            ),
                          LozengeAtlassian(
                            label: _shortInstanceLabel(event.instancia),
                            appearance: event.instancia == 'coloquio'
                                ? AparienciaLozengeAtlassian.discovery
                                : AparienciaLozengeAtlassian.brand,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          event.materia,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (event.mostrarAvisoEstado) ...[
                  const SizedBox(height: 12),
                  _AvisoEstadoExamenAtlassian(event: event),
                ],
                const SizedBox(height: 12),
                PanelAtlassian(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _DatoExamenAtlassian(
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha',
                        value: formatoFechaAtlassian(event.fechaVigente),
                      ),
                      const Divider(height: 1),
                      _DatoExamenAtlassian(
                        icon: Icons.schedule_rounded,
                        label: 'Hora',
                        value: event.horaVigente ?? 'Sin horario',
                      ),
                      if (event.tieneFechaOriginalDistinta) ...[
                        const Divider(height: 1),
                        _DatoExamenAtlassian(
                          icon: Icons.history_rounded,
                          label: 'Anterior',
                          value: formatoFechaHoraAtlassian(
                            event.fecha,
                            event.hora,
                          ),
                        ),
                      ],
                      const Divider(height: 1),
                      _DatoExamenAtlassian(
                        icon: Icons.school_outlined,
                        label: 'Año',
                        value: event.anio == null
                            ? 'Sin año'
                            : '${event.anio}°',
                      ),
                      const Divider(height: 1),
                      _DatoExamenAtlassian(
                        icon: Icons.groups_outlined,
                        label: 'Docentes',
                        value: event.docentes.isEmpty
                            ? 'Sin docentes informados'
                            : event.docentes.join(', '),
                      ),
                      if ((event.division ?? '').trim().isNotEmpty) ...[
                        const Divider(height: 1),
                        _DatoExamenAtlassian(
                          icon: Icons.badge_outlined,
                          label: 'División',
                          value: event.division!,
                        ),
                      ],
                    ],
                  ),
                ),
                if (event.puedeAbrirActa) ...[
                  const SizedBox(height: 16),
                  BotonAtlassian(
                    label: 'Abrir acta',
                    icon: Icons.open_in_new_rounded,
                    primary: true,
                    expanded: true,
                    onPressed: () => unawaited(_openAct(context)),
                  ),
                ],
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(EstadoEventoExamen status) {
  return switch (status) {
    EstadoEventoExamen.activa => 'Activa',
    EstadoEventoExamen.suspendida => 'Suspendida',
    EstadoEventoExamen.cancelada => 'Cancelada',
    EstadoEventoExamen.reprogramada => 'Reprogramada',
  };
}

class _AvisoEstadoExamenAtlassian extends StatelessWidget {
  const _AvisoEstadoExamenAtlassian({required this.event});

  final EventoExamen event;

  @override
  Widget build(BuildContext context) {
    final foreground = _statusForeground(context, event.estado);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _statusBackground(context, event.estado),
        borderRadius: BorderRadius.circular(RadioAtlassian.medium),
        border: Border.all(
          color: foreground.withValues(alpha: 0.75),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _statusIconBackground(context, event.estado),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(event.estado), color: foreground, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.tituloEstadoEfectivo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  event.mensajeEstadoEfectivo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w500,
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

AparienciaLozengeAtlassian _statusAppearance(EstadoEventoExamen status) {
  return switch (status) {
    EstadoEventoExamen.activa => AparienciaLozengeAtlassian.success,
    EstadoEventoExamen.suspendida => AparienciaLozengeAtlassian.warning,
    EstadoEventoExamen.cancelada => AparienciaLozengeAtlassian.danger,
    EstadoEventoExamen.reprogramada => AparienciaLozengeAtlassian.discovery,
  };
}

IconData _statusIcon(EstadoEventoExamen status) {
  return switch (status) {
    EstadoEventoExamen.activa => Icons.check_circle_outline_rounded,
    EstadoEventoExamen.suspendida => Icons.warning_amber_rounded,
    EstadoEventoExamen.cancelada => Icons.cancel_outlined,
    EstadoEventoExamen.reprogramada => Icons.event_repeat_rounded,
  };
}

Color _statusBackground(BuildContext context, EstadoEventoExamen status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa => Colors.transparent,
    EstadoEventoExamen.suspendida =>
      dark ? const Color(0xFF262112) : const Color(0xFFFFFBE6),
    EstadoEventoExamen.cancelada =>
      dark ? const Color(0xFF321A1A) : const Color(0xFFFFEBE6),
    EstadoEventoExamen.reprogramada =>
      dark ? const Color(0xFF16233A) : const Color(0xFFE9F2FF),
  };
}

Color _statusIconBackground(BuildContext context, EstadoEventoExamen status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa => Theme.of(context).colorScheme.primaryContainer,
    EstadoEventoExamen.suspendida =>
      dark ? const Color(0xFF4A3B00) : const Color(0xFFFFF3CD),
    EstadoEventoExamen.cancelada =>
      dark ? const Color(0xFF5A2020) : const Color(0xFFFFD5D2),
    EstadoEventoExamen.reprogramada =>
      dark ? const Color(0xFF173A66) : const Color(0xFFD6E8FF),
  };
}

Color _statusForeground(BuildContext context, EstadoEventoExamen status) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (status) {
    EstadoEventoExamen.activa => Theme.of(context).colorScheme.primary,
    EstadoEventoExamen.suspendida =>
      dark ? const Color(0xFFFFD54F) : const Color(0xFF8A5D00),
    EstadoEventoExamen.cancelada =>
      dark ? const Color(0xFFFF8F85) : const Color(0xFFAE2A19),
    EstadoEventoExamen.reprogramada =>
      dark ? const Color(0xFF85B8FF) : const Color(0xFF0052CC),
  };
}

class _DatoExamenAtlassian extends StatelessWidget {
  const _DatoExamenAtlassian({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 78,
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

String _instanceLabel(String raw) {
  return switch (raw) {
    'llamado_1' => 'Primer llamado',
    'llamado_2' => 'Segundo llamado',
    'coloquio' => 'Coloquios',
    _ => 'Exámenes',
  };
}

String _shortInstanceLabel(String raw) {
  return switch (raw) {
    'llamado_1' => 'Llamado 1',
    'llamado_2' => 'Llamado 2',
    'coloquio' => 'Coloquio',
    _ => 'Examen',
  };
}

String _normalize(String value) {
  const replacements = <String, String>{
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  var out = value.toLowerCase();
  replacements.forEach((key, replacement) {
    out = out.replaceAll(key, replacement);
  });
  return out.replaceAll(RegExp(r'\s+'), ' ').trim();
}
