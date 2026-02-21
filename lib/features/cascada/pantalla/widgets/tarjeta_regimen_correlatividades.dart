import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';

class TarjetaRegimenCorrelatividades extends ConsumerWidget {
  const TarjetaRegimenCorrelatividades({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final career = ref.watch(selectedCareerInfoProvider);

    String carreraLinea;
    String articuloCentro;
    String institucionLinea;
    String? resolucion;

    switch (career.id) {
      case 'geografia':
        carreraLinea = 'Profesorado de Educación Secundaria en Geografía';
        articuloCentro = 'el';
        institucionLinea = 'Profesorado Superior de Ciencias Sociales';
        resolucion =
        'Resolución N° 0766 C.G.E. | Expte. Grabado N° (1507261) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'historia':
        carreraLinea = 'Profesorado de Educación Secundaria en Historia';
        articuloCentro = 'el';
        institucionLinea = 'Profesorado Superior de Ciencias Sociales';
        resolucion =
        'Resolución N° 0765 C.G.E. | Expte. Grabado N° (1506606) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'artes_visuales':
        carreraLinea = 'Profesorado de Artes Visuales';
        articuloCentro = 'la';
        institucionLinea =
        'Escuela Secundaria y Superior N° 1 "Cesáreo Bernaldo de Quirós"';
        resolucion =
        'Resolución N° 0440/23 C.G.E. | Expte. Grabado N° (1943528) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'musica':
        carreraLinea = 'Profesorado de Música con Orientación en Educación Musical';
        articuloCentro = 'la';
        institucionLinea =
        'Escuela Secundaria y Superior N° 1 "Cesáreo Bernaldo de Quirós"';
        resolucion =
        'Resolución N° 2867/23 C.G.E. | Expte. Grabado N° (2856760) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'fisica':
        carreraLinea = 'Profesorado de Educación Física';
        articuloCentro = 'el';
        institucionLinea =
        'Instituto Superior de las Especialidades de la Educación Física';
        resolucion =
        'Resolución N° 0338/23 C.G.E. | Expte. Grabado N° (1943502) | Provincia de Entre Ríos - CONSEJO GENERAL DE EDUCACIÓN.';
        break;
      case 'politica':
        carreraLinea = 'Profesorado de Educación Secundaria en Ciencia Política';
        articuloCentro = 'el';
        institucionLinea = 'Profesorado Superior de Ciencias Sociales';
        resolucion = null;
        break;
      default:
        carreraLinea = career.nombre;
        articuloCentro = 'la';
        institucionLinea = 'institución correspondiente';
        resolucion = null;
    }

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
            blurRadius: 6,
            color: theme.shadowColor.withValues(alpha: 0.12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Régimen de Correlatividades Vigente',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                  'Este sistema está basado en el régimen de correlatividades actual para la carrera de ',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                TextSpan(
                  text: carreraLinea,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' que se cursa en $articuloCentro ',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
                TextSpan(
                  text: institucionLinea,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (resolucion != null) ...[
            Text(
              resolucion,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            'Si querés acceder directamente al documento oficial, podés hacerlo con el botón de descarga que encontrarás justo al final del menú de opciones.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}