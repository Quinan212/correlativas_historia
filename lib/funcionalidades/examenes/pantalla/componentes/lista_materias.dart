import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../compartido/utilidades/sanitizar_texto.dart';
import '../../../../modelos/materia.dart';

import '../logica_examenes.dart';
import '../hoja/recursos_banner_materia.dart';

part 'banner_aviso_examen.dart';
part 'proximos_examenes_strip.dart';
part 'seccion_lista_examenes.dart';
part 'tarjeta_materia_examen.dart';

class ListaMaterias extends StatelessWidget {
  const ListaMaterias({
    super.key,
    required this.careerId,
    required this.secciones,
    required this.proximos,
    required this.examsHiddenMode,
    required this.hiddenModeMessage,
    required this.isZeus,
    required this.onTapMateria,
  });

  final String careerId;
  final List<SeccionDeLista> secciones;
  final List<MateriaParaLista> proximos;
  final bool examsHiddenMode;
  final String hiddenModeMessage;
  final bool isZeus;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (secciones.isEmpty) {
      return Center(
        child: Text(
          'No hay materias para los filtros seleccionados.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1000;
        final horizontalPadding = isDesktop ? 20.0 : (isZeus ? 14.0 : 12.0);
        final bottomPadding = isDesktop ? 24.0 : (isZeus ? 20.0 : 16.0);

        final content = [
          if (hiddenModeMessage.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: isZeus ? 14 : 10),
              child: _BannerAviso(
                message: hiddenModeMessage,
                isZeus: isZeus,
              ),
            ),
          if (proximos.isNotEmpty && !examsHiddenMode) ...[
            _ProximosStrip(
              careerId: careerId,
              proximos: proximos,
              isZeus: isZeus,
              onTapMateria: onTapMateria,
            ),
            SizedBox(height: isZeus ? 16 : 14),
          ],
          if (!isDesktop)
            for (var i = 0; i < secciones.length; i++) ...[
              _Seccion(
                key: ValueKey('${secciones[i].titulo}-$i'),
                careerId: careerId,
                titulo: secciones[i].titulo,
                materias: secciones[i].materias,
                esColoquios: secciones[i].esColoquios,
                examsHiddenMode: examsHiddenMode,
                hiddenModeMessage: hiddenModeMessage,
                isZeus: isZeus,
                onTapMateria: onTapMateria,
              ),
              SizedBox(height: isZeus ? 14 : 10),
            ]
          else
            LayoutBuilder(
              builder: (context, sectionConstraints) {
                final sectionCols = sectionConstraints.maxWidth >= 1800
                    ? 3
                    : sectionConstraints.maxWidth >= 1180
                        ? 2
                        : sectionConstraints.maxWidth >= 700
                            ? 2
                            : 1;
                final sectionSpacing = isZeus ? 16.0 : 14.0;
                final sectionWidth = (sectionConstraints.maxWidth -
                        sectionSpacing * (sectionCols - 1)) /
                    sectionCols;

                return Wrap(
                  spacing: sectionSpacing,
                  runSpacing: sectionSpacing,
                  children: [
                    for (var i = 0; i < secciones.length; i++)
                      SizedBox(
                        width: sectionWidth,
                        child: _Seccion(
                          key: ValueKey('${secciones[i].titulo}-$i'),
                          careerId: careerId,
                          titulo: secciones[i].titulo,
                          materias: secciones[i].materias,
                          esColoquios: secciones[i].esColoquios,
                          examsHiddenMode: examsHiddenMode,
                          hiddenModeMessage: hiddenModeMessage,
                          isZeus: isZeus,
                          onTapMateria: onTapMateria,
                        ),
                      ),
                  ],
                );
              },
            ),
        ];

        final canOwnVerticalScroll = isDesktop && constraints.hasBoundedHeight;

        return ListView(
          shrinkWrap: !canOwnVerticalScroll,
          physics: canOwnVerticalScroll
              ? null
              : const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            isZeus ? 12 : 10,
            horizontalPadding,
            bottomPadding,
          ),
          children: content,
        );
      },
    );
  }
}

// ---------- Helper: información de tiempo relativo ----------

class _TiempoRelativoInfo {
  final String label;
  final bool isExpired;

  const _TiempoRelativoInfo({required this.label, required this.isExpired});
}

