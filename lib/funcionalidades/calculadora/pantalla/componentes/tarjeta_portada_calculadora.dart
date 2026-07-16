import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../compartido/proveedores/estado_app.dart';
import '../tema/estilos_calculadora.dart';

class TarjetaPortadaCalculadora extends ConsumerWidget {
  const TarjetaPortadaCalculadora({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: EstilosCalculadora.decoracionTarjeta(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Escenarios de cursada',
            style: TextStyle(
              fontSize: 30,
              height: 1.10,
              fontWeight: FontWeight.w700,
              color: EstilosCalculadora.textoPrincipal(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Esta pantalla no busca reducir el recorrido a un sí o un no aislado. '
            'Te ayuda a leer, en contexto, qué condiciones ya cumpliste, cuáles siguen pendientes '
            'y qué escenario de cursada se abre hoy para la materia que estás mirando.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
              color: EstilosCalculadora.textoSecundario(context),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              onPressed: () =>
                  ref.read(proveedorIndiceRouter.notifier).state = 1,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: EstilosCalculadora.bordeTarjeta(context),
                ),
                foregroundColor: EstilosCalculadora.textoPrincipal(context),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: const Text('Volver al mapa'),
            ),
          ),
        ],
      ),
    );
  }
}
