import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/examen_event.dart';
import '../examenes_visibility.dart';
import 'materia_banner_assets.dart';

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
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: theme.shadowColor.withValues(alpha: 0.10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              'Cerrar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
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
    return SizedBox(
      height: 34,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colorBarrita,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTapX,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close_rounded, size: 22, color: colorX),
                ),
              ),
            ),
          ),
        ],
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

String _divisionLabelForEvent({
  required String materiaBase,
  required String rawMateria,
  required ExamenEvent evento,
  required int index,
  required int total,
}) {
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
  if (isIdeas && total > 1) return 'Division A';
  if (isDidacticaCs && docentes.contains('patricia')) return 'Division B';
  if (isDidacticaCs && total > 1) return 'Division A';

  if (total <= 1) return 'Unica';
  return index == 0 ? 'Division A' : 'Division ${String.fromCharCode(65 + index)}';
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
  });

  final String careerId;
  final String materia;
  final List<InstanciaTabData> tabs;
  final String activeTabId;
  final String? activeDivisionId;
  final ValueChanged<String> onTabChanged;
  final ValueChanged<String> onDivisionChanged;

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
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  String _fmtHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _hasDefinedHour(DateTime dt) {
    return !(dt.hour == 0 && dt.minute == 0);
  }

  String _horaLabel(
    DateTime? dt, {
    required bool esColoquio,
    bool shortUndefinedLabel = false,
  }) {
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
      materia,
      'Instancia: ${tab.label}',
      if (option != null && tab.options.length > 1) 'Division: ${option.label}',
      'Fecha: ${dt == null ? 'A confirmar' : _fmtFecha(dt)}',
      'Hora: ${_horaLabel(dt, esColoquio: esColoquio)}',
      'Docentes: ${(e?.docentes ?? const <String>[]).isEmpty ? 'A confirmar' : e!.docentes.join(', ')}',
    ];

    await Clipboard.setData(ClipboardData(text: lines.join('\n')));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos copiados')),
    );
  }

  Widget _headerMateria(
    BuildContext context, {
    required bool isDark,
    required Color borderColor,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final anio = _activeOption?.evento.anio ??
        (tabs.first.options.isEmpty ? null : tabs.first.options.first.evento.anio);
    final assetPath = MateriaBannerAssets.resolve(
      careerId: careerId,
      materia: materia,
      anio: anio,
      variant: MateriaBannerVariant.detail,
    );

    return SizedBox(
      width: double.infinity,
      height: 170,
      child: Material(
        color: isDark ? cs.surface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: assetPath == null
                  ? ColoredBox(color: isDark ? cs.surface : Colors.white)
                  : Image.asset(
                      assetPath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) {
                        return ColoredBox(
                          color: isDark ? cs.surface : const Color(0xFFF8FAFC),
                        );
                      },
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withValues(alpha: assetPath == null ? 0.00 : 0.08),
                      Colors.black
                          .withValues(alpha: assetPath == null ? 0.00 : 0.30),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CareerPill(careerId: careerId),
                  const Spacer(),
                  Text(
                    materia,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: assetPath == null ? null : Colors.white,
                      shadows: assetPath == null
                          ? null
                          : const [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final active = _activeTab;
    final activeOption = _activeOption;
    final dt = activeOption?.evento.fechaHora;
    final hasDate = dt != null;
    final esColoquio = activeOption?.evento.instancia == 'coloquio';
    final docentes = (activeOption?.evento.docentes ?? const <String>[])
        .map((d) => d.trim())
        .where((d) => d.isNotEmpty)
        .toList();
    final examsHiddenMode = kOcultarExamenesPublicados;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerMateria(
          context,
          isDark: isDark,
          borderColor: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
        const SizedBox(height: 12),
        if (examsHiddenMode)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
              ),
            ),
            child: Text(
              kMensajeProximasMesas,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
          )
        else if (!esColoquio)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tabs.map((t) {
                final selected = t.id == active.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(t.label),
                    selected: selected,
                    onSelected: (_) => onTabChanged(t.id),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999)),
                    labelStyle: TextStyle(
                      color: selected
                          ? (isDark
                              ? cs.onPrimaryContainer
                              : const Color(0xFF1D4ED8))
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                    selectedColor:
                        isDark ? cs.primaryContainer : const Color(0xFFDBEAFE),
                    backgroundColor: isDark ? cs.surface : Colors.white,
                    side: BorderSide(
                      color:
                          isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (!examsHiddenMode && active.options.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: active.options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = active.options[index];
                final selected = option.id == activeDivisionId;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: selected,
                  onSelected: (_) => onDivisionChanged(option.id),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? (isDark
                            ? cs.onPrimaryContainer
                            : const Color(0xFF1D4ED8))
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                  ),
                  selectedColor:
                      isDark ? cs.primaryContainer : const Color(0xFFDBEAFE),
                  backgroundColor: isDark ? cs.surface : Colors.white,
                  side: BorderSide(
                    color:
                        isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
                  ),
                );
              },
            ),
          ),
        ],
        if (!examsHiddenMode) const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            ),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaPill(
                icon: examsHiddenMode
                    ? Icons.campaign_rounded
                    : hasDate
                        ? Icons.verified_rounded
                        : Icons.pending_rounded,
                label: examsHiddenMode
                    ? 'Proximamente'
                    : hasDate
                        ? 'Confirmado'
                        : 'A confirmar',
                confirmed: examsHiddenMode ? false : hasDate,
              ),
              _MetaPill(
                icon: Icons.event_available_rounded,
                label: examsHiddenMode ? 'Mesas de mayo' : _daysLabel(dt),
                confirmed: examsHiddenMode ? false : hasDate,
              ),
              _MetaPill(
                icon: Icons.update_rounded,
                label:
                    'Actualizado ${DateTime.now().day}/${DateTime.now().month}',
                confirmed: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoCard(
                icon: Icons.calendar_month_rounded,
                title: 'Fecha',
                value: examsHiddenMode
                    ? 'Proximamente'
                    : hasDate
                        ? _fmtFecha(dt)
                        : 'A confirmar',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoCard(
                icon: Icons.schedule_rounded,
                title: 'Hora',
                value: examsHiddenMode
                    ? 'A definir'
                    : _horaLabel(
                        dt,
                        esColoquio: esColoquio,
                        shortUndefinedLabel: false,
                      ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Docentes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              if (examsHiddenMode)
                Text(
                  'Volve pronto para ver las proximas fechas publicadas.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                )
              else if (docentes.isEmpty)
                Text(
                  'A confirmar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      docentes.map((d) => _TeacherChip(nombre: d)).toList(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed:
                examsHiddenMode ? null : () => _copyInfo(context, active, activeOption),
            icon: Icon(examsHiddenMode
                ? Icons.schedule_send_rounded
                : Icons.copy_all_rounded),
            label: Text(examsHiddenMode ? 'Proximamente' : 'Copiar datos'),
          ),
        ),
      ],
    );
  }
}

class _CareerPill extends StatelessWidget {
  const _CareerPill({required this.careerId});

  static const String _logoAsset = 'assets/career_icons/career_logo.png';
  static const double _pillHeight = 28;

  final String careerId;

  String get _label {
    switch (careerId) {
      case 'historia':
        return 'Profesorado de Historia';
      case 'geografia':
        return 'Profesorado de Geografía';
      case 'politica':
        return 'Ciencia Política';
      default:
        return careerId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: _pillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xCC111827),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            _label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: _pillHeight,
          height: _pillHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
          ),
          child: Image.asset(
            _logoAsset,
            fit: BoxFit.cover,
            cacheWidth: 96,
            cacheHeight: 96,
            filterQuality: FilterQuality.low,
          ),
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.confirmed,
  });

  final IconData icon;
  final String label;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = confirmed
        ? (isDark ? const Color(0xFF123127) : const Color(0xFFECFDF3))
        : (isDark ? const Color(0xFF3F2E14) : const Color(0xFFFFF7ED));
    final fg = confirmed
        ? (isDark ? const Color(0xFFA7F3D0) : const Color(0xFF047857))
        : (isDark ? const Color(0xFFFED7AA) : const Color(0xFFC2410C));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherChip extends StatelessWidget {
  const _TeacherChip({required this.nombre});

  final String nombre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final initial =
        nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? cs.primary.withValues(alpha: 0.16)
            : cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor:
                isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nombre,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
