import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../../verificacion/pantallas/dispositivo_verificacion_pantalla.dart';
import '../../verificacion/pantallas/enviar_verificacion_pantalla.dart';
import '../../verificacion/pantallas/solicitudes_verificacion_pantalla.dart';
import '../proveedores/proveedores_acceso_administrador.dart';
import '../tema/tema_administrador_atlassian.dart';
import 'actividad_administrador_pantalla.dart';
import 'estudiantes_administrador_pantalla.dart';
import 'eventos_examen_administrador_pantalla.dart';
import 'fotos_materias_administrador_pantalla.dart';
import 'limpieza_administrador_pantalla.dart';
import 'navegacion_examen_administrador_pantalla.dart';
import 'navegacion_materia_administrador_pantalla.dart';
import 'solicitudes_pendientes_administrador_pantalla.dart';

class AccesoAdministradorPantalla extends ConsumerStatefulWidget {
  const AccesoAdministradorPantalla({
    super.key,
    this.initialCareerId,
    this.initialMatterId,
    this.lockMatterSelection = false,
  });

  final String? initialCareerId;
  final String? initialMatterId;
  final bool lockMatterSelection;

  @override
  ConsumerState<AccesoAdministradorPantalla> createState() =>
      _AccesoAdministradorPantallaState();
}

