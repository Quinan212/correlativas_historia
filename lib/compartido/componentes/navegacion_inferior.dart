import 'package:flutter/material.dart';

class NavegacionInferiorApp extends StatelessWidget {
  final int current;
  final VoidCallback onTapTrayectorias;
  final VoidCallback onTapHome;
  final VoidCallback onTapCenter;
  final VoidCallback onTapMap;
  final VoidCallback onTapCalc;

  const NavegacionInferiorApp({
    super.key,
    required this.current,
    required this.onTapTrayectorias,
    required this.onTapHome,
    required this.onTapCenter,
    required this.onTapMap,
    required this.onTapCalc,
  });

  static const _fabDiameter = 54.0;
  static const _fabRadius = _fabDiameter / 2;
  static const _navBodyH = 60.0;
  static const _fabGap = _fabDiameter + 8.0;
  static const _indicatorH = 5.0;
  static const _indicatorW = 36.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final bg = cs.surface;
    final brd = cs.outlineVariant;
    final color = cs.onSurfaceVariant;
    final bodyH = _navBodyH + bottomPad;

    return MediaQuery.withNoTextScaling(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: bodyH,
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalW = constraints.maxWidth;
                      final tabW = (totalW - _fabGap) / 4;
                      final left = _indicatorLeft(current, tabW);

                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: bg,
                              border: Border(
                                top: BorderSide(color: brd, width: 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _item(
                                    Icons.school_outlined,
                                    'Inicio',
                                    onTapTrayectorias,
                                    color,
                                  ),
                                ),
                                Expanded(
                                  child: _item(
                                    Icons.assignment_outlined,
                                    'Exámenes',
                                    onTapHome,
                                    color,
                                  ),
                                ),
                                const SizedBox(width: _fabGap),
                                Expanded(
                                  child: _item(
                                    Icons.list_alt_outlined,
                                    'Materias',
                                    onTapMap,
                                    color,
                                  ),
                                ),
                                Expanded(
                                  child: _item(
                                    Icons.person_outlined,
                                    'Datos',
                                    onTapCalc,
                                    color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            top: 0,
                            left: left,
                            child: Container(
                              width: _indicatorW,
                              height: _indicatorH,
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(height: bottomPad),
              ],
            ),
          ),
          Positioned(
            top: -_fabRadius,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onTapCenter,
                    child: Container(
                      width: _fabDiameter,
                      height: _fabDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.primary,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: bg, width: 3),
                      ),
                      child: Icon(
                        Icons.account_tree_rounded,
                        color: cs.onPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Plan completo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _indicatorLeft(int idx, double tabW) {
    final offset = (tabW - _indicatorW) / 2;
    switch (idx) {
      case 0:
        return offset;
      case 1:
        return tabW + offset;
      case 2:
        return tabW * 2 + _fabGap + offset;
      case 3:
        return tabW * 3 + _fabGap + offset;
      default:
        return 0;
    }
  }

  Widget _item(IconData icon, String label, VoidCallback onTap, Color color) {
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: SizedBox(
          height: _navBodyH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
