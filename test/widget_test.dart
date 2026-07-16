import 'package:correlativas_historia/main.dart';
import 'package:correlativas_historia/compartido/supabase/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MainScreen builds sin Supabase inicializado', (
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
        child: const MaterialApp(home: MainScreen()),
      ),
    );
    await tester.pump();

    expect(find.byType(MainScreen), findsOneWidget);
  });
}
