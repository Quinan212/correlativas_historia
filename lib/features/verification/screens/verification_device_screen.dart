import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../../admin_access/providers/admin_access_providers.dart';
import '../../admin_access/screens/admin_panel_screen.dart';

class VerificationDeviceScreen extends ConsumerWidget {
  const VerificationDeviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final adminAsync = ref.watch(adminDeviceStatusProvider);
    final ownProfileAsync = ref.watch(ownDeviceProfileProvider);
    final deviceLabelAsync = ref.watch(deviceLabelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Este dispositivo')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: 'Tu perfil',
              child: ownProfileAsync.when(
                data: (profile) {
                  final detectedDeviceLabel =
                      deviceLabelAsync.valueOrNull ?? 'Dispositivo';
                  final effectiveDeviceLabel = _resolveDeviceLabel(
                    profile?.deviceLabel,
                    detectedDeviceLabel,
                  );
                  final referenceName = (profile?.referenceName ?? '').trim();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispositivo detectado',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(effectiveDeviceLabel, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 10),
                      Text(
                        'Nombre de referencia',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        referenceName.isEmpty ? 'Sin configurar' : referenceName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile == null
                            ? 'Tus referencias públicas se muestran de forma anónima.'
                            : profile.publicDisplayLabel == 'Referencia anonima'
                                ? 'Tus referencias públicas se muestran de forma anónima.'
                                : 'Tus referencias públicas usan el alias "${profile.publicDisplayLabel}".',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final client = ref.read(supabaseClientProvider);
                          if (client == null) return;
                          final currentProfile =
                              await ref.read(ownDeviceProfileProvider.future);
                          if (!context.mounted) return;
                          final draft = await showDeviceProfileSheet(
                            context: context,
                            deviceLabel: _resolveDeviceLabel(
                              currentProfile?.deviceLabel,
                              detectedDeviceLabel,
                            ),
                            initialProfile: currentProfile,
                          );
                          if (draft == null || !context.mounted) return;

                          final repo =
                              ref.read(deviceProfileRepositoryProvider);
                          final deviceId = await ref.read(deviceIdProvider.future);
                          await repo.upsertProfile(
                            client: client,
                            deviceId: deviceId,
                            deviceLabel: _resolveDeviceLabel(
                              currentProfile?.deviceLabel,
                              detectedDeviceLabel,
                            ),
                            referenceName: draft.referenceName,
                            publicMode: draft.publicMode,
                            publicAlias: draft.publicAlias,
                          );
                          ref.invalidate(ownDeviceProfileProvider);
                          ref.invalidate(deviceProfilesByIdsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Perfil actualizado'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.badge_outlined),
                        label: const Text('Editar perfil'),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (error, _) => Text(
                  'No se pudo cargar el perfil: $error',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Acceso admin',
              child: adminAsync.when(
                data: (status) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.message, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            ref.invalidate(adminDeviceStatusProvider);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refrescar'),
                        ),
                        if (status.isAdmin)
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => AdminPanelScreen(
                                    deviceId: status.deviceId,
                                    adminLabel: status.adminLabel,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.admin_panel_settings_rounded),
                            label: const Text('Panel admin'),
                          ),
                      ],
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 3),
                ),
                error: (error, _) => Text(
                  'No se pudo comprobar el acceso admin: $error',
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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

String _resolveDeviceLabel(String? current, String fallback) {
  final trimmed = current?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  return fallback.trim().isEmpty ? 'Dispositivo' : fallback.trim();
}
