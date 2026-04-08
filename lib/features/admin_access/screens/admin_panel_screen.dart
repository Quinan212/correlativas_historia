import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/admin_access_providers.dart';
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
    final observedDevicesAsync = ref.watch(adminObservedDevicesProvider);
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
      appBar: AppBar(title: const Text('Panel de revision')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _HeaderCard(adminLabel: adminLabel),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Actividad reciente en dispositivos activos',
              child: observedDevicesAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Text(
                      'Por ahora no aparece actividad reciente en dispositivos activos.',
                      style: theme.textTheme.bodyLarge,
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      final bubbleWidth =
                          (constraints.maxWidth - (spacing * 2)) / 3;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: items
                            .map(
                              (item) => SizedBox(
                                width: bubbleWidth,
                                child: _ObservedDeviceBubble(device: item),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (error, _) => Text(
                  'No se pudo leer la actividad reciente: $error',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _BulkCleanupSection(
              adminDeviceId: deviceId,
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Solicitudes pendientes',
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
          ],
        ),
      ),
    );
  }
}

class _ObservedDeviceBubble extends StatelessWidget {
  const _ObservedDeviceBubble({
    required this.device,
  });

  final AdminObservedDevice device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final online = _isConsideredOnline(device.lastSeenAt);
    final displayLabel = _normalizeDeviceLabel(device.label);
    final initials = _buildInitials(displayLabel);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.30),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: online
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF64748B),
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2.4,
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

  void _openDetails(BuildContext context) {
    final theme = Theme.of(context);
    final online = _isConsideredOnline(device.lastSeenAt);
    final status = online ? 'En linea' : _formatRelativeSeen(device.lastSeenAt);
    final displayLabel = _normalizeDeviceLabel(device.label);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(displayLabel),
          content: SizedBox(
            width: 440,
            child: FutureBuilder<_DeviceDetailData>(
              future: _loadDeviceDetailData(device.deviceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.6),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                      'No se pudo cargar el detalle: ${snapshot.error}');
                }

                final data = snapshot.data ?? const _DeviceDetailData.empty();
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: online
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Device: ${device.deviceId}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (device.notes != null && device.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(device.notes!, style: theme.textTheme.bodySmall),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        'Materias habilitadas (${data.enabledMatterNames.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (data.enabledMatterNames.isEmpty)
                        Text(
                          'Sin materias habilitadas por ahora.',
                          style: theme.textTheme.bodySmall,
                        )
                      else
                        ...data.enabledMatterNames.take(20).map(
                              (name) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text('- $name',
                                    style: theme.textTheme.bodySmall),
                              ),
                            ),
                      const SizedBox(height: 14),
                      Text(
                        'Historial de verificaciones (${data.verificationHistory.length})',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (data.verificationHistory.isEmpty)
                        Text(
                          'Sin verificaciones registradas.',
                          style: theme.textTheme.bodySmall,
                        )
                      else
                        ...data.verificationHistory.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '- ${item.matterName} (${item.statusLabel})',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
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

class _BulkCleanupSection extends ConsumerStatefulWidget {
  const _BulkCleanupSection({
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<_BulkCleanupSection> createState() =>
      _BulkCleanupSectionState();
}

class _BulkCleanupSectionState extends ConsumerState<_BulkCleanupSection> {
  String? _runningAction;
  final Set<String> _selectedActions = <String>{};

  static const List<_CleanupOption> _options = [
    _CleanupOption(
      action: 'clear_matter_reviews',
      title: 'Referencias de materias',
      description: 'Borra todas las referencias de materias.',
      confirmation:
          'Se van a borrar todas las referencias de materias. Esta accion no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_teacher_reviews',
      title: 'Referencias de docentes',
      description: 'Borra todas las referencias de docentes.',
      confirmation:
          'Se van a borrar todas las referencias de docentes. Esta accion no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_photos',
      title: 'Fotos comunitarias',
      description: 'Borra fotos y archivos de comunidad.',
      confirmation:
          'Se van a borrar todas las fotos comunitarias y sus archivos. Esta accion no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_verifications',
      title: 'Verificaciones y permisos',
      description: 'Borra verificaciones y permisos asociados.',
      confirmation:
          'Se van a borrar verificaciones y permisos vinculados. Esta accion no se puede deshacer.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      title: 'Limpieza y reinicio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elige una o varias opciones para limpiar. Tambien puedes ejecutar cada opcion de forma individual con el icono de basura.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ..._options.map(
            (option) => _CleanupChoiceTile(
              option: option,
              selected: _selectedActions.contains(option.action),
              busy: _runningAction == option.action,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedActions.add(option.action);
                  } else {
                    _selectedActions.remove(option.action);
                  }
                });
              },
              onDeletePressed: () => _runSingleAction(option),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _selectedActions.isEmpty || _runningAction != null
                      ? null
                      : _runSelectedActions,
                  child: const Text('Ejecutar seleccion'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _runningAction != null ? null : _runResetAll,
                  style: FilledButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                  ),
                  child: const Text('Reiniciar todo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _runSingleAction(_CleanupOption option) async {
    await _runAction(
      action: option.action,
      title: option.title,
      confirmation: option.confirmation,
    );
  }

  Future<void> _runSelectedActions() async {
    final selected = _options
        .where((option) => _selectedActions.contains(option.action))
        .toList(growable: false);
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar seleccion'),
            content: Text(
              'Se van a ejecutar ${selected.length} acciones de limpieza. Esta accion no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    for (final option in selected) {
      await _runAction(
        action: option.action,
        title: option.title,
        confirmation: option.confirmation,
        askConfirmation: false,
      );
    }

    if (mounted) {
      setState(() => _selectedActions.clear());
    }
  }

  Future<void> _runResetAll() async {
    await _runAction(
      action: 'reset_all',
      title: 'Reiniciar todo',
      confirmation:
          'Se va a borrar todo: referencias de materias, referencias de docentes, fotos, verificaciones y permisos. Esta accion no se puede deshacer.',
    );
  }

  Future<void> _runAction({
    required String action,
    required String title,
    required String confirmation,
    bool askConfirmation = true,
  }) async {
    if (askConfirmation) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(confirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmed) return;
    }

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _runningAction = action);
    try {
      final repo = ref.read(adminBulkCleanupRepositoryProvider);
      final result = await repo.runAction(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        action: action,
      );

      ref.invalidate(pendingVerificationRequestsProvider);
      ref.invalidate(reviewedVerificationRequestsProvider);
      ref.invalidate(ownVerificationRequestsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_summarizeCleanupResult(result.summary)),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo completar la limpieza: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _runningAction = null);
      }
    }
  }
}

