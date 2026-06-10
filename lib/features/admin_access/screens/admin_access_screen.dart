import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../verification/screens/verification_device_screen.dart';
import '../../verification/screens/verification_requests_screen.dart';
import '../../verification/screens/verification_submit_screen.dart';
import '../providers/admin_access_providers.dart';
import 'admin_activity_screen.dart';
import 'admin_cleanup_screen.dart';
import 'admin_exam_events_screen.dart';
import 'admin_exam_navigation_screen.dart';
import 'admin_matter_navigation_screen.dart';
import 'admin_matter_photos_screen.dart';
import 'admin_pending_requests_screen.dart';
import 'admin_students_screen.dart';

class AdminAccessScreen extends ConsumerStatefulWidget {
  const AdminAccessScreen({
    super.key,
    this.initialCareerId,
    this.initialMatterId,
    this.lockMatterSelection = false,
  });

  final String? initialCareerId;
  final String? initialMatterId;
  final bool lockMatterSelection;

  @override
  ConsumerState<AdminAccessScreen> createState() => _AdminAccessScreenState();
}

class _AdminAccessScreenState extends ConsumerState<AdminAccessScreen> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final adminAsync = ref.watch(adminDeviceStatusProvider);

    final verificationEntries = [
      _HubEntryData(
        icon: Icons.cloud_upload_rounded,
        title: 'Enviar verificación',
        subtitle:
            'Subí una captura, elegí materia y mandá la solicitud desde su pantalla dedicada.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => VerificationSubmitScreen(
                initialCareerId: widget.initialCareerId,
                initialMatterId: widget.initialMatterId,
                lockMatterSelection: widget.lockMatterSelection,
              ),
            ),
          );
        },
      ),
      _HubEntryData(
        icon: Icons.assignment_rounded,
        title: 'Tus solicitudes',
        subtitle:
            'Revisá el estado de lo que enviaste, las aprobaciones y los rechazos.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const VerificationRequestsScreen(),
            ),
          );
        },
      ),
      _HubEntryData(
        icon: Icons.badge_rounded,
        title: 'Este dispositivo',
        subtitle:
            'Editá el perfil del equipo y revisá si este dispositivo tiene acceso admin.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const VerificationDeviceScreen(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text('Administración'),
        backgroundColor:
            isDesktop ? const Color(0xFF0E5E86) : Colors.transparent,
        foregroundColor: isDesktop ? Colors.white : null,
        elevation: 0,
        actions: isDesktop
            ? const [
                Padding(
                  padding: EdgeInsets.only(right: 18),
                  child: Center(child: _AdminInstitutionPlaceholder()),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: adminAsync.when(
              loading: () => _AdminHubLayout(
                isDesktop: isDesktop,
                sidebarCollapsed: _sidebarCollapsed,
                onToggleSidebar: () {
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                },
                verificationEntries: verificationEntries,
                featuredEntries: const [],
                sideEntries: const [],
                infoMessage:
                    'Estamos comprobando si este dispositivo tiene permisos administrativos.',
              ),
              error: (error, _) => _AdminHubLayout(
                isDesktop: isDesktop,
                sidebarCollapsed: _sidebarCollapsed,
                onToggleSidebar: () {
                  setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                },
                verificationEntries: verificationEntries,
                featuredEntries: const [],
                sideEntries: const [],
                infoMessage: 'No se pudo comprobar el acceso admin: $error',
              ),
              data: (status) {
                final adminEntries = status.isAdmin
                    ? _adminEntries(context, status.deviceId)
                    : const <_HubEntryData>[];
                final featuredEntries = adminEntries
                    .where(
                      (entry) =>
                          entry.title == 'Mesas y coloquios' ||
                          entry.title == 'Alumnos',
                    )
                    .toList(growable: false);
                final sideEntries = adminEntries
                    .where(
                      (entry) =>
                          entry.title != 'Mesas y coloquios' &&
                          entry.title != 'Alumnos',
                    )
                    .toList(growable: false);

                return _AdminHubLayout(
                  isDesktop: isDesktop,
                  sidebarCollapsed: _sidebarCollapsed,
                  onToggleSidebar: () {
                    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
                  },
                  verificationEntries: verificationEntries,
                  featuredEntries: featuredEntries,
                  sideEntries: sideEntries,
                  infoMessage: status.isAdmin
                      ? null
                      : 'Cuando este equipo reciba permisos de administración, las herramientas institucionales van a aparecer acá mismo.',
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  List<_HubEntryData> _adminEntries(BuildContext context, String deviceId) {
    return [
      _HubEntryData(
        icon: Icons.bolt_rounded,
        title: 'Actividad reciente',
        subtitle: 'Ver dispositivos activos y revisar su detalle.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AdminActivityScreen()),
        ),
      ),
      _HubEntryData(
        icon: Icons.cleaning_services_rounded,
        title: 'Limpieza y reinicio',
        subtitle: 'Ejecutar acciones de limpieza o reinicio global.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdminCleanupScreen(adminDeviceId: deviceId),
          ),
        ),
      ),
      _HubEntryData(
        icon: Icons.inbox_rounded,
        title: 'Solicitudes pendientes',
        subtitle: 'Aprobar o rechazar verificaciones en revisión.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdminPendingRequestsScreen(adminDeviceId: deviceId),
          ),
        ),
      ),
      _HubEntryData(
        icon: Icons.photo_library_outlined,
        title: 'Fotos por carrera',
        subtitle: 'Ver fotos por carrera, año y materia.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AdminMatterPhotosScreen(),
          ),
        ),
      ),
      _HubEntryData(
        icon: Icons.timeline_rounded,
        title: 'Navegación general',
        subtitle: 'Historial de uso por día, mes y usuario.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AdminMatterNavigationScreen(),
          ),
        ),
      ),
      _HubEntryData(
        icon: Icons.school_rounded,
        title: 'Recorrido de exámenes',
        subtitle: 'Historial de aperturas y cambios en exámenes.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AdminExamNavigationScreen(),
          ),
        ),
      ),
      _HubEntryData(
        icon: Icons.event_note_rounded,
        title: 'Mesas y coloquios',
        subtitle: 'Administrar el calendario de exámenes.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdminExamEventsScreen(adminDeviceId: deviceId),
          ),
        ),
      ),
      _HubEntryData(
        icon: Icons.groups_rounded,
        title: 'Alumnos',
        subtitle: 'Crear usuarios y cargar alumnos por DNI.',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdminStudentsScreen(adminDeviceId: deviceId),
          ),
        ),
      ),
    ];
  }
}

