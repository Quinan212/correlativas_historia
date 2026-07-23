import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';

import '../sage_navegacion/lista_opciones_sage.dart';
import 'modelos_agente_sage.dart';

class PantallaLegajoPersonalSage extends StatelessWidget {
  const PantallaLegajoPersonalSage({
    super.key,
    required this.opciones,
    required this.onSelect,
    required this.onBack,
    this.busy = false,
  });

  final List<OpcionAgenteSage> opciones;
  final ValueChanged<OpcionAgenteSage> onSelect;
  final VoidCallback onBack;
  final bool busy;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: construirAppBarSage(
      context,
      title: 'Legajo Único Personal',
      leading: IconButton(
        tooltip: 'Volver',
        onPressed: busy ? null : onBack,
        icon: const Icon(Icons.arrow_back_rounded),
      ),
    ),
    body: SafeArea(
      child: ListaOpcionesSage(
        titulo: 'Legajo Único Personal',
        descripcion: 'Seleccioná una opción para continuar.',
        emptyMessage: 'No se encontraron opciones disponibles.',
        opciones: [
          for (final option in opciones)
            ItemListaOpcionSage(
              titulo: option.etiqueta,
              subtitulo: option.sigla,
              icono: iconoMaterialSage(option.icono),
              enabled: !busy,
              available: false,
              onTap: () => onSelect(option),
            ),
        ],
      ),
    ),
  );
}
