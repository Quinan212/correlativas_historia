import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../admin_access/screens/admin_access_screen.dart';
import '../../verification/models/matter_verification_state.dart';
import '../../verification/providers/verification_providers.dart';
import '../models/opiniones_catalog.dart';
import '../models/opiniones_review_models.dart';
import '../providers/opiniones_providers.dart';
import '../providers/opiniones_review_providers.dart';
import '../utils/referencias_labels.dart';
import 'docente_detail_sheet.dart';
import 'referencias_balance_bar.dart';
import 'review_composer_sheets.dart';

class MateriaComunidadSection extends ConsumerWidget {
  const MateriaComunidadSection({
    super.key,
    required this.materia,
    required this.careerId,
  });

  final Materia materia;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(matterReviewSummaryProvider(materia.id));
    final tendencyTexts = buildMatterReferenceInsights(summary.dimensions);
    final ownReview = ref.watch(ownMatterReviewProvider(materia.id)).valueOrNull;
    final docentes = ref.watch(docentesPorMateriaProvider(materia.id));
    final verification = ref.watch(matterVerificationStateProvider(materia.id));
    final showVerificationAction =
        verification.status != MatterVerificationStatus.approved;
    final commentProfilesAsync = ref.watch(
      deviceProfilesByIdsProvider(
        serializeDeviceIds(summary.comments.map((item) => item.deviceId)),
      ),
    );
    final commentProfiles = commentProfilesAsync.valueOrNull ??
        const <String, DeviceProfile>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ComunidadCard(
          title: 'Referencias de cursada',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _VerificationChip(state: verification),
                  if (ownReview != null)
                    const _MiniStateBadge(label: 'Ya dejaste una referencia'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Balance general de referencias',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              ReferenciasBalanceBar(
                average: summary.rating.promedio,
                votes: summary.rating.votos,
              ),
              const SizedBox(height: 12),
              Text(
                verification.status == MatterVerificationStatus.approved
                    ? 'Ya podes compartir tu referencia sobre esta materia desde este dispositivo.'
                    : 'Primero verifica que cursas esta materia para poder compartir tu referencia.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Las referencias publicas se muestran de forma anonima por defecto. Si alguien elige un alias publico, solo se muestra ese alias.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              _VerificationBanner(state: verification),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: verification.canReview
                        ? () {
                            showMatterReviewComposerSheet(
                              context: context,
                              ref: ref,
                              matterId: materia.id,
                              matterName: materia.displayNombre,
                              careerId: careerId,
                              initialReview: ownReview,
                            );
                          }
                        : null,
                    icon: const Icon(Icons.rate_review_rounded),
                    label: Text(
                      ownReview == null
                          ? 'Compartir referencia'
                          : 'Editar referencia',
                    ),
                  ),
                  if (showVerificationAction)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AdminAccessScreen(
                              initialCareerId: careerId,
                              initialMatterId: materia.id,
                              lockMatterSelection: true,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.verified_user_outlined),
                      label: Text(
                        verification.isPending
                            ? 'Ver estado de la verificacion'
                            : 'Verificar esta materia',
                      ),
                    ),
                ],
              ),
              if (ownReview != null) ...[
                const SizedBox(height: 12),
                _OwnMatterReviewBox(review: ownReview),
              ],
              if (tendencyTexts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Tendencias que aparecen en las referencias',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...tendencyTexts.map(
                  (text) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
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
              if (summary.dimensions.values.any((item) => item.votos > 0)) ...[
                const SizedBox(height: 12),
                Text(
                  'Referencias por eje',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.dimensions.entries
                    .where((entry) => entry.value.votos > 0)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 140,
                              child: Text(
                                matterDimensionLabel(entry.key),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ReferenciasBalanceBar(
                                average: entry.value.promedio,
                                votes: entry.value.votos,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
              if (summary.comments.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Referencias recientes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.comments.map(
                  (comment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commentProfiles[comment.deviceId]?.publicDisplayLabel ??
                              'Referencia anonima',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '"${comment.comment}"',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _ComunidadCard(
          title: 'Docentes vinculados',
          child: docentes.isEmpty
              ? Text(
                  'Todavia no encontramos docentes vinculados desde los cronogramas cargados.',
                  style: theme.textTheme.bodyMedium,
                )
              : Column(
                  children: docentes
                      .map(
                        (docente) => _DocenteTile(
                          docente: docente,
                          matter: materia,
                          careerId: careerId,
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
      ],
    );
  }
}

class _ComunidadCard extends StatelessWidget {
  const _ComunidadCard({
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
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(18),
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _VerificationChip extends StatelessWidget {
  const _VerificationChip({required this.state});

  final MatterVerificationState state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (state.status) {
      MatterVerificationStatus.approved => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
        ),
      MatterVerificationStatus.pending => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
        ),
      MatterVerificationStatus.rejected => (
          const Color(0xFFFEE2E2),
          const Color(0xFF991B1B),
        ),
      MatterVerificationStatus.unverified => (
          const Color(0xFFE2E8F0),
          const Color(0xFF334155),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        state.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _VerificationBanner extends StatelessWidget {
  const _VerificationBanner({required this.state});

  final MatterVerificationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (bg, border, icon, title, body) = switch (state.status) {
      MatterVerificationStatus.approved => (
          const Color(0xFFECFDF5),
          const Color(0xFFA7F3D0),
          Icons.verified_rounded,
          'Ya podes opinar',
          'La verificacion ya fue aprobada. Desde este dispositivo podes opinar sobre esta materia y sus docentes.',
        ),
      MatterVerificationStatus.pending => (
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          Icons.hourglass_top_rounded,
          'Verificacion pendiente',
          'Ya enviaste la captura. Cuando la revisemos, desde este dispositivo vas a poder opinar sobre esta materia y sus docentes.',
        ),
      MatterVerificationStatus.rejected => (
          const Color(0xFFFEF2F2),
          const Color(0xFFFECACA),
          Icons.report_gmailerrorred_rounded,
          'Necesita nueva captura',
          'La verificacion anterior no fue valida. Podes volver a enviar una imagen mas clara del campus.',
        ),
      MatterVerificationStatus.unverified => (
          const Color(0xFFF8FAFC),
          const Color(0xFFE2E8F0),
          Icons.shield_outlined,
          'Todavia no verificada',
          'Subi una captura del campus para demostrar que cursas esta materia y habilitar referencias desde este dispositivo.',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnMatterReviewBox extends StatelessWidget {
  const _OwnMatterReviewBox({required this.review});

  final MatterReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tu referencia actual',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ReferenciasBalanceBar(
            average: review.rating.toDouble(),
            votes: 1,
            showVotes: false,
          ),
          if (review.tags.isNotEmpty && review.dimensions.isEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.tags
                  .map((tag) => Chip(label: Text(matterTagLabel(tag))))
                  .toList(growable: false),
            ),
          ],
          if (review.dimensions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: review.dimensions.entries
                  .where((entry) => entry.value > 0)
                  .map(
                    (entry) => Chip(
                      label: Text(
                        '${matterDimensionLabel(entry.key)} · ${matterDimensionScaleLabel(entry.key, entry.value)}',
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          if ((review.comment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${review.comment!.trim()}"',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _DocenteTile extends ConsumerWidget {
  const _DocenteTile({
    required this.docente,
    required this.matter,
    required this.careerId,
  });

  final DocenteLite docente;
  final Materia matter;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(teacherReviewSummaryProvider(docente.id));
    final ownReview = ref
        .watch(
          ownTeacherReviewProvider(
            TeacherReviewScope(
              teacherId: docente.id,
              matterId: matter.id,
              careerId: careerId,
            ),
          ),
        )
        .valueOrNull;

    return InkWell(
      onTap: () {
        showDocenteDetailSheet(
          context: context,
          ref: ref,
          docente: docente,
          matterId: matter.id,
          matterName: matter.displayNombre,
          careerId: careerId,
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF111827)
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF243041)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    docente.nombre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ReferenciasBalanceBadge(
                        average: summary.general.promedio,
                        votes: summary.general.votos,
                      ),
                      Text(
                        summary.general.votos == 0
                            ? 'Todavia sin referencias'
                            : '${summary.general.votos} referencias',
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${docente.apariciones} apariciones',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (ownReview != null)
                        Text(
                          'Ya dejaste una referencia',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _MiniStateBadge extends StatelessWidget {
  const _MiniStateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
