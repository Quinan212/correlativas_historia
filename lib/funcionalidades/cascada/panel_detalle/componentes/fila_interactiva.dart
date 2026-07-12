// componentes/fila_interactiva.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:correlativas_historia/modelos/materia.dart';

import '../utilidades/paleta_detalle.dart';
import '../utilidades/reglas_practicas_detalle.dart';

Widget filaInteractivaMateria({
  required BuildContext context,
  required WidgetRef ref,
  required Materia? targetMateria,
  required String abbr,
  required String name,
  String? statusType,
  required bool isYellow,
}) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final bgColor = isDark
      ? (isYellow
          ? PaletaDetalleOscura.amberCard
          : PaletaDetalleOscura.emeraldCard)
      : (isYellow ? PaletaDetalle.amberCard : PaletaDetalle.emeraldCard);

  final bdColor = isDark
      ? (isYellow ? PaletaDetalleOscura.amberBd : PaletaDetalleOscura.emeraldBd)
      : (isYellow ? PaletaDetalle.amberBd : PaletaDetalle.emeraldBd);

  final chipBg = isDark
      ? (isYellow ? PaletaDetalleOscura.reqBg : PaletaDetalleOscura.feBg)
      : (isYellow ? PaletaDetalle.amberChip : PaletaDetalle.emeraldChip);

  final chipBd = isDark
      ? (isYellow ? PaletaDetalleOscura.reqBd : PaletaDetalleOscura.feBd)
      : (isYellow ? PaletaDetalle.amberBd : PaletaDetalle.emeraldBd);

  final chipFg = isDark
      ? (isYellow ? PaletaDetalleOscura.reqFg : PaletaDetalleOscura.feFg)
      : (isYellow ? PaletaDetalle.amberTxt : PaletaDetalle.emeraldTxt);

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: targetMateria != null
          ? () {
              HapticFeedback.selectionClick();
              ref.read(proveedorIdMateriaSeleccionada.notifier).state =
                  targetMateria.id;
            }
          : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: bdColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: chipBd),
              ),
              child: Text(
                abbr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: chipFg,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (statusType != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        etiquetaEstado(statusType),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: colorEtiquetaEstado(
                            isDark: isDark,
                            isYellow: isYellow,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (targetMateria != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: chipFg.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
