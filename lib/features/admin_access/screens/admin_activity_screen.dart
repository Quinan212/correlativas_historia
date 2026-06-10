import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_access_providers.dart';

class AdminActivityScreen extends ConsumerWidget {
  const AdminActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final observedDevicesAsync = ref.watch(adminObservedDevicesProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF030712) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Actividad reciente'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminObservedDevicesProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: observedDevicesAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(
                    title: 'Sin actividad reciente',
                    subtitle:
                        'Por ahora no aparece actividad en dispositivos activos.',
                    icon: Icons.history_rounded,
                  );
                }

                return ListView(
                  padding: isDesktop
                      ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
                      : const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    _HeaderStats(totalDevices: items.length),
                    const SizedBox(height: 24),
                    if (isDesktop)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return _ObservedDeviceCard(device: items[index]);
                        },
                      )
                    else
                      Column(
                        children: items
                            .map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ObservedDeviceCard(device: item),
                                ))
                            .toList(),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _EmptyState(
                title: 'Error al cargar',
                subtitle: error.toString(),
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  const _HeaderStats({required this.totalDevices});
  final int totalDevices;

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
            'Resumen de actividad',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Se detectaron $totalDevices dispositivos con actividad en las últimas 24 horas.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservedDeviceCard extends StatelessWidget {
  const _ObservedDeviceCard({required this.device});
  final AdminObservedDevice device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final online = _isConsideredOnline(device.lastSeenAt);
    final displayLabel = _normalizeDeviceLabel(device.label);
    final initials = _buildInitials(displayLabel);

    return Material(
      color: isDark ? const Color(0xFF0B1220) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _openDetails(context),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.25),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: online
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8),
                        border: Border.all(
                          color:
                              isDark ? const Color(0xFF0B1220) : Colors.white,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                displayLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                online ? 'En línea' : _formatRelativeSeen(device.lastSeenAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: online
                      ? const Color(0xFF16A34A)
                      : theme.hintColor,
                  fontWeight: online ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayLabel = _normalizeDeviceLabel(device.label);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(displayLabel,
            style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'ID Dispositivo', value: device.deviceId),
              const SizedBox(height: 12),
              _DetailRow(
                  label: 'Última conexión',
                  value: _formatFullDate(device.lastSeenAt)),
              if (device.notes != null && device.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailRow(label: 'Notas', value: device.notes!),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: theme.hintColor)),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
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
              style:
                  theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

String _formatRelativeSeen(DateTime? value) {
  if (value == null) return 'Sin actividad';
  final now = DateTime.now().toUtc();
  final diff = now.difference(value.toUtc());
  if (diff.inMinutes <= 1) return 'Recién';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  return 'Hace ${diff.inDays} d';
}

String _formatFullDate(DateTime? value) {
  if (value == null) return 'N/A';
  final d = value.day.toString().padLeft(2, '0');
  final m = value.month.toString().padLeft(2, '0');
  final y = value.year;
  final h = value.hour.toString().padLeft(2, '0');
  final min = value.minute.toString().padLeft(2, '0');
  return '$d/$m/$y $h:$min';
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
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _normalizeDeviceLabel(String label) {
  final cleaned = label.trim();
  if (cleaned.isEmpty ||
      cleaned.toLowerCase() == 'undefined' ||
      cleaned.toLowerCase() == 'null') {
    return 'Equipo técnico';
  }
  return cleaned.replaceAll(RegExp(r'\s+actual$', caseSensitive: false), '');
}
