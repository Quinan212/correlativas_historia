import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../../verification/models/verification_request.dart';
import '../../verification/providers/verification_providers.dart';
import '../../verification/widgets/verification_request_card.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({
    super.key,
    required this.deviceId,
    this.adminLabel,
  });

  final String deviceId;
  final String? adminLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pendingAsync = ref.watch(pendingVerificationRequestsProvider);
    final reviewedAsync = ref.watch(reviewedVerificationRequestsProvider);
    final pendingIds = pendingAsync.valueOrNull?.map((e) => e.deviceId) ??
        const Iterable<String>.empty();
    final reviewedIds = reviewedAsync.valueOrNull?.map((e) => e.deviceId) ??
        const Iterable<String>.empty();
    final profileMapAsync = ref.watch(
      deviceProfilesByIdsProvider(
        serializeDeviceIds([...pendingIds, ...reviewedIds]),
      ),
    );
    final profileMap = profileMapAsync.valueOrNull ??
        const <String, DeviceProfile>{};

    return Scaffold(
      appBar: AppBar(title: const Text('Panel admin')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderCard(
              deviceId: deviceId,
              adminLabel: adminLabel,
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Solicitudes pendientes',
              child: pendingAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'No hay solicitudes pendientes ahora mismo.',
                      style: theme.textTheme.bodyLarge,
                    );
                  }

                  return Column(
                    children: items
                        .map(
                          (item) => _PendingRequestActions(
                            request: item,
                            adminDeviceId: deviceId,
                            deviceProfile: profileMap[item.deviceId],
                          ),
                        )
                        .toList(growable: false),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (error, _) => Text(
                  'No se pudieron cargar las solicitudes: $error',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Últimas revisadas',
              child: reviewedAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'Todavía no revisaste ninguna solicitud.',
                      style: theme.textTheme.bodyLarge,
                    );
                  }

                  return Column(
                    children: items
                        .take(8)
                        .map(
                          (item) => VerificationRequestCard(
                            request: item,
                            showDevice: true,
                            deviceProfile: profileMap[item.deviceId],
                          ),
                        )
                        .toList(growable: false),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (error, _) => Text(
                  'No se pudieron cargar las revisadas: $error',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestActions extends ConsumerStatefulWidget {
  const _PendingRequestActions({
    required this.request,
    required this.adminDeviceId,
    this.deviceProfile,
  });

  final VerificationRequest request;
  final String adminDeviceId;
  final DeviceProfile? deviceProfile;

  @override
  ConsumerState<_PendingRequestActions> createState() =>
      _PendingRequestActionsState();
}

class _PendingRequestActionsState extends ConsumerState<_PendingRequestActions> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return VerificationRequestCard(
      request: widget.request,
      showDevice: true,
      deviceProfile: widget.deviceProfile,
      onApprove: _busy ? null : _approve,
      onReject: _busy ? null : _reject,
    );
  }

  Future<void> _approve() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);
      await repo.approveRequest(
        client: client,
        request: widget.request,
        adminDeviceId: widget.adminDeviceId,
      );

      ref.invalidate(pendingVerificationRequestsProvider);
      ref.invalidate(ownVerificationRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud aprobada')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo aprobar: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _reject() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);
      await repo.rejectRequest(
        client: client,
        requestId: widget.request.id,
        adminDeviceId: widget.adminDeviceId,
      );

      ref.invalidate(pendingVerificationRequestsProvider);
      ref.invalidate(ownVerificationRequestsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitud rechazada')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo rechazar: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.deviceId,
    this.adminLabel,
  });

  final String deviceId;
  final String? adminLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Administrador activo',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            adminLabel == null || adminLabel!.isEmpty
                ? 'Este dispositivo puede revisar solicitudes pendientes.'
                : 'Etiqueta admin: $adminLabel',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          SelectableText(
            deviceId,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                  color: Colors.black.withValues(alpha: 0.05),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
