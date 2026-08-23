import 'package:correlativas_historia/compartido/proveedores/estado_app.dart';
import 'package:correlativas_historia/funcionalidades/calculadora/calculadora_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/cascada/inicio_mapa_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/cascada/mapa_correlatividades_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/preguntas_frecuentes/preguntas_frecuentes_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/laboratorio_mesas_excel/pantallas/pantalla_sistema_mesas_excel_atlassian.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../componentes/componentes_atlassian.dart';
import '../tema/tema_atlassian.dart';

class PantallaAccesoDeveloperAtlassian extends StatelessWidget {
  const PantallaAccesoDeveloperAtlassian({
    super.key,
    this.inicioReactBuilder,
  });

  final WidgetBuilder? inicioReactBuilder;

  void _openLegacy(BuildContext context) {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(builder: (_) => const PantallaModoLegacyDeveloper()),
    );
  }

  void _openInicioReact(BuildContext context) {
    final builder = inicioReactBuilder;
    if (builder == null) return;
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(builder: builder),
    );
  }

  void _openExcelLab(BuildContext context) {
    Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) => const PantallaSistemaMesasExcelAtlassian(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final atlassianTheme = temaLaboratorioAtlassian(context);

    return Theme(
      data: atlassianTheme,
      child: Scaffold(
        backgroundColor: atlassianTheme.scaffoldBackgroundColor,
        body: Column(
          children: [
            EncabezadoPaginaAtlassian(
              title: 'Acceso developer',
              subtitle: 'Seleccionar modo',
              leading: IconButton(
                tooltip: 'Volver',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TarjetaAccionAtlassian(
                    label: 'Modo legacy',
                    description: 'Versión histórica 2025',
                    icon: Icons.history_rounded,
                    badge: 'DEV',
                    onTap: () => _openLegacy(context),
                  ),
                  const SizedBox(height: 12),
                  TarjetaAccionAtlassian(
                    label: 'Exámenes desde Excel',
                    description:
                        'Lectura, validación y calendario local de la fuente pública',
                    icon: Icons.table_view_outlined,
                    badge: 'LAB',
                    onTap: () => _openExcelLab(context),
                  ),
                  if (inicioReactBuilder != null) ...[
                    const SizedBox(height: 12),
                    TarjetaAccionAtlassian(
                      label: 'Inicio React',
                      description:
                          'Clon experimental del Inicio. La pantalla principal queda intacta.',
                      icon: Icons.auto_awesome_mosaic_rounded,
                      badge: 'LAB',
                      onTap: () => _openInicioReact(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PantallaModoLegacyDeveloper extends ConsumerStatefulWidget {
  const PantallaModoLegacyDeveloper({super.key});

  @override
  ConsumerState<PantallaModoLegacyDeveloper> createState() =>
      _PantallaModoLegacyDeveloperState();
}

class _PantallaModoLegacyDeveloperState
    extends ConsumerState<PantallaModoLegacyDeveloper> {
  late final VoidCallback _restoreRouterIndex;

  @override
  void initState() {
    super.initState();
    final routerController = ref.read(proveedorIndiceRouter.notifier);
    final previousRouterIndex = routerController.state;
    _restoreRouterIndex = () {
      routerController.state = previousRouterIndex;
    };
    routerController.state = 0;
  }

  @override
  void dispose() {
    _restoreRouterIndex();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(proveedorIndiceRouter).clamp(0, 3).toInt();
    const pages = <Widget>[
      PantallaInicioMapa(
        key: ValueKey('developer_legacy_inicio'),
        mostrarAccesosExternos: false,
      ),
      PantallaMapaCorrelatividades(
        key: ValueKey('developer_legacy_mapa'),
        mostrarAccesoExamenes: false,
      ),
      PantallaCalculadora(key: ValueKey('developer_legacy_calculadora')),
      PantallaPreguntasFrecuentes(key: ValueKey('developer_legacy_preguntas')),
    ];

    final content = pages[selectedIndex];
    final width = MediaQuery.sizeOf(context).width;

    if (width >= 900) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: _selectPage,
              extended: width >= 1250,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconButton(
                  tooltip: 'Salir del modo legacy',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: Text('Inicio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.account_tree_outlined),
                  selectedIcon: Icon(Icons.account_tree_rounded),
                  label: Text('Mapa'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calculate_outlined),
                  selectedIcon: Icon(Icons.calculate_rounded),
                  label: Text('Calculadora'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.help_outline_rounded),
                  selectedIcon: Icon(Icons.help_rounded),
                  label: Text('Preguntas'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: content),
          ],
        ),
      );
    }

    return Scaffold(
      body: content,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon: Icon(Icons.account_tree_rounded),
            label: 'Mapa',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate_rounded),
            label: 'Calculadora',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline_rounded),
            selectedIcon: Icon(Icons.help_rounded),
            label: 'Preguntas',
          ),
        ],
      ),
    );
  }

  void _selectPage(int index) {
    ref.read(proveedorIndiceRouter.notifier).state = index;
  }
}
