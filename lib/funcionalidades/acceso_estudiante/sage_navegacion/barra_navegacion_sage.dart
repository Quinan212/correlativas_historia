import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';

class BarraNavegacionSage extends StatelessWidget {
  const BarraNavegacionSage({
    super.key,
    required this.onBack,
    required this.onHome,
    required this.onChangeProfile,
    required this.onLogout,
    this.canGoBack = true,
    this.homeSelected = false,
    this.profileSelected = false,
    this.busy = false,
  });

  static const double height = 72;

  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback onChangeProfile;
  final VoidCallback onLogout;
  final bool canGoBack;
  final bool homeSelected;
  final bool profileSelected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final atlassian = usaEstiloAtlassianSage(context);

    return Material(
      color: scheme.surface,
      elevation: atlassian ? 0 : 12,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      child: DecoratedBox(
        decoration: atlassian
            ? BoxDecoration(
                border: Border(top: BorderSide(color: scheme.outlineVariant)),
              )
            : const BoxDecoration(),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                Expanded(
                  child: _NavigationAction(
                    icon: Icons.arrow_back_rounded,
                    label: 'Atrás',
                    enabled: canGoBack && !busy,
                    onTap: onBack,
                  ),
                ),
                Expanded(
                  child: _NavigationAction(
                    icon: Icons.home_rounded,
                    label: 'Inicio',
                    selected: homeSelected,
                    enabled: !busy,
                    onTap: onHome,
                  ),
                ),
                Expanded(
                  child: _NavigationAction(
                    icon: Icons.manage_accounts_outlined,
                    label: 'Perfil',
                    selected: profileSelected,
                    enabled: !busy && !profileSelected,
                    onTap: onChangeProfile,
                  ),
                ),
                Expanded(
                  child: _NavigationAction(
                    icon: Icons.logout_rounded,
                    label: 'Salir',
                    enabled: !busy,
                    destructive: true,
                    onTap: onLogout,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationAction extends StatelessWidget {
  const _NavigationAction({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.enabled,
    this.selected = false,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool selected;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final atlassian = usaEstiloAtlassianSage(context);
    final foreground = !enabled
        ? scheme.onSurface.withValues(alpha: 0.34)
        : destructive
        ? scheme.error
        : selected
        ? scheme.primary
        : scheme.onSurfaceVariant;

    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: EdgeInsets.symmetric(
                horizontal: selected && atlassian ? 14 : 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: selected && atlassian
                    ? scheme.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: foreground, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
