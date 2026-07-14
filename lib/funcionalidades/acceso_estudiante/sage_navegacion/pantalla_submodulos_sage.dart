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
        backgroundColor: const Color(0xFF0E5E86),
        foregroundColor: Colors.white,
        title: const Text('Legajo Único Alumno'),
        leading: IconButton(
          tooltip: 'Volver al acceso estudiantil',
          onPressed: busy ? null : onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              'Seleccioná una opción para continuar en SAGE.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ...List.generate(opcionesSubmodulosSage.length, (i) {
              final option = opcionesSubmodulosSage[i];
              final isLast = i == opcionesSubmodulosSage.length - 1;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: busy ? null : () => onSelect(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _iconoPara(option),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option.titulo,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                ],
              );
            }),
            if (loadingTitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(width: 12),
                    Flexible(child: Text('Abriendo $loadingTitle…')),
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
