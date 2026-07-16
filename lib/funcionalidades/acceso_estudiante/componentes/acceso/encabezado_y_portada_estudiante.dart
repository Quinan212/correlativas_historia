part of '../../pantallas/acceso_estudiante_pantalla.dart';

class _InstitutionLogoMark extends StatelessWidget {
  const _InstitutionLogoMark({
    required this.loggedIn,
    required this.assetPath,
    this.size = 56,
  });

  final bool loggedIn;
  final String? assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
      ),
      child: assetPath == null
          ? Icon(
              loggedIn ? Icons.school_rounded : Icons.lock_open_rounded,
              color: scheme.primary,
            )
          : Image.asset(
              assetPath!,
              fit: BoxFit.cover,
              cacheWidth: 96,
              cacheHeight: 96,
              errorBuilder: (_, _, _) =>
                  Icon(Icons.school_rounded, color: scheme.primary),
            ),
    );
  }
}

class _BannerPortada extends StatelessWidget {
  const _BannerPortada({
    required this.loggedIn,
    required this.student,
    required this.movementCount,
    required this.onRefresh,
    required this.onOpenSubjects,
    required this.onOpenHistory,
    required this.onOpenExams,
    required this.onShowStudentData,
    required this.onOpenAccountSheet,
    required this.gradientTopExtension,
  });

  final bool loggedIn;
  final PerfilAccesoEstudiante? student;
  final int movementCount;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOpenSubjects;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onOpenExams;
  final VoidCallback? onShowStudentData;
  final VoidCallback? onOpenAccountSheet;
  final double gradientTopExtension;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentStudent = student;
    final hasLoadedStudent = loggedIn && currentStudent != null;
    const headerBlue = Color(0xFF0E5E86);

