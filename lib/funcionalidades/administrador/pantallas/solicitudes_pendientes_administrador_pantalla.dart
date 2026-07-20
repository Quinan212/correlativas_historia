import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../verificacion/componentes/tarjeta_solicitud_verificacion.dart';
import '../../verificacion/modelos/solicitud_verificacion.dart';
import '../../verificacion/proveedores/proveedores_verificacion.dart';

class SolicitudesPendientesAdministradorPantalla extends ConsumerWidget {
  const SolicitudesPendientesAdministradorPantalla({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pendingAsync = ref.watch(proveedorSolicitudesVerificacionPendientes);
    final pendingIds = pendingAsync.value?.map((e) => e.deviceId) ??
        const Iterable<String>.empty();
    final profileMapAsync = ref.watch(
      proveedorPerfilesDispositivoPorIds(
        serializeDeviceIds([...pendingIds]),
      ),
    );
    final profileMap =
        profileMapAsync.value ?? const <String, PerfilDispositivo>{};

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return _SolicitudesPendientesAdminEscritorio(
            adminDeviceId: adminDeviceId,
            pendingAsync: pendingAsync,
            profileMap: profileMap,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Solicitudes pendientes'),
            actions: [
              IconButton(
                onPressed: () =>
                    ref.invalidate(proveedorSolicitudesVerificacionPendientes),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refrescar',
              ),
            ],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _TarjetaSeccion(
                  title: 'Verificaciones en revisión',
                  child: pendingAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No hay solicitudes pendientes en este momento.',
                            style: theme.textTheme.bodyLarge,
                          ),
                        );
                      }

                      return Column(
                        children: items
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MobileRequestItem(
                                  request: item,
                                  adminDeviceId: adminDeviceId,
                                  deviceProfile: profileMap[item.deviceId],
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: LinearProgressIndicator(minHeight: 3),
                    ),
                    error: (error, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No se pudieron cargar las solicitudes: $error',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SolicitudesPendientesAdminEscritorio extends StatefulWidget {
  const _SolicitudesPendientesAdminEscritorio({
    required this.adminDeviceId,
    required this.pendingAsync,
    required this.profileMap,
  });

  final String adminDeviceId;
  final AsyncValue<List<SolicitudVerificacion>> pendingAsync;
  final Map<String, PerfilDispositivo> profileMap;

  @override
  State<_SolicitudesPendientesAdminEscritorio> createState() =>
      _SolicitudesPendientesAdminEscritorioState();
}

class _SolicitudesPendientesAdminEscritorioState
    extends State<_SolicitudesPendientesAdminEscritorio> {
  SolicitudVerificacion? _selectedRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF030712) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Gestión de Solicitudes'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer(builder: (context, ref, _) {
            return IconButton(
              onPressed: () =>
                  ref.invalidate(proveedorSolicitudesVerificacionPendientes),
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refrescar',
            );
          }),
        ],
      ),
      body: widget.pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const _EstadoVacio(
              title: 'Todo al día',
              subtitle: 'No hay solicitudes pendientes de revisión.',
              icon: Icons.done_all_rounded,
            );
          }

          if (_selectedRequest == null ||
              !items.any((e) => e.id == _selectedRequest?.id)) {
            _selectedRequest = items.first;
          }

          return Row(
            children: [
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1220) : Colors.white,
                  border: Border(
                    right: BorderSide(
                      color: isDark
                          ? const Color(0xFF243041)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark
                        ? const Color(0xFF243041)
                        : const Color(0xFFE5E7EB),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final profile = widget.profileMap[item.deviceId];
                    final isSelected = _selectedRequest?.id == item.id;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      selected: isSelected,
                      selectedTileColor:
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _buildInitials(
                              profile?.adminDisplayLabel ?? 'Usuario'),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        profile?.adminDisplayLabel ?? 'Usuario desconocido',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          item.matterName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => setState(() => _selectedRequest = item),
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: _selectedRequest == null
                      ? const Center(child: Text('Seleccioná una solicitud'))
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 850),
                            child: _VistaDetalleSolicitudPendiente(
                              request: _selectedRequest!,
                              adminDeviceId: widget.adminDeviceId,
                              deviceProfile:
                                  widget.profileMap[_selectedRequest!.deviceId],
                              onHandled: () {
                                setState(() => _selectedRequest = null);
                              },
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _buildInitials(String label) {
    final parts = label.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _VistaDetalleSolicitudPendiente extends ConsumerStatefulWidget {
  const _VistaDetalleSolicitudPendiente({
    required this.request,
    required this.adminDeviceId,
    required this.onHandled,
    this.deviceProfile,
  });

  final SolicitudVerificacion request;
  final String adminDeviceId;
  final PerfilDispositivo? deviceProfile;
  final VoidCallback onHandled;

  @override
  ConsumerState<_VistaDetalleSolicitudPendiente> createState() =>
      _VistaDetalleSolicitudPendienteState();
}

class _VistaDetalleSolicitudPendienteState
    extends ConsumerState<_VistaDetalleSolicitudPendiente> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _EncabezadoDetalle(
            deviceProfile: widget.deviceProfile,
            request: widget.request,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _TituloSeccion(title: 'Detalles de la solicitud'),
                  const SizedBox(height: 16),
                  _GrillaInfoDetalle(request: widget.request),
                  const SizedBox(height: 32),
                  const _TituloSeccion(title: 'Captura adjunta'),
                  const SizedBox(height: 16),
                  _ImagePreview(imageUrl: widget.request.imageUrl),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _BarraAcciones(
            busy: _busy,
            onApprove: _approve,
            onReject: _reject,
          ),
        ],
      ),
    );
  }

  Future<void> _approve() async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioVerificacion);
      await repo.approveRequest(
        client: client,
        request: widget.request,
        adminDeviceId: widget.adminDeviceId,
      );
      ref.invalidate(proveedorSolicitudesVerificacionPendientes);
      widget.onHandled();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioVerificacion);
      await repo.rejectRequest(
        client: client,
        requestId: widget.request.id,
        adminDeviceId: widget.adminDeviceId,
      );
      ref.invalidate(proveedorSolicitudesVerificacionPendientes);
      widget.onHandled();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _EncabezadoDetalle extends StatelessWidget {
  const _EncabezadoDetalle(
      {required this.deviceProfile, required this.request});
  final PerfilDispositivo? deviceProfile;
  final SolicitudVerificacion request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      color: isDark ? const Color(0xFF161E2C) : const Color(0xFFF8FAFC),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(Icons.person_outline_rounded,
                color: theme.colorScheme.primary, size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceProfile?.adminDisplayLabel ?? 'Usuario desconocido',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'ID: ${request.deviceId}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(99),
            ),
            child: const Text(
              'PENDIENTE',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.primary,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _GrillaInfoDetalle extends StatelessWidget {
  const _GrillaInfoDetalle({required this.request});
  final SolicitudVerificacion request;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Wrap(
        spacing: 24,
        runSpacing: 20,
        children: [
          _InfoItem(label: 'Materia', value: request.matterName, width: 200),
          _InfoItem(label: 'Carrera', value: request.careerId, width: 150),
          _InfoItem(
              label: 'Fecha de envío',
              value: _formatDateTime(request.createdAt),
              width: 180),
        ],
      );
    });
  }

  String _formatDateTime(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem(
      {required this.label, required this.value, required this.width});
  final String label;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  theme.textTheme.labelSmall?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, _, _) => const Center(
          child:
              Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey),
        ),
      ),
    );
  }
}

