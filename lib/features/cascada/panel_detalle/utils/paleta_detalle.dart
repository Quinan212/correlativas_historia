import 'package:flutter/material.dart';

Color darken(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t) ?? c;

class PaletaDetalle {
  static const amberCard = Color(0xFFFFFBEB);
  static const amberBd = Color(0xFFFDE68A);
  static const amberChip = Color(0xFFFEF3C7);
  static const amberTxt = Color(0xFF92400E);

  static const emeraldCard = Color(0xFFECFDF5);
  static const emeraldBd = Color(0xFFA7F3D0);
  static const emeraldChip = Color(0xFFE7F8EF);
  static const emeraldTxt = Color(0xFF065F46);

  static const blueCard = Color(0xFFF0F7FF);
  static const blueBd = Color(0xFFBFDBFE);
  static const bluePill = Color(0xFFE5EDFF);
  static const blueTxt = Color(0xFF1D4ED8);
}

class PaletaDetalleOscura {
  static const fgBg = Color(0xFF223761);
  static const fgBd = Color(0xFF3E60A4);
  static const fgFg = Color(0xFFBFD4FF);

  static const feBg = Color(0xFF1E4F45);
  static const feBd = Color(0xFF2D8C78);
  static const feFg = Color(0xFFBFEFE0);

  static const ppBg = Color(0xFF3A2769);
  static const ppBd = Color(0xFF7351D4);
  static const ppFg = Color(0xFFE7D7FF);

  static const asigBg = fgBg;
  static const asigBd = fgBd;
  static const asigFg = fgFg;

  static const semBg = feBg;
  static const semBd = feBd;
  static const semFg = feFg;

  static const stBg = ppBg;
  static const stBd = ppBd;
  static const stFg = ppFg;

  static const tallerBg = Color(0xFF5A3027);
  static const tallerBd = Color(0xFFB75B33);
  static const tallerFg = Color(0xFFF4CBB5);

  static const reqBg = Color(0xFF55451A);
  static const reqBd = Color(0xFF8A6F2C);
  static const reqFg = Color(0xFFEED083);

  static const amberCard = Color(0xFF2B2414);
  static const amberBd = reqBd;

  static const emeraldCard = Color(0xFF15372F);
  static const emeraldBd = feBd;

  static const blueCard = Color(0xFF16233F);
  static const blueBd = fgBd;
  static const bluePill = Color(0xFF1D2E54);
  static const blueTxt = fgFg;
}

Color colorEtiquetaEstado({required bool isDark, required bool isYellow}) {
  if (isYellow) return isDark ? PaletaDetalleOscura.reqFg : PaletaDetalle.amberTxt;
  return isDark ? PaletaDetalleOscura.feFg : PaletaDetalle.emeraldTxt;
}