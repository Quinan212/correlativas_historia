import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_matter_navigation_providers.dart';
import 'admin_matter_navigation_user_screen.dart';

class AdminMatterNavigationScreen extends ConsumerWidget {
  const AdminMatterNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overviewAsync = ref.watch(adminMatterNavigationOverviewProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF030712) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Recorrido de materias'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () =>
                ref.invalidate(adminMatterNavigationOverviewProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
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
                  overview.events
                      .where((e) => _isSameMonth(e.createdAt, today)),
                );
                final allViews = _topMatterCounts(overview.events);
                final viewEvents = overview.events
                    .where((event) => event.eventType == 'view')
                    .toList(
                      growable: false,
                    );

                final padding = isDesktop
                    ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
                    : const EdgeInsets.fromLTRB(16, 12, 16, 24);

                if (isDesktop) {
                  return _AdminMatterNavigationDesktop(
                    overview: overview,
                    todayViews: todayViews,
                    monthViews: monthViews,
                    allViews: allViews,
                    viewEvents: viewEvents,
                    padding: padding,
                  );
                }

                return ListView(
                  padding: padding,
                  children: [
                    _SummaryCard(
                      totalEvents: overview.events.length,
                      totalViews: overview.events
                          .where((e) => e.eventType == 'view')
                          .length,
                      totalTransitions: overview.events
                          .where((e) => e.eventType != 'view')
                          .length,
                      totalUsers: overview.deviceSummaries.length,
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: 'Usuarios',
                      child: Column(
                        children: overview.deviceSummaries
                            .map(
                              (device) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _UserTile(
                                  device: device,
                                  onTap: () => _navigateToUser(context, device),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RankSection(
                      title: 'Más vistas hoy',
                      emptyLabel: 'Hoy todavía no hubo visitas.',
                      items: todayViews,
                    ),
                    const SizedBox(height: 24),
                    _RankSection(
                      title: 'Más vistas este mes',
                      emptyLabel: 'Este mes todavía no hubo visitas.',
                      items: monthViews,
                    ),
                    const SizedBox(height: 24),
                    _RankSection(
                      title: 'Ranking histórico',
                      emptyLabel: 'Sin vistas registradas.',
                      items: allViews,
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: 'Actividad reciente',
                      child: viewEvents.isEmpty
                          ? const Text('Sin actividad reciente.')
                          : SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: viewEvents.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (context, index) => SizedBox(
                                  width: 280,
                                  child: _EventTile(event: viewEvents[index]),
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _EmptyState(
                title: 'Error de carga',
                subtitle: '$error',
                icon: Icons.error_outline_rounded,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToUser(
      BuildContext context, AdminMatterNavigationDeviceSummary device) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminMatterNavigationUserScreen(
          deviceId: device.deviceId,
          deviceLabel: device.label,
        ),
      ),
    );
  }
}

class _AdminMatterNavigationDesktop extends StatelessWidget {
  const _AdminMatterNavigationDesktop({
    required this.overview,
    required this.todayViews,
    required this.monthViews,
    required this.allViews,
    required this.viewEvents,
    required this.padding,
  });

  final AdminMatterNavigationOverview overview;
  final List<_MatterRankItem> todayViews;
  final List<_MatterRankItem> monthViews;
  final List<_MatterRankItem> allViews;
  final List<AdminMatterNavigationEvent> viewEvents;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: [
        _SummaryCard(
          totalEvents: overview.events.length,
          totalViews:
              overview.events.where((e) => e.eventType == 'view').length,
          totalTransitions:
              overview.events.where((e) => e.eventType != 'view').length,
          totalUsers: overview.deviceSummaries.length,
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Usuarios Activos',
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: overview.deviceSummaries.length,
                      itemBuilder: (context, index) {
                        final device = overview.deviceSummaries[index];
                        return _UserTile(
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
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'Actividad Reciente',
                    child: viewEvents.isEmpty
                        ? const Text('Sin actividad reciente.')
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3.2,
                            ),
                            itemCount: viewEvents.length.clamp(0, 10),
                            itemBuilder: (context, index) =>
                                _EventTile(event: viewEvents[index]),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _RankSection(
                    title: 'Tendencia Hoy',
                    emptyLabel: 'Sin visitas hoy.',
                    items: todayViews.take(5).toList(),
                  ),
                  const SizedBox(height: 24),
                  _RankSection(
                    title: 'Top Mensual',
                    emptyLabel: 'Sin visitas este mes.',
                    items: monthViews.take(5).toList(),
                  ),
                  const SizedBox(height: 24),
                  _RankSection(
                    title: 'Histórico Global',
                    emptyLabel: 'Sin datos registrados.',
                    items: allViews.take(5).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métricas de Navegación',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(
                  label: 'Total Eventos',
                  value: '$totalEvents',
                  icon: Icons.analytics_rounded),
              _Metric(
                  label: 'Vistas Materia',
                  value: '$totalViews',
                  icon: Icons.visibility_rounded),
              _Metric(
                  label: 'Saltos/Filtros',
                  value: '$totalTransitions',
                  icon: Icons.navigation_rounded),
              _Metric(
                  label: 'Usuarios Únicos',
                  value: '$totalUsers',
                  icon: Icons.people_alt_rounded),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900)),
              Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.hintColor)),
            ],
          ),
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
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(emptyLabel),
            )
          : Column(
              children: items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MatterRankTile(item: item),
                      ))
                  .toList(),
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

List<_MatterRankItem> _topMatterCounts(
    Iterable<AdminMatterNavigationEvent> events) {
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
  }).toList();
  items.sort((a, b) => b.count.compareTo(a.count));
  return items;
}

class _MatterRankTile extends StatelessWidget {
  const _MatterRankTile({required this.item});
  final _MatterRankItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(item.matterName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${item.count}',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary)),
          ),
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
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161E2C) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(event.matterName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(_formatHourMinute(event.createdAt),
              style: theme.textTheme.bodySmall),
        ],
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
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.device, required this.onTap});
  final AdminMatterNavigationDeviceSummary device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF161E2C) : const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Text(_initials(device.label),
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text('${device.views} vistas',
                        style: theme.textTheme.bodySmall),
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
  final parts = label.trim().split(RegExp(r'\s+'));
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
  const _EmptyState(
      {required this.title, required this.subtitle, required this.icon});
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
