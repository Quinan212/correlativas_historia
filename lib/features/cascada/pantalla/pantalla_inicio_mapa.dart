import 'package:correlativas_historia/features/examenes/examenes_screen.dart';
import 'package:correlativas_historia/features/student_access/screens/student_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/app_state.dart';
import 'widgets/banner_colapsable_mapa.dart';
import 'widgets/callout_examenes.dart';
import 'widgets/tarjeta_autor_mapa.dart';
import 'widgets/tarjeta_leyenda_mapa.dart';

class InicioMapaScreen extends ConsumerWidget {
  const InicioMapaScreen({super.key});

  static const Color kPageBgLight = Color(0xFFF5F7FA);

  void _openExamenes(BuildContext context, WidgetRef ref) {
    prewarmExamenesData(ref);
    Navigator.of(context).push(buildExamenesRoute());
  }

  void _openStudentAccess(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const StudentAccessScreen(),
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
        body: _DesktopHomeLayout(
          onOpenMapa: () => ref.read(routerIndexProvider.notifier).state = 1,
          onOpenCalculadora: () =>
              ref.read(routerIndexProvider.notifier).state = 2,
          onOpenExamenes: () => _openExamenes(context, ref),
          onOpenStudentAccess: () => _openStudentAccess(context),
        ),
      );
    }

    // VERSION MOVIL
    final items = <Widget>[
      _PanelInicioMobile(
        onOpenMapa: () => ref.read(routerIndexProvider.notifier).state = 1,
        onOpenCalculadora: () =>
            ref.read(routerIndexProvider.notifier).state = 2,
        onOpenExamenes: () => _openExamenes(context, ref),
        onOpenStudentAccess: () => _openStudentAccess(context),
      ),
      CalloutExamenes(onTap: () => _openExamenes(context, ref)),
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

class _DesktopHomeLayout extends StatelessWidget {
  const _DesktopHomeLayout({
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
                              child: _DesktopActionCard(
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
                              child: _DesktopActionCard(
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
                        _DesktopActionCard(
                          title: 'Exámenes',
                          desc:
                              'Cronograma oficial de mesas y llamados de finales.',
                          icon: Icons.event_note_rounded,
                          color: const Color(0xFF8B5CF6),
                          horizontal: true,
                          onTap: onOpenExamenes,
                        ),
                        const SizedBox(height: 20),
                        _DesktopActionCard(
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

class _DesktopActionCard extends StatefulWidget {
  const _DesktopActionCard({
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
  State<_DesktopActionCard> createState() => _DesktopActionCardState();
}

class _DesktopActionCardState extends State<_DesktopActionCard> {
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

class _PanelInicioMobile extends StatelessWidget {
  const _PanelInicioMobile({
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFDCE3EC),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inicio del mapa',
            style: theme.textTheme.labelLarge?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Una lectura situada del recorrido de cursada',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Desde acá podés ubicarte en el plan, abrir herramientas clave y entrar rápido a cada recorrido.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _HomeQuickAction(
                  icon: Icons.map_rounded,
                  label: 'Mapa',
                  onTap: onOpenMapa,
                ),
                _HomeQuickAction(
                  icon: Icons.calculate_rounded,
                  label: 'Calculadora',
                  onTap: onOpenCalculadora,
                ),
                _HomeQuickAction(
                  icon: Icons.event_note_rounded,
                  label: 'Mesas',
                  onTap: onOpenExamenes,
                ),
                _HomeQuickAction(
                  icon: Icons.school_rounded,
                  label: 'Trayectoria',
                  onTap: onOpenStudentAccess,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeQuickAction extends StatelessWidget {
  const _HomeQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withValues(alpha: 0.10),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
