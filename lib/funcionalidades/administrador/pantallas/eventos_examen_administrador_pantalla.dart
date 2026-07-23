import 'package:flutter/material.dart';

import '../componentes/eventos_examen_administrador_escritorio.dart';
import '../componentes/seccion_eventos_examen_administrador.dart';

class EventosExamenAdministradorPantalla extends StatelessWidget {
  const EventosExamenAdministradorPantalla({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return Scaffold(
            appBar: AppBar(title: const Text('Gestión de mesas y coloquios')),
            body: EventosExamenAdministradorEscritorio(
              adminDeviceId: adminDeviceId,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Mesas y coloquios')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                SeccionEventosExamenAdministrador(adminDeviceId: adminDeviceId),
              ],
            ),
          ),
        );
      },
    );
  }
}
