import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../shared/providers/app_state.dart';
import '../../../../models/materia.dart';
import '../../../opiniones/providers/opiniones_review_providers.dart';
import '../../../verification/models/matter_verification_state.dart';
import '../../../verification/providers/verification_providers.dart';

import '../utils/estilos_chips.dart';
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

    final selectedId = ref.watch(selectedMateriaIdProvider);
    final isSelected = selectedId == m.id;
    final careerId = ref.watch(selectedCareerInfoProvider).id;
    final showHistoriaCommunity = careerId == 'historia';
    final reviewSummary = ref.watch(matterReviewSummaryProvider(m.id));
    final verification = ref.watch(matterVerificationStateProvider(m.id));

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final plan = ref.watch(planProvider).valueOrNull;
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
          HapticFeedback.lightImpact();
          ref.read(selectedMateriaIdProvider.notifier).state = m.id;
          await mostrarModalDetalleMateria(
            context: context,
            ref: ref,
            heroId: m.id,
          );
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
                          color: titleColor.withValues(
                            alpha: isDark ? 0.9 : 0.8,
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
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                              horizontal: 8,
                              vertical: 2,
                            ),
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
                          if (showHistoriaCommunity &&
                              (reviewSummary.rating.votos > 0 ||
                                  verification.status !=
                                      MatterVerificationStatus.unverified))
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

  final MatterVerificationState verification;
  final int votes;

  @override
  Widget build(BuildContext context) {
    final hasCommunity = votes > 0;
    final verified = verification.status == MatterVerificationStatus.approved;

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