class _BarraAcciones extends StatelessWidget {
  const _BarraAcciones(
      {required this.busy, required this.onApprove, required this.onReject});
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2C) : const Color(0xFFF8FAFC),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: busy ? null : onReject,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
            ),
            child: const Text('RECHAZAR SOLICITUD',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: busy ? null : onApprove,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            ),
            child: Text(busy ? 'PROCESANDO...' : 'APROBAR VERIFICACIÓN',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _MobileRequestItem extends ConsumerStatefulWidget {
  const _MobileRequestItem({
    required this.request,
    required this.adminDeviceId,
    this.deviceProfile,
  });

  final SolicitudVerificacion request;
  final String adminDeviceId;
  final PerfilDispositivo? deviceProfile;

  @override
  ConsumerState<_MobileRequestItem> createState() => _MobileRequestItemState();
}

class _MobileRequestItemState extends ConsumerState<_MobileRequestItem> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return TarjetaSolicitudVerificacion(
      request: widget.request,
      showDevice: true,
      deviceProfile: widget.deviceProfile,
      onApprove: _busy ? null : _approve,
      onReject: _busy ? null : _reject,
    );
  }

  Future<void> _approve() async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioVerificacion);
      await repo.approveRequest(
        client: client,
        request: widget.request,
        adminDeviceId: widget.adminDeviceId,
      );
      ref.invalidate(proveedorSolicitudesVerificacionPendientes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;
    setState(() => _busy = true);
    try {
      final repo = ref.read(proveedorRepositorioVerificacion);
      await repo.rejectRequest(
        client: client,
        requestId: widget.request.id,
        adminDeviceId: widget.adminDeviceId,
      );
      ref.invalidate(proveedorSolicitudesVerificacionPendientes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
          Text(title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: theme.hintColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
