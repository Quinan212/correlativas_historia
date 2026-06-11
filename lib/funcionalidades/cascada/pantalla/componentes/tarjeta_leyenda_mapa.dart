import 'package:flutter/material.dart';

import '../../grilla/utilidades/estilos_etiquetas.dart';

class TarjetaLeyendaMapa extends StatelessWidget {
  const TarjetaLeyendaMapa({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    Widget colorCard(
        String label, String desc, Color bg, Color border, Color textC) {
      return Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(
                  color: textC,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: textC.withOpacity(0.82),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget chipRow(String label, String desc, Color bg, Color fg, Color bd) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 110,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: bd),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                desc,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final general = coloresTipo(isDark, 'Formacion General');
    final especifica = coloresTipo(isDark, 'Formacion Especifica');
    final practica = coloresTipo(isDark, 'Practica Profesional');

    final asignatura = coloresFormato(isDark, 'asignatura');
    final seminario = coloresFormato(isDark, 'seminario');
    final taller = coloresFormato(isDark, 'taller');
    final semTaller = coloresFormato(isDark, 'seminario-taller');
    final variable = isDark
        ? (
            oscurecer(const Color(0xFF29313A)),
            const Color(0xFFE5E7EB),
            const Color(0xFF3E4753),
          )
        : (
            const Color(0xFFF3F4F6),
            const Color(0xFF374151),
            const Color(0xFFE5E7EB),
          );
    final abreviatura = isDark
        ? (
            oscurecer(const Color(0xFF6B4E16)),
            const Color(0xFFFDE68A),
            const Color(0xFFD4A72C),
          )
        : (
            const Color(0xFFFEF3C7),
            const Color(0xFF92400E),
            const Color(0xFFFDE68A),
          );
    final especial = isDark
        ? (
            oscurecer(const Color(0xFF223761)),
            const Color(0xFFBFD4FF),
            const Color(0xFF3E60A4),
          )
        : (
            const Color(0xFFE0E7FF),
            const Color(0xFF1D4ED8),
            const Color(0xFFBFDBFE),
          );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            offset: const Offset(0, 2),
            color: theme.shadowColor.withOpacity(0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            maintainState: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            backgroundColor: isDark ? cs.surface : Colors.white,
            collapsedBackgroundColor: isDark ? cs.surface : Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            collapsedShape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent),
            ),
            iconColor: cs.primary,
            collapsedIconColor: cs.onSurfaceVariant,
            title: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 22, color: cs.primary),
                const SizedBox(width: 12),
                Text(
                  'Guia del mapa',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 34, top: 2),
              child: Text(
                'Lee los colores y las etiquetas dentro del contexto del plan.',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            children: [
              Divider(color: isDark ? cs.outlineVariant : Colors.grey.shade200),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'COLORES DE LAS MATERIAS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  colorCard(
                    'General',
                    'Formacion comun y transversal.',
                    general.$1,
                    general.$3,
                    general.$2,
                  ),
                  colorCard(
                    'Especifica',
                    'Propia de la especialidad.',
                    especifica.$1,
                    especifica.$3,
                    especifica.$2,
                  ),
                  colorCard(
                    'Practica',
                    'Vinculacion profesional.',
                    practica.$1,
                    practica.$3,
                    practica.$2,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ETIQUETAS Y FORMATOS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              chipRow(
                'Asignatura',
                'Materia regular, teorica o practica.',
                asignatura.$1,
                asignatura.$2,
                asignatura.$3,
              ),
              chipRow(
                'Seminario',
                'Estudio intensivo de un tema especifico.',
                seminario.$1,
                seminario.$2,
                seminario.$3,
              ),
              chipRow(
                'Taller',
                'Espacio practico de produccion.',
                taller.$1,
                taller.$2,
                taller.$3,
              ),
              chipRow(
                'Sem-Taller',
                'Combinacion entre seminario y taller.',
                semTaller.$1,
                semTaller.$2,
                semTaller.$3,
              ),
              chipRow(
                'Variable',
                'Definido por la institucion (UDI).',
                variable.$1,
                variable.$2,
                variable.$3,
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: isDark ? cs.outlineVariant : Colors.grey.shade100,
              ),
              const SizedBox(height: 16),
              chipRow(
                'ABC',
                'Abreviatura usada para hacer más legible la materia dentro del mapa.',
                abreviatura.$1,
                abreviatura.$2,
                abreviatura.$3,
              ),
              chipRow(
                'Especial',
                'Condición especial que no se explica solo por una correlativa puntual.',
                especial.$1,
                especial.$2,
                especial.$3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
