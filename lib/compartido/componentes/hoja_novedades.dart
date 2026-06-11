import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String currentWhatsNewVersion = '1.3.928-r2';

class HojaNovedades {
  HojaNovedades._();

  static const String _prefsKey = 'whats_new.last_seen_version';

  static Future<void> maybeShow(BuildContext context) async {
    // TEMPORALMENTE DESACTIVADO — reactivar cuando se actualice el contenido
    return;
    // ignore: dead_code
    final prefs = await SharedPreferences.getInstance();
    final lastSeen = prefs.getString(_prefsKey)?.trim();
    if (lastSeen == currentWhatsNewVersion) return;
    if (!context.mounted) return;

    await show(context, markAsSeen: true);
  }

  static Future<void> show(
    BuildContext context, {
    bool markAsSeen = false,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HojaNovedadesBody(),
    );

    if (!markAsSeen) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, currentWhatsNewVersion);
  }
}

class _HojaNovedadesBody extends StatelessWidget {
  const _HojaNovedadesBody();

  @override
  Widget build(BuildContext context) {
    return const SizedBox
        .shrink(); // RADICAL: no mostrar nada hasta nuevo aviso
    // ignore: dead_code
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final media = MediaQuery.of(context);
    final maxSheetHeight = media.size.height * 0.82;

    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxHeight: maxSheetHeight, maxWidth: 980),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1220) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF243041)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isDark
                    ? const []
                    : [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                          color: Colors.black.withOpacity(0.10),
                        ),
                      ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.18)
                              : Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Novedades y orientaciones prácticas',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Compartimos cambios pensados para apoyar la práctica docente y estudiantil: mejoras funcionales concretas, ajustes de usabilidad y recursos situados para usar en las cursadas.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    const _ItemNovedades(
                      icon: Icons.forum_rounded,
                      title: 'Referencias por materia (situadas)',
                      body:
                          'Ahora podés dejar y leer referencias de cursada vinculadas a cada materia; las descripciones están pensadas para situar experiencias concretas, no para juzgar.',
                    ),
                    const SizedBox(height: 12),
                    const _ItemNovedades(
                      icon: Icons.groups_2_rounded,
                      title: 'Comunidad y evidencias',
                      body:
                          'Podés sumar imágenes, anotar contextos y conectar testimonios con los docentes y espacios reales de la cursada; la idea es construir un registro práctico y útil.',
                    ),
                    const SizedBox(height: 12),
                    const _ItemNovedades(
                      icon: Icons.campaign_rounded,
                      title: 'Notificaciones útiles',
                      body:
                          'Activá avisos relevantes: te notificamos cuando cambien verificaciones o llegue contenido nuevo que afecte tu experiencia de cursada.',
                    ),
                    const SizedBox(height: 12),
                    const _ItemNovedades(
                      icon: Icons.bolt_rounded,
                      title: 'Mejora de fluidez y robustez',
                      body:
                          'Ajustamos rendimiento y moderación para que el panel responda mejor en situaciones reales de uso y para reducir fricciones en el trabajo del aula.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF111827)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF243041)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Text(
                        'Volvé a esta síntesis desde la pantalla de Verificación cuando quieras; está pensada como guía práctica, no como doctrina.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Entendido — lo pruebo'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemNovedades extends StatelessWidget {
  const _ItemNovedades({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF243041) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF005B7F).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF005B7F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
