import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_matter_navigation_providers.dart';

class AdminMatterNavigationUserScreen extends ConsumerWidget {
  const AdminMatterNavigationUserScreen({
    super.key,
    required this.deviceId,
    required this.deviceLabel,
  });

  final String deviceId;
  final String deviceLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(adminMatterNavigationEventsByDeviceProvider(deviceId));

    return Scaffold(
      appBar: AppBar(
        title: Text(deviceLabel),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(adminMatterNavigationOverviewProvider),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: SafeArea(
        child: events.isEmpty
            ? _EmptyState(
                title: 'Aún no hay navegación registrada',
                subtitle:
                    'Cuando este dispositivo abra materias o salte entre correlativas, acá vas a ver el historial completo.',
                icon: Icons.person_search_rounded,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _SummaryCard(events: events),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: 'Línea de tiempo',
                    child: Column(
                      children: events
                          .map(
                            (event) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TimelineTile(event: event),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.events});

  final List<AdminMatterNavigationEvent> events;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final views = events.where((e) => e.eventType == 'view').length;
    final transitions = events.where((e) => e.eventType != 'view').length;
    final distinctMatters = events
        .where((e) => e.eventType == 'view')
        .map((e) => e.matterId)
        .toSet()
        .length;

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
          _Metric(label: 'Vistas', value: '$views'),
          _Metric(label: 'Saltos', value: '$transitions'),
          _Metric(label: 'Materias únicas', value: '$distinctMatters'),
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
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
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

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event});

  final AdminMatterNavigationEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isView = event.eventType == 'view';
    final icon = isView ? Icons.visibility_outlined : Icons.alt_route_rounded;
    final title = isView ? 'Abrió' : 'Saltó a';
    final sourceText = event.sourceMatterName == null
        ? ''
        : ' desde ${event.sourceMatterName}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title ${event.matterName}$sourceText',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatHourMinute(event.createdAt),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatHourMinute(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

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

