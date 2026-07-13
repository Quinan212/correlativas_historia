import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final busy = loadingTitle != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAGE'),
        leading: IconButton(
          tooltip: 'Volver al acceso estudiantil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          children: [
            Text(
              'Legajo Único Alumno',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Seleccioná una opción para continuar en SAGE.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 18),
            for (final option in opcionesSubmodulosSage)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    enabled: !busy,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: Icon(_iconoPara(option)),
                    title: Text(option.titulo),
                    subtitle: const Text('Se abrirá en SAGE'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: busy ? null : () => onSelect(option),
                  ),
                ),
              ),
            if (loadingTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Abriendo $loadingTitle…')),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconoPara(OpcionSubmoduloSage option) {
    switch (option.titulo) {
      case 'Legajo Alumnos':
        return Icons.badge_outlined;
      case 'Certificado de Alumno Regular. N. Superior':
        return Icons.description_outlined;
      case 'Inscripción a una nueva materia (Nivel Superior)':
        return Icons.library_add_outlined;
      case 'Mis Inscripciones Anuales':
        return Icons.fact_check_outlined;
      case 'Inscripción anual obligatoria (Nivel Superior)':
        return Icons.event_available_outlined;
      case 'Consulta para Tutor/Alumnos':
        return Icons.supervisor_account_outlined;
      default:
        return Icons.chevron_right_rounded;
    }
  }
}