class _CleanupChoiceTile extends StatelessWidget {
  const _CleanupChoiceTile({
    required this.option,
    required this.selected,
    required this.busy,
    required this.onChanged,
    required this.onDeletePressed,
  });

  final _CleanupOption option;
  final bool selected;
  final bool busy;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: busy ? null : onChanged,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.3),
                )
              : IconButton(
                  onPressed: onDeletePressed,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFB91C1C),
                  tooltip: 'Borrar solo esta opcion',
                ),
        ],
      ),
    );
  }
}

class _CleanupOption {
  const _CleanupOption({
    required this.action,
    required this.title,
    required this.description,
    required this.confirmation,
  });

  final String action;
  final String title;
  final String description;
  final String confirmation;
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    this.adminLabel,
  });

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
            'Tareas de revision',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            adminLabel == null || adminLabel!.isEmpty
                ? 'Desde este panel podes acompanar solicitudes, ordenar referencias y seguir la actividad reciente.'
                : 'Equipo admin: $adminLabel',
            style: theme.textTheme.bodyLarge,
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

String _formatRelativeSeen(DateTime? value) {
  if (value == null) return 'Sin actividad reciente';

  final now = DateTime.now().toUtc();
  final diff = now.difference(value.toUtc());

  if (diff.inMinutes <= 1) return 'Conectado recien';
  if (diff.inMinutes < 60) return 'Conectado hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Conectado hace ${diff.inHours} h';
  return 'Conectado hace ${diff.inDays} dias';
}

String _summarizeCleanupResult(Map<String, dynamic> summary) {
  final matterReviews = (summary['matter_reviews_deleted'] ?? 0).toString();
  final teacherReviews = (summary['teacher_reviews_deleted'] ?? 0).toString();
  final photos = (summary['photos_deleted'] ?? 0).toString();
  final verifications =
      (summary['verification_requests_deleted'] ?? 0).toString();
  final permissions =
      (summary['verification_permissions_deleted'] ?? 0).toString();

  return 'Listo. Materias: $matterReviews, docentes: $teacherReviews, fotos: $photos, verificaciones: $verifications, permisos: $permissions.';
}

bool _isConsideredOnline(DateTime? value) {
  if (value == null) return false;
  final now = DateTime.now().toUtc();
  final diff = now.difference(value.toUtc());
  return diff.inMinutes <= 2;
}

String _buildInitials(String label) {
  final parts = label
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _normalizeDeviceLabel(String label) {
  final cleaned = label.trim();
  if (cleaned.isEmpty) return 'Dispositivo';
  final withoutActual =
      cleaned.replaceAll(RegExp(r'\s+actual$', caseSensitive: false), '');
  return withoutActual.isEmpty ? cleaned : withoutActual;
}

Future<_DeviceDetailData> _loadDeviceDetailData(String deviceId) async {
  final client = Supabase.instance.client;

  final matterRows = await client
      .from('device_subject_permissions')
      .select('matter_name')
      .eq('device_id', deviceId)
      .order('matter_name');

  final verificationRows = await client
      .from('verification_requests')
      .select('matter_name, status, updated_at')
      .eq('device_id', deviceId)
      .order('updated_at', ascending: false)
      .limit(20);

  final matterNames = matterRows
      .cast<Map<String, dynamic>>()
      .map((row) => (row['matter_name'] ?? '').toString().trim())
      .where((name) => name.isNotEmpty)
      .toList(growable: false);

  final history = verificationRows
      .cast<Map<String, dynamic>>()
      .map(
        (row) => _DeviceVerificationItem(
          matterName: (row['matter_name'] ?? '').toString().trim(),
          status: (row['status'] ?? '').toString().trim(),
        ),
      )
      .where((item) => item.matterName.isNotEmpty)
      .toList(growable: false);

  return _DeviceDetailData(
    enabledMatterNames: matterNames,
    verificationHistory: history,
  );
}

class _DeviceDetailData {
  const _DeviceDetailData({
    required this.enabledMatterNames,
    required this.verificationHistory,
  });

  const _DeviceDetailData.empty()
      : enabledMatterNames = const <String>[],
        verificationHistory = const <_DeviceVerificationItem>[];

  final List<String> enabledMatterNames;
  final List<_DeviceVerificationItem> verificationHistory;
}

class _DeviceVerificationItem {
  const _DeviceVerificationItem({
    required this.matterName,
    required this.status,
  });

  final String matterName;
  final String status;

  String get statusLabel {
    switch (status) {
      case 'approved':
        return 'aprobada';
      case 'rejected':
        return 'rechazada';
      case 'pending':
      default:
        return 'pendiente';
    }
  }
}
