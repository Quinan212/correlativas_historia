import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/materia.dart';
import '../../admin_access/providers/admin_access_providers.dart';
import '../../../shared/device_identity/device_identity.dart';
import '../../../shared/performance/app_performance.dart';
import '../../../shared/supabase/supabase.dart';
import '../../admin_access/screens/admin_access_screen.dart';
import '../../verification/models/matter_verification_state.dart';
import '../../verification/models/verification_upload_image.dart';
import '../../verification/providers/verification_providers.dart';
import '../../verification/screens/verification_image_editor_screen.dart';
import '../config/opiniones_visibility.dart';
import '../models/opiniones_catalog.dart';
import '../models/matter_photo_post.dart';
import '../models/opiniones_review_models.dart';
import '../providers/opiniones_providers.dart';
import '../providers/opiniones_review_providers.dart';
import '../utils/referencias_labels.dart';
import 'docente_detail_sheet.dart';
import 'referencias_balance_bar.dart';
import 'review_composer_sheets.dart';

class MateriaComunidadSection extends StatelessWidget {
  const MateriaComunidadSection({
    super.key,
    required this.materia,
    required this.careerId,
  });

  final Materia materia;
  final String careerId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MatterReferencesCard(
          materia: materia,
          careerId: careerId,
        ),
        const SizedBox(height: 14),
        _MatterTeachersCard(
          materia: materia,
          careerId: careerId,
        ),
      ],
    );
  }
}

class _MatterReferencesCard extends ConsumerWidget {
  const _MatterReferencesCard({
    required this.materia,
    required this.careerId,
  });

  final Materia materia;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (!kShowOpinionUi) {
      final verification = ref.watch(matterVerificationStateProvider(materia.id));
      return RepaintBoundary(
        child: _ComunidadCard(
          title: 'Fotos de cursada',
          child: _MatterPhotoGallerySection(
            matter: materia,
            careerId: careerId,
            verification: verification,
          ),
        ),
      );
    }
    final summary = ref.watch(matterReviewSummaryProvider(materia.id));
    final tendencyTexts = buildMatterReferenceInsights(summary.dimensions);
    final ownReview =
        ref.watch(ownMatterReviewProvider(materia.id)).valueOrNull;
    final verification = ref.watch(matterVerificationStateProvider(materia.id));
    final showVerificationAction =
        verification.status != MatterVerificationStatus.approved;

    return RepaintBoundary(
      child: _ComunidadCard(
        title: 'Referencias de cursada',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MatterPhotoGallerySection(
              matter: materia,
              careerId: careerId,
              verification: verification,
            ),
            const SizedBox(height: 12),
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
                  ? 'Ya podés compartir una referencia situada sobre esta materia desde este dispositivo.'
                  : 'Primero verificá que cursás esta materia para poder compartir una referencia desde esa experiencia concreta.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Estas referencias no buscan calificar personas ni fijar verdades definitivas. Reúnen experiencias de cursada y se muestran de forma anónima por defecto. Si alguien elige un alias público, solo se muestra ese alias.',
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
                'Lecturas que emergen de las referencias',
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
                'Lectura por eje',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReferenciasBalanceBar(
                                  average: entry.value.promedio,
                                  votes: entry.value.votos,
                                  showVotes: false,
                                ),
                                const SizedBox(height: 8),
                                ReferenciasReadingBadge(
                                  rating: entry.value,
                                ),
                              ],
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
                'Experiencias compartidas',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              _MatterCommentsSection(comments: summary.comments),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatterPhotoGallerySection extends ConsumerWidget {
  const _MatterPhotoGallerySection({
    required this.matter,
    required this.careerId,
    required this.verification,
  });

  final Materia matter;
  final String careerId;
  final MatterVerificationState verification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPosts =
        ref.watch(matterPhotoPostsProvider(matter.id)).valueOrNull ??
            const <MatterPhotoPost>[];

    return _MatterPhotoGallery(
      matter: matter,
      careerId: careerId,
      verification: verification,
      photoPosts: photoPosts,
    );
  }
}

class _MatterCommentsSection extends ConsumerWidget {
  const _MatterCommentsSection({required this.comments});

  final List<ReviewCommentSnippet> comments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final commentProfilesAsync = ref.watch(
      deviceProfilesByIdsProvider(
        serializeDeviceIds(comments.map((item) => item.deviceId)),
      ),
    );
    final commentProfiles =
        commentProfilesAsync.valueOrNull ?? const <String, DeviceProfile>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: comments
          .map(
            (comment) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commentProfiles[comment.deviceId]?.publicDisplayLabel ??
                        'Referencia anónima',
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
          )
          .toList(growable: false),
    );
  }
}

class _MatterTeachersCard extends ConsumerWidget {
  const _MatterTeachersCard({
    required this.materia,
    required this.careerId,
  });

