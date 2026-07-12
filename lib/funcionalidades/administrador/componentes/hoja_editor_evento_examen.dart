import 'package:flutter/material.dart';

import '../modelos/evento_examen_administrador.dart';
import 'editor_evento_examen.dart';

Future<BorradorEventoExamenAdministrador?> mostrarHojaEditorEventoExamen({
  required BuildContext context,
  required String title,
  required bool coloquioMode,
  EventoExamenAdministrador? initialEvent,
}) {
  return showModalBottomSheet<BorradorEventoExamenAdministrador>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ContenedorHojaMobile(
      title: title,
      coloquioMode: coloquioMode,
      initialEvent: initialEvent,
    ),
  );
}

class _ContenedorHojaMobile extends StatelessWidget {
  const _ContenedorHojaMobile({
    required this.title,
    required this.coloquioMode,
    this.initialEvent,
  });

  final String title;
  final bool coloquioMode;
  final EventoExamenAdministrador? initialEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.18),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
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
