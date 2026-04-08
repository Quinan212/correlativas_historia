import 'package:flutter/material.dart';

import '../tema/estilos_calculadora.dart';

class BloqueAutorCalculadora extends StatelessWidget {
  const BloqueAutorCalculadora({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: EstilosCalculadora.decoracionTarjeta(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Proyecto',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: EstilosCalculadora.textoPrincipal(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Desarrollo y curaduría inicial: Alan Gabriel Maillet.',
            style: TextStyle(
              fontSize: 12,
              color: EstilosCalculadora.textoSecundario(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Material didáctico de apoyo, pensado para leer condiciones reales de cursada y acompañar decisiones concretas desde una mirada estudiantil.',
            style: TextStyle(
              fontSize: 13,
              color: EstilosCalculadora.textoSecundario(context),
            ),
          ),
        ],
      ),
    );
  }
}
