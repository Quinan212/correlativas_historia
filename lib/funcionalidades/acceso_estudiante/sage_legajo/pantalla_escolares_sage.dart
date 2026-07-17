import 'package:flutter/material.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';

import '../sage_navegacion/lista_opciones_sage.dart';
import 'modelos_legajo_sage.dart';

class PantallaEscolaresSage extends StatelessWidget {
  const PantallaEscolaresSage({
    super.key,
    required this.opciones,
    required this.onSelect,
    required this.onBack,
    this.loadingTitle,
  });

  final List<OpcionEscolarSage> opciones;
  final ValueChanged<OpcionEscolarSage> onSelect;
  final VoidCallback onBack;
  final String? loadingTitle;

  bool _isImplemented(OpcionEscolarSage option) =>
      option.clave == 'nivel_superior_historial' ||
      normalizarLegajoSage(option.titulo) == 'nivel superior - historial';

  @override
  Widget build(BuildContext context) {
    final busy = loadingTitle != null;
    final unique = <String, OpcionEscolarSage>{
      for (final option in opciones)
        if (option.clave.isNotEmpty) option.clave: option,
    };
    unique.putIfAbsent(
      'nivel_superior_historial',
      () => const OpcionEscolarSage(
        clave: 'nivel_superior_historial',
        titulo: 'Nivel Superior - Historial',
        firmaTecnica: 'contract:nivel_superior_historial',
        frameId: 'frm_alumnos',
        pathname: '/dic/tabs.php',
        controlEncontrado: false,
      ),
    );
    final orderedOptions = [
      unique.remove('nivel_superior_historial')!,
      ...unique.values,
    ];

    return Scaffold(
      appBar: construirAppBarSage(
        context,
        title: 'Escolares',
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListaOpcionesSage(
          titulo: 'Información académica',
          descripcion: 'Seleccioná una opción para continuar.',
          opciones: [
            for (final option in orderedOptions)
              ItemListaOpcionSage(
                titulo: option.titulo,
                icono: _isImplemented(option)
                    ? Icons.history_edu_outlined
                    : Icons.school_outlined,
                enabled: !busy,
                available: _isImplemented(option),
                highlighted: _isImplemented(option),
                subtitulo: _isImplemented(option)
                    ? 'Carreras, materias, estados y documentos académicos'
                    : null,
                onTap: () => onSelect(option),
              ),
          ],
        ),
      ),
    );
  }
}
