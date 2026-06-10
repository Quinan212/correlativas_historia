import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int current; // 0 = Trayectorias, 1 = Inicio, 2 = Cascada/Mapa, 3 = Calculadora
  final VoidCallback onTapTrayectorias;
  final VoidCallback onTapHome;
  final VoidCallback onTapMap;
  final VoidCallback onTapCalc;

  const AppBottomNav({
    super.key,
    required this.current,
    required this.onTapTrayectorias,
    required this.onTapHome,
    required this.onTapMap,
    required this.onTapCalc,
  });

  static const _brand = Color(0xFF1D4ED8);

  static const _bgLight = Color(0xFFFFFFFF);
  static const _borderLight = Color(0xFFE5E7EB);
  static const _unselectedLight = Color(0xFF6B7280);

  static const _bgDark = Color(0xFF0B1220);
  static const _borderDark = Color(0xFF243041);
  static const _unselectedDark = Color(0xFF9CA3AF);

  Widget _tile({
    required bool selected,
    required IconData icon,
    required IconData filledIcon,
    required Color color,
  }) {
    return Center(
      child: Icon(selected ? filledIcon : icon, size: 30, color: color),
    );
  }

  Widget _divider(Color c) => Container(width: 1, height: 24, color: c);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? _bgDark : _bgLight;
    final brd = isDark ? _borderDark : _borderLight;
    final unselected = isDark ? _unselectedDark : _unselectedLight;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(top: BorderSide(color: brd)),
        ),
        child: Row(
          children: [
            // TRAYECTORIAS
            Expanded(
              child: InkWell(
                onTap: onTapTrayectorias,
                splashColor: _brand.withOpacity(0.08),
                highlightColor: _brand.withOpacity(0.04),
                child: SizedBox(
                  height: 60,
                  child: _tile(
                    selected: current == 0,
                    icon: Icons.school_outlined,
                    filledIcon: Icons.school_rounded,
                    color: current == 0 ? _brand : unselected,
                  ),
                ),
              ),
            ),
            _divider(brd),

            // INICIO
            Expanded(
              child: InkWell(
                onTap: onTapHome,
                splashColor: _brand.withOpacity(0.08),
                highlightColor: _brand.withOpacity(0.04),
                child: SizedBox(
                  height: 60,
                  child: _tile(
                    selected: current == 1,
                    icon: Icons.home_outlined,
                    filledIcon: Icons.home_rounded,
                    color: current == 1 ? _brand : unselected,
                  ),
                ),
              ),
            ),
            _divider(brd),

            // MAPA
            Expanded(
              child: InkWell(
                onTap: onTapMap,
                splashColor: _brand.withOpacity(0.08),
                highlightColor: _brand.withOpacity(0.04),
                child: SizedBox(
                  height: 60,
                  child: _tile(
                    selected: current == 2,
                    icon: Icons.map_outlined,
                    filledIcon: Icons.map,
                    color: current == 2 ? _brand : unselected,
                  ),
                ),
              ),
            ),
            _divider(brd),

            // CALCULADORA
            Expanded(
              child: InkWell(
                onTap: onTapCalc,
                splashColor: _brand.withOpacity(0.08),
                highlightColor: _brand.withOpacity(0.04),
                child: SizedBox(
                  height: 60,
                  child: _tile(
                    selected: current == 3,
                    icon: Icons.calculate_outlined,
                    filledIcon: Icons.calculate,
                    color: current == 3 ? _brand : unselected,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

