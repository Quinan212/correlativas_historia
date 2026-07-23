import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../../compartido/utilidades/sanitizar_texto.dart';
import '../modelos/evento_examen_administrador.dart';
import '../proveedores/proveedores_eventos_examen_administrador.dart';
import '../tema/tema_administrador_atlassian.dart';
import 'hoja_editor_evento_examen.dart';

part 'src/seccion_eventos_examen_administrador/pantalla_eventos_por_carrera.dart';
part 'src/seccion_eventos_examen_administrador/pantalla_eventos_global.dart';
part 'src/seccion_eventos_examen_administrador/pantalla_carrera_examen.dart';
part 'src/seccion_eventos_examen_administrador/widgets_carrera_examen.dart';
part 'src/seccion_eventos_examen_administrador/utilidades_eventos_examen.dart';

class SeccionEventosExamenAdministrador extends ConsumerStatefulWidget {
  const SeccionEventosExamenAdministrador({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<SeccionEventosExamenAdministrador> createState() =>
      _SeccionEventosExamenAdministradorState();
}

class _SeccionEventosExamenAdministradorState
    extends ConsumerState<SeccionEventosExamenAdministrador> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mesas y coloquios',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Elegí si querés entrar por carrera o ver toda la lista en una vista global.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _openByCareer(context),
                icon: const Icon(Icons.account_tree_outlined),
                label: const Text('Por carrera'),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _openGlobal(context),
                icon: const Icon(Icons.view_list_rounded),
                label: const Text('Vista global'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openByCareer(BuildContext context) async {
    await abrirPantallaAdministradorAtlassian<void>(
      context,
      _PantallaEventosExamenPorCarreraAdmin(
        adminDeviceId: widget.adminDeviceId,
      ),
    );
    if (!mounted) return;
    ref.invalidate(proveedorEventosExamenAdministrador);
  }

  Future<void> _openGlobal(BuildContext context) async {
    await abrirPantallaAdministradorAtlassian<void>(
      context,
      _PantallaEventosExamenGlobalAdmin(adminDeviceId: widget.adminDeviceId),
    );
    if (!mounted) return;
    ref.invalidate(proveedorEventosExamenAdministrador);
  }
}
