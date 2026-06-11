import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proveedores/proveedores_acceso_administrador.dart';
import '../pantallas/panel_administrador_pantalla.dart';

class BannerAccesoAdministrador extends ConsumerWidget {
  const BannerAccesoAdministrador({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(proveedorEstadoDispositivoAdministrador);

    return statusAsync.when(
      data: (status) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = status.isAdmin
            ? (isDark ? const Color(0xFF052E16) : const Color(0xFFDCFCE7))
            : (isDark ? const Color(0xFF172033) : const Color(0xFFF8FAFC));
        final border = status.isAdmin
            ? (isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC))
            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0));

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status.isAdmin ? 'Dispositivo admin' : 'Acceso admin',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PanelAdministradorPantalla(
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
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
        child: LinearProgressIndicator(minHeight: 3),
      ),
      error: (error, _) => Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Text('No se pudo resolver acceso admin: $error'),
      ),
    );
  }
}
