import 'package:flutter/material.dart';
import '../../../../modelos/materia.dart';
import '../tema/estilos_calculadora.dart';

class ResumenMateriaCalculadora extends StatelessWidget {
  const ResumenMateriaCalculadora({super.key, required this.materia});
  final Materia materia;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: EstilosCalculadora.decoracionTarjeta(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            materia.nombre,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: EstilosCalculadora.textoPrincipal(context),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chipTipo(context, materia.tipo),
              _chipFormato(context, materia.formato),
              _chipAnio(context, materia.anio),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chipBase({
    required String text,
    required Color bg,
    required Color bd,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bd),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _chipTipo(BuildContext context, String tipo) {
    final s = EstilosCalculadora.estiloTipo(context, tipo);
    return _chipBase(text: tipo, bg: s.bg, bd: s.bd, fg: s.fg);
  }

  Widget _chipFormato(BuildContext context, String formato) {
    final s = EstilosCalculadora.estiloFormato(context, formato);
    return _chipBase(text: formato, bg: s.bg, bd: s.bd, fg: s.fg);
  }

  Widget _chipAnio(BuildContext context, int anio) {
    final s = EstilosCalculadora.estiloAnio(context);
    return _chipBase(text: '$anio° Año', bg: s.bg, bd: s.bd, fg: s.fg);
  }
}
