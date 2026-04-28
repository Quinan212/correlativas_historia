import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../verification/screens/verification_device_screen.dart';
import '../../verification/screens/verification_requests_screen.dart';
import '../../verification/screens/verification_submit_screen.dart';
import '../providers/admin_access_providers.dart';
import 'admin_panel_screen.dart';

class AdminAccessScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final adminAsync = ref.watch(adminDeviceStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeaderCard(
              title: 'Verificación',
              subtitle:
                  'Usá esta pantalla solo como acceso. Cada función tiene ahora su propia pantalla.',
              icon: Icons.verified_user_rounded,
            ),
            const SizedBox(height: 14),
            _EntryCard(
              icon: Icons.cloud_upload_rounded,
              title: 'Enviar verificación',
              subtitle:
                  'Subí una captura, elegí materia y mandá la solicitud desde su pantalla dedicada.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VerificationSubmitScreen(
                      initialCareerId: initialCareerId,
                      initialMatterId: initialMatterId,
                      lockMatterSelection: lockMatterSelection,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.receipt_long_rounded,
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
            const SizedBox(height: 12),
            _EntryCard(
              icon: Icons.badge_outlined,
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
            const SizedBox(height: 12),
            adminAsync.when(
              data: (status) {
                if (!status.isAdmin) {
                  return _InfoCard(
                    title: 'Panel admin',
                    subtitle:
                        'Este dispositivo todavía no tiene permisos de administración.',
                  );
                }

                return _EntryCard(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Panel admin',
                  subtitle:
                      'Abrí el panel con las tareas avanzadas de administración.',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => AdminPanelScreen(
                          deviceId: status.deviceId,
                          adminLabel: status.adminLabel,
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const _LoadingCard(
                title: 'Panel admin',
                subtitle: 'Comprobando si este dispositivo tiene permisos...',
              ),
              error: (error, _) => _InfoCard(
                title: 'Panel admin',
                subtitle: 'No se pudo comprobar el acceso admin: $error',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'La pantalla raíz quedó como hub de accesos. Las acciones viven en pantallas separadas para que la navegación sea más clara.',
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
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
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyLarge),
              ],
            ),
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
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
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
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
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}
