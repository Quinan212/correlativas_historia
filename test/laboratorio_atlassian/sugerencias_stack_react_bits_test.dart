import 'package:correlativas_historia/funcionalidades/laboratorio_atlassian/componentes/inicio_trayectoria_atlassian.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void noop() {}

  SugerenciasStackReactBitsAtlassianDelegate buildDelegate() {
    return SugerenciasStackReactBitsAtlassianDelegate(
      viewportHeight: 800,
      onOpenExams: noop,
      onOpenScenarios: noop,
      onOpenSubjects: noop,
      onOpenCalendar: noop,
    );
  }

  test('la variante React Bits conserva los extents del stack original', () {
    final original = SugerenciasApiladasAtlassianDelegate(
      viewportHeight: 800,
      onOpenExams: noop,
      onOpenScenarios: noop,
      onOpenSubjects: noop,
      onOpenCalendar: noop,
    );
    final experimental = buildDelegate();

    expect(experimental.minExtent, original.minExtent);
    expect(experimental.maxExtent, original.maxExtent);
  });

  test('la cola permite alcanzar el tope en viewports Android habituales', () {
    final delegate = buildDelegate();

    for (final viewportHeight in <double>[640, 720, 800, 960, 1200]) {
      final tail = SugerenciasStackReactBitsAtlassianDelegate.trailingExtentFor(
        viewportHeight,
      );
      expect(
        delegate.minExtent + tail,
        greaterThanOrEqualTo(viewportHeight),
        reason: 'viewportHeight=$viewportHeight',
      );
    }
  });

  testWidgets(
    'el estilo React Bits empieza antes de que llegue la ultima tarjeta',
    (WidgetTester tester) async {
      final delegate = buildDelegate();

      // 24 px corresponden al pinTravel. Con 180 px adicionales estamos a
      // mitad del primer tramo: la segunda tarjeta todavía no llegó al tope.
      const double shrinkOffset = 24 + 180;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: 430,
                  height: 900,
                  child: delegate.build(context, shrinkOffset, false),
                );
              },
            ),
          ),
        ),
      );

      final Finder firstCard = find.byKey(
        const ValueKey<String>('react-bits-card-0'),
      );
      expect(firstCard, findsOneWidget);

      final Finder animatedCard = find.descendant(
        of: firstCard,
        matching: find.byType(AnimatedContainer),
      );
      expect(animatedCard, findsOneWidget);

      final AnimatedContainer container = tester.widget<AnimatedContainer>(
        animatedCard,
      );
      final transform = container.transform!;

      // Si regresara el bug V2, esta tarjeta seguiria con transformacion
      // neutra hasta el final del recorrido. En V3 ya debe estar escalando y
      // rotando durante el primer tramo.
      expect(transform.storage[0], lessThan(0.999));
    },
  );
}
