import 'package:flutter/material.dart';

import 'premium_feature_accordion.dart';

class TarjetaPresentacionMapa extends StatefulWidget {
  const TarjetaPresentacionMapa({super.key});

  static const _items = <PremiumAccordionItemData>[
    PremiumAccordionItemData(
      icon: Icons.search_rounded,
      title: 'Busca una materia',
      kicker: 'Busqueda puntual',
      summary:
          'Encuentra rapido la materia que quieres revisar sin recorrer todo el mapa.',
      detail:
          'Puedes entrar por nombre o codigo para abrir una consulta concreta y mirar solo la parte del plan que te interesa.',
      bullets: [
        'Ahorra tiempo cuando ya sabes que materia quieres revisar.',
        'Sirve para despejar dudas antes de cursar o rendir.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.rule_folder_outlined,
      title: 'Ve requisitos previos',
      kicker: 'Antes de llegar',
      summary:
          'Mira que condiciones debes cumplir antes de llegar a esa materia.',
      detail:
          'El mapa muestra las correlativas que la bloquean para que entiendas de inmediato que te falta hoy.',
      bullets: [
        'Distingue si el requisito es por aprobacion o regularidad.',
        'Evita leer toda la red para entender una sola condicion.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.alt_route_rounded,
      title: 'Entiende que habilita',
      kicker: 'Despues de aprobar',
      summary:
          'Descubre que materias se destraban cuando apruebas una correlativa importante.',
      detail:
          'No solo ves lo que falta hacia atras. Tambien puedes mirar el efecto que una materia tiene sobre las que vienen despues.',
      bullets: [
        'Ayuda a detectar materias clave dentro del plan.',
        'Hace visible el impacto real de aprobar una correlativa.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.tune_rounded,
      title: 'Filtra el mapa',
      kicker: 'Entrada rapida',
      summary: 'Ordena la vista por carrera, ano o tipo para ir mas directo.',
      detail:
          'Antes de explorar, puedes ajustar los filtros para acotar la consulta y leer solo la parte del plan que te interesa.',
      bullets: [
        'Reduce ruido cuando el plan tiene muchas materias.',
        'Te deja arrancar desde un tramo mas manejable.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.touch_app_outlined,
      title: 'Toca y explora',
      kicker: 'Recorrido visual',
      summary:
          'Cada materia abre su red para que sigas relaciones sin perder contexto.',
      detail:
          'Al tocar una materia puedes moverte por sus conexiones y entender mejor como se encadenan los requisitos dentro del plan.',
      bullets: [
        'Convierte una lista estatica en una lectura mas intuitiva.',
        'Facilita seguir caminos sin salir de la herramienta.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.insights_outlined,
      title: 'Planea la cursada',
      kicker: 'Decision siguiente',
      summary:
          'Usa lo que ves para decidir que conviene cursar, regularizar o rendir despues.',
      detail:
          'La herramienta no solo responde una duda puntual. Tambien sirve para ordenar tu proximo paso con mas criterio.',
      bullets: [
        'Ayuda a priorizar materias con mayor efecto sobre el resto.',
        'Te da una base mas clara para planear la siguiente cursada.',
      ],
    ),
  ];

  @override
  State<TarjetaPresentacionMapa> createState() =>
      _TarjetaPresentacionMapaState();
}

class _TarjetaPresentacionMapaState extends State<TarjetaPresentacionMapa> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF0A0D11),
                  Color(0xFF12161C),
                ]
              : const [
                  Color(0xFFF9F9F8),
                  Color(0xFFF1F3F5),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF21262F) : const Color(0xFFD6DBE1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: _expanded ? (isDark ? 26 : 18) : (isDark ? 20 : 14),
            offset: const Offset(0, 12),
            color: theme.shadowColor.withValues(alpha: isDark ? 0.18 : 0.08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _expanded = !_expanded),
                  borderRadius: BorderRadius.circular(16),
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF111A26)
                                    : const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF213046)
                                      : const Color(0xFFD6DDE7),
                                ),
                              ),
                              child: Icon(
                                Icons.account_tree_outlined,
                                size: 18,
                                color: isDark
                                    ? const Color(0xFF9CC7FF)
                                    : const Color(0xFF2056D8),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Herramienta interactiva',
                                style: tt.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary.withValues(alpha: 0.92),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedRotation(
                              turns: _expanded ? 0.125 : 0,
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? cs.surfaceContainerHighest.withValues(
                                          alpha: 0.20,
                                        )
                                      : Colors.white.withValues(alpha: 0.72),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF2B3645)
                                        : const Color(0xFFD6DDE7),
                                  ),
                                ),
                                child: Icon(
                                  _expanded
                                      ? Icons.close_rounded
                                      : Icons.add_rounded,
                                  size: 18,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Mapa de Correlatividades\nQue me falta',
                          style: tt.headlineSmall?.copyWith(
                            height: 1.12,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          style: tt.bodyMedium!.copyWith(
                            height: 1.55,
                            color: _expanded
                                ? cs.onSurfaceVariant
                                : cs.onSurfaceVariant.withValues(alpha: 0.92),
                          ),
                          child: const Text('Consulta, explora y planifica'),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, (1 - value) * 8),
                                    child: child,
                                  ),
                                );
                              },
                              child: const PremiumFeatureAccordion(
                                items: TarjetaPresentacionMapa._items,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
