import 'package:flutter/material.dart';

class BarraNavegacionSage extends StatelessWidget {
  const BarraNavegacionSage({
    super.key,
    required this.onBack,
    required this.onHome,
    required this.onChangeProfile,
    this.canGoBack = true,
    this.homeSelected = false,
    this.profileSelected = false,
    this.busy = false,
  });

  static const double height = 72;

  final VoidCallback onBack;
  final VoidCallback onHome;
  final VoidCallback onChangeProfile;
  final bool canGoBack;
  final bool homeSelected;
  final bool profileSelected;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.18),
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
                  label: 'Cambiar perfil',
                  selected: profileSelected,
                  enabled: !busy && !profileSelected,
                  onTap: onChangeProfile,
                ),
              ),
            ],
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = !enabled
        ? scheme.onSurface.withOpacity(0.34)
        : selected
        ? scheme.primary
        : scheme.onSurfaceVariant;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: foreground, size: 24),
            const SizedBox(height: 3),
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
