import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/identidad_dispositivo/identidad_dispositivo.dart';
import '../../../compartido/proveedores/estado_app.dart';
import '../../cascada/panel_detalle/componentes/controles_superiores.dart';
import '../../verificacion/proveedores/proveedores_verificacion.dart';
import '../configuracion/visibilidad_opiniones.dart';
import '../modelos/catalogo_opiniones.dart';
import '../modelos/modelos_resenas_opiniones.dart';
import '../proveedores/opiniones_providers.dart';
import '../proveedores/proveedores_resenas_opiniones.dart';
import '../utilidades/etiquetas_referencias.dart';
import 'barra_balance_referencias.dart';
import 'hojas_compositor_resenas.dart';

Future<void> mostrarHojaDetalleDocente({
  required BuildContext context,
  required WidgetRef ref,
  required DocenteLite docente,
  required String matterId,
  required String matterName,
  required String careerId,
}) {
  if (!kShowOpinionUi) {
    return Future<void>.value();
  }
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _PaginaDetalleDocente(
        docente: docente,
        matterId: matterId,
        matterName: matterName,
        careerId: careerId,
      ),
    ),
  );
}

class _PaginaDetalleDocente extends ConsumerWidget {
  const _PaginaDetalleDocente({
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
    final backgroundTop =
        isDark ? const Color(0xFF0B1220) : const Color(0xFFF5F7FB);
    final backgroundBottom =
        isDark ? const Color(0xFF111827) : const Color(0xFFE9EEF5);

    final base = ref.watch(docenteBaseProvider(docente.id));
    final summary = ref.watch(proveedorResumenResenasDocente(docente.id));
    final tendencyTexts = buildTeacherReferenceInsights(summary.aspectos);
    final ownReview = ref
        .watch(
          proveedorResenaDocentePropia(
            AlcanceResenaDocente(
              teacherId: docente.id,
              matterId: matterId,
              careerId: careerId,
            ),
          ),
        )
        .value;
    final verification =
        ref.watch(proveedorEstadoVerificacionMateria(matterId));
    final reviews =
        ref.watch(proveedorResenasDocente(docente.id)).value ??
            const <ResenaDocente>[];

    final matterNameById = <String, String>{
      for (final materia in base?.materias ?? const <MateriaLite>[])
        materia.id: materia.nombre,
    };

    final commentedReviews = reviews
        .where((review) => (review.comment ?? '').trim().isNotEmpty)
        .toList(growable: false);
    final commentProfiles = ref
            .watch(
              proveedorPerfilesDispositivoPorIds(
                serializeDeviceIds(
                    commentedReviews.map((item) => item.deviceId)),
              ),
            )
            .value ??
        const <String, PerfilDispositivo>{};

    return Scaffold(
      backgroundColor: backgroundTop,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundTop,
              Color.lerp(backgroundTop, backgroundBottom, 0.65) ??
                  backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 980),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TarjetaSeccion(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  docente.nombre,
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
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
                                BarraBalanceReferencias(
                                  average: summary.general.promedio,
                                  votes: summary.general.votos,
                                ),
                                const SizedBox(height: 10),
                                _MiniInsignia(
                                    label:
                                        '${docente.apariciones} apariciones'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _TarjetaSeccion(
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
                                      ? 'Ya podés compartir una referencia situada sobre este docente desde esta materia.'
                                      : 'Primero verificá que cursás esta materia para poder compartir referencias desde esa experiencia concreta.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Estas referencias se leen dentro de una materia y un momento de cursada concretos. Se muestran de forma anónima por defecto; si alguien elige un alias público, solo se muestra ese alias.',
                                  style: theme.textTheme.bodySmall,
                                ),
                                if (ownReview != null) ...[
                                  const SizedBox(height: 12),
                                  BarraBalanceReferencias(
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
                                          (entry) => _MiniInsignia(
                                            label:
                                                '${etiquetaAspectoDocente(entry.key)} · ${etiquetaEscalaAspectoDocente(entry.key, entry.value)}',
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
                                ],
                                if (verification.canReview) ...[
                                  const SizedBox(height: 12),
                                  FilledButton.icon(
                                    onPressed: () {
                                      mostrarHojaCompositorResenaDocente(
                                        context: context,
                                        ref: ref,
                                        scope: AlcanceResenaDocente(
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
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (tendencyTexts.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _TarjetaSeccion(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lecturas que emergen de las referencias',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...tendencyTexts.map(
                                    (text) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
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
                          ],
                          const SizedBox(height: 14),
                          _TarjetaSeccion(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lectura por eje',
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
                                            etiquetaAspectoDocente(entry.key),
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
                                                  style: theme
                                                      .textTheme.bodyMedium,
                                                )
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    BarraBalanceReferencias(
                                                      average: item.promedio,
                                                      votes: item.votos,
                                                      showVotes: false,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    ReferenciasReadingInsignia(
                                                      rating: item,
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
                          _TarjetaSeccion(
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
                                    'Todavía no hay materias vinculadas para este docente.',
                                    style: theme.textTheme.bodyMedium,
                                  )
                                else
                                  ...base.materias.map(
                                    (materia) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                      title: Text(materia.nombre),
                                      subtitle: Text('${materia.anio}° año'),
                                      trailing: const Icon(
                                          Icons.chevron_right_rounded),
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        ref
                                            .read(proveedorIdMateriaSeleccionada
                                                .notifier)
                                            .state = materia.id;
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (commentedReviews.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            _TarjetaSeccion(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Experiencias compartidas',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
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
                                                  ReferenciasBalanceInsignia(
                                                    average: review.general
                                                        .toDouble(),
                                                    votes: 1,
                                                  ),
                                                  _MiniInsignia(
                                                    label: matterNameById[
                                                            review.matterId] ??
                                                        review.matterId,
                                                  ),
                                                  _MiniInsignia(
                                                    label: commentProfiles[
                                                                review.deviceId]
                                                            ?.publicDisplayLabel ??
                                                        'Referencia anónima',
                                                  ),
                                                  Text(
                                                    _formatDate(
                                                        review.updatedAt),
                                                    style: theme
                                                        .textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '“${review.comment!.trim()}”',
                                                style:
                                                    theme.textTheme.bodyMedium,
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
                ),
              ),
              SafeArea(
                top: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: BarraInferiorDetalle(
                    onTap: () => Navigator.of(context).pop(),
                    label: 'Volver a la materia',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? const []
            : [
                BoxShadow(
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                  color: Colors.black.withValues(alpha: 0.035),
                ),
              ],
      ),
      child: child,
    );
  }
}

class _MiniInsignia extends StatelessWidget {
  const _MiniInsignia({required this.label});

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

String _formatDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day/$month/$year';
}