  final Materia materia;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kShowOpinionUi) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final docentes = ref.watch(docentesPorMateriaProvider(materia.id));

    return RepaintBoundary(
      child: _ComunidadCard(
        title: 'Docentes vinculados',
        child: docentes.isEmpty
            ? Text(
                'Todavía no encontramos docentes vinculados desde los cronogramas cargados.',
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
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                  color: Colors.black.withOpacity(0.035),
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

class _MatterPhotoGallery extends ConsumerStatefulWidget {
  static const double _tileWidth = 210;
  static const double _tileHeight = 320;
  const _MatterPhotoGallery({
    required this.matter,
    required this.careerId,
    required this.verification,
    required this.photoPosts,
  });

  final Materia matter;
  final String careerId;
  final MatterVerificationState verification;
  final List<MatterPhotoPost> photoPosts;

  @override
  ConsumerState<_MatterPhotoGallery> createState() =>
      _MatterPhotoGalleryState();
}

class _MatterPhotoGalleryState extends ConsumerState<_MatterPhotoGallery> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _MatterPhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPosts.length != widget.photoPosts.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escenas de cursada',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Una imagen también puede sumar contexto: una selfie con tu grupo, un material, una producción o una escena simple de la cursada.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _MatterPhotoGallery._tileHeight,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount:
                widget.photoPosts.isEmpty ? 1 : widget.photoPosts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MatterPhotoAddCard(
                  width: _MatterPhotoGallery._tileWidth,
                  height: _MatterPhotoGallery._tileHeight,
                  enabled: true,
                  onTap: () => _handleAddPhoto(context),
                );
              }

              final post = widget.photoPosts[index - 1];
              return _MatterPhotoTile(
                width: _MatterPhotoGallery._tileWidth,
                height: _MatterPhotoGallery._tileHeight,
                post: post,
                posts: widget.photoPosts,
                initialIndex: index - 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleAddPhoto(BuildContext context) async {
    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    final repo = ref.read(opinionesReviewsRepositoryProvider);
    final sourceImage = await repo.pickMatterPhoto();
    if (sourceImage == null || !context.mounted) return;

    final editedImage =
        await Navigator.of(context).push<VerificationUploadImage>(
      MaterialPageRoute<VerificationUploadImage>(
        builder: (_) => VerificationImageEditorScreen(sourceImage: sourceImage),
      ),
    );
    if (editedImage == null || !context.mounted) return;

    final captionController = TextEditingController();
    final caption = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sumar imagen de cursada'),
        content: TextField(
          controller: captionController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText:
                'Si querés, agregá una frase breve sobre la escena, el grupo o ese momento de cursada.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(captionController.text),
            child: const Text('Compartir'),
          ),
        ],
      ),
    );
    captionController.dispose();
    if (caption == null || !context.mounted) return;

    final uploadTrace = await AppPerformance.startTrace(
      'matter_photo_upload',
      attributes: {
        'career_id': widget.careerId,
        'matter_id': widget.matter.id,
      },
    );
    var traceStopped = false;

    try {
      final deviceId = await ref.read(deviceIdProvider.future);
      await repo.createMatterPhotoPost(
        client: client,
        deviceId: deviceId,
        matterId: widget.matter.id,
        careerId: widget.careerId,
        image: editedImage,
        caption: caption,
      );
      await AppPerformance.stopTrace(
        uploadTrace,
        metrics: {
          'success': 1,
          'caption_provided': caption.trim().isEmpty ? 0 : 1,
        },
      );
      traceStopped = true;
      ref.invalidate(matterPhotoPostsProvider(widget.matter.id));
      await ref.read(matterPhotoPostsProvider(widget.matter.id).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('La imagen se compartió en la comunidad de la materia.'),
          ),
        );
      }
    } catch (error) {
      if (!traceStopped) {
        await AppPerformance.stopTrace(
          uploadTrace,
          metrics: const {'success': 0},
        );
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo compartir la imagen: $error'),
          ),
        );
      }
    }
  }
}

class _MatterPhotoAddCard extends StatelessWidget {
  const _MatterPhotoAddCard({
    required this.width,
    required this.height,
    required this.enabled,
    required this.onTap,
  });

  final double width;
  final double height;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _MatterPhotoTileFrame(
      width: width,
      height: height,
      backgroundColor: const Color(0xFFEAF8FC),
      borderColor: const Color(0xFF8FD0E1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 34,
              color:
                  enabled ? const Color(0xFF0B657A) : const Color(0xFF5E7F88),
            ),
            const SizedBox(height: 12),
            Text(
              enabled
                  ? 'Comparte algo de la cursada'
                  : 'Verifica la materia para sumar imágenes',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0B657A),
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              enabled
                  ? 'Selfie, grupo o una escena simple de la materia.'
                  : 'Cuando la materia quede habilitada, desde aquí vas a poder sumar imágenes.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF255764),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatterPhotoTile extends StatelessWidget {
  const _MatterPhotoTile({
    required this.width,
    required this.height,
    required this.post,
    required this.posts,
    required this.initialIndex,
  });

  final double width;
  final double height;
  final MatterPhotoPost post;
  final List<MatterPhotoPost> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (width * pixelRatio).round();
    return RepaintBoundary(
      child: _MatterPhotoTileFrame(
        width: width,
        height: height,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        borderColor: theme.colorScheme.outlineVariant,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _MatterPhotoPreviewScreen(
                posts: posts,
                initialIndex: initialIndex,
              ),
            ),
          );
        },
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            width: width,
            height: height,
            cacheWidth: cacheWidth,
            // cacheHeight eliminado: especificar ambas distorsiona la imagen.
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 34),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatterPhotoTileFrame extends StatelessWidget {
  const _MatterPhotoTileFrame({
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
    this.onTap,
  });

  final double width;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
        ),
        child: ClipRRect(
          clipBehavior: Clip.hardEdge,
          borderRadius: BorderRadius.circular(22),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: SizedBox.expand(child: child),
          ),
        ),
      ),
    );
  }
}

