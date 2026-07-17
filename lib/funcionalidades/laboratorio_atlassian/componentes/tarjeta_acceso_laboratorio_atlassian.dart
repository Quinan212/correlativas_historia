import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tema/tema_atlassian.dart';

class TarjetaAccesoLaboratorioAtlassian extends StatelessWidget {
  const TarjetaAccesoLaboratorioAtlassian({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      label: 'Abrir laboratorio de interfaces Atlassian',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: dark
                  ? PaletaAtlassian.surfaceRaisedDark
                  : PaletaAtlassian.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark
                    ? PaletaAtlassian.borderDark
                    : PaletaAtlassian.borderLight,
              ),
              boxShadow: [
                if (!dark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: PaletaAtlassian.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.view_quilt_rounded,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Laboratorio de interfaces',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? PaletaAtlassian.brandSubtleDark
                                  : PaletaAtlassian.brandSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'ATLASSIAN',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: dark
                                    ? const Color(0xFFCCE0FF)
                                    : const Color(0xFF09326C),
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
