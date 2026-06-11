import 'package:flutter/material.dart';

import '../../funcionalidades/administrador/pantallas/acceso_administrador_pantalla.dart';
import 'ruta_suave.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void abrirPantallaVerificacion() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) return;

    navigator.push(
      rutaSuave<void>(const AccesoAdministradorPantalla()),
    );
  });
}
