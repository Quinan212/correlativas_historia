import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../proveedores/estado_app.dart';

class EtiquetaOpcionCarrera extends StatelessWidget {
  const EtiquetaOpcionCarrera(
    this.career, {
    super.key,
    this.iconSize = 22,
    this.gap = 8,
    this.iconShiftX = 0,
    this.iconVerticalPadding = 0,
  });

  final CareerInfo career;
  final double iconSize;
  final double gap;
  final double iconShiftX;
  final double iconVerticalPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasIcon = career.iconAsset != null;
        final effectiveGap = hasIcon ? math.max(0.0, gap + iconShiftX) : 0.0;
        final iconBlock = hasIcon ? iconSize + effectiveGap : 0.0;

        final text = Text(
          career.nombre,
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
              Padding(
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
                      career.iconAsset!,
                      fit: BoxFit.cover,
                      cacheWidth: 64,
                      cacheHeight: 64,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (_, _, _) => _fallbackIcon(context),
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
        Icons.school_rounded,
        size: iconSize - 4,
        color: cs.primary,
      ),
    );
  }
}
