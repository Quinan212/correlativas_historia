import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/supabase/supabase.dart';
import '../../verification/providers/verification_providers.dart';
import '../providers/admin_access_providers.dart';

class AdminCleanupScreen extends ConsumerStatefulWidget {
  const AdminCleanupScreen({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  ConsumerState<AdminCleanupScreen> createState() => _AdminCleanupScreenState();
}

class _AdminCleanupScreenState extends ConsumerState<AdminCleanupScreen> {
  String? _runningAction;
  final Set<String> _selectedActions = <String>{};

  static const List<_CleanupOption> _options = [
    _CleanupOption(
      action: 'clear_matter_reviews',
      title: 'Referencias de materias',
      description: 'Borra todas las referencias de materias.',
      confirmation:
          'Se van a borrar todas las referencias de materias. Esta accion no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_teacher_reviews',
      title: 'Referencias de docentes',
      description: 'Borra todas las referencias de docentes.',
      confirmation:
          'Se van a borrar todas las referencias de docentes. Esta accion no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_photos',
      title: 'Fotos comunitarias',
      description: 'Borra fotos y archivos de comunidad.',
      confirmation:
          'Se van a borrar todas las fotos comunitarias y sus archivos. Esta accion no se puede deshacer.',
    ),
    _CleanupOption(
      action: 'clear_verifications',
      title: 'Verificaciones y permisos',
      description: 'Borra verificaciones y permisos asociados.',
      confirmation:
          'Se van a borrar verificaciones y permisos vinculados. Esta accion no se puede deshacer.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limpieza y reinicio'),
        actions: [
          IconButton(
            onPressed: _runningAction != null
                ? null
                : () => setState(() => _selectedActions.clear()),
            icon: const Icon(Icons.deselect_rounded),
            tooltip: 'Limpiar selección',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _SectionCard(
              title: 'Acciones destructivas',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elegí una o varias opciones para limpiar. También podés ejecutar cada una de forma individual.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  ..._options.map(
                    (option) => _CleanupChoiceTile(
                      option: option,
                      selected: _selectedActions.contains(option.action),
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _selectedActions.isEmpty ||
                                  _runningAction != null
                              ? null
                              : _runSelectedActions,
                          child: const Text('Ejecutar selección'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed:
                              _runningAction != null ? null : _runResetAll,
                          style: FilledButton.styleFrom(
                            foregroundColor: const Color(0xFFB91C1C),
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
        .toList(growable: false);
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar selección'),
            content: Text(
              'Se van a ejecutar ${selected.length} acciones de limpieza. Esta accion no se puede deshacer.',
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
      setState(() => _selectedActions.clear());
    }
  }

  Future<void> _runResetAll() async {
    await _runAction(
      action: 'reset_all',
      title: 'Reiniciar todo',
      confirmation:
          'Se va a borrar todo: referencias de materias, referencias de docentes, fotos, verificaciones y permisos. Esta accion no se puede deshacer.',
    );
  }

  Future<void> _runAction({
    required String action,
    required String title,
    required String confirmation,
    bool askConfirmation = true,
  }) async {
    if (askConfirmation) {
      final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(title),
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

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    setState(() => _runningAction = action);
    try {
      final repo = ref.read(adminBulkCleanupRepositoryProvider);
      final result = await repo.runAction(
        client: client,
        adminDeviceId: widget.adminDeviceId,
        action: action,
      );

      ref.invalidate(pendingVerificationRequestsProvider);
      ref.invalidate(reviewedVerificationRequestsProvider);
      ref.invalidate(ownVerificationRequestsProvider);

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
        SnackBar(
          content: Text('No se pudo completar la limpieza: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _runningAction = null);
      }
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Checkbox(
            value: selected,
            onChanged: busy ? null : onChanged,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option.description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.3),
                )
              : IconButton(
                  onPressed: onDeletePressed,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFFB91C1C),
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
  final matterReviews = (summary['matter_reviews_deleted'] ?? 0).toString();
  final teacherReviews = (summary['teacher_reviews_deleted'] ?? 0).toString();
  final photos = (summary['photos_deleted'] ?? 0).toString();
  final verifications =
      (summary['verification_requests_deleted'] ?? 0).toString();
  final permissions =
      (summary['verification_permissions_deleted'] ?? 0).toString();

  return 'Listo. Materias: $matterReviews, docentes: $teacherReviews, fotos: $photos, verificaciones: $verifications, permisos: $permissions.';
}
