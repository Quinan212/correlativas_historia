import 'package:flutter/material.dart';

import '../logica_examenes.dart';

// 👇 cambiá esta ruta por donde tengas esas funciones
import 'package:correlativas_historia/features/cascada/grilla/utils/estilos_chips.dart';

class ListaMaterias extends StatelessWidget {
  const ListaMaterias({
    super.key,
    required this.secciones,
    required this.onTapMateria,
  });

  final List<SeccionDeLista> secciones;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: secciones.length,
      itemBuilder: (context, idx) {
        final s = secciones[idx];
        return _Seccion(
          titulo: s.titulo,
          materias: s.materias,
          esColoquios: s.esColoquios,
          onTapMateria: onTapMateria,
        );
      },
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.materias,
    required this.esColoquios,
    required this.onTapMateria,
  });

  final String titulo;
  final List<MateriaParaLista> materias;
  final bool esColoquios;
  final void Function(String materia, bool fromColoquios) onTapMateria;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
            child: Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...materias.map(
                (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TarjetaMateria(
                item: m,
                onTap: () => onTapMateria(m.nombreEvento, esColoquios),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaMateria extends StatelessWidget {
  const _TarjetaMateria({
    required this.item,
    required this.onTap,
  });

  final MateriaParaLista item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasPlan = item.materiaPlan != null;

    final fmt = item.formato;
    final tipo = item.tipo;

    final (fmtBg, fmtFg, fmtBd) = (hasPlan && fmt.isNotEmpty)
        ? coloresFormato(isDark, fmt)
        : (Colors.transparent, cs.onSurfaceVariant, Colors.transparent);

    final (tipoBg, tipoFg, tipoBd) = (hasPlan && tipo.isNotEmpty)
        ? coloresTipo(isDark, tipo)
        : (Colors.transparent, cs.onSurfaceVariant, Colors.transparent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                blurRadius: 6,
                color: theme.shadowColor.withValues(alpha: 0.10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreMostrable,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (hasPlan && fmt.isNotEmpty)
                      _chip(
                        text: normalizarFormatoChip(fmt),
                        bg: fmtBg,
                        fg: fmtFg,
                        bd: fmtBd,
                      ),
                    if (hasPlan && fmt.isNotEmpty) const SizedBox(width: 8),
                    if (hasPlan && tipo.isNotEmpty)
                      _chip(
                        text: tipo,
                        bg: tipoBg,
                        fg: tipoFg,
                        bd: tipoBd,
                      ),

                  ],
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          fontSize: 12,
        ),
      ),
    );
  }
}