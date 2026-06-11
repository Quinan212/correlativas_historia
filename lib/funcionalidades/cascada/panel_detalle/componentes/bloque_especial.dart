// componentes/bloque_especial.dart
import 'package:flutter/material.dart';

import '../utilidades/paleta_detalle.dart';

Widget bloqueEspecial(BuildContext context, String text) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final card = isDark ? PaletaDetalleOscura.blueCard : PaletaDetalle.blueCard;
  final bd = isDark ? PaletaDetalleOscura.blueBd : PaletaDetalle.blueBd;
  final pill = isDark ? PaletaDetalleOscura.bluePill : PaletaDetalle.bluePill;
  final fg = isDark ? PaletaDetalleOscura.blueTxt : PaletaDetalle.blueTxt;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: bd),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: pill,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: bd),
          ),
          child: Text(
            'Especial',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}
