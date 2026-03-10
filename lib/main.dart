import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:correlativas_historia/features/cascada/cascada_screen.dart';
import 'package:correlativas_historia/features/cascada/inicio_mapa_screen.dart';
import 'package:correlativas_historia/features/calculadora/calculadora_screen.dart';
import 'package:correlativas_historia/features/faq/faq_screen.dart';
import 'package:correlativas_historia/shared/providers/app_state.dart';
import 'package:correlativas_historia/shared/widgets/bottom_nav.dart';
import 'package:correlativas_historia/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
    final routerIndex = ref.watch(routerIndexProvider).clamp(0, 3);

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: routerIndex,
          children: const [
            InicioMapaScreen(key: ValueKey('inicio_mapa')),
            CascadaScreen(key: ValueKey('cascada')),
            CalculadoraScreen(key: ValueKey('calculadora')),
            FaqScreen(key: ValueKey('faq')),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        current: routerIndex,
        onTapHome: () => ref.read(routerIndexProvider.notifier).state = 0,
        onTapMap: () => ref.read(routerIndexProvider.notifier).state = 1,
        onTapCalc: () => ref.read(routerIndexProvider.notifier).state = 2,
        onTapFaq: () => ref.read(routerIndexProvider.notifier).state = 3,
      ),
    );
  }
}
