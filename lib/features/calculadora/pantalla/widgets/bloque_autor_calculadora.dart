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
            'Autor',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: EstilosCalculadora.textoPrincipal(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '© 2025 Alan Gabriel Maillet — Autor original\nTodos los derechos reservados.',
            style: TextStyle(
              fontSize: 12,
              color: EstilosCalculadora.textoSecundario(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Material educativo didáctico, creado con la única intención de facilitarle la vida a los estudiantes.',
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