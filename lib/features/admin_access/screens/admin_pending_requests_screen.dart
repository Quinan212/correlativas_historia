import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../../verification/models/verification_request.dart';
import '../../verification/providers/verification_providers.dart';
import '../../verification/widgets/verification_request_card.dart';

class AdminPendingRequestsScreen extends ConsumerWidget {
  const AdminPendingRequestsScreen({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pendingAsync = ref.watch(pendingVerificationRequestsProvider);
    final pendingIds = pendingAsync.valueOrNull?.map((e) => e.deviceId) ??
        const Iterable<String>.empty();
    final profileMapAsync = ref.watch(
      deviceProfilesByIdsProvider(
        serializeDeviceIds([...pendingIds]),
      ),
    );
    final profileMap =
        profileMapAsync.valueOrNull ?? const <String, DeviceProfile>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes pendientes'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(pendingVerificationRequestsProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: 'Verificaciones en revisión',
              child: pendingAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'No hay solicitudes pendientes en este momento.',
                      style: theme.textTheme.bodyLarge,
                    );
                  }

                  return Column(
                    children: items
                        .map(
                          (item) => _PendingRequestActions(
                            request: item,
                            adminDeviceId: adminDeviceId,
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

class _PendingRequestActionsState
    extends ConsumerState<_PendingRequestActions> {
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
