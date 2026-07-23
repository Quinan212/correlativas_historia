import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../pantallas/panel_administrador_pantalla.dart';
import '../proveedores/proveedores_acceso_administrador.dart';
import '../tema/tema_administrador_atlassian.dart';

class BannerAccesoAdministrador extends ConsumerWidget {
  const BannerAccesoAdministrador({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(proveedorEstadoDispositivoAdministrador);

    return statusAsync.when(
      data: (status) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final bg = status.isAdmin
            ? (isDark
                  ? PaletaAtlassian.successSubtleDark
                  : PaletaAtlassian.successSubtle)
            : theme.colorScheme.surfaceContainerLow;
        final border = status.isAdmin
            ? PaletaAtlassian.success
            : theme.colorScheme.outlineVariant;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.isAdmin ? 'Dispositivo admin' : 'Acceso admin',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                status.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.invalidate(proveedorEstadoDispositivoAdministrador);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refrescar'),
                  ),
                  if (status.isAdmin)
                    FilledButton.icon(
                      onPressed: () {
                        abrirPantallaAdministradorAtlassian<void>(
                          context,
                          PanelAdministradorPantalla(
                            deviceId: status.deviceId,
                            adminLabel: status.adminLabel,
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
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: LinearProgressIndicator(minHeight: 3),
      ),
      error: (error, _) {
        final theme = Theme.of(context);
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? PaletaAtlassian.dangerSubtleDark
                : PaletaAtlassian.dangerSubtle,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: PaletaAtlassian.danger),
          ),
          child: Text('No se pudo resolver acceso admin: $error'),
        );
      },
    );
  }
}
