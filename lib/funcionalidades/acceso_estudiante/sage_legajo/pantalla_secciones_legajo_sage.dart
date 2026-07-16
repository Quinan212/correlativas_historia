import 'package:flutter/material.dart';

import '../sage_navegacion/lista_opciones_sage.dart';
import 'modelos_legajo_sage.dart';

class PantallaSeccionesLegajoSage extends StatelessWidget {
  const PantallaSeccionesLegajoSage({
    super.key,
    required this.secciones,
    required this.onSelect,
    required this.onBack,
    this.loadingTitle,
  });

  final List<SeccionLegajoSage> secciones;
  final ValueChanged<SeccionLegajoSage> onSelect;
  final VoidCallback onBack;
  final String? loadingTitle;

  bool _isImplemented(SeccionLegajoSage section) =>
      section.clave == 'escolares' ||
      normalizarLegajoSage(section.titulo) == 'escolares';

  @override
  Widget build(BuildContext context) {
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Mi legajo'),
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListaOpcionesSage(
          titulo: 'Secciones',
          descripcion: 'Seleccioná una sección para continuar.',
          opciones: [
            for (final section in secciones)
              ItemListaOpcionSage(
                titulo: section.titulo,
                icono: _isImplemented(section)
                    ? Icons.school_outlined
                    : Icons.folder_outlined,
                enabled: !busy,
                available: _isImplemented(section),
                highlighted: _isImplemented(section),
                onTap: () => onSelect(section),
              ),
          ],
        ),
      ),
    );
  }
}