_TiempoRelativoInfo _tiempoRelativo(DateTime? dt) {
  if (dt == null)
    return const _TiempoRelativoInfo(label: 'Sin fecha', isExpired: false);

  final now = DateTime.now();
  final diff = dt.difference(now);
  final isExpired = diff.isNegative;

  if (!isExpired) {
    final totalMinutes = diff.inMinutes;
    final totalHours = (totalMinutes / 60).ceil();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final daysDiff = target.difference(today).inDays;

    if (daysDiff == 0)
      return const _TiempoRelativoInfo(label: 'Hoy', isExpired: false);
    if (totalHours <= 48)
      return _TiempoRelativoInfo(
          label: 'En $totalHours horas', isExpired: false);
    if (daysDiff == 1)
      return const _TiempoRelativoInfo(label: 'Mañana', isExpired: false);
    return _TiempoRelativoInfo(label: 'En $daysDiff días', isExpired: false);
  }

  final ago = diff.abs();
  final totalMinutes = ago.inMinutes;
  final totalHours = (totalMinutes / 60).floor();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final daysAgo = target.difference(today).inDays.abs();

  if (totalMinutes < 60)
    return const _TiempoRelativoInfo(label: 'Ahora mismo', isExpired: true);
  if (totalHours < 2)
    return const _TiempoRelativoInfo(label: 'Hace 1 hora', isExpired: true);
  if (totalHours < 24)
    return _TiempoRelativoInfo(
        label: 'Hace $totalHours horas', isExpired: true);
  if (daysAgo == 1)
    return const _TiempoRelativoInfo(label: 'Ayer', isExpired: true);
  if (daysAgo == 2)
    return const _TiempoRelativoInfo(label: 'Anteayer', isExpired: true);
  if (daysAgo < 7)
    return _TiempoRelativoInfo(label: 'Hace $daysAgo días', isExpired: true);
  if (daysAgo < 14)
    return const _TiempoRelativoInfo(label: 'Hace 1 semana', isExpired: true);
  if (daysAgo < 21)
    return const _TiempoRelativoInfo(label: 'Hace 2 semanas', isExpired: true);
  if (daysAgo < 30)
    return const _TiempoRelativoInfo(label: 'Hace 3 semanas', isExpired: true);
  if (daysAgo < 60)
    return const _TiempoRelativoInfo(label: 'Hace 1 mes', isExpired: true);
  if (daysAgo < 90)
    return const _TiempoRelativoInfo(label: 'Hace 2 meses', isExpired: true);
  if (daysAgo < 180)
    return const _TiempoRelativoInfo(label: 'Hace 3 meses', isExpired: true);
  return const _TiempoRelativoInfo(label: 'Expirado', isExpired: true);
}

// ---------- Helpers de visualización ----------

String _displayNameForScreen(MateriaParaLista item) {
  final raw =
      sanitizarTexto(item.materiaPlan?.displayNombre ?? item.nombreBase).trim();
  final low = sanitizeLowerNoAccents(raw);
  if (!low.contains('practica docente')) return raw;

  final match = RegExp(
    r'practica\s+docente\s+(i{1,3}|iv|\d+)',
    caseSensitive: false,
  ).firstMatch(low);
  if (match == null) return 'Práctica Docente';

  final token = match.group(1)!.toLowerCase();
  final number = switch (token) {
    'i' => 1,
    'ii' => 2,
    'iii' => 3,
    'iv' => 4,
    _ => int.tryParse(token),
  };

  return number == null ? 'Práctica Docente' : 'Práctica Docente $number';
}

// ---------- Componentes compartidos ----------

Widget _statusPill(
  BuildContext context, {
  required String label,
  required bool confirmed,
  bool isExpired = false,
}) {
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;

  late final Color bg;
  late final Color fg;

  if (isExpired) {
    bg = isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
    fg = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  } else if (confirmed) {
    bg = isDark ? const Color(0xFF13302A) : const Color(0xFFECFDF3);
    fg = isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857);
  } else {
    bg = isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    fg = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: isExpired
            ? (isDark ? const Color(0xFF4B5563) : const Color(0xFFD1D5DB))
            : (confirmed
                ? (isDark ? cs.outlineVariant : const Color(0xFFA7F3D0))
                : (isDark ? cs.outlineVariant : const Color(0xFFD1D5DB))),
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w800,
        fontSize: 10,
      ),
    ),
  );
}

Widget _chip({
  required String text,
  required Color bg,
  required Color fg,
  required Color bd,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: bd),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w800,
        fontSize: 10,
      ),
    ),
  );
}

Widget _metaChip({
  required IconData icon,
  required String text,
  required Color bg,
  required Color fg,
  required Color bd,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: bd),
      boxShadow: [
        BoxShadow(
          blurRadius: 8,
          offset: const Offset(0, 2),
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: fg),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w800,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

// ---------- Formateo de fecha/hora ----------

String _fmtFecha(DateTime dt) {
  final d = dt.day.toString().padLeft(2, '0');
  final m = dt.month.toString().padLeft(2, '0');
  return '$d/$m';
}

String _fmtHora(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

bool _hasDefinedHour(DateTime dt) {
  return !(dt.hour == 0 && dt.minute == 0);
}

String _etiquetaHora(
  DateTime dt, {
  required bool esColoquio,
  bool shortUndefinedLabel = false,
}) {
  if (_hasDefinedHour(dt)) return _fmtHora(dt);
  if (shortUndefinedLabel) return 'A definir';
  return esColoquio
      ? 'A definir · consultar con docente de catedra'
      : 'A definir';
}

// ignore: unused_element
String _etiquetaDiasCompacta(DateTime? dt) {
  if (dt == null) return 'Sin fecha';
  final info = _tiempoRelativo(dt);
  return info.label;
}

// ignore: unused_element
String _daysInsigniaText(DateTime? dt) {
  if (dt == null) return 'SIN\nFECHA';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(dt.year, dt.month, dt.day);
  final diff = target.difference(today).inDays;

  if (diff == 0) return 'HOY';
  if (diff == 1) return '1\nDÍA';
  if (diff > 1) return '$diff\nDÍAS';

  final absDays = diff.abs();
  return absDays == 1 ? '1\nDÍA' : '$absDays\nDÍAS';
}

// ignore: unused_element
String _etiquetaDias(DateTime? dt) {
  if (dt == null) return 'Sin fecha';
  final info = _tiempoRelativo(dt);
  return info.label;
}
