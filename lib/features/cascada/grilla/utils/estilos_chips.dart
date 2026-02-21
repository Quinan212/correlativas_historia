import 'package:flutter/material.dart';

Color oscurecer(Color c, [double t = 0.2]) => Color.lerp(c, Colors.black, t)!;

String normalizarFormatoChip(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('práctica docente') ||
      s.contains('practica docente') ||
      s.contains('práctica profesional docente') ||
      s.contains('practica profesional docente') ||
      s.contains('residencia')) {
    return 'Seminario-Taller';
  }
  return raw;
}

(Color bg, Color fg, Color bd) coloresFormato(bool isDark, String fmtRaw) {
  final value = normalizarFormatoChip(fmtRaw);
  final t = value.toLowerCase();

  if (!isDark) {
    if (t == 'asignatura') {
      return (
      const Color(0xFFDBEAFE),
      const Color(0xFF1D4ED8),
      const Color(0xFFBFDBFE),
      );
    }
    if (t == 'seminario') {
      return (
      const Color(0xFFD1FAE5),
      const Color(0xFF065F46),
      const Color(0xFFA7F3D0),
      );
    }
    if (t == 'seminario-taller') {
      return (
      const Color(0xFFEDE9FE),
      const Color(0xFF5B21B6),
      const Color(0xFFC4B5FD),
      );
    }
    if (t == 'taller') {
      return (
      const Color(0xFFFFF7ED),
      const Color(0xFFC2410C),
      const Color(0xFFFED7AA),
      );
    }
    if (t == 'electiva') {
      return (
      const Color(0xFFEFF6FF),
      const Color(0xFF1D4ED8),
      const Color(0xFFBFDBFE),
      );
    }
    if (t == 'práctica' || t == 'practica') {
      return (
      const Color(0xFFF5F3FF),
      const Color(0xFF6D28D9),
      const Color(0xFFDDD6FE),
      );
    }

    return (
    const Color(0xFFF3F4F6),
    const Color(0xFF374151),
    const Color(0xFFE5E7EB),
    );
  }

  if (t == 'asignatura') {
    return (
    oscurecer(const Color(0xFF223761)),
    const Color(0xFFBFD4FF),
    const Color(0xFF3E60A4),
    );
  }
  if (t == 'seminario') {
    return (
    oscurecer(const Color(0xFF1E4F45)),
    const Color(0xFFBFEFE0),
    const Color(0xFF2D8C78),
    );
  }
  if (t == 'seminario-taller') {
    return (
    oscurecer(const Color(0xFF3A2769)),
    const Color(0xFFE7D7FF),
    const Color(0xFF7351D4),
    );
  }
  if (t == 'taller') {
    return (
    oscurecer(const Color(0xFF7C2D12)),
    const Color(0xFFFED7AA),
    const Color(0xFFEA580C),
    );
  }
  if (t == 'electiva') {
    return (
    oscurecer(const Color(0xFF223761)),
    const Color(0xFFBFD4FF),
    const Color(0xFF3E60A4),
    );
  }
  if (t == 'práctica' || t == 'practica') {
    return (
    oscurecer(const Color(0xFF4C1D95)),
    const Color(0xFFDDD6FE),
    const Color(0xFF7C3AED),
    );
  }

  return (
  oscurecer(const Color(0xFF29313A)),
  const Color(0xFFE5E7EB),
  const Color(0xFF3E4753),
  );
}

(Color bg, Color fg, Color bd) coloresTipo(bool isDark, String tipo) {
  final s = tipo.toLowerCase();

  final isContable = s.contains('contable');
  final isJuridica = s.contains('jurídica') || s.contains('juridica');
  final isEconomia = s.contains('economía') || s.contains('economia');
  final isAdmin = s.contains('administración') || s.contains('administracion') || s.contains('admin');
  final isMate = s.contains('matemática') || s.contains('matematica') || s.contains('mate');
  final isFlexible = s.contains('flexible');
  final isHumanistica = s.contains('humanística') || s.contains('humanistica') || s.contains('humani');

  final isGen = s.contains('general');
  final isEsp = s.contains('espec');
  final isPra = s.contains('práctica') || s.contains('practica') || s.contains('profesional');

  if (!isDark) {
    if (isContable) {
      return (const Color(0xFFECFDF3), const Color(0xFF047857), const Color(0xFFA7F3D0));
    }
    if (isJuridica) {
      return (const Color(0xFFFEF2F2), const Color(0xFFB91C1C), const Color(0xFFFECACA));
    }
    if (isEconomia) {
      return (const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), const Color(0xFFBFDBFE));
    }
    if (isAdmin) {
      return (const Color(0xFFFFF7ED), const Color(0xFFC2410C), const Color(0xFFFED7AA));
    }
    if (isMate) {
      return (const Color(0xFFF5F3FF), const Color(0xFF6D28D9), const Color(0xFFDDD6FE));
    }
    if (isFlexible) {
      return (const Color(0xFFECFEFF), const Color(0xFF0E7490), const Color(0xFFA5F3FC));
    }
    if (isHumanistica) {
      return (const Color(0xFFFDF2F8), const Color(0xFFBE185D), const Color(0xFFFBCFE8));
    }

    if (isGen) {
      return (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8), const Color(0xFFBFDBFE));
    }
    if (isEsp) {
      return (const Color(0xFFD1FAE5), const Color(0xFF065F46), const Color(0xFFA7F3D0));
    }
    if (isPra) {
      return (const Color(0xFFEDE9FE), const Color(0xFF5B21B6), const Color(0xFFC4B5FD));
    }

    return (const Color(0xFFF3F4F6), const Color(0xFF374151), const Color(0xFFE5E7EB));
  }

  if (isContable) {
    return (oscurecer(const Color(0xFF064E3B)), const Color(0xFFA7F3D0), const Color(0xFF047857));
  }
  if (isJuridica) {
    return (oscurecer(const Color(0xFF7F1D1D)), const Color(0xFFFECACA), const Color(0xFFDC2626));
  }
  if (isEconomia) {
    return (oscurecer(const Color(0xFF1E3A8A)), const Color(0xFFBFDBFE), const Color(0xFF2563EB));
  }
  if (isAdmin) {
    return (oscurecer(const Color(0xFF7C2D12)), const Color(0xFFFED7AA), const Color(0xFFEA580C));
  }
  if (isMate) {
    return (oscurecer(const Color(0xFF4C1D95)), const Color(0xFFDDD6FE), const Color(0xFF7C3AED));
  }
  if (isFlexible) {
    return (oscurecer(const Color(0xFF155E75)), const Color(0xFFA5F3FC), const Color(0xFF06B6D4));
  }
  if (isHumanistica) {
    return (oscurecer(const Color(0xFF831843)), const Color(0xFFFBCFE8), const Color(0xFFDB2777));
  }

  if (isGen) {
    return (oscurecer(const Color(0xFF223761)), const Color(0xFFBFD4FF), const Color(0xFF3E60A4));
  }
  if (isEsp) {
    return (oscurecer(const Color(0xFF1E4F45)), const Color(0xFFBFEFE0), const Color(0xFF2D8C78));
  }
  if (isPra) {
    return (oscurecer(const Color(0xFF3A2769)), const Color(0xFFE7D7FF), const Color(0xFF7351D4));
  }

  return (oscurecer(const Color(0xFF29313A)), const Color(0xFFE5E7EB), const Color(0xFF3E4753));
}

Color colorTituloDesdeTipo(bool isDark, String tipo) {
  final (_, fg, __) = coloresTipo(isDark, tipo);
  return fg;
}