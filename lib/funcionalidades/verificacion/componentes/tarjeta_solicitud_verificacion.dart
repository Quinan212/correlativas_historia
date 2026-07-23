import 'package:flutter/material.dart';

import '../../../compartido/identidad_dispositivo/perfil_dispositivo.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../modelos/solicitud_verificacion.dart';

class TarjetaSolicitudVerificacion extends StatelessWidget {
  const TarjetaSolicitudVerificacion({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
    this.showDevice = false,
    this.deviceProfile,
  });

  final SolicitudVerificacion request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final bool showDevice;
  final PerfilDispositivo? deviceProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _openImagePreview(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
                      final cacheWidth = (constraints.maxWidth * pixelRatio)
                          .round();
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.network(
                          request.imageUrl,
                          fit: BoxFit.cover,
                          cacheWidth: cacheWidth,
                          filterQuality: FilterQuality.low,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Color(0xFFE2E8F0),
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.zoom_in_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Abrir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.matterName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _EtiquetaEstado(status: request.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Enviado: ${_formatDate(request.createdAt)}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (deviceProfile != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    deviceProfile!.adminDisplayLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (showDevice) ...[
                  const SizedBox(height: 4),
                  Text(
                    'device_id: ${request.deviceId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
                if ((request.reviewNote ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(request.reviewNote!, style: theme.textTheme.bodyMedium),
                ],
                if (onApprove != null || onReject != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (onApprove != null)
                        FilledButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Aprobar'),
                        ),
                      if (onReject != null)
                        OutlinedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close_rounded),
                          label: const Text('Rechazar'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openImagePreview(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VistaPreviaImagenVerificacionPantalla(
          imageUrl: request.imageUrl,
          title: request.matterName,
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _VistaPreviaImagenVerificacionPantalla extends StatelessWidget {
  const _VistaPreviaImagenVerificacionPantalla({
    required this.imageUrl,
    required this.title,
  });

  final String imageUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.devicePixelRatioOf(context);
                final cacheW = (constraints.maxWidth * dpr).round();
                return Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  cacheWidth: cacheW,
                  filterQuality: FilterQuality.medium,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white54),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.status});

  final EstadoSolicitudVerificacion status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dark = theme.brightness == Brightness.dark;
    final (bg, fg, label, border) = switch (status) {
      EstadoSolicitudVerificacion.pending => (
        dark
            ? PaletaAtlassian.warningSubtleDark
            : PaletaAtlassian.warningSubtle,
        dark ? const Color(0xFFFFF0B3) : const Color(0xFF7F5F01),
        'Pendiente',
        PaletaAtlassian.warning,
      ),
      EstadoSolicitudVerificacion.approved => (
        dark
            ? PaletaAtlassian.successSubtleDark
            : PaletaAtlassian.successSubtle,
        dark ? const Color(0xFFBAF3DB) : const Color(0xFF164B35),
        'Aprobada',
        PaletaAtlassian.success,
      ),
      EstadoSolicitudVerificacion.rejected => (
        dark ? PaletaAtlassian.dangerSubtleDark : PaletaAtlassian.dangerSubtle,
        dark ? const Color(0xFFFFD2CC) : const Color(0xFF5D1F1A),
        'Rechazada',
        PaletaAtlassian.danger,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
