import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/examen_event.dart';
import '../../../../models/materia.dart';
import '../../../../shared/utils/text_sanitize.dart';
import '../logica_examenes.dart';

class TarjetaCerrar extends StatelessWidget {
  const TarjetaCerrar({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 54,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
                const SizedBox(width: 8),
                Text(
                  'CERRAR DETALLE',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white70 : Colors.black87,
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

class InstanciaTabData {
  factory InstanciaTabData.fromEventos({
    required String id,
    required String label,
    required String materia,
    required List<ExamenEvent> eventos,
  }) {
    final options = <DivisionOptionData>[];
    for (var i = 0; i < eventos.length; i++) {
      final evento = eventos[i];
      final divisionLabel = _divisionLabelForEvent(
        materiaBase: materia,
        rawMateria: evento.materia,
        evento: evento,
        index: i,
        total: eventos.length,
      );
      options.add(
        DivisionOptionData(
          id: '$id-$i-${divisionLabel.toLowerCase().replaceAll(' ', '-')}',
          label: divisionLabel,
          evento: evento,
        ),
      );
    }
    return InstanciaTabData(id: id, label: label, options: options);
  }

  const InstanciaTabData({
    required this.id,
    required this.label,
    required this.options,
  });

  final String id;
  final String label;
  final List<DivisionOptionData> options;
}

class DivisionOptionData {
  const DivisionOptionData({
    required this.id,
    required this.label,
    required this.evento,
  });

  final String id;
  final String label;
  final ExamenEvent evento;
}

String _normalizeDivision(String s) {
  return s
      .toLowerCase()
      .replaceAll('\u00e1', 'a')
      .replaceAll('\u00e9', 'e')
      .replaceAll('\u00ed', 'i')
      .replaceAll('\u00f3', 'o')
      .replaceAll('\u00fa', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _displayMateriaForSheet(String rawInput) {
  final raw = _stripDivisionNoiseForSheet(rawInput);
  final low = sanitizeLowerNoAccents(raw);

  final match = RegExp(
    r'^\s*practica\s+docente\s+(i{1,3}|iv|\d+)\b',
  ).firstMatch(low);
  if (match == null) return raw;

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

String _stripDivisionNoiseForSheet(String value) {
  var text = sanitizeText(value).trim();
  text = text.replaceAll(
    RegExp(
      r'\s*[-–—]?\s*(comision|comisión|division|división|grupo)\s+([ab])\b',
      caseSensitive: false,
    ),
    '',
  );
  text = text.replaceAll(
    RegExp(r'\s*[-–—]?\s*a\s*y\s*b\b', caseSensitive: false),
    '',
  );
  text = text.replaceAll(
    RegExp(r'\(\s*a\s*y\s*b\s*\)', caseSensitive: false),
    '',
  );
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

String _divisionLabelForEvent({
  required String materiaBase,
  required String rawMateria,
  required ExamenEvent evento,
  required int index,
  required int total,
}) {
  if (evento.division != null && evento.division!.isNotEmpty) {
    return evento.division!;
  }

  final normalized = _normalizeDivision(rawMateria);

  if (RegExp(r'\bcomision b\b').hasMatch(normalized)) return 'Comision B';
  if (RegExp(r'\bcomision a\b').hasMatch(normalized)) return 'Comision A';
  if (RegExp(r'\bdivision b\b').hasMatch(normalized)) return 'Division B';
  if (RegExp(r'\bdivision a\b').hasMatch(normalized)) return 'Division A';
  if (RegExp(r'\bgrupo b\b').hasMatch(normalized)) return 'Division B';
  if (RegExp(r'\bgrupo a\b').hasMatch(normalized)) return 'Division A';

  final base = _normalizeDivision(materiaBase);
  final docentes = evento.docentes.map(_normalizeDivision).join(' ');

  final isIdeas = base.contains('historia de las ideas');
  final isDidacticaCs =
      base.contains('didactica') && base.contains('ciencias sociales');

  if (isIdeas && docentes.contains('borche')) return 'Division B';
  if (isIdeas && (docentes.contains('javier') || total > 1)) {
    return 'Division A';
  }

  if (isDidacticaCs && docentes.contains('patricia')) return 'Division B';
  if (isDidacticaCs && (docentes.contains('emilia') || total > 1)) {
    return 'Division A';
  }

  if (total > 1) {
    return 'Division ${String.fromCharCode(65 + index)}';
  }

  return 'Unica';
}

class PanelExamenMateria extends StatelessWidget {
  const PanelExamenMateria({
    super.key,
    required this.careerId,
    required this.materia,
    required this.tabs,
    required this.activeTabId,
    required this.activeDivisionId,
    required this.onTabChanged,
    required this.onDivisionChanged,
    required this.mapaPlan,
  });

  final String careerId;
  final String materia;
  final List<InstanciaTabData> tabs;
  final String activeTabId;
  final String? activeDivisionId;
  final ValueChanged<String> onTabChanged;
  final ValueChanged<String> onDivisionChanged;
  final Map<String, Materia> mapaPlan;

  InstanciaTabData get _activeTab {
    if (tabs.isEmpty) {
      return const InstanciaTabData(
        id: 'none',
        label: 'Sin datos',
        options: <DivisionOptionData>[],
      );
    }
    return tabs.firstWhere(
      (t) => t.id == activeTabId,
      orElse: () => tabs.first,
    );
  }

  DivisionOptionData? get _activeOption {
    if (_activeTab.options.isEmpty) return null;
    return _activeTab.options.firstWhere(
      (o) => o.id == activeDivisionId,
      orElse: () => _activeTab.options.first,
    );
  }

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

  String _horaLabel(DateTime? dt, {required bool esColoquio}) {
    if (dt == null) return 'A confirmar';
    if (_hasDefinedHour(dt)) return '${_fmtHora(dt)} hs';
    return 'A definir';
  }

  String _daysLabel(DateTime? dt) {
    if (dt == null) return 'A confirmar';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    if (diff < -14) return 'Fue hace mas de dos semanas';
    if (diff < -7) return 'Fue hace mas de una semana';
    if (diff == -1) return 'Fue ayer';
    if (diff < 0) {
      final daysAgo = diff.abs();
      return daysAgo == 1 ? 'Fue hace un dia' : 'Fue hace $daysAgo dias';
    }
    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Manana';
    return 'En $diff dias';
  }

  Future<void> _copyInfo(
    BuildContext context,
    InstanciaTabData tab,
    DivisionOptionData? option,
  ) async {
    final e = option?.evento;
    final dt = e?.fechaHora;
    final esColoquio = e?.instancia == 'coloquio';

    final lines = <String>[
      _displayMateriaForSheet(materia),
      'Instancia: ${tab.label}',
      if (option != null && tab.options.length > 1) 'Division: ${option.label}',
      'Fecha: ${dt == null ? 'A confirmar' : _fmtFecha(dt)}',
      'Hora: ${_horaLabel(dt, esColoquio: esColoquio)}',
      if (e != null && e.docentes.isNotEmpty)
        'Tribunal: ${e.docentes.join(', ')}',
    ];

    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información copiada al portapapeles')),
    );
  }

  Future<void> _openActa(BuildContext context) async {
    final raw = _activeOption?.evento.actaUrl;
    final uri = raw == null || raw.trim().isEmpty ? null : Uri.tryParse(raw);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acta no disponible para esta materia')),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final activeTab = _activeTab;
    final activeOption = _activeOption;
    final multipleDivisions = activeTab.options.length > 1;

    final borderColor = isDark ? cs.outlineVariant : const Color(0xFFD1D5DB);
    final colorBlanco = isDark ? cs.surface : Colors.white;
    final colorGris = isDark ? cs.surfaceContainerLow : const Color(0xFFF3F4F6);

    Widget buildCell({
      required Widget child,
      required Color bgColor,
      bool isLast = false,
    }) {
      return Container(
        height: double.infinity,
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            right: isLast ? BorderSide.none : BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Center(child: child),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre de la materia
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            _displayMateriaForSheet(materia).toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: cs.onSurface,
            ),
          ),
        ),

        // Tabs de Instancias (si hay más de una)
        if (tabs.length > 1)
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: tabs.map((tab) {
                final isSel = tab.id == activeTabId;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTabChanged(tab.id),
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSel ? cs.primary.withValues(alpha: 0.1) : null,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        tab.label.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                          color: isSel ? cs.primary : theme.hintColor,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        // Selector de Divisiones
        if (multipleDivisions)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: activeTab.options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final opt = activeTab.options[i];
                final isSel = opt.id == activeDivisionId;
                return ChoiceChip(
                  label: Text(opt.label),
                  selected: isSel,
                  onSelected: (_) => onDivisionChanged(opt.id),
                  labelStyle: theme.textTheme.labelSmall?.copyWith(
                    color: isSel ? Colors.white : cs.onSurface,
                    fontWeight: isSel ? FontWeight.w900 : FontWeight.w500,
                  ),
                );
              },
            ),
          ),

        if (multipleDivisions) const SizedBox(height: 12),

        // Grid con borde exterior completo
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fila: Año | Fecha | Horario | Días (VERDE)
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: buildCell(
                        bgColor: colorBlanco,
                        child: Text(
                          () {
                            final int? realAnio = activeOption?.evento.anio ??
                                (activeOption?.evento != null
                                    ? anioPlanParaEvento(
                                        activeOption!.evento, mapaPlan)
                                    : null);
                            return realAnio != null ? '$realAnio°' : '-';
                          }(),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    if (activeOption?.evento.instancia == 'coloquio')
                      Expanded(
                        flex: 2,
                        child: buildCell(
                          bgColor: colorBlanco,
                          child: Text(
                            (activeOption?.evento.division != null &&
                                    activeOption!.evento.division!.isNotEmpty)
                                ? activeOption.evento.division!.toUpperCase()
                                : '-',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: buildCell(
                        bgColor: colorBlanco,
                        child: Text(
                          activeOption?.evento.fechaHora == null
                              ? 'A CONF'
                              : _fmtFecha(activeOption!.evento.fechaHora!),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: buildCell(
                        bgColor: colorBlanco,
                        child: Text(
                          activeOption?.evento.fechaHora == null
                              ? '-'
                              : _horaLabel(
                                  activeOption?.evento.fechaHora,
                                  esColoquio: activeOption?.evento.instancia ==
                                      'coloquio',
                                ),
                          style: theme.textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: buildCell(
                        isLast: true,
                        bgColor: const Color(0xFF047857),
                        child: Text(
                          _daysLabel(activeOption?.evento.fechaHora)
                              .toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Encabezado TRIBUNAL
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorGris,
                  border: Border(bottom: BorderSide(color: borderColor)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Center(
                  child: Text(
                    'TRIBUNAL',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                      letterSpacing: 1.5,
                      color: theme.hintColor,
                    ),
                  ),
                ),
              ),

              // Docentes en la misma fila, cada uno en su celda
              IntrinsicHeight(
                child: Row(
                  children: () {
                    final docentes = activeOption?.evento.docentes ?? [];
                    if (docentes.isEmpty) {
                      return [
                        Expanded(
                          child: buildCell(
                            bgColor: colorBlanco,
                            isLast: true,
                            child: Text(
                              'NO ASIGNADO',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ];
                    }
                    return docentes.asMap().entries.map((entry) {
                      final isLast = entry.key == docentes.length - 1;
                      return Expanded(
                        child: buildCell(
                          bgColor: colorBlanco,
                          isLast: isLast,
                          child: Text(
                            entry.value.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      );
                    }).toList();
                  }(),
                ),
              ),

              // Acciones: COPIAR | VER ACTA
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _copyInfo(context, activeTab, activeOption),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorGris,
                          border: Border(right: BorderSide(color: borderColor)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy_all_rounded,
                                size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'COPIAR',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _openActa(context),
                      child: Container(
                        height: 48,
                        color: colorGris,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined,
                                size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'VER ACTA',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ), // cierre Container borde exterior
      ],
    );
  }
}

class BarritaYBotonX extends StatelessWidget {
  const BarritaYBotonX({
    super.key,
    required this.onTapX,
    required this.colorX,
    required this.colorBarrita,
  });

  final VoidCallback onTapX;
  final Color colorX;
  final Color colorBarrita;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: colorBarrita,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: onTapX,
            icon: Icon(Icons.close_rounded, color: colorX),
          ),
        ),
      ],
    );
  }
}
