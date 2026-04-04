import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/supabase/supabase.dart';
import '../models/opiniones_review_models.dart';
import '../providers/opiniones_review_providers.dart';
import '../utils/referencias_labels.dart';
import 'referencias_balance_bar.dart';

Future<void> showMatterReviewComposerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String matterId,
  required String matterName,
  required String careerId,
  MatterReview? initialReview,
}) async {
  MatterReview? resolvedInitialReview = initialReview;
  final client = ref.read(supabaseClientProvider);
  if (client != null) {
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(opinionesReviewsRepositoryProvider);
      resolvedInitialReview = await repo.fetchOwnMatterReview(
        client: client,
        deviceId: deviceId,
        matterId: matterId,
      );
    } catch (_) {
      resolvedInitialReview ??= initialReview;
    }
  }
  if (!context.mounted) return;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _MatterReviewComposerSheet(
      matterId: matterId,
      matterName: matterName,
      careerId: careerId,
      initialReview: resolvedInitialReview,
    ),
  );
}

Future<void> showTeacherReviewComposerSheet({
  required BuildContext context,
  required WidgetRef ref,
  required TeacherReviewScope scope,
  required String teacherName,
  required String matterName,
  TeacherReview? initialReview,
}) async {
  TeacherReview? resolvedInitialReview = initialReview;
  final client = ref.read(supabaseClientProvider);
  if (client != null) {
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(opinionesReviewsRepositoryProvider);
      resolvedInitialReview = await repo.fetchOwnTeacherReview(
        client: client,
        deviceId: deviceId,
        scope: scope,
      );
    } catch (_) {
      resolvedInitialReview ??= initialReview;
    }
  }
  if (!context.mounted) return;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _TeacherReviewComposerSheet(
      scope: scope,
      teacherName: teacherName,
      matterName: matterName,
      initialReview: resolvedInitialReview,
    ),
  );
}

class _MatterReviewComposerSheet extends ConsumerStatefulWidget {
  const _MatterReviewComposerSheet({
    required this.matterId,
    required this.matterName,
    required this.careerId,
    this.initialReview,
  });

  final String matterId;
  final String matterName;
  final String careerId;
  final MatterReview? initialReview;

  @override
  ConsumerState<_MatterReviewComposerSheet> createState() =>
      _MatterReviewComposerSheetState();
}

