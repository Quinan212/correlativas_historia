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
                    color:
                        circleBorderColor ??
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
    this.onTapAprobadas,
    this.onTapCursando,
    this.onTapHabilitadas,
    this.onTapPlanTotal,
  });

  final DatosAccesoEstudiante payload;
  final List<Materia> plan;
  final List<_CurriculumEntry> entries;
  final VoidCallback? onTapAprobadas;
  final VoidCallback? onTapCursando;
  final VoidCallback? onTapHabilitadas;
  final VoidCallback? onTapPlanTotal;

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
        .where((e) => e.current != null && _isSubjectInProgress(e.current!))
        .length;
    final available = entries
        .where((e) => e.current == null && e.available)
        .length;
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: largeWidth,
                  child: GestureDetector(
                    onTap: onTapAprobadas,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: tileHeight),
                      child: _TarjetaProgresoGrande(
                        progress: progress,
                        approved: approved,
                        totalPlan: totalPlan,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: spacing),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: tileHeight),
                    child: GestureDetector(
                      onTap: onTapAprobadas,
                      child: TarjetaMetrica(
                        icon: Icons.check_circle_rounded,
                        label: 'Aprobadas',
                        value: '$approved',
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: tileHeight),
                  child: GestureDetector(
                    onTap: onTapHabilitadas,
                    child: SizedBox(
                      width: thirdWidth,
                      child: TarjetaMetrica(
                        icon: Icons.lock_open_rounded,
                        label: 'Habilitadas',
                        value: '$available',
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: spacing),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: tileHeight),
                  child: GestureDetector(
                    onTap: onTapCursando,
                    child: SizedBox(
                      width: thirdWidth,
                      child: TarjetaMetrica(
                        icon: Icons.play_circle_rounded,
                        label: 'Cursando',
                        value: '$inProgress',
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: spacing),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: tileHeight),
                  child: GestureDetector(
                    onTap: onTapPlanTotal,
                    child: SizedBox(
                      width: thirdWidth,
                      child: TarjetaMetrica(
                        icon: Icons.menu_book_rounded,
                        label: 'Plan total',
                        value: '$totalPlan',
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
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
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.10,
                  ),
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
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.2,
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
            border: Border.all(color: scheme.secondary.withValues(alpha: 0.14)),
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

class _GrillaAccionesEstudiante extends StatelessWidget {
  const _GrillaAccionesEstudiante({
    required this.onOpenSelfSubjects,
    required this.onOpenPlan,
    required this.onOpenEscenarios,
    required this.onOpenAyuda,
    required this.onOpenNextSteps,
    required this.onOpenProgress,
    required this.onOpenAcademicCalendar,
    required this.onOpenReimaginedTrajectory,
    required this.onOpenCurriculum,
  });

  final VoidCallback onOpenSelfSubjects;
  final VoidCallback onOpenPlan;
  final VoidCallback onOpenEscenarios;
  final VoidCallback onOpenAyuda;
  final VoidCallback onOpenNextSteps;
  final VoidCallback onOpenProgress;
  final VoidCallback onOpenAcademicCalendar;
  final VoidCallback onOpenReimaginedTrajectory;
  final VoidCallback onOpenCurriculum;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(
      context,
    ).colorScheme.outline.withValues(alpha: 0.12);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 8;
        final double itemWidth = (constraints.maxWidth - (spacing * 3)) / 4;
        final List<Widget> actions = <Widget>[
          _AccionCircularRapida(
            icon: Icons.edit_note_rounded,
            label: 'Mi registro',
            onTap: onOpenSelfSubjects,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularRapida(
            icon: Icons.account_tree_rounded,
            label: 'Plan completo',
            onTap: onOpenPlan,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularRapida(
            icon: Icons.auto_graph_rounded,
            label: 'Escenarios',
            onTap: onOpenEscenarios,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularRapida(
            icon: Icons.help_rounded,
            label: 'Ayuda',
            onTap: onOpenAyuda,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularRapida(
            icon: Icons.flag_outlined,
            label: 'Próximos pasos',
            onTap: onOpenNextSteps,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularRapida(
            icon: Icons.insights_outlined,
            label: 'Mi avance',
            onTap: onOpenProgress,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          _AccionCircularRapida(
            icon: Icons.calendar_month_outlined,
            label: 'Calendario',
            onTap: onOpenAcademicCalendar,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
          /* _AccionCircularRapida(
            icon: Icons.layers_rounded,
            label: '1',
            onTap: onOpenReimaginedTrajectory,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ), */
          _AccionCircularRapida(
            icon: Icons.menu_book_rounded,
            label: 'Diseños',
            onTap: onOpenCurriculum,
            circleColor: Colors.white,
            circleBorderColor: outline,
          ),
        ];

        return Wrap(
          spacing: spacing,
          runSpacing: 12,
          children: actions
              .map((Widget action) => SizedBox(width: itemWidth, child: action))
              .toList(growable: false),
        );
      },
    );
  }
}

// Sección promocional al final de Trayectorias con efecto "stacked cards"
// sincronizado al scroll: las tarjetas empiezan desplegadas (se ven todas)
// y al bajar se van apilando una por una. Si se sube, se desapilan.
class _PromocionalTrayectoriasHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  static const List<_CardPromocional> _items = <_CardPromocional>[
    _CardPromocional(
      assetPath: 'assets/banners/historia/recorrido/01.jpg',
      eyebrow: 'Recorrido sugerido',
      title: 'Repasá los núcleos del primer año',
      cta: 'Conocé más',
      alignment: Alignment.center,
    ),
    _CardPromocional(
      assetPath: 'assets/banners/historia/recorrido/02.jpg',
      eyebrow: 'Seguimiento',
      title: 'Volvé a tus tramos con más movimiento',
      cta: 'Ver avance',
      alignment: Alignment.center,
    ),
    _CardPromocional(
      assetPath: 'assets/banners/historia/recorrido/03.jpg',
      eyebrow: 'Proyección',
      title: 'Visualizá el trayecto que sigue',
      cta: 'Planificar',
      alignment: Alignment.center,
    ),
    _CardPromocional(
      assetPath: 'assets/banners/historia/recorrido/04.jpg',
      eyebrow: 'Tu carrera',
      title: 'Descubrí más sobre tu plan',
      cta: 'Explorar',
      alignment: Alignment.topCenter,
    ),
  ];

  _PromocionalTrayectoriasHeaderDelegate({required this.viewportHeight});

  final double viewportHeight;

  static const double _cardHeight = 340.0;
  static const double _cardGap = 28.0;
  static const double _stackedSpread = 5.0;
  static const double _horizontalPadding = 16.0;
  static const double _sectionTopPadding = 16.0;
  static const double _sectionHeaderHeight = 72.0;
  static const double _sectionHeaderGap = 24.0;
  static const double _bottomPadding = 16.0;
  static const double _pinTravel = 24.0;

  static const double _fullSpread = _cardHeight + _cardGap;

  double get _cardsStartTop =>
      _sectionTopPadding + _sectionHeaderHeight + _sectionHeaderGap;

  double get _headerTop => _sectionTopPadding;

  double get _stackScrollExtent =>
      (_items.length - 1) * (_fullSpread - _stackedSpread);

  double get _stackedHeight =>
      _cardsStartTop +
      _cardHeight +
      ((_items.length - 1) * _stackedSpread) +
      _bottomPadding;

  @override
  double get maxExtent => _stackedHeight + _pinTravel + _stackScrollExtent;

  @override
  double get minExtent => _stackedHeight;

  double _naturalTopFor(int index) => _cardsStartTop + (index * _fullSpread);

  double _stackedTopFor(int index) => _cardsStartTop + (index * _stackedSpread);

  double _topFor(int index, double scroll) {
    final double naturalTop = _naturalTopFor(index);
    final double stackedTop = _stackedTopFor(index);
    return math.max(stackedTop, naturalTop - scroll);
  }

  double _progressFor(int index, double scroll) {
    if (index >= _items.length - 1) return 0;
    final double top = _topFor(index, scroll);
    final double nextTop = _topFor(index + 1, scroll);
    final double distance = nextTop - top;
    final double progress = 1 - (distance / _cardHeight);
    return progress.clamp(0.0, 1.0);
  }

  double _depthFor(int index, double scroll) {
    if (index == _items.length - 1) return 0;
    final double naturalTop = _naturalTopFor(index);
    final double stackedTop = _stackedTopFor(index);
    final double travel = naturalTop - stackedTop;
    if (travel <= 0) return 0;
    final double currentTop = _topFor(index, scroll);
    return ((currentTop - stackedTop) / travel).clamp(0.0, 1.0);
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double scroll = math
        .max(shrinkOffset - _pinTravel, 0.0)
        .clamp(0.0, _stackScrollExtent);

    final ThemeData theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: ColoredBox(color: theme.scaffoldBackgroundColor),
        ),
        ...List<Widget>.generate(_items.length, (int index) {
          final _CardPromocional item = _items[index];
          final double top = _topFor(index, scroll);
          return Positioned(
            left: _horizontalPadding,
            right: _horizontalPadding,
            top: top,
            child: _CardPromocionalTrayectorias(
              item: item,
              collisionProgress: _progressFor(index, scroll),
              depthProgress: _depthFor(index, scroll),
              cardHeight: _cardHeight,
            ),
          );
        }),
        Positioned(
          left: _horizontalPadding,
          right: _horizontalPadding,
          top: _headerTop,
          child: const _InicioSugerenciasTrayectorias(
            height: _sectionHeaderHeight,
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(
    covariant _PromocionalTrayectoriasHeaderDelegate oldDelegate,
  ) {
    return oldDelegate.viewportHeight != viewportHeight;
  }
}

class _InicioSugerenciasTrayectorias extends StatelessWidget {
  const _InicioSugerenciasTrayectorias({this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return SizedBox(
      height: height,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Sugerencias',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardPromocionalTrayectorias extends StatelessWidget {
  const _CardPromocionalTrayectorias({
    required this.item,
    required this.collisionProgress,
    required this.depthProgress,
    required this.cardHeight,
  });

  final _CardPromocional item;
  final double collisionProgress;
  final double depthProgress;
  final double cardHeight;

  ColorFilter _brightnessFilter(double brightness) {
    return ColorFilter.matrix(<double>[
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      brightness,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    final double stackProgress = Curves.easeOutCubic.transform(
      collisionProgress.clamp(0.0, 1.0),
    );
    final double scale = 1 - (stackProgress * 0.06);
    final double brightness = 1 - (stackProgress * 0.40);
    final double translateY = stackProgress * -6.0;
    final double shadowOpacity = 0.12 + (depthProgress * 0.10);

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: ColorFiltered(
          colorFilter: _brightnessFilter(brightness),
          child: Container(
            height: cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowOpacity),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ColoredBox(color: scheme.surfaceContainerHighest),
                  Transform.scale(
                    scale: 1.08,
                    child: Image.asset(
                      item.assetPath,
                      fit: BoxFit.cover,
                      alignment: item.alignment,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const <double>[0.0, 0.35, 0.75, 1.0],
                        colors: <Color>[
                          Colors.black.withValues(alpha: 0.22),
                          Colors.black.withValues(alpha: 0.06),
                          Colors.black.withValues(alpha: 0.26),
                          Colors.black.withValues(alpha: 0.64),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                        const Spacer(),

                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Text(
                              item.cta,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardPromocional {
  const _CardPromocional({
    required this.assetPath,
    required this.eyebrow,
    required this.title,
    required this.cta,
    required this.alignment,
  });

  final String assetPath;
  final String eyebrow;
  final String title;
  final String cta;
  final Alignment alignment;
}