class _MatterPhotoPreviewScreen extends StatelessWidget {
  const _MatterPhotoPreviewScreen({
    required this.posts,
    required this.initialIndex,
  });

  final List<MatterPhotoPost> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _MatterPhotoPreviewPager(
      posts: posts,
      initialIndex: initialIndex,
      theme: theme,
    );
  }
}

class _MatterPhotoPreviewPager extends ConsumerStatefulWidget {
  const _MatterPhotoPreviewPager({
    required this.posts,
    required this.initialIndex,
    required this.theme,
  });

  final List<MatterPhotoPost> posts;
  final int initialIndex;
  final ThemeData theme;

  @override
  ConsumerState<_MatterPhotoPreviewPager> createState() =>
      _MatterPhotoPreviewPagerState();
}

class _MatterPhotoPreviewPagerState
    extends ConsumerState<_MatterPhotoPreviewPager> {
  late final PageController _controller;
  late int _currentIndex;
  late List<MatterPhotoPost> _posts;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _posts = List<MatterPhotoPost>.from(widget.posts);
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPost = _posts[_currentIndex];
    final adminStatus = ref.watch(adminDeviceStatusProvider).valueOrNull;
    final canModerate = adminStatus?.isAdmin == true;
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagen ${_currentIndex + 1} de ${_posts.length}'),
        actions: [
          if (canModerate)
            IconButton(
              tooltip: 'Quitar imagen',
              onPressed: () => _handleDeleteCurrentPhoto(
                context: context,
                adminDeviceId: adminStatus!.deviceId,
              ),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: _posts.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _ZoomableMatterPhoto(imageUrl: post.imageUrl);
              },
            ),
          ),
          if ((currentPost.caption ?? '').trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Text(
                currentPost.caption!.trim(),
                style: widget.theme.textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteCurrentPhoto({
    required BuildContext context,
    required String adminDeviceId,
  }) async {
    final currentPost = _posts[_currentIndex];
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Quitar imagen'),
            content: const Text(
              'Esta imagen dejara de verse en la comunidad de la materia. Puedes usar esta accion si el contenido no corresponde.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Quitar'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldDelete || !context.mounted) return;

    final client = ref.read(supabaseClientProvider);
    if (client == null) return;

    try {
      final repo = ref.read(opinionesReviewsRepositoryProvider);
      await repo.deleteMatterPhotoPost(
        client: client,
        adminDeviceId: adminDeviceId,
        photoId: currentPost.id,
      );
      ref.invalidate(matterPhotoPostsProvider(currentPost.matterId));

      if (_posts.length == 1) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La imagen fue retirada de la comunidad.'),
            ),
          );
        }
        return;
      }

      final updatedPosts = List<MatterPhotoPost>.from(_posts)
        ..removeAt(_currentIndex);
      final nextIndex = _currentIndex.clamp(0, updatedPosts.length - 1);

      setState(() {
        _posts = updatedPosts;
        _currentIndex = nextIndex;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.hasClients) {
          _controller.jumpToPage(nextIndex);
        }
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen fue retirada de la comunidad.'),
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo quitar la imagen: $error'),
          ),
        );
      }
    }
  }
}

class _ZoomableMatterPhoto extends StatefulWidget {
  const _ZoomableMatterPhoto({required this.imageUrl});

  final String imageUrl;

  @override
  State<_ZoomableMatterPhoto> createState() => _ZoomableMatterPhotoState();
}

class _ZoomableMatterPhotoState extends State<_ZoomableMatterPhoto> {
  late final TransformationController _transformationController;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final details = _doubleTapDetails;
    if (details == null) return;

    final isIdentity = _transformationController.value.isIdentity();
    if (!isIdentity) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    const scale = 2.5;
    final position = details.localPosition;
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(
        -position.dx * (scale - 1),
        -position.dy * (scale - 1),
        0,
        1,
      )
      ..scaleByDouble(scale, scale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (size.width * pixelRatio * 1.2).round();

    return GestureDetector(
      onDoubleTapDown: (details) => _doubleTapDetails = details,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        clipBehavior: Clip.none,
        minScale: 1,
        maxScale: 5,
        boundaryMargin: const EdgeInsets.all(32),
        child: Center(
          child: Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            cacheWidth: cacheWidth,
            // cacheHeight eliminado: especificar ambas distorsiona la imagen.
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              size: 40,
            ),
          ),
        ),
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
    if (!kShowOpinionUi) {
      return const SizedBox.shrink();
    }
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

