import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../proveedores/estado_app.dart';
import 'texto_auto_desplazable.dart';

class EtiquetaOpcionInstitucion extends StatelessWidget {
  const EtiquetaOpcionInstitucion(
    this.institution, {
    super.key,
    this.iconSize = 24,
    this.gap = 8,
    this.iconShiftX = -6,
    this.iconVerticalPadding = 0,
    this.enableMarquee = false,
  });

  final InstitutionInfo institution;
  final double iconSize;
  final double gap;
  final double iconShiftX;
  final double iconVerticalPadding;
  final bool enableMarquee;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasIcon = institution.iconAsset != null;
        final effectiveGap = hasIcon ? math.max(0.0, gap + iconShiftX) : 0.0;
        final iconSlot = hasIcon ? iconSize : 0.0;
        final iconBlock = hasIcon ? iconSlot + effectiveGap : 0.0;

        final text = enableMarquee
            ? TextoAutoDesplazable(
                institution.nombre,
                style: DefaultTextStyle.of(context).style,
              )
            : Text(
                institution.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );

        final textChild = constraints.hasBoundedWidth
            ? SizedBox(
                width: math.max(0, constraints.maxWidth - iconBlock),
                child: text,
              )
            : text;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) ...[
              SizedBox(
                width: iconSlot,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: iconVerticalPadding),
                  child: Transform.translate(
                    offset: Offset(iconShiftX, 0),
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      clipBehavior: Clip.antiAlias,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        institution.iconAsset!,
                        fit: BoxFit.cover,
                        cacheWidth: 96,
                        cacheHeight: 96,
                        filterQuality: FilterQuality.low,
                        errorBuilder: (_, _, _) => _fallbackIcon(context),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: effectiveGap),
            ],
            textChild,
          ],
        );
      },
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.primary.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: Icon(
        Icons.domain_rounded,
        size: iconSize - 4,
        color: cs.primary,
      ),
    );
  }
}
