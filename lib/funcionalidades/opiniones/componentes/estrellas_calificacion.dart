import 'package:flutter/material.dart';

class EstrellasCalificacion extends StatelessWidget {
  const EstrellasCalificacion({
    super.key,
    required this.value,
    this.size = 18,
    this.color,
  });

  final double value;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final starColor = color ?? const Color(0xFFF59E0B);
    final muted = theme.colorScheme.outlineVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (index) {
        final starNumber = index + 1;
        final icon = value >= starNumber
            ? Icons.star_rounded
            : value >= starNumber - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded;
        return Icon(
          icon,
          size: size,
          color: icon == Icons.star_outline_rounded ? muted : starColor,
        );
      }),
    );
  }
}
