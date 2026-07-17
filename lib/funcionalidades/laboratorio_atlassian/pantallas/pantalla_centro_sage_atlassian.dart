import 'package:flutter/material.dart';

import '../componentes/componentes_atlassian.dart';
import '../tema/tema_atlassian.dart';

enum AccionCentroSageAtlassian { sincronizar, abrirSage }

class PantallaCentroSageAtlassian extends StatelessWidget {
  const PantallaCentroSageAtlassian({super.key, this.ultimaSincronizacion});

  final DateTime? ultimaSincronizacion;

  @override
  Widget build(BuildContext context) {
    final theme = temaLaboratorioAtlassian(context);
    final scheme = theme.colorScheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SAGE'),
          leading: IconButton(
            tooltip: 'Cerrar',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PanelAtlassian(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                RadioAtlassian.large,
                              ),
                            ),
                            child: Image.asset(
                              'assets/sage_banner.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.school_rounded,
                                color: scheme.primary,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sesión activa',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                if (ultimaSincronizacion != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Actualizado ${_formatDate(ultimaSincronizacion!)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const LozengeAtlassian(
                            label: 'Conectado',
                            appearance: AparienciaLozengeAtlassian.success,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 520;
                        Widget syncCard() => TarjetaAccionAtlassian(
                          label: 'Sincronizar trayectoria',
                          icon: Icons.sync_rounded,
                          badge: 'Recomendado',
                          onTap: () => Navigator.of(
                            context,
                          ).pop(AccionCentroSageAtlassian.sincronizar),
                        );
                        Widget openCard() => TarjetaAccionAtlassian(
                          label: 'Abrir SAGE',
                          icon: Icons.open_in_new_rounded,
                          onTap: () => Navigator.of(
                            context,
                          ).pop(AccionCentroSageAtlassian.abrirSage),
                        );
                        if (wide) {
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: syncCard()),
                                const SizedBox(width: 12),
                                Expanded(child: openCard()),
                              ],
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            syncCard(),
                            const SizedBox(height: 12),
                            openCard(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }
}
