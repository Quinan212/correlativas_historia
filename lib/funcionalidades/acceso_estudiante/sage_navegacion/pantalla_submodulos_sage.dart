import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';

import 'lista_opciones_sage.dart';
import 'modelos_navegacion_sage.dart';

class PantallaSubmodulosSage extends StatelessWidget {
  const PantallaSubmodulosSage({
    super.key,
    required this.onSelect,
    required this.onBack,
    this.loadingTitle,
  });

  final ValueChanged<OpcionSubmoduloSage> onSelect;
  final VoidCallback onBack;
  final String? loadingTitle;

  @override
  Widget build(BuildContext context) {
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: construirAppBarSage(
        context,
        title: 'Legajo Único Alumno',
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListaOpcionesSage(
          titulo: '',
          descripcion: 'Seleccioná una opción para continuar.',
          opciones: [
            for (final option in opcionesSubmodulosSage)
              ItemListaOpcionSage(
                titulo: option.titulo,
                icono: IconData(option.icono, fontFamily: 'MaterialIcons'),
                enabled: !busy,
                available: option.titulo == 'Legajo Alumnos',
                highlighted: option.titulo == 'Legajo Alumnos',
                onTap: () => onSelect(option),
              ),
          ],
        ),
      ),
    );
  }
}
