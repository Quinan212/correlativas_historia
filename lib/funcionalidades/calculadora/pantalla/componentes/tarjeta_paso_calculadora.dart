import 'package:flutter/material.dart';
import '../tema/estilos_calculadora.dart';

class TarjetaPasoCalculadora extends StatelessWidget {
  const TarjetaPasoCalculadora({
    super.key,
    required this.numero,
    required this.titulo,
    required this.subtitulo,
  });

  final int numero;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = EstilosCalculadora.esOscuro(context);

    return Container(
      decoration: EstilosCalculadora.decoracionTarjeta(context),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark
                  ? EstilosCalculadora.oscurecer(const Color(0xFFE5EDFF), 0.82)
                  : const Color(0xFFE5EDFF),
              border: Border.all(
                color: isDark ? cs.outlineVariant : const Color(0xFFBFDBFE),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$numero',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? cs.onSurface : const Color(0xFF1D4ED8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: EstilosCalculadora.textoPrincipal(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: EstilosCalculadora.textoSecundario(context),
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