class _AdminInstitutionPlaceholder extends StatelessWidget {
  const _AdminInstitutionPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 430,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/career_icons/logo_artes.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Instituto Superior de Formación Docente N° 1 "Cesáreo Bernaldo de Quirós"',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HubEntryData {
  const _HubEntryData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _AdminHubLayout extends StatelessWidget {
  const _AdminHubLayout({
    required this.isDesktop,
    required this.sidebarCollapsed,
    required this.onToggleSidebar,
    required this.verificationEntries,
    required this.featuredEntries,
    required this.sideEntries,
    this.infoMessage,
  });

  final bool isDesktop;
  final bool sidebarCollapsed;
  final VoidCallback onToggleSidebar;
  final List<_HubEntryData> verificationEntries;
  final List<_HubEntryData> featuredEntries;
  final List<_HubEntryData> sideEntries;
  final String? infoMessage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: isDesktop
          ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
          : const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: sidebarCollapsed ? 92 : 318,
                child: _AdminSidePanel(
                  collapsed: sidebarCollapsed,
                  onToggle: onToggleSidebar,
                  verificationEntries: verificationEntries,
                  entries: sideEntries,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: featuredEntries.isEmpty
                    ? _AdminInfoPanel(
                        title: 'Herramientas institucionales',
                        subtitle: infoMessage ??
                            'No hay herramientas institucionales disponibles para este equipo.',
                      )
                    : _AdminFeaturedSection(featuredEntries: featuredEntries),
              ),
            ],
          )
        else ...[
          _AdminSection(
            title: 'Verificación y acceso',
            subtitle:
                'Accesos operativos para enviar, revisar y gestionar el dispositivo actual.',
            entries: verificationEntries,
            desktopColumns: 1,
          ),
          const SizedBox(height: 22),
          if (featuredEntries.isNotEmpty || sideEntries.isNotEmpty)
            _AdminSection(
              title: 'Herramientas institucionales',
              subtitle:
                  'Módulos de administración centralizados dentro del mismo dashboard.',
              entries: [...featuredEntries, ...sideEntries],
              desktopColumns: 1,
            )
          else if (infoMessage != null)
            _AdminInfoPanel(
              title: 'Herramientas institucionales',
              subtitle: infoMessage!,
            ),
        ],
      ],
    );
  }
}

