import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:correlativas_historia/features/cascada/cascada_screen.dart';
import 'package:correlativas_historia/features/calculadora/calculadora_screen.dart';
import 'package:correlativas_historia/features/faq/faq_screen.dart';
import 'package:correlativas_historia/shared/providers/app_state.dart';
import 'package:correlativas_historia/shared/widgets/bottom_nav.dart';
import 'package:correlativas_historia/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Mapa y Calculadora de Correlatividades',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerIndex = ref.watch(routerIndexProvider).clamp(0, 2);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: routerIndex,
          children: const [
            CascadaScreen(key: ValueKey('cascada')),
            CalculadoraScreen(key: ValueKey('calculadora')),
            FaqScreen(key: ValueKey('faq')),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: routerIndex,
        onTapMap: () => ref.read(routerIndexProvider.notifier).state = 0,   // izquierda
        onTapCalc: () => ref.read(routerIndexProvider.notifier).state = 1,  // medio
        onTapFaq: () => ref.read(routerIndexProvider.notifier).state = 2,   // derecha
      ),
    );
  }
}