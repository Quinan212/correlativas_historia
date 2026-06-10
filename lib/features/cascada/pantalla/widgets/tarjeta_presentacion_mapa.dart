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
          'Ubica rapido una materia cuando quieres revisar un tramo puntual del plan.',
      detail:
          'Puedes buscar por nombre o por codigo para abrir una consulta puntual y mirar con mas detalle la parte del recorrido formativo que te interesa.',
      bullets: [
        'Ayuda a entrar por una duda concreta sin perder el resto del contexto.',
        'Sirve para revisar decisiones de cursada, regularidad o examen.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.rule_folder_outlined,
      title: 'Ve requisitos previos',
      kicker: 'Antes de llegar',
      summary:
          'Mira que condiciones tienes que cumplir antes de llegar a esa materia.',
      detail:
          'El mapa muestra las correlativas que la condicionan para que puedas leer que te falta hoy y por que ese recorrido aparece ordenado de ese modo.',
      bullets: [
        'Distingue si el requisito es por aprobacion o por regularidad.',
        'Hace visible que el avance no depende solo de una materia aislada.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.alt_route_rounded,
      title: 'Entiende que habilita',
      kicker: 'Despues de aprobar',
      summary:
          'Descubre que nuevas posibilidades se abren cuando apruebas una correlativa importante.',
      detail:
          'No solo ves lo que falta hacia atras. Tambien puedes mirar como una materia reorganiza lo que viene despues dentro del plan.',
      bullets: [
        'Ayuda a detectar materias clave dentro del plan.',
        'Permite pensar el avance como una trama y no como una lista suelta.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.tune_rounded,
      title: 'Filtra el mapa',
      kicker: 'Entrada rapida',
      summary:
          'Ordena la vista por carrera, ano o tipo para leer el plan desde un recorte mas manejable.',
      detail:
          'Antes de explorar, puedes ajustar los filtros para acotar la consulta y leer solo el tramo del plan que necesitas en este momento.',
      bullets: [
        'Reduce ruido cuando el plan tiene muchas materias.',
        'Te deja empezar desde un recorte situado y no desde el mapa entero.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.touch_app_outlined,
      title: 'Toca y explora',
      kicker: 'Recorrido visual',
      summary:
          'Cada materia abre su red para que sigas relaciones sin perder el contexto del plan.',
      detail:
          'Al tocar una materia puedes moverte por sus conexiones y entender mejor como se encadenan las condiciones de cursada, aprobacion y avance.',
      bullets: [
        'Convierte una lista estatica en una lectura mas relacional.',
        'Facilita seguir recorridos sin salir de la herramienta.',
      ],
    ),
    PremiumAccordionItemData(
      icon: Icons.insights_outlined,
      title: 'Planea la cursada',
      kicker: 'Decision siguiente',
      summary:
          'Usa lo que ves para decidir que conviene cursar, regularizar o rendir en el siguiente tramo.',
      detail:
          'La herramienta no solo responde una duda puntual. Tambien sirve para ordenar decisiones reales de cursada con mas criterio y menos intuicion aislada.',
      bullets: [
        'Ayuda a priorizar materias con mayor efecto sobre el resto.',
        'Te da una base mas clara para conversar y planear la siguiente cursada.',
      ],
    ),
  ];

  @override
  State<TarjetaPresentacionMapa> createState() =>
      _TarjetaPresentacionMapaState();
}

class _TarjetaPresentacionMapaState extends State<TarjetaPresentacionMapa> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final baseDuration = reduceMotion
        ? const Duration(milliseconds: 1)
        : const Duration(milliseconds: 260);

    return AnimatedContainer(
      duration: baseDuration,
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
            blurRadius: _expanded ? (isDark ? 18 : 12) : (isDark ? 14 : 9),
            offset: const Offset(0, 8),
            color: theme.shadowColor.withOpacity(isDark ? 0.14 : 0.06),
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
                                'Lectura interactiva del plan',
                                style: tt.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.primary.withOpacity(0.92),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedRotation(
                              turns: _expanded ? 0.125 : 0,
                              duration: reduceMotion
                                  ? const Duration(milliseconds: 1)
                                  : const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                    color: isDark
                                        ? cs.surfaceContainerHighest.withOpacity(0.20)
                                        : Colors.white.withOpacity(0.72),
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
                          duration: reduceMotion
                              ? const Duration(milliseconds: 1)
                              : const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          style: tt.bodyMedium!.copyWith(
                            height: 1.55,
                            color: _expanded
                                ? cs.onSurfaceVariant
                                : cs.onSurfaceVariant.withOpacity(0.92),
                          ),
                          child: const Text(
                            'Consulta, interpreta y ordena tu recorrido de cursada',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: reduceMotion
                      ? const Duration(milliseconds: 1)
                      : const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: 1),
                              duration: reduceMotion
                                  ? const Duration(milliseconds: 1)
                                  : const Duration(milliseconds: 240),
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
                                lightweight: true,
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
