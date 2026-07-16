import 'package:correlativas_historia/funcionalidades/examenes/examenes_pantalla.dart';
import 'package:correlativas_historia/funcionalidades/acceso_estudiante/pantallas/acceso_estudiante_pantalla.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../compartido/proveedores/estado_app.dart';
import 'componentes/banner_colapsable_mapa.dart';
import 'componentes/tarjeta_autor_mapa.dart';
import 'componentes/tarjeta_leyenda_mapa.dart';

class PantallaInicioMapa extends ConsumerWidget {
  const PantallaInicioMapa({super.key});

  static const Color kPageBgLight = Color(0xFFF5F7FA);

  void _openExamenes(BuildContext context, WidgetRef ref) {
    prewarmExamenesData(ref);
    Navigator.of(context).push(buildExamenesRoute());
  }

  void _openStudentAccess(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AccesoEstudiantePantalla(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? cs.surface : kPageBgLight,
        body: _LayoutInicioEscritorio(
          onOpenMapa: () => ref.read(proveedorIndiceRouter.notifier).state = 1,
          onOpenCalculadora: () =>
              ref.read(proveedorIndiceRouter.notifier).state = 2,
          onOpenExamenes: () => _openExamenes(context, ref),
          onOpenStudentAccess: () => _openStudentAccess(context),
        ),
      );
    }

    // VERSION MOVIL
    final items = <Widget>[
      const TarjetaLeyendaMapa(),
      const TarjetaAutorMapa(),
    ];

    return Scaffold(
      backgroundColor: isDark ? cs.surface : kPageBgLight,
      body: SafeArea(
        top: false,
        bottom: true,
        child: CustomScrollView(
          cacheExtent: 200,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: BannerColapsableMapa(
                topInset: topInset,
                expandedTitle: 'Inicio',
                collapsedTitle: 'INICIO',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: items[index],
                  ),
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LayoutInicioEscritorio extends StatelessWidget {
  const _LayoutInicioEscritorio({
    required this.onOpenMapa,
    required this.onOpenCalculadora,
    required this.onOpenExamenes,
    required this.onOpenStudentAccess,
  });

  final VoidCallback onOpenMapa;
  final VoidCallback onOpenCalculadora;
  final VoidCallback onOpenExamenes;
  final VoidCallback onOpenStudentAccess;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 48, 40),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO ESTILO MOVIL PERO WIDE
              Text(
                'Mapa de Correlatividades',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF004966),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Profesorado de Educación Secundaria en Historia',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // COLUMNA PRINCIPAL
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _TarjetaAccionEscritorio(
                                title: 'Mapa de Carrera',
                                desc:
                                    'Visualizá el plan de estudios y correlatividades.',
                                icon: Icons.map_rounded,
                                color: const Color(0xFF005B7F),
                                onTap: onOpenMapa,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _TarjetaAccionEscritorio(
                                title: 'Calculadora',
                                desc: 'Gestioná tus finales y promedios.',
                                icon: Icons.calculate_rounded,
                                color: const Color(0xFF0EA5E9),
                                onTap: onOpenCalculadora,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _TarjetaAccionEscritorio(
                          title: 'Exámenes',
                          desc:
                              'Cronograma oficial de mesas y llamados de finales.',
                          icon: Icons.event_note_rounded,
                          color: const Color(0xFF8B5CF6),
                          horizontal: true,
                          onTap: onOpenExamenes,
                        ),
                        const SizedBox(height: 20),
                        _TarjetaAccionEscritorio(
                          title: 'Alumno y trayectoria',
                          desc:
                              'Ingreso del alumno para ver materias, estados y avance.',
                          icon: Icons.school_rounded,
                          color: const Color(0xFF1F7A99),
                          horizontal: true,
                          onTap: onOpenStudentAccess,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // SIDEBAR
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        const TarjetaLeyendaMapa(),
                        const SizedBox(height: 20),
                        const TarjetaAutorMapa(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaAccionEscritorio extends StatefulWidget {
  const _TarjetaAccionEscritorio({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.onTap,
    this.horizontal = false,
  });

  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  State<_TarjetaAccionEscritorio> createState() =>
      _TarjetaAccionEscritorioState();
}

class _TarjetaAccionEscritorioState extends State<_TarjetaAccionEscritorio> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(widget.icon, color: widget.color, size: 28),
        ),
        const SizedBox(height: 20),
        Text(
          widget.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          widget.desc,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );

    if (widget.horizontal) {
      content = Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(widget.icon, color: widget.color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w900),
                ),
                Text(
                  widget.desc,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.grey),
        ],
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(24),
          transform: Matrix4.translationValues(0.0, _hover ? -4.0 : 0.0, 0.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161F2E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hover
                  ? widget.color
                  : (isDark
                      ? const Color(0xFF243041)
                      : const Color(0xFFE5E7EB)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _hover
                    ? widget.color.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _hover ? 20 : 10,
                offset: Offset(0, _hover ? 8 : 4),
              ),
            ],
          ),
          child: content,
        ),
      ),
    );
  }
}


