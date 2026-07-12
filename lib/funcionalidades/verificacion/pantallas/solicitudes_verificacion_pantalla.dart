import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos/solicitud_verificacion.dart';
import '../proveedores/proveedores_verificacion.dart';
import '../componentes/tarjeta_solicitud_verificacion.dart';

class SolicitudesVerificacionPantalla extends ConsumerWidget {
  const SolicitudesVerificacionPantalla({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ownRequestsAsync = ref.watch(proveedorSolicitudesVerificacionPropias);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF030712) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Tus solicitudes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () =>
                ref.invalidate(proveedorSolicitudesVerificacionPropias),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: isDesktop
                  ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
                  : const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _TarjetaSeccion(
                  title: 'Tus verificaciones',
                  child: ownRequestsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'Todavía no enviaste ninguna verificación.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        );
                      }

                      final latestReviewed = _latestReviewedRequest(items);
                      return Column(
                        children: [
                          if (latestReviewed != null) ...[
                            _BannerVerificacionLista(request: latestReviewed),
                            const SizedBox(height: 16),
                          ],
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child:
                                  TarjetaSolicitudVerificacion(request: item),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No se pudieron cargar tus solicitudes: $error',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
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

SolicitudVerificacion? _latestReviewedRequest(
    List<SolicitudVerificacion> items) {
  final reviewed = items
      .where((item) => item.status != EstadoSolicitudVerificacion.pending)
      .toList(growable: false);
  if (reviewed.isEmpty) return null;

  reviewed.sort((a, b) {
    final aTime = a.reviewedAt ?? a.createdAt;
    final bTime = b.reviewedAt ?? b.createdAt;
    return bTime.compareTo(aTime);
  });
  return reviewed.first;
}

String _verificationReadyMessage(SolicitudVerificacion request) {
  switch (request.status) {
    case EstadoSolicitudVerificacion.approved:
      return 'La verificación de ${request.matterName} ya quedó lista. Desde ahora podés compartir referencias sobre esta materia y sus docentes.';
    case EstadoSolicitudVerificacion.rejected:
      final note = (request.reviewNote ?? '').trim();
      final suffix = note.isEmpty
          ? ' Revisá la observación en la solicitud y, si hace falta, volvé a enviarla.'
          : ' Revisá la observación que quedó cargada y, si hace falta, volvé a enviarla.';
      return 'La revisión de ${request.matterName} ya quedó lista. Esta captura no alcanzó para habilitar la referencia.$suffix';
    case EstadoSolicitudVerificacion.pending:
      return 'Tu solicitud sigue en revisión.';
  }
}

class _BannerVerificacionLista extends StatelessWidget {
  const _BannerVerificacionLista({required this.request});

  final SolicitudVerificacion request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final approved = request.status == EstadoSolicitudVerificacion.approved;
    final background =
        approved ? const Color(0xFFE6F5F1) : const Color(0xFFF7ECE6);
    final foreground =
        approved ? const Color(0xFF195F56) : const Color(0xFF8A4D3A);
    final icon =
        approved ? Icons.mark_email_read_rounded : Icons.info_outline_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: foreground.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _verificationReadyMessage(request),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