class _AdminFeaturedSection extends StatelessWidget {
  const _AdminFeaturedSection({
    required this.featuredEntries,
  });

  final List<_HubEntryData> featuredEntries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Herramientas institucionales',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Mesas y coloquios y alumnos quedan al frente como accesos principales del panel.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < featuredEntries.length; i++) ...[
          _AdminFeaturedEntryCard(entry: featuredEntries[i]),
          if (i != featuredEntries.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _AdminFeaturedEntryCard extends StatelessWidget {
  const _AdminFeaturedEntryCard({required this.entry});

  final _HubEntryData entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: entry.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFDCE6F0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 10),
                color: Colors.black.withValues(alpha: 0.045),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E5E86).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  entry.icon,
                  color: const Color(0xFF0E5E86),
                  size: 34,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.subtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSidePanel extends StatelessWidget {
  const _AdminSidePanel({
    required this.collapsed,
    required this.onToggle,
    required this.verificationEntries,
    required this.entries,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final List<_HubEntryData> verificationEntries;
  final List<_HubEntryData> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(collapsed ? 10 : 18, 18, collapsed ? 10 : 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDCE6F0)),
      ),
      child: Column(
        crossAxisAlignment: collapsed
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!collapsed)
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0E5E86).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/career_icons/logo_artes.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (!collapsed) const Spacer(),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  collapsed
                      ? Icons.keyboard_double_arrow_right_rounded
                      : Icons.keyboard_double_arrow_left_rounded,
                ),
                tooltip: collapsed ? 'Mostrar panel' : 'Ocultar panel',
              ),
            ],
          ),
          SizedBox(height: collapsed ? 8 : 18),
          if (!collapsed)
            Text(
              'Verificación y acceso',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          if (!collapsed) const SizedBox(height: 12),
          for (var i = 0; i < verificationEntries.length; i++) ...[
            _AdminCompactEntryCard(
              entry: verificationEntries[i],
              collapsed: collapsed,
            ),
            if (i != verificationEntries.length - 1)
              const SizedBox(height: 10),
          ],
          if (entries.isNotEmpty && !collapsed) ...[
            const SizedBox(height: 20),
            Text(
              'Otras opciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (entries.isNotEmpty)
            for (var i = 0; i < entries.length; i++) ...[
              _AdminCompactEntryCard(
                entry: entries[i],
                collapsed: collapsed,
              ),
              if (i != entries.length - 1) const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _AdminCompactEntryCard extends StatelessWidget {
  const _AdminCompactEntryCard({
    required this.entry,
    this.collapsed = false,
  });

  final _HubEntryData entry;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: const Color(0xFFF8FBFF),
      borderRadius: BorderRadius.circular(collapsed ? 16 : 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(collapsed ? 16 : 18),
        onTap: entry.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 10 : 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(collapsed ? 16 : 18),
            border: Border.all(color: const Color(0xFFDCE6F0)),
          ),
          child: Row(
            mainAxisAlignment:
                collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E5E86).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry.icon,
                  color: const Color(0xFF0E5E86),
                  size: 20,
                ),
              ),
              if (!collapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({
    required this.title,
    required this.subtitle,
    required this.entries,
    required this.desktopColumns,
  });

  final String title;
  final String subtitle;
  final List<_HubEntryData> entries;
  final int desktopColumns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        if (desktopColumns > 1)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: desktopColumns,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 2.2,
            ),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _AdminCompactEntryCard(entry: entries[index]),
          )
        else
          Column(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                _AdminCompactEntryCard(entry: entries[i]),
                if (i != entries.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _AdminInfoPanel extends StatelessWidget {
  const _AdminInfoPanel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFDCE6F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
