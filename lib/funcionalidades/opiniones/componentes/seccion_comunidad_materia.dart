import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../../administrador/proveedores/proveedores_acceso_administrador.dart';
import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/rendimiento/rendimiento_app.dart';
import '../../../compartido/supabase/supabase.dart';
import '../../administrador/pantallas/acceso_administrador_pantalla.dart';
import '../../verificacion/modelos/estado_verificacion_materia.dart';
import '../../verificacion/modelos/imagen_subida_verificacion.dart';
import '../../verificacion/proveedores/proveedores_verificacion.dart';
import '../../verificacion/pantallas/editor_imagen_verificacion_pantalla.dart';
import '../configuracion/visibilidad_opiniones.dart';
import '../modelos/catalogo_opiniones.dart';
import '../modelos/publicacion_foto_materia.dart';
import '../modelos/modelos_resenas_opiniones.dart';
import '../proveedores/opiniones_providers.dart';
import '../proveedores/proveedores_resenas_opiniones.dart';
import '../utilidades/etiquetas_referencias.dart';
import 'hoja_detalle_docente.dart';
import 'barra_balance_referencias.dart';
import 'hojas_compositor_resenas.dart';

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
        _TarjetaReferenciasMateria(
          materia: materia,
          careerId: careerId,
        ),
        const SizedBox(height: 14),
        _TarjetaDocentesMateria(
          materia: materia,
          careerId: careerId,
        ),
      ],
    );
  }
}

class _TarjetaReferenciasMateria extends ConsumerWidget {
  const _TarjetaReferenciasMateria({
    required this.materia,
    required this.careerId,
  });

  final Materia materia;
  final String careerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    if (!kShowOpinionUi) {
      final verification =
          ref.watch(proveedorEstadoVerificacionMateria(materia.id));
      return RepaintBoundary(
        child: _ComunidadCard(
          title: 'Fotos de cursada',
          child: _SeccionGaleriaFotosMateria(
            matter: materia,
            careerId: careerId,
            verification: verification,
          ),
        ),
      );
    }
    final summary = ref.watch(proveedorResumenResenasMateria(materia.id));
    final tendencyTexts = buildMatterReferenceInsights(summary.dimensions);
    final ownReview =
        ref.watch(proveedorResenaMateriaPropia(materia.id)).valueOrNull;
    final verification =
        ref.watch(proveedorEstadoVerificacionMateria(materia.id));
    final showVerificationAction =
        verification.status != SituacionVerificacionMateria.approved;

