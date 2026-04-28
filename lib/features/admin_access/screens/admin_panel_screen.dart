import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_activity_screen.dart';
import 'admin_cleanup_screen.dart';
import 'admin_exam_events_screen.dart';
import 'admin_exam_navigation_screen.dart';
import 'admin_matter_photos_screen.dart';
import 'admin_matter_navigation_screen.dart';
import 'admin_pending_requests_screen.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de admin')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeaderCard(adminLabel: adminLabel),
            const SizedBox(height: 14),
            _EntryCard(
              icon: Icons.bolt_rounded,
              title: 'Actividad reciente',
              subtitle: 'Ver dispositivos activos y revisar su detalle.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminActivityScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.cleaning_services_rounded,
              title: 'Limpieza y reinicio',
              subtitle: 'Ejecutar acciones de limpieza o reinicio global.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdminCleanupScreen(
                      adminDeviceId: deviceId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.inbox_rounded,
              title: 'Solicitudes pendientes',
              subtitle: 'Aprobar o rechazar verificaciones en revisión.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdminPendingRequestsScreen(
                      adminDeviceId: deviceId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.photo_library_outlined,
              title: 'Fotos por carrera',
              subtitle:
                  'Ver cuántas fotos hay por carrera, año y materia sin mostrar vacíos.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminMatterPhotosScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.timeline_rounded,
              title: 'Recorrido de navegación',
              subtitle:
                  'Ver el historial general por día, mes, total y por usuario.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminMatterNavigationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.school_rounded,
              title: 'Recorrido de examenes',
              subtitle:
                  'Ver el historial de aperturas y cambios dentro de examenes.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AdminExamNavigationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.event_note_rounded,
              title: 'Mesas y coloquios',
              subtitle: 'Administrar el calendario de exámenes.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AdminExamEventsScreen(
                      adminDeviceId: deviceId,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Este panel ahora solo organiza accesos. Cada tarea vive en su propia pantalla para que sea más claro navegar y operar.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
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
            'Panel de administración',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            adminLabel == null || adminLabel!.isEmpty
                ? 'Elegí una tarea para abrir su pantalla específica.'
                : 'Equipo admin: $adminLabel',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF0B1220) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodyMedium),
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