class _AccesoAdministradorPantallaState
    extends ConsumerState<AccesoAdministradorPantalla> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final adminAsync = ref.watch(proveedorEstadoDispositivoAdministrador);

    final verificationEntries = [
      _DatosEntradaPanel(
        icon: Icons.cloud_upload_rounded,
        title: 'Enviar verificación',
        subtitle:
            'Subí una captura, elegí materia y mandá la solicitud desde su pantalla dedicada.',
        onTap: () => _pushRutaAdminConTema(
          context,
          EnviarVerificacionPantalla(
            initialCareerId: widget.initialCareerId,
            initialMatterId: widget.initialMatterId,
            lockMatterSelection: widget.lockMatterSelection,
          ),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.assignment_rounded,
        title: 'Tus solicitudes',
        subtitle:
            'Revisá el estado de lo que enviaste, las aprobaciones y los rechazos.',
        onTap: () => _pushRutaAdminConTema(
          context,
          const SolicitudesVerificacionPantalla(),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.badge_rounded,
        title: 'Este dispositivo',
        subtitle:
            'Editá el perfil del equipo y revisá si este dispositivo tiene acceso admin.',
        onTap: () => _pushRutaAdminConTema(
          context,
          const DispositivoVerificacionPantalla(),
        ),
      ),
    ];

    final atlassianTheme = temaAdministradorAtlassian(context);
    return Theme(
      data: atlassianTheme,
      child: Scaffold(
        backgroundColor: atlassianTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Administración'),
          backgroundColor: isDesktop
              ? PaletaAtlassian.brand
              : Colors.transparent,
          foregroundColor: isDesktop ? Colors.white : null,
          elevation: 0,
          actions: isDesktop
              ? const [
                  Padding(
                    padding: EdgeInsets.only(right: 18),
                    child: Center(child: _MarcadorInstitucionAdmin()),
                  ),
                ]
              : null,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: adminAsync.when(
                loading: () => _DisposicionPanelAdmin(
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
                error: (error, _) => _DisposicionPanelAdmin(
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
                      : const <_DatosEntradaPanel>[];
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

                  return _DisposicionPanelAdmin(
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
      ),
    );
  }

  void _pushRutaAdminConTema(BuildContext context, Widget child) {
    abrirPantallaAdministradorAtlassian<void>(context, child);
  }

  List<_DatosEntradaPanel> _adminEntries(
    BuildContext context,
    String deviceId,
  ) {
    return [
      _DatosEntradaPanel(
        icon: Icons.bolt_rounded,
        title: 'Actividad reciente',
        subtitle: 'Ver dispositivos activos y revisar su detalle.',
        onTap: () => _pushRutaAdminConTema(
          context,
          const ActividadAdministradorPantalla(),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.cleaning_services_rounded,
        title: 'Limpieza y reinicio',
        subtitle: 'Ejecutar acciones de limpieza o reinicio global.',
        onTap: () => _pushRutaAdminConTema(
          context,
          LimpiezaAdministradorPantalla(adminDeviceId: deviceId),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.inbox_rounded,
        title: 'Solicitudes pendientes',
        subtitle: 'Aprobar o rechazar verificaciones en revisión.',
        onTap: () => _pushRutaAdminConTema(
          context,
          SolicitudesPendientesAdministradorPantalla(adminDeviceId: deviceId),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.photo_library_outlined,
        title: 'Fotos por carrera',
        subtitle: 'Ver fotos por carrera, año y materia.',
        onTap: () => _pushRutaAdminConTema(
          context,
          const FotosMateriasAdministradorPantalla(),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.timeline_rounded,
        title: 'Navegación general',
        subtitle: 'Historial de uso por día, mes y usuario.',
        onTap: () => _pushRutaAdminConTema(
          context,
          const NavegacionMateriaAdministradorPantalla(),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.school_rounded,
        title: 'Recorrido de exámenes',
        subtitle: 'Historial de aperturas y cambios en exámenes.',
        onTap: () => _pushRutaAdminConTema(
          context,
          const NavegacionExamenAdministradorPantalla(),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.event_note_rounded,
        title: 'Mesas y coloquios',
        subtitle: 'Administrar el calendario de exámenes.',
        onTap: () => _pushRutaAdminConTema(
          context,
          EventosExamenAdministradorPantalla(adminDeviceId: deviceId),
        ),
      ),
      _DatosEntradaPanel(
        icon: Icons.groups_rounded,
        title: 'Alumnos',
        subtitle: 'Crear usuarios y cargar alumnos por DNI.',
        onTap: () => _pushRutaAdminConTema(
          context,
          EstudiantesAdministradorPantalla(adminDeviceId: deviceId),
        ),
      ),
    ];
  }
}

class _MarcadorInstitucionAdmin extends StatelessWidget {
  const _MarcadorInstitucionAdmin();

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
              borderRadius: BorderRadius.circular(RadioAtlassian.medium),
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

class _DatosEntradaPanel {
  const _DatosEntradaPanel({
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

class _DisposicionPanelAdmin extends StatelessWidget {
  const _DisposicionPanelAdmin({
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
  final List<_DatosEntradaPanel> verificationEntries;
  final List<_DatosEntradaPanel> featuredEntries;
  final List<_DatosEntradaPanel> sideEntries;
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
                child: _PanelLateralAdmin(
                  collapsed: sidebarCollapsed,
                  onToggle: onToggleSidebar,
                  verificationEntries: verificationEntries,
                  entries: sideEntries,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: featuredEntries.isEmpty
                    ? _PanelInfoAdmin(
                        title: 'Herramientas institucionales',
                        subtitle:
                            infoMessage ??
                            'No hay herramientas institucionales disponibles para este equipo.',
                      )
                    : _SeccionDestacadaAdmin(featuredEntries: featuredEntries),
              ),
            ],
          )
        else ...[
          _SeccionAdmin(
            title: 'Verificación y acceso',
            subtitle:
                'Accesos operativos para enviar, revisar y gestionar el dispositivo actual.',
            entries: verificationEntries,
            desktopColumns: 1,
          ),
          const SizedBox(height: 22),
          if (featuredEntries.isNotEmpty || sideEntries.isNotEmpty)
            _SeccionAdmin(
              title: 'Herramientas institucionales',
              subtitle:
                  'Módulos de administración centralizados dentro del mismo dashboard.',
              entries: [...featuredEntries, ...sideEntries],
              desktopColumns: 1,
            )
          else if (infoMessage != null)
            _PanelInfoAdmin(
              title: 'Herramientas institucionales',
              subtitle: infoMessage!,
            ),
        ],
      ],
    );
  }
}

class _SeccionDestacadaAdmin extends StatelessWidget {
  const _SeccionDestacadaAdmin({required this.featuredEntries});

  final List<_DatosEntradaPanel> featuredEntries;

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
        const SizedBox(height: 14),
        for (var i = 0; i < featuredEntries.length; i++) ...[
          _TarjetaEntradaDestacadaAdmin(entry: featuredEntries[i]),
          if (i != featuredEntries.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _TarjetaEntradaDestacadaAdmin extends StatelessWidget {
  const _TarjetaEntradaDestacadaAdmin({required this.entry});

  final _DatosEntradaPanel entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(RadioAtlassian.large),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadioAtlassian.large),
        onTap: entry.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(RadioAtlassian.large),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PaletaAtlassian.brand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                ),
                child: Icon(entry.icon, color: PaletaAtlassian.brand, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      entry.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
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

class _PanelLateralAdmin extends StatelessWidget {
  const _PanelLateralAdmin({
    required this.collapsed,
    required this.onToggle,
    required this.verificationEntries,
    required this.entries,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final List<_DatosEntradaPanel> verificationEntries;
  final List<_DatosEntradaPanel> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        collapsed ? 10 : 18,
        18,
        collapsed ? 10 : 18,
        18,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(RadioAtlassian.large),
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
                    color: PaletaAtlassian.brand.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(RadioAtlassian.large),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(RadioAtlassian.medium),
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
            _TarjetaEntradaCompactaAdmin(
              entry: verificationEntries[i],
              collapsed: collapsed,
            ),
            if (i != verificationEntries.length - 1) const SizedBox(height: 10),
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
              _TarjetaEntradaCompactaAdmin(
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

class _TarjetaEntradaCompactaAdmin extends StatelessWidget {
  const _TarjetaEntradaCompactaAdmin({
    required this.entry,
    this.collapsed = false,
  });

  final _DatosEntradaPanel entry;
  final bool collapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: isDark
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(RadioAtlassian.medium),
      child: InkWell(
        borderRadius: BorderRadius.circular(RadioAtlassian.medium),
        onTap: entry.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 10 : 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(RadioAtlassian.medium),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: collapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: PaletaAtlassian.brand.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                ),
                child: Icon(entry.icon, color: PaletaAtlassian.brand, size: 20),
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

class _SeccionAdmin extends StatelessWidget {
  const _SeccionAdmin({
    required this.title,
    required this.subtitle,
    required this.entries,
    required this.desktopColumns,
  });

  final String title;
  final String subtitle;
  final List<_DatosEntradaPanel> entries;
  final int desktopColumns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
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
                _TarjetaEntradaCompactaAdmin(entry: entries[index]),
          )
        else
          Column(
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                _TarjetaEntradaCompactaAdmin(entry: entries[i]),
                if (i != entries.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _PanelInfoAdmin extends StatelessWidget {
  const _PanelInfoAdmin({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
