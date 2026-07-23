import 'package:flutter/material.dart';

import '../../laboratorio_atlassian/tema/tema_atlassian.dart';

class PanelAdministradorAtlassian extends StatelessWidget {
  const PanelAdministradorAtlassian({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(EspacioAtlassian.md),
    this.onTap,
    this.selected = false,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fill =
        backgroundColor ??
        (selected
            ? scheme.primaryContainer.withValues(alpha: 0.72)
            : scheme.surface);

    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(RadioAtlassian.large),
        border: Border.all(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadioAtlassian.large),
        child: content,
      ),
    );
  }
}

class EncabezadoAdministradorAtlassian extends StatelessWidget {
  const EncabezadoAdministradorAtlassian({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: EspacioAtlassian.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: EspacioAtlassian.md),
          trailing!,
        ],
      ],
    );
  }
}

class EstadoVacioAdministradorAtlassian extends StatelessWidget {
  const EstadoVacioAdministradorAtlassian({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: PanelAdministradorAtlassian(
          padding: const EdgeInsets.all(EspacioAtlassian.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: EspacioAtlassian.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              if (message != null && message!.trim().isNotEmpty) ...[
                const SizedBox(height: EspacioAtlassian.xs),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: EspacioAtlassian.md),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AvisoAdministradorAtlassian extends StatelessWidget {
  const AvisoAdministradorAtlassian({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.level = NivelAvisoAdministrador.neutral,
  });

  final IconData icon;
  final String title;
  final String? message;
  final NivelAvisoAdministrador level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final (background, foreground, border) = switch (level) {
      NivelAvisoAdministrador.success => (
        dark
            ? PaletaAtlassian.successSubtleDark
            : PaletaAtlassian.successSubtle,
        dark ? const Color(0xFFBAF3DB) : const Color(0xFF164B35),
        PaletaAtlassian.success,
      ),
      NivelAvisoAdministrador.warning => (
        dark
            ? PaletaAtlassian.warningSubtleDark
            : PaletaAtlassian.warningSubtle,
        dark ? const Color(0xFFFFF0B3) : const Color(0xFF7F5F01),
        PaletaAtlassian.warning,
      ),
      NivelAvisoAdministrador.danger => (
        dark ? PaletaAtlassian.dangerSubtleDark : PaletaAtlassian.dangerSubtle,
        dark ? const Color(0xFFFFD2CC) : const Color(0xFF5D1F1A),
        PaletaAtlassian.danger,
      ),
      NivelAvisoAdministrador.discovery => (
        dark
            ? PaletaAtlassian.discoverySubtleDark
            : PaletaAtlassian.discoverySubtle,
        dark ? const Color(0xFFDFD8FD) : const Color(0xFF352C63),
        PaletaAtlassian.discovery,
      ),
      NivelAvisoAdministrador.neutral => (
        theme.colorScheme.surfaceContainerLow,
        theme.colorScheme.onSurface,
        theme.colorScheme.outlineVariant,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EspacioAtlassian.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RadioAtlassian.large),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: EspacioAtlassian.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                  ),
                ),
                if (message != null && message!.trim().isNotEmpty) ...[
                  const SizedBox(height: EspacioAtlassian.xxs),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum NivelAvisoAdministrador { neutral, success, warning, danger, discovery }
