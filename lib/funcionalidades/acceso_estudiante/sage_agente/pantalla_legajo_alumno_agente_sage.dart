import 'package:flutter/material.dart';

import '../sage_navegacion/lista_opciones_sage.dart';
import 'modelos_agente_sage.dart';

class PantallaLegajoAlumnoAgenteSage extends StatelessWidget {
  const PantallaLegajoAlumnoAgenteSage({
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

  bool _isImplemented(OpcionAgenteSage option) =>
      option.claveCanonica == 'legajo_alumnos';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: const Color(0xFF0E5E86),
      foregroundColor: Colors.white,
      title: const Text('Legajo Único Alumno'),
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
        emptyMessage:
            'No se encontraron opciones de Legajo Único Alumno en SAGE.',
        opciones: [
          for (final option in opciones)
            ItemListaOpcionSage(
              titulo: option.etiqueta,
              subtitulo: option.sigla,
              icono: IconData(option.icono, fontFamily: 'MaterialIcons'),
              enabled: !busy,
              available: _isImplemented(option),
              highlighted: _isImplemented(option),
              onTap: () => onSelect(option),
            ),
        ],
      ),
    ),
  );
}
