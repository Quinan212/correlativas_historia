import 'package:flutter/material.dart';

import '../componentes/seccion_eventos_examen_administrador.dart';
import '../tema/tema_administrador_atlassian.dart';

class EventosExamenAdministradorPantalla extends StatelessWidget {
  const EventosExamenAdministradorPantalla({
    super.key,
    required this.adminDeviceId,
  });

  final String adminDeviceId;

  @override
  Widget build(BuildContext context) {
    return TemaAdministradorAtlassian(
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: SeccionEventosExamenAdministrador(
            adminDeviceId: adminDeviceId,
          ),
        ),
      ),
    );
  }
}
