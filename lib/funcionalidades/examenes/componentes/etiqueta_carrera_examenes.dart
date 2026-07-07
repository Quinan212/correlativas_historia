import 'package:flutter/material.dart';

import '../../../compartido/proveedores/estado_app.dart';

class EtiquetaCarreraExamenes extends StatelessWidget {
  const EtiquetaCarreraExamenes({
    super.key,
    required this.career,
    required this.textColor,
    this.iconSize = 22,
    this.gap = 8,
    this.iconShiftX = 0,
  });

  final CareerInfo career;
  final Color textColor;
  final double iconSize;
  final double gap;
  final double iconShiftX;

  @override
  Widget build(BuildContext context) {
    final hasIcon = career.iconAsset != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasIcon) ...[
          Transform.translate(
            offset: Offset(iconShiftX, 0),
            child: Container(
              width: iconSize,
              height: iconSize,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Image.asset(
                career.iconAsset!,
                fit: BoxFit.cover,
                cacheWidth: 64,
                cacheHeight: 64,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.school_rounded,
                  size: iconSize - 4,
                  color: textColor,
                ),
              ),
            ),
          ),
          SizedBox(width: gap),
        ],
        Flexible(
          child: Text(
            career.nombre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
