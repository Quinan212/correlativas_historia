import 'package:flutter/material.dart';

import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../modelos/evento_examen_administrador.dart';
import 'editor_evento_examen.dart';

Future<BorradorEventoExamenAdministrador?> mostrarHojaEditorEventoExamen({
  required BuildContext context,
  required String title,
  required bool coloquioMode,
  EventoExamenAdministrador? initialEvent,
}) {
  return mostrarHojaAtlassian<BorradorEventoExamenAdministrador>(
    context: context,
    builder: (sheetContext) => _ContenidoEditorEventoExamen(
      title: title,
      coloquioMode: coloquioMode,
      initialEvent: initialEvent,
    ),
  );
}

class _ContenidoEditorEventoExamen extends StatelessWidget {
  const _ContenidoEditorEventoExamen({
    required this.title,
    required this.coloquioMode,
    this.initialEvent,
  });

  final String title;
  final bool coloquioMode;
  final EventoExamenAdministrador? initialEvent;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + bottomInset),
          child: EditorEventoExamenAdministrador(
            title: title,
            coloquioMode: coloquioMode,
            initialEvent: initialEvent,
            onCancel: () => Navigator.of(context).pop(),
            onSave: (draft) => Navigator.of(context).pop(draft),
          ),
        ),
      ),
    );
  }
}
