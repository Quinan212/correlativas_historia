import 'package:flutter/material.dart';

import '../../examenes/modelos/evento_examen.dart';
import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../modelos/modelos_mesas_excel.dart';

String etiquetaInstanciaMesasExcel(String value) {
  return switch (value) {
    'llamado_1' => 'Primer llamado',
    'llamado_2' => 'Segundo llamado',
    'coloquio' => 'Coloquio',
    _ => value,
  };
}

String etiquetaCarreraMesasExcel(String value) {
  return switch (value) {
    'historia' => 'Historia',
    'geografia' => 'Geografía',
    'politica' => 'Ciencia Política',
    _ => value,
  };
}

String fechaCortaMesasExcel(DateTime? value) {
  if (value == null) return 'Fecha no informada';
  const months = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}

String fechaHoraControlMesasExcel(DateTime? value) {
  if (value == null) return 'Sin verificación';
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} · '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

class TarjetaInicioMesasExcelAtlassian extends StatelessWidget {
  const TarjetaInicioMesasExcelAtlassian({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.enabled,
    this.onTap,
    this.badge,
  });

  final String label;
  final String description;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = enabled
        ? scheme.onSurface
        : scheme.onSurfaceVariant.withValues(alpha: 0.52);
    final iconColor = enabled
        ? scheme.primary
        : scheme.onSurfaceVariant.withValues(alpha: 0.40);
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: enabled ? label : '$label, deshabilitado',
      child: PanelAtlassian(
        onTap: enabled ? onTap : null,
        backgroundColor: enabled
            ? scheme.surface
            : scheme.surfaceContainerLow.withValues(alpha: 0.72),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: enabled
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(
                      RadioAtlassian.medium,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 21),
                ),
                const Spacer(),
                if (badge != null)
                  LozengeAtlassian(
                    label: badge!,
                    appearance: enabled
                        ? AparienciaLozengeAtlassian.brand
                        : AparienciaLozengeAtlassian.neutral,
                  )
                else
                  Icon(
                    enabled
                        ? Icons.arrow_forward_rounded
                        : Icons.lock_outline_rounded,
                    color: iconColor,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BannerEstadoFuenteMesasExcel extends StatelessWidget {
  const BannerEstadoFuenteMesasExcel({
    super.key,
    required this.estado,
    required this.metadatos,
    this.mensaje,
  });

  final EstadoFuenteMesasExcel estado;
  final MetadatosFuenteMesasExcel? metadatos;
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    final appearance = switch (estado) {
      EstadoFuenteMesasExcel.disponible ||
      EstadoFuenteMesasExcel.sinCambios =>
        AparienciaLozengeAtlassian.success,
      EstadoFuenteMesasExcel.disponibleDesdeCopiaLocal ||
      EstadoFuenteMesasExcel.sinConexion =>
        AparienciaLozengeAtlassian.warning,
      EstadoFuenteMesasExcel.inicializando ||
      EstadoFuenteMesasExcel.comprobando =>
        AparienciaLozengeAtlassian.brand,
      _ => AparienciaLozengeAtlassian.danger,
    };
    final text = switch (estado) {
      EstadoFuenteMesasExcel.inicializando =>
        'Preparando el lector y la copia local.',
      EstadoFuenteMesasExcel.comprobando =>
        'Descargando y validando el archivo institucional.',
      EstadoFuenteMesasExcel.disponible =>
        'Fuente verificada ${fechaHoraControlMesasExcel(metadatos?.validatedAt)}.',
      EstadoFuenteMesasExcel.sinCambios =>
        'La fuente continúa sin cambios. Última comprobación ${fechaHoraControlMesasExcel(metadatos?.checkedAt)}.',
      EstadoFuenteMesasExcel.disponibleDesdeCopiaLocal =>
        'Se muestra la última copia local verificada.',
      EstadoFuenteMesasExcel.sinConexion =>
        'No se pudo comprobar la fuente. Se muestran datos verificados ${fechaHoraControlMesasExcel(metadatos?.validatedAt)}.',
      _ => mensaje ?? 'La fuente no está disponible por el momento.',
    };
    return MensajeSeccionAtlassian(
      title: estado.etiqueta,
      message: text,
      appearance: appearance,
      icon: estado.estaComprobando
          ? Icons.sync_rounded
          : estado.permiteMostrarDatos
          ? Icons.verified_outlined
          : Icons.error_outline_rounded,
    );
  }
}

class TarjetaEventoMesasExcelAtlassian extends StatelessWidget {
  const TarjetaEventoMesasExcelAtlassian({
    super.key,
    required this.item,
    required this.onTap,
    this.compact = false,
  });

  final EventoMesaExcel item;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final event = item.evento;
    final scheme = Theme.of(context).colorScheme;
    final date = event.fechaVigente;
    final statusAppearance = switch (event.estado) {
      EstadoEventoExamen.activa => AparienciaLozengeAtlassian.success,
      EstadoEventoExamen.reprogramada => AparienciaLozengeAtlassian.warning,
      EstadoEventoExamen.suspendida || EstadoEventoExamen.cancelada =>
        AparienciaLozengeAtlassian.danger,
    };
    return PanelAtlassian(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 44 : 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: date == null
                  ? scheme.surfaceContainerLow
                  : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(RadioAtlassian.medium),
            ),
            child: Column(
              children: [
                Text(
                  date == null ? '—' : date.day.toString(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: date == null
                        ? scheme.onSurfaceVariant
                        : scheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  event.horaVigente ?? 'S/H',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: date == null
                        ? scheme.onSurfaceVariant
                        : scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.materia,
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '${etiquetaCarreraMesasExcel(event.careerId)} · '
                  '${event.anio == null ? 'Año sin informar' : '${event.anio}.º año'}'
                  '${event.division == null ? '' : ' · ${event.division}'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    LozengeAtlassian(
                      label: etiquetaInstanciaMesasExcel(event.instancia),
                      appearance: AparienciaLozengeAtlassian.brand,
                    ),
                    if (event.estado != EstadoEventoExamen.activa)
                      LozengeAtlassian(
                        label: event.estado.etiqueta,
                        appearance: statusAppearance,
                      ),
                    LozengeAtlassian(
                      label: event.puedeAbrirActa ? 'ACTA' : 'SIN ACTA',
                      appearance: event.puedeAbrirActa
                          ? AparienciaLozengeAtlassian.success
                          : AparienciaLozengeAtlassian.neutral,
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

class EstadoNoDisponibleMesasExcel extends StatelessWidget {
  const EstadoNoDisponibleMesasExcel({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onDiagnostic,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onDiagnostic;

  @override
  Widget build(BuildContext context) {
    return EstadoVacioAtlassian(
      icon: Icons.event_busy_rounded,
      title: 'Mesas temporalmente no disponibles',
      message: message,
      action: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          BotonAtlassian(
            label: 'Reintentar',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
          BotonAtlassian(
            label: 'Ver diagnóstico',
            icon: Icons.rule_folder_outlined,
            onPressed: onDiagnostic,
          ),
        ],
      ),
    );
  }
}
