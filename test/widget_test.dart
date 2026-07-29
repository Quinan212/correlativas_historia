import 'package:correlativas_historia/compartido/supabase/supabase.dart';
import 'package:correlativas_historia/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App se construye sin Supabase inicializado', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          proveedorArranqueSupabase.overrideWithValue(
            const ResultadoArranqueSupabase(
              status: EstadoArranqueSupabase.missingAnonKey,
              message: 'Test',
            ),
          ),
        ],
        child: const App(),
      ),
    );
    await tester.pump();

    expect(find.byType(App), findsOneWidget);
  });
}