class _MatterReviewComposerSheetState
    extends ConsumerState<_MatterReviewComposerSheet> {
  late int _rating;
  late final TextEditingController _commentCtrl;
  late final Map<String, int> _dimensions;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialReview?.rating ?? 0;
    _commentCtrl = TextEditingController(
      text: widget.initialReview?.comment ?? '',
    );
    _dimensions = {
      for (final key in kMatterDimensionKeys)
        key: widget.initialReview?.dimensions[key] ?? 0,
    };
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ComposerShell(
      title: 'Compartir referencia sobre la materia',
      subtitle: widget.matterName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Balance general de la cursada',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _EditableReferenceScale(
            value: _rating,
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 8),
          Text(
            referenciasBalanceFromAverage(
              _rating.toDouble(),
              votes: _rating == 0 ? 0 : 1,
            ).label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Marca que rasgos describen mejor esta experiencia',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          ...kMatterDimensionKeys.map((key) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          matterDimensionLabel(key),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          matterDimensionScaleLabel(key, _dimensions[key] ?? 0),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _EditableReferenceScale(
                      value: _dimensions[key] ?? 0,
                      onChanged: (value) {
                        setState(() => _dimensions[key] = value);
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            minLines: 3,
            maxLines: 5,
            maxLength: 240,
            decoration: const InputDecoration(
              labelText: 'Referencia breve',
              hintText: 'Conta como se vivio la cursada, que peso tuvo y en que condiciones te resulto llevadera o dificil.',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving || _rating == 0 ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rate_review_rounded),
              label: Text(_saving ? 'Guardando...' : 'Guardar referencia'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    final canReview = ref.read(matterCanReviewProvider(widget.matterId));
    if (!canReview) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Primero verifica esta materia para poder compartir referencias.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(opinionesReviewsRepositoryProvider);
      await repo.upsertMatterReview(
        client: client,
        deviceId: deviceId,
        matterId: widget.matterId,
        careerId: widget.careerId,
        rating: _rating,
        dimensions: _dimensions,
        comment: _commentCtrl.text,
      );

      ref.invalidate(matterReviewsProvider(widget.matterId));
      ref.invalidate(ownMatterReviewProvider(widget.matterId));
      ref.invalidate(matterReviewSummaryProvider(widget.matterId));

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _TeacherReviewComposerSheet extends ConsumerStatefulWidget {
  const _TeacherReviewComposerSheet({
    required this.scope,
    required this.teacherName,
    required this.matterName,
    this.initialReview,
  });

  final TeacherReviewScope scope;
  final String teacherName;
  final String matterName;
  final TeacherReview? initialReview;

  @override
  ConsumerState<_TeacherReviewComposerSheet> createState() =>
      _TeacherReviewComposerSheetState();
}

class _TeacherReviewComposerSheetState
    extends ConsumerState<_TeacherReviewComposerSheet> {
  late int _general;
  late final TextEditingController _commentCtrl;
  late final Map<String, int> _dimensions;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _general = widget.initialReview?.general ?? 0;
    _commentCtrl = TextEditingController(
      text: widget.initialReview?.comment ?? '',
    );
    _dimensions = {
      for (final key in kTeacherDimensionKeys)
        key: widget.initialReview?.dimensions[key] ?? 0,
    };
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ComposerShell(
      title: 'Compartir referencia sobre el docente',
      subtitle: '${widget.teacherName} · ${widget.matterName}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Balance general en esta materia',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _EditableReferenceScale(
            value: _general,
            onChanged: (value) => setState(() => _general = value),
          ),
          const SizedBox(height: 8),
          Text(
            referenciasBalanceFromAverage(
              _general.toDouble(),
              votes: _general == 0 ? 0 : 1,
            ).label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          ...kTeacherDimensionKeys.map((key) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacherAspectLabel(key),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            teacherAspectScaleLabel(key, _dimensions[key] ?? 0),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _EditableReferenceScale(
                      value: _dimensions[key] ?? 0,
                      onChanged: (value) {
                        setState(() => _dimensions[key] = value);
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          TextField(
            controller: _commentCtrl,
            minLines: 3,
            maxLines: 5,
            maxLength: 240,
            decoration: const InputDecoration(
              labelText: 'Referencia breve',
              hintText: 'Conta como fue trabajar con este docente en esta materia y que marco la experiencia.',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _saving || _general == 0 ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rate_review_rounded),
              label: Text(_saving ? 'Guardando...' : 'Guardar referencia'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;
    final canReview = ref.read(matterCanReviewProvider(widget.scope.matterId));
    if (!canReview) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Necesitas verificar la materia antes de compartir referencias sobre docentes.',
            ),
          ),
        );
      }
      return;
    }

    setState(() => _saving = true);
    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      final repo = ref.read(opinionesReviewsRepositoryProvider);
      await repo.upsertTeacherReview(
        client: client,
        deviceId: deviceId,
        scope: widget.scope,
        general: _general,
        dimensions: _dimensions,
        comment: _commentCtrl.text,
      );

      ref.invalidate(teacherReviewsProvider(widget.scope.teacherId));
      ref.invalidate(ownTeacherReviewsForMatterProvider(widget.scope.matterId));
      ref.invalidate(teacherReviewSummaryProvider(widget.scope.teacherId));

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _ComposerShell extends StatelessWidget {
  const _ComposerShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final insets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + insets.bottom),
      child: Material(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditableReferenceScale extends StatelessWidget {
  const _EditableReferenceScale({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const palette = <Color>[
      Color(0xFFC96F5D),
      Color(0xFFD9A35F),
      Color(0xFFDDD6C8),
      Color(0xFF58AEB1),
      Color(0xFF0A6C8E),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List<Widget>.generate(5, (index) {
            final step = index + 1;
            final selected = step <= value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 4 ? 0 : 6),
                child: InkWell(
                  onTap: () => onChanged(value == step ? 0 : step),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    height: 16,
                    decoration: BoxDecoration(
                      color: selected
                          ? palette[index]
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: selected
                            ? palette[index]
                            : theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          value == 0 ? 'Sin marcar' : 'Toca el mismo nivel para limpiar',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
