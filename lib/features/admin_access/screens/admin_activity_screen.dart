import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_access_providers.dart';

class AdminActivityScreen extends ConsumerWidget {
  const AdminActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final observedDevicesAsync = ref.watch(adminObservedDevicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividad reciente'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminObservedDevicesProvider),
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
              title: 'Dispositivos activos',
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
            child: Text(
              '${device.deviceId}\n\n$status\n${device.notes ?? ''}',
              style: theme.textTheme.bodyMedium,
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

String _formatRelativeSeen(DateTime? value) {
  if (value == null) return 'Sin actividad reciente';

  final now = DateTime.now().toUtc();
  final diff = now.difference(value.toUtc());

  if (diff.inMinutes <= 1) return 'Conectado recién';
  if (diff.inMinutes < 60) return 'Conectado hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Conectado hace ${diff.inHours} h';
  return 'Conectado hace ${diff.inDays} días';
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
  if (cleaned.toLowerCase() == 'undefined' || cleaned.toLowerCase() == 'null') {
    return 'Dispositivo';
  }
  final withoutActual =
      cleaned.replaceAll(RegExp(r'\s+actual$', caseSensitive: false), '');
  return withoutActual.isEmpty ? cleaned : withoutActual;
}
