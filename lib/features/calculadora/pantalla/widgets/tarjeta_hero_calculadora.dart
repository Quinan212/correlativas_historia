import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/app_state.dart';
import '../tema/estilos_calculadora.dart';

class TarjetaHeroCalculadora extends ConsumerWidget {
  const TarjetaHeroCalculadora({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: EstilosCalculadora.decoracionTarjeta(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Puedo Cursar?',
            style: TextStyle(
              fontSize: 30,
              height: 1.10,
              fontWeight: FontWeight.w700,
              color: EstilosCalculadora.textoPrincipal(context),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ya sabés qué te falta... ahora, ¿Podés Cursar?\n'
            'Con Puedo Cursar descubrís en segundos si podés avanzar en tu carrera. '
            'Un par de clics y sabrás exactamente qué camino seguir para llegar a tu meta académica.',
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
              onPressed: () => ref.read(routerIndexProvider.notifier).state = 1,
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side:
                    BorderSide(color: EstilosCalculadora.bordeTarjeta(context)),
                foregroundColor: EstilosCalculadora.textoPrincipal(context),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: const Text('Volver al Mapa'),
            ),
          ),
        ],
      ),
    );
  }
}
