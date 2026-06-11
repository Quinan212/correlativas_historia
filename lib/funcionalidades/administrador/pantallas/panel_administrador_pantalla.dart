import 'package:flutter/material.dart';

import 'acceso_administrador_pantalla.dart';

class PanelAdministradorPantalla extends StatelessWidget {
  const PanelAdministradorPantalla({
    super.key,
    required this.deviceId,
    this.adminLabel,
  });

  final String deviceId;
  final String? adminLabel;

  @override
  Widget build(BuildContext context) {
    return const AccesoAdministradorPantalla();
  }
}
