import 'package:flutter/material.dart';

@immutable
class EstiloVisualSage extends ThemeExtension<EstiloVisualSage> {
  const EstiloVisualSage({required this.atlassian});

  const EstiloVisualSage.atlassian() : atlassian = true;

  final bool atlassian;

  @override
  EstiloVisualSage copyWith({bool? atlassian}) =>
      EstiloVisualSage(atlassian: atlassian ?? this.atlassian);

  @override
  EstiloVisualSage lerp(covariant EstiloVisualSage? other, double t) {
    if (other == null) return this;
    return t < 0.5 ? this : other;
  }
}

bool usaEstiloAtlassianSage(BuildContext context) =>
    Theme.of(context).extension<EstiloVisualSage>()?.atlassian ?? false;

PreferredSizeWidget construirAppBarSage(
  BuildContext context, {
  required String title,
  Widget? leading,
  List<Widget> actions = const <Widget>[],
  PreferredSizeWidget? bottom,
  double? toolbarHeight,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final atlassian = usaEstiloAtlassianSage(context);

  return AppBar(
    backgroundColor: atlassian
        ? theme.scaffoldBackgroundColor
        : const Color(0xFF0E5E86),
    foregroundColor: atlassian ? scheme.onSurface : Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    toolbarHeight: toolbarHeight,
    shape: atlassian
        ? Border(bottom: BorderSide(color: scheme.outlineVariant))
        : null,
    titleTextStyle: atlassian
        ? theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)
        : null,
    leading: leading,
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    actions: actions,
    bottom: bottom,
  );
}

InputDecoration decoracionBusquedaSage(
  BuildContext context, {
  required String hintText,
  VoidCallback? onClear,
  bool showClear = false,
}) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;
  final atlassian = usaEstiloAtlassianSage(context);
  final radius = BorderRadius.circular(atlassian ? 999 : 12);
  final border = OutlineInputBorder(
    borderRadius: radius,
    borderSide: BorderSide(color: scheme.outlineVariant),
  );

  return InputDecoration(
    hintText: hintText,
    labelText: atlassian ? null : hintText,
    filled: true,
    fillColor: scheme.surface,
    prefixIcon: Icon(Icons.search_rounded, color: scheme.primary, size: 21),
    suffixIcon: showClear
        ? IconButton(
            tooltip: 'Limpiar búsqueda',
            onPressed: onClear,
            icon: const Icon(Icons.close_rounded, size: 19),
          )
        : null,
    contentPadding: EdgeInsets.symmetric(
      horizontal: atlassian ? 18 : 14,
      vertical: atlassian ? 14 : 12,
    ),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: scheme.primary, width: 2),
    ),
  );
}

BoxDecoration decoracionPanelSage(
  BuildContext context, {
  bool selected = false,
}) {
  final scheme = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: selected ? scheme.primaryContainer : scheme.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: selected
          ? scheme.primary.withValues(alpha: 0.42)
          : scheme.outlineVariant,
    ),
  );
}
