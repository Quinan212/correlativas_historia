import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/supabase/supabase.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../../verificacion/proveedores/proveedores_verificacion.dart';
import '../componentes/componentes_administrador_atlassian.dart';
import '../proveedores/proveedores_acceso_administrador.dart';

class LimpiezaAdministradorPantalla extends ConsumerStatefulWidget {
  const LimpiezaAdministradorPantalla({super.key, required this.adminDeviceId});

  final String adminDeviceId;

  @override
  ConsumerState<LimpiezaAdministradorPantalla> createState() =>
      _LimpiezaAdministradorPantallaState();
}

class _LimpiezaAdministradorPantallaState
    extends ConsumerState<LimpiezaAdministradorPantalla> {
  String? _runningAction;
  final Set<String> _selectedActions = <String>{};

  static const List<_CleanupOption> _options = [
    _CleanupOption(
      action: 'clear_matter_reviews',
      title: 'Referencias de materias',
      description: 'Borra todas las referencias de materias.',
      confirmation:
          'Se van a borrar todas las referencias de materias. Esta acción no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_teacher_reviews',
      title: 'Referencias de docentes',
      description: 'Borra todas las referencias de docentes.',
      confirmation:
          'Se van a borrar todas las referencias de docentes. Esta acción no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_photos',
      title: 'Fotos comunitarias',
      description: 'Borra fotos y archivos de comunidad.',
      confirmation:
          'Se van a borrar todas las fotos comunitarias y sus archivos. Esta acción no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_verifications',
      title: 'Verificaciones y permisos',
      description: 'Borra verificaciones y permisos asociados.',
      confirmation:
          'Se van a borrar verificaciones y permisos vinculados. Esta acción no se puede deshacer.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Limpieza y reinicio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _runningAction != null
                ? null
                : () => setState(_selectedActions.clear),
            icon: const Icon(Icons.deselect_rounded),
            tooltip: 'Limpiar selección',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: ListView(
              padding: isDesktop
                  ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24)
                  : const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _TarjetaEncabezado(),
                const SizedBox(height: 24),
                _TarjetaSeccion(
                  title: 'Acciones disponibles',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seleccioná los módulos que querés limpiar o ejecutá cada acción individualmente.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      if (isDesktop)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2.8,
                              ),
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            final option = _options[index];
                            return _CleanupChoiceTile(
                              option: option,
                              selected: _selectedActions.contains(
                                option.action,
                              ),
                              busy: _runningAction == option.action,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedActions.add(option.action);
                                  } else {
                                    _selectedActions.remove(option.action);
                                  }
                                });
                              },
                              onDeletePressed: () => _runSingleAction(option),
                            );
                          },
                        )
                      else
                        Column(
                          children: _options
                              .map(
                                (option) => _CleanupChoiceTile(
                                  option: option,
                                  selected: _selectedActions.contains(
                                    option.action,
                                  ),
                                  busy: _runningAction == option.action,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedActions.add(option.action);
                                      } else {
                                        _selectedActions.remove(option.action);
                                      }
                                    });
                                  },
                                  onDeletePressed: () =>
                                      _runSingleAction(option),
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: isDesktop
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: isDesktop ? 0 : 1,
                            child: FilledButton.icon(
                              onPressed:
                                  _selectedActions.isEmpty ||
                                      _runningAction != null
                                  ? null
                                  : _runSelectedActions,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Ejecutar selección'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: isDesktop ? 0 : 1,
                            child: FilledButton.tonal(
                              onPressed: _runningAction != null
                                  ? null
                                  : _runResetAll,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                foregroundColor: PaletaAtlassian.danger,
                                backgroundColor: PaletaAtlassian.danger
                                    .withValues(alpha: 0.08),
                              ),
                              child: const Text('Reiniciar todo'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _runSingleAction(_CleanupOption option) async {
    await _runAction(
      action: option.action,
      title: option.title,
      confirmation: option.confirmation,
    );
  }

  Future<void> _runSelectedActions() async {
    final selected = _options
        .where((option) => _selectedActions.contains(option.action))
        .toList();
    if (selected.isEmpty) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(
              'Confirmar selección',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: Text(
              'Se van a ejecutar ${selected.length} acciones de limpieza. Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    for (final option in selected) {
      await _runAction(
        action: option.action,
        title: option.title,
        confirmation: option.confirmation,
        askConfirmation: false,
      );
    }

    if (mounted) {
      setState(_selectedActions.clear);
    }
  }

  Future<void> _runResetAll() async {
    await _runAction(
      action: 'reset_all',
      title: 'Reiniciar todo',
      confirmation:
          'Se va a borrar todo: referencias, fotos, verificaciones y permisos. Esta acción no se puede deshacer.',
    );
  }

  Future<void> _runAction({
    required String action,
    required String title,
    required String confirmation,
    bool askConfirmation = true,
  }) async {
    if (askConfirmation) {
      final confirmed =
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Text(confirmation),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Confirmar'),
                ),
              ],
            ),
          ) ??
          false;

      if (!confirmed) return;
    }

    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    setState(() => _runningAction = action);
    try {
      final repo = ref.read(proveedorRepositorioLimpiezaMasivaAdministrador);
      final result = await repo.runAction(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        action: action,
      );

      ref.invalidate(proveedorSolicitudesVerificacionPendientes);
      ref.invalidate(proveedorSolicitudesVerificacionRevisadas);
      ref.invalidate(proveedorSolicitudesVerificacionPropias);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_summarizeCleanupResult(result.summary)),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo completar la limpieza: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _runningAction = null);
      }
    }
  }
}

class _TarjetaEncabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AvisoAdministradorAtlassian(
      icon: Icons.warning_amber_rounded,
      title: 'Zona de peligro',
      message: 'Las acciones de esta pantalla son permanentes.',
      level: NivelAvisoAdministrador.danger,
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CleanupChoiceTile extends StatelessWidget {
  const _CleanupChoiceTile({
    required this.option,
    required this.selected,
    required this.busy,
    required this.onChanged,
    required this.onDeletePressed,
  });

  final _CleanupOption option;
  final bool selected;
  final bool busy;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Checkbox(value: selected, onChanged: busy ? null : onChanged),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(option.description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (busy)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              onPressed: onDeletePressed,
              icon: const Icon(Icons.delete_outline_rounded),
              color: PaletaAtlassian.danger,
              tooltip: 'Borrar solo esta opción',
            ),
        ],
      ),
    );
  }
}

class _CleanupOption {
  const _CleanupOption({
    required this.action,
    required this.title,
    required this.description,
    required this.confirmation,
  });

  final String action;
  final String title;
  final String description;
  final String confirmation;
}

String _summarizeCleanupResult(Map<String, dynamic> summary) {
  final resenasMateria = (summary['matter_reviews_deleted'] ?? 0).toString();
  final resenasDocente = (summary['teacher_reviews_deleted'] ?? 0).toString();
  final photos = (summary['photos_deleted'] ?? 0).toString();
  final verifications = (summary['verification_requests_deleted'] ?? 0)
      .toString();
  final permissions = (summary['verification_permissions_deleted'] ?? 0)
      .toString();

  return 'Listo. Materias: $resenasMateria, docentes: $resenasDocente, fotos: $photos, verificaciones: $verifications, permisos: $permissions.';
}
