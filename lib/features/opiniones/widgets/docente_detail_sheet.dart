import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../verification/providers/verification_providers.dart';
import '../models/opiniones_catalog.dart';
import '../models/opiniones_review_models.dart';
import '../providers/opiniones_providers.dart';
import '../providers/opiniones_review_providers.dart';
import '../utils/referencias_labels.dart';
import 'referencias_balance_bar.dart';
import 'review_composer_sheets.dart';

Future<void> showDocenteDetailSheet({
  required BuildContext context,
  required WidgetRef ref,
  required DocenteLite docente,
  required String matterId,
  required String matterName,
  required String careerId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FractionallySizedBox(
      heightFactor: 0.9,
      child: _DocenteDetailSheet(
        docente: docente,
        matterId: matterId,
        matterName: matterName,
        careerId: careerId,
      ),
    ),
  );
}

class _DocenteDetailSheet extends ConsumerWidget {
  const _DocenteDetailSheet({
    required this.docente,
    required this.matterId,
    required this.matterName,
    required this.careerId,
  });

  final DocenteLite docente;
  final String matterId;
  final String matterName;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final base = ref.watch(docenteBaseProvider(docente.id));
    final summary = ref.watch(teacherReviewSummaryProvider(docente.id));
    final tendencyTexts = buildTeacherReferenceInsights(summary.aspectos);
    final ownReview = ref
        .watch(
          ownTeacherReviewProvider(
            TeacherReviewScope(
              teacherId: docente.id,
              matterId: matterId,
              careerId: careerId,
            ),
          ),
        )
        .valueOrNull;
    final verification = ref.watch(matterVerificationStateProvider(matterId));
    final reviews = ref.watch(teacherReviewsProvider(docente.id)).valueOrNull ??
        const <TeacherReview>[];

    final matterNameById = <String, String>{
      for (final materia in base?.materias ?? const <MateriaLite>[])
        materia.id: materia.nombre,
    };

    final commentedReviews = reviews
        .where((review) => (review.comment ?? '').trim().isNotEmpty)
        .toList(growable: false);
    final commentProfilesAsync = ref.watch(
      deviceProfilesByIdsProvider(
        serializeDeviceIds(commentedReviews.map((item) => item.deviceId)),
      ),
    );
    final commentProfiles =
        commentProfilesAsync.valueOrNull ?? const <String, DeviceProfile>{};

    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Material(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          docente.nombre,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Balance general de referencias',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ReferenciasBalanceBar(
                          average: summary.general.promedio,
                          votes: summary.general.votos,
                        ),
                        const SizedBox(height: 10),
                        _MiniBadge(
                          label: '${docente.apariciones} apariciones',
                        ),
                        const SizedBox(height: 18),
                        _SheetCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tu referencia actual',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                verification.canReview
                                    ? 'Ya podes compartir una referencia sobre este docente desde esta materia.'
                                    : 'Primero verifica que cursas esta materia para poder compartir referencias sobre sus docentes.',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Las referencias publicas se muestran de forma anonima por defecto. Si alguien elige un alias publico, se muestra solo ese alias.',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 12),
                              if (ownReview != null) ...[
                                ReferenciasBalanceBar(
                                  average: ownReview.general.toDouble(),
                                  votes: 1,
                                  showVotes: false,
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: ownReview.dimensions.entries
                                      .where((entry) => entry.value > 0)
                                      .map(
                                        (entry) => _MiniBadge(
                                          label:
                                              '${_aspectLabel(entry.key)} · ${teacherAspectScaleLabel(entry.key, entry.value)}',
                                        ),
                                      )
                                      .toList(growable: false),
                                ),
                                if ((ownReview.comment ?? '')
                                    .trim()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    '“${ownReview.comment!.trim()}”',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                                const SizedBox(height: 12),
                              ],
                              if (verification.canReview)
                                FilledButton.icon(
                                  onPressed: () {
                                    showTeacherReviewComposerSheet(
                                      context: context,
                                      ref: ref,
                                      scope: TeacherReviewScope(
                                        teacherId: docente.id,
                                        matterId: matterId,
                                        careerId: careerId,
                                      ),
                                      teacherName: docente.nombre,
                                      matterName: matterName,
                                      initialReview: ownReview,
                                    );
                                  },
                                  icon: const Icon(Icons.rate_review_rounded),
                                  label: Text(
                                    ownReview == null
                                        ? 'Compartir referencia'
                                        : 'Editar referencia',
                                  ),
                                )
                              else
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon:
                                      const Icon(Icons.verified_user_outlined),
                                  label: const Text('Volver'),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (tendencyTexts.isNotEmpty) ...[
                          _SheetCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tendencias que aparecen en las referencias',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...tendencyTexts.map(
                                  (text) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Icon(
                                            Icons.remove_rounded,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            text,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _SheetCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Referencias por aspecto',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...summary.aspectos.entries.map((entry) {
                                final item = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 110,
                                        child: Text(
                                          _aspectLabel(entry.key),
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: item.votos == 0
                                            ? Text(
                                                'Sin referencias',
                                                style:
                                                    theme.textTheme.bodyMedium,
                                              )
                                            : Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        ReferenciasBalanceBar(
                                                      average: item.promedio,
                                                      votes: item.votos,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SheetCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Materias donde aparece',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (base == null || base.materias.isEmpty)
                                Text(
                                  'Todavia no hay materias vinculadas para este docente.',
                                  style: theme.textTheme.bodyMedium,
                                )
                              else
                                ...base.materias.map((materia) {
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    title: Text(materia.nombre),
                                    subtitle: Text('${materia.anio}° año'),
                                    trailing:
                                        const Icon(Icons.chevron_right_rounded),
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(selectedMateriaIdProvider
                                              .notifier)
                                          .state = materia.id;
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }),
                            ],
                          ),
                        ),
                        if (commentedReviews.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _SheetCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Referencias recientes',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...commentedReviews.take(4).map(
                                      (review) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                ReferenciasBalanceBadge(
                                                  average:
                                                      review.general.toDouble(),
                                                  votes: 1,
                                                ),
                                                _MiniBadge(
                                                  label: matterNameById[
                                                          review.matterId] ??
                                                      review.matterId,
                                                ),
                                                _MiniBadge(
                                                  label: commentProfiles[
                                                              review.deviceId]
                                                          ?.publicDisplayLabel ??
                                                      'Referencia anonima',
                                                ),
                                                Text(
                                                  _formatDate(review.updatedAt),
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '“${review.comment!.trim()}”',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Volver'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetCard extends StatelessWidget {
  const _SheetCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE2E8F0),
        ),
      ),
      child: child,
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _aspectLabel(String key) {
  return teacherAspectLabel(key);
}

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day/$month/$year';
}
