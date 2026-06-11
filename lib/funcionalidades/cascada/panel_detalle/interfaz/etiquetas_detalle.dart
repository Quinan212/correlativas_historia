// ui/etiquetas_detalle.dart
import 'package:flutter/material.dart';

import '../utilidades/paleta_detalle.dart';

Widget _chipBase({
  required String text,
  required Color bg,
  required Color bd,
  required Color fg,
  bool bold = false,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: bd),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
        color: fg,
      ),
    ),
  );
}

Widget chipTipoDetalle(BuildContext context, String tipo) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  Color bg, bd, fg;

  if (!isDark) {
    switch (tipo.trim()) {
      case 'Formación General':
        bg = const Color(0xFFDBEAFE);
        bd = const Color(0xFFBFDBFE);
        fg = PaletaDetalle.blueTxt;
        break;
      case 'Formación Específica':
        bg = const Color(0xFFD1FAE5);
        bd = const Color(0xFFA7F3D0);
        fg = PaletaDetalle.emeraldTxt;
        break;
      case 'Práctica Profesional':
        bg = const Color(0xFFEDE9FE);
        bd = const Color(0xFFC4B5FD);
        fg = const Color(0xFF5B21B6);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        bd = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
    }
    return _chipBase(text: tipo, bg: bg, bd: bd, fg: fg, bold: true);
  }

  switch (tipo.trim()) {
    case 'Formación General':
      bg = darken(PaletaDetalleOscura.fgBg);
      bd = PaletaDetalleOscura.fgBd;
      fg = PaletaDetalleOscura.fgFg;
      break;
    case 'Formación Específica':
      bg = darken(PaletaDetalleOscura.feBg);
      bd = PaletaDetalleOscura.feBd;
      fg = PaletaDetalleOscura.feFg;
      break;
    case 'Práctica Profesional':
      bg = darken(PaletaDetalleOscura.ppBg);
      bd = PaletaDetalleOscura.ppBd;
      fg = PaletaDetalleOscura.ppFg;
      break;
    default:
      bg = darken(const Color(0xFF29313A));
      bd = const Color(0xFF3E4753);
      fg = const Color(0xFFE5E7EB);
  }

  return _chipBase(text: tipo, bg: bg, bd: bd, fg: fg, bold: true);
}

Widget chipFormatoDetalle(BuildContext context, String formato) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  Color bg, bd, fg;

  if (!isDark) {
    switch (formato.trim()) {
      case 'Asignatura':
        bg = const Color(0xFFDBEAFE);
        bd = const Color(0xFFBFDBFE);
        fg = PaletaDetalle.blueTxt;
        break;
      case 'Seminario':
        bg = const Color(0xFFD1FAE5);
        bd = const Color(0xFFA7F3D0);
        fg = PaletaDetalle.emeraldTxt;
        break;
      case 'Seminario-Taller':
        bg = const Color(0xFFEDE9FE);
        bd = const Color(0xFFC4B5FD);
        fg = const Color(0xFF5B21B6);
        break;
      case 'Taller':
        bg = const Color(0xFFFFEDD5);
        bd = const Color(0xFFFED7AA);
        fg = const Color(0xFF9A3412);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        bd = const Color(0xFFE5E7EB);
        fg = const Color(0xFF374151);
    }
    return _chipBase(text: formato, bg: bg, bd: bd, fg: fg, bold: true);
  }

  switch (formato.trim()) {
    case 'Asignatura':
      bg = darken(PaletaDetalleOscura.asigBg);
      bd = PaletaDetalleOscura.asigBd;
      fg = PaletaDetalleOscura.asigFg;
      break;
    case 'Seminario':
      bg = darken(PaletaDetalleOscura.semBg);
      bd = PaletaDetalleOscura.semBd;
      fg = PaletaDetalleOscura.semFg;
      break;
    case 'Seminario-Taller':
      bg = darken(PaletaDetalleOscura.stBg);
      bd = PaletaDetalleOscura.stBd;
      fg = PaletaDetalleOscura.stFg;
      break;
    case 'Taller':
      bg = darken(PaletaDetalleOscura.tallerBg);
      bd = PaletaDetalleOscura.tallerBd;
      fg = PaletaDetalleOscura.tallerFg;
      break;
    default:
      bg = darken(const Color(0xFF29313A));
      bd = const Color(0xFF3E4753);
      fg = const Color(0xFFE5E7EB);
  }

  return _chipBase(text: formato, bg: bg, bd: bd, fg: fg, bold: true);
}

Widget chipAnioDetalle(BuildContext context, int anio) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return _chipBase(
    text: '$anio° Año',
    bg: isDark ? darken(cs.surface, 0.25) : const Color(0xFFF3F4F6),
    bd: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
    fg: cs.onSurface,
    bold: true,
  );
}
