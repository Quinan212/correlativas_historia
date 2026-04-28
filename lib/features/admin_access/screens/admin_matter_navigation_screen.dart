import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../providers/admin_matter_navigation_providers.dart';
import 'admin_matter_navigation_user_screen.dart';

class AdminMatterNavigationScreen extends ConsumerWidget {
  const AdminMatterNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(adminMatterNavigationOverviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recorrido de materias'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminMatterNavigationOverviewProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: overviewAsync.when(
          data: (overview) {
            if (overview.events.isEmpty) {
              return _EmptyState(
                title: 'Todavía no hay visitas registradas',
                subtitle:
                    'Cuando los usuarios naveguen por materias y correlativas, acá vas a ver el historial por día, mes y total.',
                icon: Icons.timeline_rounded,
              );
            }

            final today = DateTime.now();
            final todayViews = _topMatterCounts(
              overview.events.where((e) => _isSameDay(e.createdAt, today)),
            );
            final monthViews = _topMatterCounts(
              overview.events.where((e) => _isSameMonth(e.createdAt, today)),
            );
            final allViews = _topMatterCounts(overview.events);
            final viewEvents =
                overview.events.where((event) => event.eventType == 'view').toList(
                      growable: false,
                    );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _SummaryCard(
                  totalEvents: overview.events.length,
                  totalViews:
                      overview.events.where((e) => e.eventType == 'view').length,
                  totalTransitions:
                      overview.events.where((e) => e.eventType != 'view').length,
                  totalUsers: overview.deviceSummaries.length,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Usuarios',
                  child: Column(
                    children: overview.deviceSummaries
                        .map(
                          (device) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _UserTile(
                              device: device,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => AdminMatterNavigationUserScreen(
                                      deviceId: device.deviceId,
                                      deviceLabel: device.label,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 14),
                _RankSection(
                  title: 'Más vistas hoy',
                  emptyLabel: 'Hoy todavía no hubo visitas a materias.',
                  items: todayViews,
                ),
                const SizedBox(height: 14),
                _RankSection(
                  title: 'Más vistas este mes',
                  emptyLabel: 'Este mes todavía no hubo visitas a materias.',
                  items: monthViews,
                ),
                const SizedBox(height: 14),
                _RankSection(
                  title: 'Más vistas históricamente',
                  emptyLabel:
                      'Todavía no hay suficientes vistas para armar un ranking.',
                  items: allViews,
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Todas las vistas',
                  child: viewEvents.isEmpty
                      ? Text(
                          'Todavía no hay vistas registradas.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: viewEvents
                                .map(
                                  (event) => Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: SizedBox(
                                      width: 320,
                                      child: _EventTile(event: event),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _EmptyState(
            title: 'No se pudo cargar el recorrido',
            subtitle: '$error',
            icon: Icons.error_outline_rounded,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalEvents,
    required this.totalViews,
    required this.totalTransitions,
    required this.totalUsers,
  });

  final int totalEvents;
  final int totalViews;
  final int totalTransitions;
  final int totalUsers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _Metric(label: 'Eventos', value: '$totalEvents'),
          _Metric(label: 'Vistas', value: '$totalViews'),
          _Metric(label: 'Saltos', value: '$totalTransitions'),
          _Metric(label: 'Usuarios', value: '$totalUsers'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RankSection extends StatelessWidget {
  const _RankSection({
    required this.title,
    required this.emptyLabel,
    required this.items,
  });

  final String title;
  final String emptyLabel;
  final List<_MatterRankItem> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: items.isEmpty
          ? Text(emptyLabel, style: Theme.of(context).textTheme.bodyLarge)
          : Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MatterRankTile(item: item),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _MatterRankItem {
  const _MatterRankItem({
    required this.matterId,
    required this.matterName,
    required this.careerId,
    required this.count,
  });

  final String matterId;
  final String matterName;
  final String careerId;
  final int count;
}

List<_MatterRankItem> _topMatterCounts(Iterable<AdminMatterNavigationEvent> events) {
  final byMatter = <String, _MatterRankItem>{};
  final counts = <String, int>{};
  for (final event in events) {
    if (event.eventType != 'view') continue;
    final key = event.matterId;
    counts[key] = (counts[key] ?? 0) + 1;
    byMatter.putIfAbsent(
      key,
      () => _MatterRankItem(
        matterId: event.matterId,
        matterName: event.matterName,
        careerId: event.careerId,
        count: 0,
      ),
    );
  }

  final items = counts.entries.map((entry) {
    final base = byMatter[entry.key]!;
    return _MatterRankItem(
      matterId: base.matterId,
      matterName: base.matterName,
      careerId: base.careerId,
      count: entry.value,
    );
  }).toList(growable: false);

  items.sort((a, b) {
    final byCount = b.count.compareTo(a.count);
    if (byCount != 0) return byCount;
    return a.matterName.compareTo(b.matterName);
  });
  return items;
}

class _MatterRankTile extends StatelessWidget {
  const _MatterRankTile({required this.item});

  final _MatterRankItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final career = kCareers.firstWhere(
      (c) => c.id == item.careerId,
      orElse: () => kCareers.first,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.matterName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  career.nombre,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Badge(label: '${item.count}'),
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final AdminMatterNavigationEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTransition = event.eventType != 'view';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Badge(label: isTransition ? 'salto' : 'vista'),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.matterName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatHourMinute(event.createdAt),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

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

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.device,
    required this.onTap,
  });

  final AdminMatterNavigationDeviceSummary device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
                child: Text(
                  _initials(device.label),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${device.views} vistas • ${device.transitions} saltos',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

String _initials(String label) {
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

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

String _formatHourMinute(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}