    return RepaintBoundary(
      child: _ComunidadCard(
        title: 'Referencias de cursada',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SeccionGaleriaFotosMateria(
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
                _ChipVerificacion(state: verification),
                if (ownReview != null)
                  const _MiniStateInsignia(label: 'Ya dejaste una referencia'),
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
            BarraBalanceReferencias(
              average: summary.rating.promedio,
              votes: summary.rating.votos,
            ),
            const SizedBox(height: 12),
            Text(
              verification.status == SituacionVerificacionMateria.approved
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
            _BannerVerificacion(state: verification),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: verification.canReview
                      ? () {
                          mostrarHojaCompositorResenaMateria(
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
                          builder: (_) => AccesoAdministradorPantalla(
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
              _CajaResenaMateriaPropia(review: ownReview),
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
                              etiquetaDimensionMateria(entry.key),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BarraBalanceReferencias(
                                  average: entry.value.promedio,
                                  votes: entry.value.votos,
                                  showVotes: false,
                                ),
                                const SizedBox(height: 8),
                                ReferenciasReadingInsignia(
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
              _SeccionComentariosMateria(comments: summary.comments),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeccionGaleriaFotosMateria extends ConsumerWidget {
  const _SeccionGaleriaFotosMateria({
    required this.matter,
    required this.careerId,
    required this.verification,
  });

  final Materia matter;
  final String careerId;
  final EstadoVerificacionMateria verification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoPosts =
        ref.watch(proveedorPublicacionesFotoMateria(matter.id)).valueOrNull ??
            const <PublicacionFotoMateria>[];

    return _GaleriaFotosMateria(
      matter: matter,
      careerId: careerId,
      verification: verification,
      photoPosts: photoPosts,
    );
  }
}

class _SeccionComentariosMateria extends ConsumerWidget {
  const _SeccionComentariosMateria({required this.comments});

  final List<ReviewCommentSnippet> comments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final commentProfilesAsync = ref.watch(
      proveedorPerfilesDispositivoPorIds(
        serializeDeviceIds(comments.map((item) => item.deviceId)),
      ),
    );
    final commentProfiles =
        commentProfilesAsync.valueOrNull ?? const <String, PerfilDispositivo>{};

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

class _TarjetaDocentesMateria extends ConsumerWidget {
  const _TarjetaDocentesMateria({
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

class _ChipVerificacion extends StatelessWidget {
  const _ChipVerificacion({required this.state});

  final EstadoVerificacionMateria state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (state.status) {
      SituacionVerificacionMateria.approved => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
        ),
      SituacionVerificacionMateria.pending => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
        ),
      SituacionVerificacionMateria.rejected => (
          const Color(0xFFFEE2E2),
          const Color(0xFF991B1B),
        ),
      SituacionVerificacionMateria.unverified => (
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

class _BannerVerificacion extends StatelessWidget {
  const _BannerVerificacion({required this.state});

  final EstadoVerificacionMateria state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (bg, border, icon, title, body) = switch (state.status) {
      SituacionVerificacionMateria.approved => (
          const Color(0xFFECFDF5),
          const Color(0xFFA7F3D0),
          Icons.verified_rounded,
          'Ya podes opinar',
          'La verificacion ya fue aprobada. Desde este dispositivo podes opinar sobre esta materia y sus docentes.',
        ),
      SituacionVerificacionMateria.pending => (
          const Color(0xFFFFFBEB),
          const Color(0xFFFDE68A),
          Icons.hourglass_top_rounded,
          'Verificacion pendiente',
          'Ya enviaste la captura. Cuando la revisemos, desde este dispositivo vas a poder opinar sobre esta materia y sus docentes.',
        ),
      SituacionVerificacionMateria.rejected => (
          const Color(0xFFFEF2F2),
          const Color(0xFFFECACA),
          Icons.report_gmailerrorred_rounded,
          'Necesita nueva captura',
          'La verificacion anterior no fue valida. Podes volver a enviar una imagen mas clara del campus.',
        ),
      SituacionVerificacionMateria.unverified => (
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

class _CajaResenaMateriaPropia extends StatelessWidget {
  const _CajaResenaMateriaPropia({required this.review});

  final ResenaMateria review;

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
          BarraBalanceReferencias(
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
                  .map((tag) => Chip(label: Text(etiquetaTagMateria(tag))))
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
                        '${etiquetaDimensionMateria(entry.key)} · ${etiquetaEscalaDimensionMateria(entry.key, entry.value)}',
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

class _GaleriaFotosMateria extends ConsumerStatefulWidget {
  static const double _tileWidth = 210;
  static const double _tileHeight = 320;
  const _GaleriaFotosMateria({
    required this.matter,
    required this.careerId,
    required this.verification,
    required this.photoPosts,
  });

  final Materia matter;
  final String careerId;
  final EstadoVerificacionMateria verification;
  final List<PublicacionFotoMateria> photoPosts;

  @override
  ConsumerState<_GaleriaFotosMateria> createState() =>
      _GaleriaFotosMateriaState();
}

class _GaleriaFotosMateriaState extends ConsumerState<_GaleriaFotosMateria> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant _GaleriaFotosMateria oldWidget) {
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
          height: _GaleriaFotosMateria._tileHeight,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount:
                widget.photoPosts.isEmpty ? 1 : widget.photoPosts.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _TarjetaAgregarFotoMateria(
                  width: _GaleriaFotosMateria._tileWidth,
                  height: _GaleriaFotosMateria._tileHeight,
                  enabled: true,
                  onTap: () => _manejarAgregarFoto(context),
                );
              }

              final post = widget.photoPosts[index - 1];
              return _MosaicoFotoMateria(
                width: _GaleriaFotosMateria._tileWidth,
                height: _GaleriaFotosMateria._tileHeight,
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

  Future<void> _manejarAgregarFoto(BuildContext context) async {
    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    final repo = ref.read(proveedorRepositorioResenasOpiniones);
    final sourceImage = await repo.seleccionarFotoMateria();
    if (sourceImage == null || !context.mounted) return;

    final editedImage =
        await Navigator.of(context).push<ImagenSubidaVerificacion>(
      MaterialPageRoute<ImagenSubidaVerificacion>(
        builder: (_) =>
            EditorImagenVerificacionPantalla(sourceImage: sourceImage),
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

    final uploadTrace = await RendimientoApp.iniciarTraza(
      'matter_photo_upload',
      attributes: {
        'career_id': widget.careerId,
        'matter_id': widget.matter.id,
      },
    );
    var traceStopped = false;

    try {
      final deviceId = await ref.read(proveedorIdDispositivo.future);
      await repo.createPublicacionFotoMateria(
        client: client,
        deviceId: deviceId,
        matterId: widget.matter.id,
        careerId: widget.careerId,
        image: editedImage,
        caption: caption,
      );
      await RendimientoApp.detenerTraza(
        uploadTrace,
        metrics: {
          'success': 1,
          'caption_provided': caption.trim().isEmpty ? 0 : 1,
        },
      );
      traceStopped = true;
      ref.invalidate(proveedorPublicacionesFotoMateria(widget.matter.id));
      await ref
          .read(proveedorPublicacionesFotoMateria(widget.matter.id).future);
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
        await RendimientoApp.detenerTraza(
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

class _TarjetaAgregarFotoMateria extends StatelessWidget {
  const _TarjetaAgregarFotoMateria({
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
    return _MarcoFotoMateria(
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

class _MosaicoFotoMateria extends StatelessWidget {
  const _MosaicoFotoMateria({
    required this.width,
    required this.height,
    required this.post,
    required this.posts,
    required this.initialIndex,
  });

  final double width;
  final double height;
  final PublicacionFotoMateria post;
  final List<PublicacionFotoMateria> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (width * pixelRatio).round();
    return RepaintBoundary(
      child: _MarcoFotoMateria(
        width: width,
        height: height,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        borderColor: theme.colorScheme.outlineVariant,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _VistaPreviaFotoMateriaPantalla(
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

class _MarcoFotoMateria extends StatelessWidget {
  const _MarcoFotoMateria({
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

class _VistaPreviaFotoMateriaPantalla extends StatelessWidget {
  const _VistaPreviaFotoMateriaPantalla({
    required this.posts,
    required this.initialIndex,
  });

  final List<PublicacionFotoMateria> posts;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _PaginadorVistaPreviaFotoMateria(
      posts: posts,
      initialIndex: initialIndex,
      theme: theme,
    );
  }
}

class _PaginadorVistaPreviaFotoMateria extends ConsumerStatefulWidget {
  const _PaginadorVistaPreviaFotoMateria({
    required this.posts,
    required this.initialIndex,
    required this.theme,
  });

  final List<PublicacionFotoMateria> posts;
  final int initialIndex;
  final ThemeData theme;

  @override
  ConsumerState<_PaginadorVistaPreviaFotoMateria> createState() =>
      _PaginadorVistaPreviaFotoMateriaState();
}

class _PaginadorVistaPreviaFotoMateriaState
    extends ConsumerState<_PaginadorVistaPreviaFotoMateria> {
  late final PageController _controller;
  late int _currentIndex;
  late List<PublicacionFotoMateria> _posts;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _posts = List<PublicacionFotoMateria>.from(widget.posts);
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
    final adminStatus =
        ref.watch(proveedorEstadoDispositivoAdministrador).valueOrNull;
    final canModerate = adminStatus?.isAdmin == true;
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagen ${_currentIndex + 1} de ${_posts.length}'),
        actions: [
          if (canModerate)
            IconButton(
              tooltip: 'Quitar imagen',
              onPressed: () => _manejarEliminarFotoActual(
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
                return _FotoMateriaConZoom(imageUrl: post.imageUrl);
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

  Future<void> _manejarEliminarFotoActual({
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

    final client = ref.read(proveedorClienteSupabase);
    if (client == null) return;

    try {
      final repo = ref.read(proveedorRepositorioResenasOpiniones);
      await repo.deletePublicacionFotoMateria(
        client: client,
        adminDeviceId: adminDeviceId,
        photoId: currentPost.id,
      );
      ref.invalidate(proveedorPublicacionesFotoMateria(currentPost.matterId));

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

      final updatedPosts = List<PublicacionFotoMateria>.from(_posts)
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

class _FotoMateriaConZoom extends StatefulWidget {
  const _FotoMateriaConZoom({required this.imageUrl});

  final String imageUrl;

  @override
  State<_FotoMateriaConZoom> createState() => _FotoMateriaConZoomState();
}

class _FotoMateriaConZoomState extends State<_FotoMateriaConZoom> {
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
    final summary = ref.watch(proveedorResumenResenasDocente(docente.id));
    final ownReview = ref
        .watch(
          proveedorResenaDocentePropia(
            AlcanceResenaDocente(
              teacherId: docente.id,
              matterId: matter.id,
              careerId: careerId,
            ),
          ),
        )
        .valueOrNull;

    return InkWell(
      onTap: () {
        mostrarHojaDetalleDocente(
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
                      ReferenciasBalanceInsignia(
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

class _MiniStateInsignia extends StatelessWidget {
  const _MiniStateInsignia({required this.label});

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
