import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartido/proveedores/estado_app.dart';
import '../../../../modelos/materia.dart';
import '../../../opiniones/configuracion/visibilidad_opiniones.dart';
import '../../../opiniones/proveedores/proveedores_resenas_opiniones.dart';
import '../../../verificacion/modelos/estado_verificacion_materia.dart';
import '../../../verificacion/proveedores/proveedores_verificacion.dart';

import '../utilidades/estilos_etiquetas.dart';
import 'modal_detalle_materia.dart';

class _TokensTarjeta {
  static const borderLight = Color(0xFFE5E7EB);
}

class TarjetaMateriaGrilla extends ConsumerStatefulWidget {
  const TarjetaMateriaGrilla(this.m, {super.key, this.borderless = false});

  final Materia m;
  final bool borderless;

  @override
  ConsumerState<TarjetaMateriaGrilla> createState() =>
      _TarjetaMateriaGrillaState();
}

class _TarjetaMateriaGrillaState extends ConsumerState<TarjetaMateriaGrilla> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.m;

    final isSelected =
        ref.watch(proveedorIdMateriaSeleccionada.select((id) => id == m.id));
    final careerId = ref.watch(proveedorCarreraSeleccionada).id;
    final showHistoriaCommunity = careerId == 'historia';
    final reviewSummary = ref.watch(proveedorResumenResenasMateria(m.id));
    final verification = ref.watch(proveedorEstadoVerificacionMateria(m.id));

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final plan = ref.watch(proveedorPlan).value;
    final codeById = {
      for (final x in (plan?.materias ?? <Materia>[])) x.id: x.codigo
    };

    String abbr = (codeById[m.id] ?? m.codigo).toString().trim().toUpperCase();
    if (abbr.isEmpty) abbr = m.id.substring(0, 2).toUpperCase();

    final bgColor = isDark ? oscurecer(cs.surface) : Colors.white;
    final borderColor = isSelected
        ? const Color(0xFF005B7F)
        : (isDark ? const Color(0xFF374151) : _TokensTarjeta.borderLight);

    final titleColor = colorTituloDesdeTipo(isDark, m.tipo);

    final normalizedFormato = normalizarFormatoChip(m.formato);
    final (fmtBg, fmtFg, fmtBd) = coloresFormato(isDark, normalizedFormato);
    final (typeBg, typeFg, typeBd) = coloresTipo(isDark, m.tipo);

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final width = MediaQuery.of(context).size.width;
          final isDesktop = width >= 900;

          // Bloquear doble tap: Si ya hay una materia abriéndose, ignoramos
          // los clicks siguientes para no ahogar al procesador abriendo dos
          // paneles gigantes superpuestos.
          if (!isDesktop && ref.read(proveedorIdMateriaSeleccionada) != null) {
            return;
          }

          unawaited(HapticFeedback.lightImpact());

          if (isDesktop) {
            // En escritorio solo seleccionamos, el SidePanel reacciona
            ref.read(proveedorIdMateriaSeleccionada.notifier).state = m.id;
          } else {
            debugPrint(
                'Abrir detalle: setting selectedId=${m.id} and pushing route');
            ref.read(proveedorIdMateriaSeleccionada.notifier).state = m.id;
            await mostrarModalDetalleMateria(
              context: context,
              ref: ref,
              heroId: m.id,
            );
            ref.read(proveedorIdMateriaSeleccionada.notifier).state = null;
          }
        },
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isDark || widget.borderless
                  ? const []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      )
                    ],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        abbr,
                        style: TextStyle(
                          fontSize: 15.4,
                          fontWeight: FontWeight.w800,
                          color: titleColor.withValues(alpha: 
                            isDark ? 0.9 : 0.8,
                          ),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        m.nombre,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: fmtBg,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: fmtBd),
                            ),
                            child: Text(
                              normalizedFormato,
                              style: TextStyle(
                                fontSize: 11.34,
                                fontWeight: FontWeight.w600,
                                color: fmtFg,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeBg,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: typeBd),
                            ),
                            child: Text(
                              m.tipo,
                              style: TextStyle(
                                fontSize: 11.34,
                                fontWeight: FontWeight.w600,
                                color: typeFg,
                              ),
                            ),
                          ),
                          if (kShowOpinionUi &&
                              showHistoriaCommunity &&
                              (reviewSummary.rating.votos > 0 ||
                                  verification.status !=
                                      SituacionVerificacionMateria.unverified))
                            _CommunityPill(
                              verification: verification,
                              votes: reviewSummary.rating.votos,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return card;
  }
}

class _CommunityPill extends StatelessWidget {
  const _CommunityPill({
    required this.verification,
    required this.votes,
  });

  final EstadoVerificacionMateria verification;
  final int votes;

  @override
  Widget build(BuildContext context) {
    final hasCommunity = votes > 0;
    final verified =
        verification.status == SituacionVerificacionMateria.approved;

    final (bg, fg, bd, icon, label) = switch ((verified, hasCommunity)) {
      (true, true) => (
          const Color(0xFFECFDF5),
          const Color(0xFF166534),
          const Color(0xFFA7F3D0),
          Icons.forum_rounded,
          '$votes opiniones',
        ),
      (true, false) => (
          const Color(0xFFECFDF5),
          const Color(0xFF166534),
          const Color(0xFFA7F3D0),
          Icons.verified_rounded,
          'Habilitada',
        ),
      (false, true) => (
          const Color(0xFFFEF3C7),
          const Color(0xFF92400E),
          const Color(0xFFFDE68A),
          Icons.star_rounded,
          '$votes opiniones',
        ),
      (false, false) => (
          const Color(0xFFE2E8F0),
          const Color(0xFF334155),
          const Color(0xFFCBD5E1),
          Icons.shield_outlined,
          verification.label,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: bd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.1,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
