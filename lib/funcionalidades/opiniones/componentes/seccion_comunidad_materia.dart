import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../modelos/materia.dart';
import '../../administrador/pantallas/acceso_administrador_pantalla.dart';
import '../../verificacion/modelos/estado_verificacion_materia.dart';
import '../../verificacion/proveedores/proveedores_verificacion.dart';
import '../configuracion/visibilidad_opiniones.dart';
import '../modelos/publicacion_foto_materia.dart';
import '../proveedores/opiniones_providers.dart';
import '../proveedores/proveedores_resenas_opiniones.dart';
import '../utilidades/etiquetas_referencias.dart';
import 'banner_verificacion_materia.dart';
import 'barra_balance_referencias.dart';
import 'caja_resena_materia_propia.dart';
import 'chip_verificacion_materia.dart';
import 'comunidad_card.dart';
import 'docente_tile.dart';
import 'galeria_fotos_materia.dart';
import 'hojas_compositor_resenas.dart';
import 'seccion_comentarios_materia.dart';

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
        child: ComunidadCard(
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
        ref.watch(proveedorResenaMateriaPropia(materia.id)).value;
    final verification =
        ref.watch(proveedorEstadoVerificacionMateria(materia.id));
    final showVerificationAction =
        verification.status != SituacionVerificacionMateria.approved;

    return RepaintBoundary(
      child: ComunidadCard(
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
                ChipVerificacionMateria(state: verification),
                if (ownReview != null)
                  const MiniStateInsignia(label: 'Ya dejaste una referencia'),
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
            BannerVerificacionMateria(state: verification),
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
              CajaResenaMateriaPropia(review: ownReview),
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
              SeccionComentariosMateria(comments: summary.comments),
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
        ref.watch(proveedorPublicacionesFotoMateria(matter.id)).value ??
            const <PublicacionFotoMateria>[];

    return GaleriaFotosMateria(
      matter: matter,
      careerId: careerId,
      verification: verification,
      photoPosts: photoPosts,
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
      child: ComunidadCard(
        title: 'Docentes vinculados',
        child: docentes.isEmpty
            ? Text(
                'Todavía no encontramos docentes vinculados desde los cronogramas cargados.',
                style: theme.textTheme.bodyMedium,
              )
            : Column(
                children: docentes
                    .map(
                      (docente) => DocenteTile(
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
