// lib/features/examenes/sheet/widgets_sheet_examenes.dart
import 'package:flutter/material.dart';
import '../../models/examen_event.dart';

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
    return Stack(
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
    );
  }
}

class CajaMateria extends StatelessWidget {
  const CajaMateria({
    super.key,
    required this.materia,
    required this.llamado1,
    required this.llamado2,
    required this.onTapDetalle,
  });

  final String materia;
  final ExamenEvent? llamado1;
  final ExamenEvent? llamado2;
  final void Function(String titulo, ExamenEvent? evento) onTapDetalle;

  Widget _botonCuadrado(
      BuildContext context, {
        required String titulo,
        required ExamenEvent? evento,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTapDetalle(titulo, evento),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
            materia,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final itemW = ((c.maxWidth - gap) / 2).clamp(150.0, 420.0);

            return Row(
              children: [
                SizedBox(
                  width: itemW,
                  child: _botonCuadrado(
                    context,
                    titulo: 'Primer\nllamado',
                    evento: llamado1,
                  ),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: itemW,
                  child: _botonCuadrado(
                    context,
                    titulo: 'Segundo\nllamado',
                    evento: llamado2,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CajaDetalle extends StatelessWidget {
  const CajaDetalle({
    super.key,
    required this.titulo,
    required this.materia,
    required this.evento,
  });

  final String titulo;
  final String materia;
  final ExamenEvent? evento;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final dt = evento?.fechaHora;

    String lineaFecha() {
      if (dt == null) return 'Fecha: —';
      return 'Fecha: ${_fmtFecha(dt)}';
    }

    String lineaHora() {
      if (evento == null) return 'Horario: —';
      if (evento!.hora == null || dt == null) return 'Horario: —';
      return 'Horario: ${_fmtHora(dt)} hs';
    }

    final docentes = (evento?.docentes ?? const <String>[])
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            ),
          ),
          child: Text(
            '$materia — ${titulo.replaceAll('\n', ' ')}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? cs.surface : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? cs.outlineVariant : const Color(0xFFD1D5DB),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: theme.shadowColor.withValues(alpha: 0.10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lineaFecha(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lineaHora(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Docentes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              if (docentes.isEmpty)
                Text(
                  '—',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: docentes
                      .map(
                        (d) => ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 160),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? cs.primary.withValues(alpha: 0.14)
                              : cs.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? cs.outlineVariant : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          d,
                          softWrap: true,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}