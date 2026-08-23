import 'dart:ui' as ui;

import 'package:flutter/material.dart';

@immutable
class TemaReactDeveloper {
  const TemaReactDeveloper._({
    required this.isDark,
    required this.canvas,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.surface,
    required this.surfaceStrong,
    required this.surfaceSoft,
    required this.resultSurface,
    required this.border,
    required this.shadow,
    required this.wordmark,
  });

  factory TemaReactDeveloper.of(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return TemaReactDeveloper._(
      isDark: isDark,
      canvas: isDark ? theme.scaffoldBackgroundColor : const Color(0xFFF7FAFF),
      text: isDark ? scheme.onSurface : const Color(0xFF0B2341),
      textMuted: isDark
          ? scheme.onSurfaceVariant
          : const Color(0xFF36506F),
      textSubtle: isDark
          ? scheme.onSurfaceVariant.withValues(alpha: 0.68)
          : const Color(0xFF536B88),
      surface: isDark
          ? const Color(0xFF171A22).withValues(alpha: 0.78)
          : Colors.white.withValues(alpha: 0.84),
      surfaceStrong: isDark
          ? const Color(0xFF151922).withValues(alpha: 0.94)
          : Colors.white.withValues(alpha: 0.96),
      surfaceSoft: isDark
          ? const Color(0xFF11151D).withValues(alpha: 0.82)
          : Colors.white.withValues(alpha: 0.72),
      resultSurface: isDark
          ? const Color(0xFF151922)
          : Colors.white.withValues(alpha: 0.88),
      border: (isDark ? Colors.white : const Color(0xFF0C66E4))
          .withValues(alpha: isDark ? 0.10 : 0.50),
      shadow: (isDark ? Colors.black : const Color(0xFF245D92))
          .withValues(alpha: isDark ? 0.30 : 0.10),
      wordmark: isDark ? Colors.white : const Color(0xFF003F9E),
    );
  }

  final bool isDark;
  final Color canvas;
  final Color text;
  final Color textMuted;
  final Color textSubtle;
  final Color surface;
  final Color surfaceStrong;
  final Color surfaceSoft;
  final Color resultSurface;
  final Color border;
  final Color shadow;
  final Color wordmark;

  Color foreground(double alpha) => text.withValues(alpha: alpha);

  Color muted(double alpha) => textMuted.withValues(alpha: alpha);

  Color neutralOverlay(double alpha) =>
      (isDark ? Colors.white : const Color(0xFF172B4D))
          .withValues(alpha: alpha);

  Color decorativeAccent(Color accent) {
    if (isDark) return accent;
    final hsl = HSLColor.fromColor(accent);
    return hsl
        .withSaturation(hsl.saturation < 0.62 ? 0.62 : hsl.saturation)
        .withLightness(0.52)
        .toColor();
  }

  Color _lightTint(Color color, double amount) =>
      Color.lerp(Colors.white, decorativeAccent(color), amount)!;

  List<Color> liquidGradient(ColorScheme scheme) => isDark
      ? <Color>[
          scheme.surface.withValues(alpha: 0.84),
          const Color(0xFF0C66E4).withValues(alpha: 0.16),
          const Color(0xFFA78BFA).withValues(alpha: 0.10),
          scheme.surface.withValues(alpha: 0.78),
        ]
      : const <Color>[
          Color(0xDFFFFFFF),
          Color(0x96FFFFFF),
          Color(0x72FFFFFF),
          Color(0xB8FFFFFF),
        ];

  List<Color> cardGradient(List<Color> darkColors) {
    if (isDark) return darkColors;
    return <Color>[
      _lightTint(darkColors.first, 0.12),
      Colors.white,
      Colors.white,
      _lightTint(darkColors.last, 0.075),
    ];
  }

  List<Color> accentGradient(Color accent) => isDark
      ? <Color>[accent.withValues(alpha: 0.54), const Color(0xFF171726)]
      : <Color>[
          _lightTint(accent, 0.12),
          Colors.white,
          Colors.white,
          _lightTint(const Color(0xFFA78BFA), 0.06),
        ];

  List<Color> sageGradient() => isDark
      ? const <Color>[
          Color(0xFF0B2C5C),
          Color(0xFF24163D),
          Color(0xFF121620),
        ]
      : <Color>[
          _lightTint(const Color(0xFF579DFF), 0.06),
          Colors.white,
          Colors.white,
          _lightTint(const Color(0xFFA78BFA), 0.035),
          _lightTint(const Color(0xFF36B37E), 0.025),
        ];

  List<Color> spotlightGradient() => isDark
      ? const <Color>[
          Color(0xFF0B356A),
          Color(0xFF2E1A52),
          Color(0xFF111820),
        ]
      : <Color>[
          _lightTint(const Color(0xFF579DFF), 0.13),
          Colors.white,
          Colors.white,
          _lightTint(const Color(0xFFA78BFA), 0.08),
        ];

  List<Color> noResultsGradient() => isDark
      ? const <Color>[Color(0xFF191A28), Color(0xFF121720)]
      : <Color>[
          _lightTint(const Color(0xFF579DFF), 0.08),
          Colors.white,
          Colors.white,
        ];

  List<Color> suggestionGradient(Color accent) => isDark
      ? <Color>[
          accent.withValues(alpha: 0.28),
          const Color(0xFF171A22),
        ]
      : <Color>[_lightTint(accent, 0.08), Colors.white, Colors.white];

  List<Color> resultGradient(Color accent, {required bool pressed}) {
    if (isDark) {
      return <Color>[
        accent.withValues(alpha: pressed ? 0.22 : 0.13),
        resultSurface,
      ];
    }
    return <Color>[
      _lightTint(accent, pressed ? 0.13 : 0.09),
      Colors.white,
      Colors.white,
    ];
  }
}

class ReactGlassBlur extends StatelessWidget {
  const ReactGlassBlur({
    required this.borderRadius,
    required this.child,
    this.sigma = 24,
    super.key,
  });

  final BorderRadius borderRadius;
  final Widget child;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    if (context.reactTheme.isDark) return child;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }
}

extension TemaReactDeveloperContext on BuildContext {
  TemaReactDeveloper get reactTheme => TemaReactDeveloper.of(this);
}
