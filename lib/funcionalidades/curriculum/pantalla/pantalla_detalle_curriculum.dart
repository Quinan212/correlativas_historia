import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../proveedores/proveedores_curriculum.dart';

class PantallaDetalleCurriculum extends ConsumerWidget {
  final String materiaId;

  const PantallaDetalleCurriculum({super.key, required this.materiaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contenido = ref.watch(proveedorContenidoPorId(materiaId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (contenido == null) {
      return Scaffold(
        backgroundColor: isDark ? cs.surface : Colors.white,
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final texto = theme.textTheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060B14) : Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(contenido.nombre),
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${contenido.anio}° Año',
                      style: texto.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isDark ? cs.onSurface : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaTexto(
                      label: 'Formato',
                      value: contenido.formato,
                      cs: cs,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _MetaTexto(
                      label: 'Carga horaria',
                      value: contenido.cargaHoraria,
                      cs: cs,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _MetaTexto(
                      label: 'Régimen de cursado',
                      value: contenido.regimenCursado,
                      cs: cs,
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Seccion(
              titulo: 'Marco Orientador',
              cs: cs,
              children: [
                Text(
                  contenido.marcoOrientador,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: 15.5,
                    height: 1.58,
                    color: isDark ? cs.onSurface : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Seccion(
              titulo: 'Ejes de contenidos',
              cs: cs,
              children: [
                for (int i = 0; i < contenido.ejes.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  Text(
                    contenido.ejes[i].titulo,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? cs.onSurface : const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    contenido.ejes[i].descripcion,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.58,
                      color: isDark ? cs.onSurface : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            _Seccion(
              titulo: 'Bibliografía',
              cs: cs,
              children: [
                for (int i = 0; i < contenido.bibliografia.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${i + 1}.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            contenido.bibliografia[i],
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.48,
                              color: isDark
                                  ? cs.onSurface
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final ColorScheme cs;
  final List<Widget> children;

  const _Seccion({
    required this.titulo,
    required this.cs,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _MetaTexto extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final bool isDark;

  const _MetaTexto({
    required this.label,
    required this.value,
    required this.cs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: double.infinity,
        child: RichText(
          textAlign: TextAlign.left,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: isDark ? cs.onSurface : const Color(0xFF111827),
            ),
            children: <InlineSpan>[
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
