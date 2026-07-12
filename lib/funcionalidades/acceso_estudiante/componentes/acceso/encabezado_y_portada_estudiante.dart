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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentStudent = student;
    final hasLoadedStudent = loggedIn && currentStudent != null;
    const headerBlue = Color(0xFF0E5E86);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
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
                stops: const [0, 0.34, 0.42, 0.62, 0.84, 1],
              )
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          hasLoadedStudent ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (loggedIn && currentStudent != null) ...[
              const SizedBox(height: 8),
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
              const SizedBox(height: 12),
              Text(
                'Entrá con DNI o correo técnico para ver tu recorrido académico.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ],
          ],
        ),
      ),
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
  });

  final bool loggedIn;
  final PerfilAccesoEstudiante? student;
  final ScrollController scrollController;
  final int movementCount;
  final VoidCallback? onOpenHistory;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onOpenAccountSheet;

  @override
  State<_EncabezadoEstudianteFijo> createState() =>
      _EncabezadoEstudianteFijoState();
}

class _EncabezadoEstudianteFijoState extends State<_EncabezadoEstudianteFijo> {
  bool _compact = false;

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
    final compact = widget.scrollController.hasClients &&
        widget.scrollController.offset > 180;
    if (compact != _compact && mounted) {
      setState(() => _compact = compact);
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
    final compact = _compact;

    final TextStyle? titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
      color: Colors.white,
      fontSize: 17,
    );

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          14,
          MediaQuery.of(context).padding.top + 6,
          14,
          8,
        ),
        decoration: const BoxDecoration(color: Color(0xFF0E5E86)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onOpenAccountSheet,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    _InstitutionLogoMark(
                      loggedIn: widget.loggedIn,
                      assetPath: currentStudent == null
                          ? null
                          : _institutionLogoAssetFor(currentStudent.careerId),
                      size: 38,
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 170,
                      height: 24,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOut,
                            opacity: compact ? 0 : 1,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 140),
                              curve: Curves.easeOut,
                              offset: compact
                                  ? const Offset(-0.06, 0)
                                  : Offset.zero,
                              child: Text(
                                'Hola, $greetingName',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: titleStyle,
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 140),
                            curve: Curves.easeOut,
                            opacity: compact ? 1 : 0,
                            child: AnimatedSlide(
                              duration: const Duration(milliseconds: 140),
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
            const Spacer(),
            const SizedBox(width: 8),
            if (widget.loggedIn)
              _BotonIconoPortada(
                icon: Icons.notifications_none_rounded,
                badge: widget.movementCount,
                tooltip: 'Movimientos',
                onTap: widget.onOpenHistory,
                compact: true,
              ),
            if (widget.loggedIn) const SizedBox(width: 6),
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
    final size = compact ? 38.0 : 42.0;
    final radius = compact ? 11.0 : 12.0;

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
              child: Icon(icon, color: Colors.white, size: compact ? 20 : 24),
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

TextStyle themeTextSmall(BuildContext context) {
  return Theme.of(context).textTheme.labelSmall ??
      const TextStyle(fontSize: 11);
}
