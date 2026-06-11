part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _AccionesRapidasTablero extends StatelessWidget {
  const _AccionesRapidasTablero({
    required this.onOpenSubjects,
    required this.onOpenHistory,
    required this.onOpenExams,
    required this.onShowStudentData,
    required this.movementCount,
  });

  final VoidCallback? onOpenSubjects;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenExams;
  final VoidCallback? onShowStudentData;
  final int movementCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.grid_view_rounded,
            label: 'Materias',
            onTap: onOpenSubjects,
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.history_rounded,
            label: 'Historial',
            onTap: onOpenHistory,
            badge: movementCount,
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.event_note_rounded,
            label: 'Mesas',
            onTap: onOpenExams,
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.badge_rounded,
            label: 'Tus datos',
            onTap: onShowStudentData,
          ),
        ),
      ],
    );
  }
}

class _AccionCircularRapida extends StatelessWidget {
  const _AccionCircularRapida({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
    this.circleColor,
    this.circleBorderColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final int badge;
  final Color? circleColor;
  final Color? circleBorderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circleColor ?? scheme.primary.withValues(alpha: 0.10),
                  border: Border.all(
                    color: circleBorderColor ??
                        scheme.primary.withValues(alpha: 0.08),
                  ),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaIngreso extends StatelessWidget {
  const _TarjetaIngreso({
    required this.loading,
    required this.error,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.onLogin,
    required this.onGuestLogin,
  });

  final bool loading;
  final String? error;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final Future<void> Function() onLogin;
  final VoidCallback onGuestLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _TarjetaVidrio(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acceso al perfil',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Usá DNI o correo técnico y contraseña para entrar al perfil del alumno.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 420;
              final dniField = TextField(
                controller: emailCtrl,
                enabled: !loading,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'DNI o correo',
                  prefixIcon: Icon(Icons.badge_rounded),
                ),
              );
              final passwordField = TextField(
                controller: passwordCtrl,
                enabled: !loading,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_rounded),
                ),
              );

              if (compact) {
                return Column(
                  children: [
                    dniField,
                    const SizedBox(height: 12),
                    passwordField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: dniField),
                  const SizedBox(width: 12),
                  Expanded(child: passwordField),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: loading ? null : onLogin,
              icon: const Icon(Icons.login_rounded),
              label: Text(loading ? 'Ingresando...' : 'Entrar'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: loading ? null : onGuestLogin,
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('Ingresar como Invitado'),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FranjaResumen extends StatelessWidget {
  const _FranjaResumen({
    required this.payload,
    required this.plan,
    required this.entries,
  });

  final DatosAccesoEstudiante payload;
  final List<Materia> plan;
  final List<_CurriculumEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totalPlan = plan.length;
    final approved = entries
        .where(
          (e) =>
              e.current != null &&
              e.current!.status.toLowerCase().trim() == 'aprobada',
        )
        .length;
    final inProgress = entries
        .where(
          (e) => e.current != null && _isSubjectInProgress(e.current!),
        )
        .length;
    final available =
        entries.where((e) => e.current == null && e.available).length;
    final progress = totalPlan == 0 ? 0.0 : approved / totalPlan;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final thirdWidth = (constraints.maxWidth - (spacing * 2)) / 3;
        final tileHeight = thirdWidth * 0.84;
        final largeWidth = (thirdWidth * 2) + spacing;

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: largeWidth,
                  height: tileHeight,
                  child: _TarjetaProgresoGrande(
                    progress: progress,
                    approved: approved,
                    totalPlan: totalPlan,
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(
                  child: SizedBox(
                    height: tileHeight,
                    child: TarjetaMetrica(
                      icon: Icons.check_circle_rounded,
                      label: 'Aprobadas',
                      value: '$approved',
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: TarjetaMetrica(
                    icon: Icons.lock_open_rounded,
                    label: 'Habilitadas',
                    value: '$available',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: TarjetaMetrica(
                    icon: Icons.play_circle_rounded,
                    label: 'Cursando',
                    value: '$inProgress',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
                const SizedBox(width: spacing),
                SizedBox(
                  width: thirdWidth,
                  height: tileHeight,
                  child: TarjetaMetrica(
                    icon: Icons.menu_book_rounded,
                    label: 'Plan total',
                    value: '$totalPlan',
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _TarjetaProgresoGrande extends StatelessWidget {
  const _TarjetaProgresoGrande({
    required this.progress,
    required this.approved,
    required this.totalPlan,
  });

  final double progress;
  final int approved;
  final int totalPlan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _TarjetaVidrio(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.10),
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progreso general',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$approved de $totalPlan materias ya están acreditadas en tu recorrido.',
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamShortcutBanner extends StatelessWidget {
  const _ExamShortcutBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer.withValues(alpha: 0.46),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: scheme.secondary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.secondary.withValues(alpha: 0.16),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: scheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mesas y fechas publicadas',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccionesSecundariasAccesoEstudiante extends StatelessWidget {
  const _AccionesSecundariasAccesoEstudiante({
    required this.onOpenInicio,
    required this.onOpenPlan,
    required this.onOpenEscenarios,
    required this.onOpenAyuda,
  });

  final VoidCallback onOpenInicio;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenEscenarios;
  final VoidCallback onOpenAyuda;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.home_rounded,
            label: 'Inicio',
            onTap: onOpenInicio,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.account_tree_rounded,
            label: 'Plan completo',
            onTap: onOpenPlan,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.auto_graph_rounded,
            label: 'Escenarios',
            onTap: onOpenEscenarios,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.help_rounded,
            label: 'Ayuda',
            onTap: onOpenAyuda,
            circleColor: Colors.white,
            circleBorderColor: Theme.of(context).colorScheme.outline.withValues(
                  alpha: 0.12,
                ),
          ),
        ),
      ],
    );
  }
}

class _AccionesAnaliticasAccesoEstudiante extends StatelessWidget {
  const _AccionesAnaliticasAccesoEstudiante({
    required this.onOpenNextSteps,
    required this.onOpenProgress,
    required this.onOpenAcademicCalendar,
    required this.onOpenSelfSubjects,
  });

  final VoidCallback onOpenNextSteps;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenAcademicCalendar;
  final VoidCallback onOpenSelfSubjects;

  @override
  Widget build(BuildContext context) {
    final outline =
        Theme.of(context).colorScheme.outline.withValues(alpha: 0.12);

    return Row(
      children: [
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.flag_outlined,
            label: 'Pr\u00f3ximos pasos',
            onTap: onOpenNextSteps,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.insights_outlined,
            label: 'Mi avance',
            onTap: onOpenProgress,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.calendar_month_outlined,
            label: 'Calendario',
            onTap: onOpenAcademicCalendar,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
        Expanded(
          child: _AccionCircularRapida(
            icon: Icons.edit_note_rounded,
            label: 'Mi registro',
            onTap: onOpenSelfSubjects,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ),
      ],
    );
  }
}