    final backgroundDecoration = BoxDecoration(
      color: hasLoadedStudent ? null : headerBlue,
      gradient: hasLoadedStudent
          ? LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                headerBlue,
                headerBlue,
                headerBlue,
                headerBlue.withValues(alpha: 0.82),
                const Color(0xFFEAF1F7),
                const Color(0xFFF6F8FC),
              ],
              stops: const [0, 0.40, 0.52, 0.70, 0.88, 1],
            )
          : null,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -gradientTopExtension,
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(decoration: backgroundDecoration),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, hasLoadedStudent ? 16 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loggedIn && currentStudent != null) ...[
                InkWell(
                  onTap: onOpenAccountSheet,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.primary.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Estudiante',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentStudent.fullName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.04,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'DNI ${currentStudent.dni} · ${_etiquetaCarrera(currentStudent.careerId)} · ${currentStudent.yearLabel}'
                          '${currentStudent.cohortYear == null ? '' : ' · Cohorte ${currentStudent.cohortYear}'}'
                          '${currentStudent.division == null ? '' : ' · División ${currentStudent.division}'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _AccionesRapidasTablero(
                          onOpenSubjects: onOpenSubjects,
                          onOpenHistory: onOpenHistory,
                          onOpenExams: onOpenExams,
                          onShowStudentData: onShowStudentData,
                          movementCount: movementCount,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EncabezadoEstudianteFijo extends StatefulWidget {
  const _EncabezadoEstudianteFijo({
    required this.loggedIn,
    required this.student,
    required this.scrollController,
    required this.movementCount,
    required this.onOpenHistory,
    required this.onRefresh,
    required this.onOpenAccountSheet,
    required this.onOpenSearch,
  });

  final bool loggedIn;
  final PerfilAccesoEstudiante? student;
  final ScrollController scrollController;
  final int movementCount;
  final VoidCallback? onOpenHistory;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOpenAccountSheet;
  final VoidCallback? onOpenSearch;

  @override
  State<_EncabezadoEstudianteFijo> createState() =>
      _EncabezadoEstudianteFijoState();
}

class _EncabezadoEstudianteFijoState extends State<_EncabezadoEstudianteFijo> {
  bool _compact = false;
  double _searchProgress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final offset = widget.scrollController.hasClients
        ? widget.scrollController.offset
        : 0.0;

    final compact = offset > 180;

    final searchProgress = (offset / 60).clamp(0.0, 1.0);

    if ((compact != _compact ||
            (searchProgress - _searchProgress).abs() > 0.01) &&
        mounted) {
      setState(() {
        _compact = compact;
        _searchProgress = searchProgress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStudent = widget.student;
    final firstName = currentStudent?.firstName.trim() ?? '';
    final greetingName = firstName.isEmpty
        ? 'alumno'
        : firstName.split(RegExp(r'\s+')).first;
    final headerTitle = widget.loggedIn
        ? 'Hola, $greetingName'
        : 'Acceso estudiantil';
    final compact = _compact;
    final titleWidth = compact ? 64.0 : 104.0;
    final searchProgress = _searchProgress;
    final hasSearch = widget.loggedIn && widget.onOpenSearch != null;
    final titleOpacity = widget.loggedIn
        ? (1 - searchProgress * 1.25).clamp(0.0, 1.0)
        : 1.0;
    final titleOffset = widget.loggedIn ? -52 * searchProgress : 0.0;
    final actionsOpacity = (1 - searchProgress * 1.15).clamp(0.0, 1.0);
    final topInset = MediaQuery.paddingOf(context).top;
    const headerBlue = Color(0xFF0E5E86);
    final headerRadius = 24 * searchProgress;

    final TextStyle? titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: Colors.white,
      fontSize: 17,
    );

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.fromLTRB(10, topInset + 6, 10, 14),
        decoration: BoxDecoration(
          color: headerBlue,
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(headerRadius),
          ),
        ),
        child: SizedBox(
          height: 42,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: widget.onOpenAccountSheet,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Transform.translate(
                        offset: Offset(titleOffset, 0),
                        child: Opacity(
                          opacity: titleOpacity,
                          child: Row(
                            children: [
                              _InstitutionLogoMark(
                                loggedIn: widget.loggedIn,
                                assetPath: currentStudent == null
                                    ? null
                                    : _institutionLogoAssetFor(
                                        currentStudent.careerId,
                                      ),
                                size: 36,
                              ),
                              const SizedBox(width: 10),
                              if (!widget.loggedIn)
                                SizedBox(
                                  width: 180,
                                  child: Text(
                                    headerTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: titleStyle,
                                  ),
                                )
                              else
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  width: titleWidth,
                                  height: 24,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 140,
                                        ),
                                        curve: Curves.easeOut,
                                        opacity: compact ? 0 : 1,
                                        child: AnimatedSlide(
                                          duration: const Duration(
                                            milliseconds: 140,
                                          ),
                                          curve: Curves.easeOut,
                                          offset: compact
                                              ? const Offset(-0.06, 0)
                                              : Offset.zero,
                                          child: Text(
                                            headerTitle,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: titleStyle,
                                          ),
                                        ),
                                      ),
                                      AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 140,
                                        ),
                                        curve: Curves.easeOut,
                                        opacity: compact ? 1 : 0,
                                        child: AnimatedSlide(
                                          duration: const Duration(
                                            milliseconds: 140,
                                          ),
                                          curve: Curves.easeOut,
                                          offset: compact
                                              ? Offset.zero
                                              : const Offset(0.06, 0),
                                          child: Text(
                                            greetingName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: titleStyle,
                                          ),
                                        ),
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
                  ),
                  if (hasSearch)
                    Opacity(
                      opacity: 1 - searchProgress,
                      child: _BotonIconoPortada(
                        icon: Icons.search_rounded,
                        tooltip: 'Buscar materias y carreras',
                        onTap: widget.onOpenSearch,
                        compact: true,
                      ),
                    ),
                  if (hasSearch) const SizedBox(width: 2),
                  if (widget.loggedIn || widget.onRefresh != null)
                    Opacity(
                      opacity: actionsOpacity,
                      child: Transform.translate(
                        offset: Offset(72 * searchProgress, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.loggedIn)
                              _BotonIconoPortada(
                                icon: Icons.notifications_none_rounded,
                                badge: widget.movementCount,
                                tooltip: 'Movimientos',
                                onTap: widget.onOpenHistory,
                                compact: true,
                              ),
                            if (widget.loggedIn) const SizedBox(width: 2),
                            if (widget.onRefresh != null)
                              _BotonIconoPortada(
                                icon: Icons.refresh_rounded,
                                tooltip: 'Actualizar',
                                onTap: widget.onRefresh,
                                compact: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (hasSearch)
                Positioned(
                  left: 0,
                  right: 78 * (1 - searchProgress),
                  top: 0,
                  bottom: 0,
                  child: _BarraBusquedaPortada(
                    progress: searchProgress,
                    tooltip: 'Buscar materias y carreras',
                    onTap: widget.onOpenSearch,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonIconoPortada extends StatelessWidget {
  const _BotonIconoPortada({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
    this.compact = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final int badge;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 34.0 : 42.0;
    final radius = compact ? 10.0 : 12.0;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: Colors.white, size: compact ? 19 : 24),
            ),
            if (badge > 0)
              Positioned(
                right: -2,
                top: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.error,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge > 99 ? '99+' : '$badge',
                    style: themeTextSmall(context).copyWith(
                      color: scheme.onError,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BarraBusquedaPortada extends StatelessWidget {
  const _BarraBusquedaPortada({
    required this.progress,
    required this.tooltip,
    required this.onTap,
  });

  final double progress;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const searchBorder = Color(0xFFEAF1F7);
    final normalizedProgress = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final width = 42 + (maxWidth - 42) * normalizedProgress;
        final background = Color.lerp(
          Colors.white.withValues(alpha: 0.10),
          Colors.white,
          normalizedProgress,
        );
        final border = Color.lerp(
          Colors.white.withValues(alpha: 0.28),
          searchBorder,
          normalizedProgress,
        );
        final labelOpacity = ((normalizedProgress - 0.18) / 0.82).clamp(
          0.0,
          1.0,
        );
        final contentWidth = (width - 2).clamp(0.0, double.infinity).toDouble();
        final iconWidth = contentWidth.clamp(0.0, 42.0).toDouble();
        final showLabel = normalizedProgress > 0.18 && contentWidth > 58;

        return Align(
          child: Tooltip(
            message: tooltip,
            child: Opacity(
              opacity: normalizedProgress,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: width,
                    height: 42,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: border!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.10 * normalizedProgress,
                          ),
                          blurRadius: 12 * normalizedProgress,
                          offset: Offset(0, 4 * normalizedProgress),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: iconWidth,
                          child: Icon(
                            Icons.search_rounded,
                            color: scheme.primary,
                            size: 20,
                          ),
                        ),
                        if (showLabel)
                          Expanded(
                            child: Opacity(
                              opacity: labelOpacity,
                              child: Text(
                                'Buscar materias y carreras...',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        if (showLabel) const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

TextStyle themeTextSmall(BuildContext context) {
  return Theme.of(context).textTheme.labelSmall ??
      const TextStyle(fontSize: 11);
}

class _FondoEsquinasEncabezadoPainter extends CustomPainter {
  const _FondoEsquinasEncabezadoPainter({
    required this.scrollOffset,
    required this.gradientTopExtension,
    required this.bannerHeight,
    required this.hasLoadedStudent,
  });

  final double scrollOffset;
  final double gradientTopExtension;
  final double bannerHeight;
  final bool hasLoadedStudent;

  static const Color _headerBlue = Color(0xFF0E5E86);

  @override
  void paint(Canvas canvas, Size size) {
    final canvasRect = Offset.zero & size;

    if (!hasLoadedStudent) {
      canvas.drawRect(canvasRect, Paint()..color = _headerBlue);
      return;
    }

    final totalGradientHeight = math.max(
      gradientTopExtension + bannerHeight,
      1.0,
    );
    final bandTopInsideGradient =
        gradientTopExtension - size.height + scrollOffset;
    final shaderRect = Rect.fromLTWH(
      0,
      -bandTopInsideGradient,
      size.width,
      totalGradientHeight,
    );

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _headerBlue,
        _headerBlue,
        _headerBlue,
        _headerBlue.withValues(alpha: 0.82),
        const Color(0xFFEAF1F7),
        const Color(0xFFF6F8FC),
      ],
      stops: const [0.0, 0.40, 0.52, 0.70, 0.88, 1.0],
    );

    canvas.drawRect(
      canvasRect,
      Paint()..shader = gradient.createShader(shaderRect),
    );
  }

  @override
  bool shouldRepaint(covariant _FondoEsquinasEncabezadoPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.gradientTopExtension != gradientTopExtension ||
        oldDelegate.bannerHeight != bannerHeight ||
        oldDelegate.hasLoadedStudent != hasLoadedStudent;
  }
}
