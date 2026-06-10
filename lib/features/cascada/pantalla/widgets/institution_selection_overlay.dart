import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../../../../shared/providers/app_state.dart';

OverlayEntry? _activeInstitutionSelectionOverlay;
const _pscsOverlayLogoAsset = 'assets/career_icons/logo_pscs_overlay.png';
const _artesOverlayBannerAsset = 'assets/career_icons/artes_overlay_banner.mp4';
const _geografiaOverlayBannerAsset =
    'assets/career_icons/geografia_overlay_banner.mp4';
const _historiaOverlayBannerAsset =
    'assets/career_icons/historia_overlay_banner.mp4';
const _artesOverlayCompactAsset = 'assets/career_icons/logo_artes.png';
const _bannerCollapseDuration = Duration(milliseconds: 760);
const Map<String, String> _overlayBannerVideosByInstitutionId = {
  'artes_visuales_cesareo': _artesOverlayBannerAsset,
  'geografia_pscs': _geografiaOverlayBannerAsset,
  'historia_pscs': _historiaOverlayBannerAsset,
};

Future<void> showInstitutionSelectionOverlay(
  BuildContext context, {
  required InstitutionInfo institution,
}) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null || !_hasOverlayArtwork(institution)) return;

  _activeInstitutionSelectionOverlay?.remove();
  _activeInstitutionSelectionOverlay = null;

  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (overlayContext) => _InstitutionSelectionOverlay(
      institution: institution,
      onFinished: () {
        if (_activeInstitutionSelectionOverlay == entry) {
          _activeInstitutionSelectionOverlay = null;
        }
        entry?.remove();
      },
    ),
  );

  _activeInstitutionSelectionOverlay = entry;
  overlay.insert(entry);
}

bool _usesOverlayBannerFor(InstitutionInfo institution) {
  return _overlayBannerVideosByInstitutionId.containsKey(institution.id);
}

bool _isPscsInstitution(InstitutionInfo institution) {
  return institution.id.endsWith('_pscs') ||
      institution.nombre.toLowerCase().contains('ciencias sociales');
}

bool _hasOverlayArtwork(InstitutionInfo institution) {
  return _usesOverlayBannerFor(institution) ||
      _isPscsInstitution(institution) ||
      institution.iconAsset != null;
}

String _overlayArtworkAssetFor(InstitutionInfo institution) {
  final bannerVideo = _overlayBannerVideosByInstitutionId[institution.id];
  if (bannerVideo != null) {
    return bannerVideo;
  }
  if (_isPscsInstitution(institution)) {
    return _pscsOverlayLogoAsset;
  }
  return institution.iconAsset!;
}

String? _overlayCompactArtworkAssetFor(InstitutionInfo institution) {
  if (institution.id == 'artes_visuales_cesareo') {
    return _artesOverlayCompactAsset;
  }
  return null;
}

class _InstitutionSelectionOverlay extends StatefulWidget {
  const _InstitutionSelectionOverlay({
    required this.institution,
    required this.onFinished,
  });

  final InstitutionInfo institution;
  final VoidCallback onFinished;

  @override
  State<_InstitutionSelectionOverlay> createState() =>
      _InstitutionSelectionOverlayState();
}

class _InstitutionSelectionOverlayState
    extends State<_InstitutionSelectionOverlay> with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _exitController;
  late final AnimationController _pulseController;
  late final AnimationController _checkController;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _entryScale;
  late final Animation<Offset> _entryOffset;
  late final Animation<Offset> _exitOffset;
  Timer? _sequenceTimer;
  Timer? _fallbackExitTimer;
  bool _showCheck = false;
  bool _isExiting = false;
  bool _collapseBannerForCheck = false;

  bool get _usesBanner => _usesOverlayBannerFor(widget.institution);

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Retrasamos el inicio de la animación de pulso un segundo exacto.
    // Durante este intervalo ocurrirá la paralización de inicialización del
    // decodificador de video (a los 700ms). Como nada se estará moviendo
    // gráficamente en pantalla, la congelación del Thread UI será 100%
    // indetectable por el usuario.
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _pulseController.repeat(reverse: true);
    });
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _entryOpacity = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryScale = Tween<double>(
      begin: 0.84,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _entryOffset = Tween<Offset>(
      begin: const Offset(0, -0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _exitOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.2),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInBack),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await _entryController.forward();
    if (!mounted) return;

    if (_usesBanner) {
      _fallbackExitTimer = Timer(const Duration(seconds: 15), () {
        if (!_showCheck && !_collapseBannerForCheck) {
          _startBannerCheckAndExit();
        }
      });
      return;
    }

    _sequenceTimer = Timer(const Duration(milliseconds: 1180), () {
      if (!mounted) return;
      setState(() {
        _showCheck = true;
      });
      _checkController.forward(from: 0);
    });

    _sequenceTimer = Timer(const Duration(milliseconds: 2050), () {
      _startExitSequence();
    });
  }

  void _handleArtworkCompleted() {
    if (!_usesBanner || _entryController.status != AnimationStatus.completed) {
      return;
    }
    _fallbackExitTimer?.cancel();
    // Ensure there is no dead time after video completion:
    // if near-end did not trigger for any reason, start collapse now and
    // show the check immediately instead of waiting another collapse timer.
    if (!_collapseBannerForCheck) {
      _startBannerCollapseOnly();
    }
    _showCheckAndExit();
  }

  void _handleArtworkNearEnd() {
    if (!_usesBanner || _entryController.status != AnimationStatus.completed) {
      return;
    }
    _fallbackExitTimer?.cancel();
    _startBannerCollapseOnly();
  }

  void _startBannerCollapseOnly() {
    if (_isExiting || !mounted || _collapseBannerForCheck) return;
    setState(() {
      _collapseBannerForCheck = true;
    });
  }

  void _showCheckAndExit() {
    if (_isExiting || !mounted || _showCheck) return;
    setState(() {
      _showCheck = true;
    });
    _checkController.forward(from: 0);
    _sequenceTimer?.cancel();
    _sequenceTimer = Timer(const Duration(milliseconds: 700), () {
      _startExitSequence();
    });
  }

  void _startBannerCheckAndExit() {
    if (_isExiting || !mounted) return;
    _startBannerCollapseOnly();
    _sequenceTimer?.cancel();
    _sequenceTimer = Timer(_bannerCollapseDuration, () {
      if (!mounted) return;
      _showCheckAndExit();
    });
  }

  Future<void> _startExitSequence() async {
    if (_isExiting || !mounted) return;
    setState(() {
      _isExiting = true;
    });
    await _exitController.forward();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _fallbackExitTimer?.cancel();
    _entryController.dispose();
    _exitController.dispose();
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final squareSize = math.min(media.width * 0.452, 180.0);
    final useBanner = _usesOverlayBannerFor(widget.institution);
    final bannerWidth =
        useBanner ? math.min(media.width * 0.733, 359.0) : squareSize;
    final bannerHeight =
        useBanner ? math.min(bannerWidth / 1.70, 199.0) : squareSize;
    final cardWidth =
        useBanner && _collapseBannerForCheck ? squareSize : bannerWidth;
    final cardHeight =
        useBanner && _collapseBannerForCheck ? squareSize : bannerHeight;
    final topOffset = topInset + 10;

    return IgnorePointer(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _entryController,
                  _exitController,
                  _pulseController,
                ]),
                builder: (context, child) {
                  Widget current = child!;

                  if (_isExiting) {
                    current = SlideTransition(
                      position:
                          AlwaysStoppedAnimation<Offset>(_exitOffset.value),
                      child: current,
                    );
                  } else {
                    current = FadeTransition(
                      opacity: _entryOpacity,
                      child: ScaleTransition(
                        scale: _entryScale,
                        child: SlideTransition(
                          position: _entryOffset,
                          child: current,
                        ),
                      ),
                    );
                  }

                  return current;
                },
                child: RepaintBoundary(
                  child: Center(
                    child: _PremiumSelectionCard(
                      width: cardWidth,
                      height: cardHeight,
                      useBanner: useBanner,
                      useWhiteCompactSurface:
                          useBanner && (_collapseBannerForCheck || _showCheck),
                      pulse: _pulseController,
                      checkAnimation: _checkController,
                      showCheck: _showCheck,
                      institution: widget.institution,
                      onArtworkNearEnd: _handleArtworkNearEnd,
                      onArtworkCompleted: _handleArtworkCompleted,
                    ),
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

class _PremiumSelectionCard extends StatelessWidget {
  const _PremiumSelectionCard({
    required this.width,
    required this.height,
    required this.useBanner,
    required this.useWhiteCompactSurface,
    required this.pulse,
    required this.checkAnimation,
    required this.showCheck,
    required this.institution,
    this.onArtworkNearEnd,
    this.onArtworkCompleted,
  });

  final double width;
  final double height;
  final bool useBanner;
  final bool useWhiteCompactSurface;
  final Animation<double> pulse;
  final Animation<double> checkAnimation;
  final bool showCheck;
  final InstitutionInfo institution;
  final VoidCallback? onArtworkNearEnd;
  final VoidCallback? onArtworkCompleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final useDarkCompactPalette = isDark && useBanner && useWhiteCompactSurface;
    final glow = CurvedAnimation(parent: pulse, curve: Curves.easeInOut).value;
    final orbitAngle = glow * math.pi * 1.5;
    final compactCheckMode = showCheck;
    final usePscsCheckStyle = showCheck;
    final enforceWhiteCompactSurface =
        useBanner && useWhiteCompactSurface && !isDark && !usePscsCheckStyle;
    final enforceWhiteBannerSurface =
        useBanner && !isDark && !usePscsCheckStyle;
    final checkHaloColor = colorScheme.primary;
    final haloOpacity = showCheck ? 0.14 + (glow * 0.10) : 0.0;
    const successGreen = Color(0xFF16A34A);
    final successIconColor = colorScheme.onPrimary;
    final surfaceStart =
        (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
            ? Colors.white
            : colorScheme.surface;
    final surfaceEnd = (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
        ? Colors.white
        : colorScheme.surfaceContainerHighest.withOpacity(0.94);
    final borderColor =
        (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
            ? Colors.white
            : colorScheme.outlineVariant.withOpacity(0.40);

    return AnimatedContainer(
      duration: _bannerCollapseDuration,
      curve: Curves.easeInOutCubicEmphasized,
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        color: surfaceStart,
        gradient: (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceStart, surfaceEnd],
              ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
                  ? (0.14 + (glow * 0.06))
                  : (0.16 + (glow * 0.08)),
            ),
            blurRadius:
                (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
                    ? (24 + (glow * 8))
                    : (28 + (glow * 10)),
            spreadRadius:
                (enforceWhiteCompactSurface || enforceWhiteBannerSurface)
                    ? 0.8
                    : 1,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final animatedWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : width;
          final animatedHeight =
              constraints.maxHeight.isFinite ? constraints.maxHeight : height;
          final contentWidth = useBanner && !compactCheckMode
              ? animatedWidth
              : animatedWidth * 0.74;
          final contentHeight = useBanner && !compactCheckMode
              ? animatedHeight
              : animatedHeight * 0.74;
          final checkSize = math.min(contentWidth, contentHeight) * 0.72;

          return Stack(
            alignment: Alignment.center,
            children: [
              if (useBanner && useWhiteCompactSurface)
                Positioned.fill(
                  child: useDarkCompactPalette
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.surface,
                                colorScheme.surfaceContainerHighest
                                    .withOpacity(0.94),
                              ],
                            ),
                          ),
                        )
                      : ColoredBox(color: surfaceStart),
                ),
              if (haloOpacity > 0) ...[
                Container(
                  width: compactCheckMode
                      ? contentWidth * 1.06
                      : (useBanner ? contentWidth * 1.02 : contentWidth * 1.06),
                  height: compactCheckMode
                      ? contentHeight * 1.06
                      : (useBanner
                          ? contentHeight * 1.08
                          : contentHeight * 1.06),
                  decoration: BoxDecoration(
                    color: checkHaloColor.withOpacity(haloOpacity),
                    borderRadius: compactCheckMode || !useBanner
                        ? null
                        : BorderRadius.circular(24),
                    shape: compactCheckMode || !useBanner
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                  ),
                ),
                if (!useBanner || compactCheckMode)
                  Transform.translate(
                    offset: Offset(
                      math.cos(orbitAngle) * animatedWidth * 0.075,
                      math.sin(orbitAngle) * animatedWidth * 0.075,
                    ),
                    child: Container(
                      width: contentWidth * 0.22,
                      height: contentWidth * 0.22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: checkHaloColor.withOpacity(0.14),
                      ),
                    ),
                  ),
              ],
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.linear,
                switchOutCurve: Curves.linear,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1).animate(
                        CurvedAnimation(
                            parent: animation, curve: Curves.easeOut),
                      ),
                      child: child,
                    ),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return SizedBox(
                    width: useBanner && !compactCheckMode
                        ? contentWidth
                        : contentWidth * 1.18,
                    height: useBanner && !compactCheckMode
                        ? contentHeight
                        : contentHeight * 1.18,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                  );
                },
                child: showCheck
                    ? SizedBox(
                        key: const ValueKey('check'),
                        width: checkSize,
                        height: checkSize,
                        child: Center(
                          child: _AnimatedSuccessCheck(
                            animation: checkAnimation,
                            size: checkSize,
                            color: successGreen,
                            iconColor: successIconColor,
                            iconSize: checkSize * 0.48,
                          ),
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('logo'),
                        width: contentWidth,
                        height: contentHeight,
                        child: _AnimatedInstitutionArtwork(
                          assetPath: _overlayArtworkAssetFor(institution),
                          compactAssetPath: _overlayCompactArtworkAssetFor(
                            institution,
                          ),
                          width: contentWidth,
                          height: contentHeight,
                          useBanner: useBanner,
                          // Keep banner careers on the exact same rendering
                          // path as Artes; only the video asset changes.
                          useContainedFit: useBanner
                              ? false
                              : _isPscsInstitution(institution),
                          useNeutralCollapseSurface: useWhiteCompactSurface,
                          glow: glow,
                          colorScheme: colorScheme,
                          onNearEnd: onArtworkNearEnd,
                          onCompleted: onArtworkCompleted,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedSuccessCheck extends StatelessWidget {
  const _AnimatedSuccessCheck({
    required this.animation,
    required this.size,
    required this.color,
    required this.iconColor,
    required this.iconSize,
  });

  final Animation<double> animation;
  final double size;
  final Color color;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final fade = Curves.easeOut.transform(animation.value);
        final ring = 1 + (animation.value * 0.18);
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - animation.value) * 0.22,
              child: Transform.scale(
                scale: ring,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.18),
                  ),
                ),
              ),
            ),
            Opacity(
              opacity: fade,
              child: Transform.scale(
                scale: Tween<double>(begin: 0.72, end: 1).evaluate(curved),
                child: child,
              ),
            ),
          ],
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.26),
              blurRadius: 18,
              spreadRadius: 1.5,
            ),
          ],
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.check_rounded,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _AnimatedInstitutionArtwork extends StatefulWidget {
  const _AnimatedInstitutionArtwork({
    required this.assetPath,
    required this.compactAssetPath,
    required this.width,
    required this.height,
    required this.useBanner,
    required this.useContainedFit,
    required this.useNeutralCollapseSurface,
    required this.glow,
    required this.colorScheme,
    this.onNearEnd,
    this.onCompleted,
  });

  final String assetPath;
  final String? compactAssetPath;
  final double width;
  final double height;
  final bool useBanner;
  final bool useContainedFit;
  final bool useNeutralCollapseSurface;
  final double glow;
  final ColorScheme colorScheme;
  final VoidCallback? onNearEnd;
  final VoidCallback? onCompleted;

  @override
  State<_AnimatedInstitutionArtwork> createState() =>
      _AnimatedInstitutionArtworkState();
}

class _AnimatedInstitutionArtworkState
    extends State<_AnimatedInstitutionArtwork> {
  static const Duration _collapseLeadBeforeEnd = Duration(milliseconds: 1200);
  VideoPlayerController? _videoController;
  bool _nearEndReported = false;
  bool _completionReported = false;

  bool get _usesVideo => widget.assetPath.endsWith('.mp4');

  @override
  void initState() {
    super.initState();
    // Retrasar la instanciación de Texture/MediaCodec 700ms para asegurar
    // que la animación de entrada de 650ms termine por completo.
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _initializeVideoIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedInstitutionArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath) {
      _disposeVideo();
      _nearEndReported = false;
      _completionReported = false;
      _initializeVideoIfNeeded();
    }
  }

  Future<void> _initializeVideoIfNeeded() async {
    if (!_usesVideo) return;
    final controller = VideoPlayerController.asset(widget.assetPath);
    _videoController = controller;
    controller.addListener(_handleVideoTick);
    await controller.initialize();
    await controller.setLooping(false);
    await controller.setVolume(0);
    await controller.play();
    if (mounted) {
      setState(() {});
    }
  }

  void _handleVideoTick() {
    final controller = _videoController;
    if (controller == null ||
        !controller.value.isInitialized ||
        (_nearEndReported && _completionReported)) {
      return;
    }
    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration <= Duration.zero) return;
    final triggerLead = duration > _collapseLeadBeforeEnd
        ? _collapseLeadBeforeEnd
        : const Duration(milliseconds: 40);
    if (!_nearEndReported && position >= duration - triggerLead) {
      _nearEndReported = true;
      widget.onNearEnd?.call();
    }
    if (!_completionReported &&
        position >= duration - const Duration(milliseconds: 40)) {
      _completionReported = true;
      widget.onCompleted?.call();
    }
  }

  Future<void> _disposeVideo() async {
    final controller = _videoController;
    _videoController = null;
    controller?.removeListener(_handleVideoTick);
    await controller?.dispose();
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.colorScheme.brightness == Brightness.dark;
    final compactSurfaceColor =
        isDark ? widget.colorScheme.surface : Colors.white;

    if (widget.useBanner && widget.useNeutralCollapseSurface && !_usesVideo) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox.expand(
          child: ColoredBox(
            color: compactSurfaceColor,
            child: Center(
              child: Container(
                width: widget.width * 0.86,
                height: widget.height * 0.86,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.colorScheme.outlineVariant.withValues(
                      alpha: 0.18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_usesVideo && widget.useBanner) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return const SizedBox.shrink();
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: _buildAssetImage(
          widget.assetPath,
          useContainedFit: widget.useContainedFit,
        ),
      );
    }

    final shimmerTravel = (widget.glow - 0.5) * widget.width * 0.64;
    final bannerDriftX =
        widget.useBanner ? (widget.glow - 0.5) * widget.width * 0.045 : 0.0;
    final bannerDriftY =
        widget.useBanner ? (0.5 - widget.glow) * widget.height * 0.028 : 0.0;
    final bannerScale = widget.useBanner ? 1.035 + (widget.glow * 0.02) : 1.0;
    final reveal = widget.useBanner ? 0.92 + (widget.glow * 0.08) : 1.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: widget.useNeutralCollapseSurface
            ? compactSurfaceColor
            : widget.colorScheme.surface,
        borderRadius: widget.useBanner ? BorderRadius.circular(22) : null,
        shape: widget.useBanner ? BoxShape.rectangle : BoxShape.circle,
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.useBanner
            ? ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: reveal.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(bannerDriftX, bannerDriftY),
                          child: Transform.scale(
                            scale: bannerScale,
                            alignment: Alignment.center,
                            child: _buildAssetImage(
                              widget.assetPath,
                              useContainedFit: widget.useContainedFit,
                            ),
                          ),
                        ),
                      ),
                    ),
                    widget.useNeutralCollapseSurface
                        ? ColoredBox(color: compactSurfaceColor)
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.colorScheme.surface
                                      .withOpacity(0.02),
                                  widget.colorScheme.primary.withValues(
                                    alpha: 0.05 + (widget.glow * 0.04),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    Transform.translate(
                      offset: Offset(shimmerTravel, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IgnorePointer(
                          child: Container(
                            width: widget.width * 0.10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.22),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: IgnorePointer(
                        child: widget.useNeutralCollapseSurface
                            ? const SizedBox.shrink()
                            : Container(
                                height: widget.height * 0.20,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(0),
                                      Colors.black.withValues(
                                        alpha: 0.10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              )
            : ClipOval(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildAssetImage(
                      widget.assetPath,
                      useContainedFit: widget.useContainedFit,
                    ),
                    Transform.translate(
                      offset: Offset(shimmerTravel, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IgnorePointer(
                          child: Container(
                            width: widget.width * 0.14,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.white.withOpacity(0),
                                  Colors.white.withOpacity(0.22),
                                  Colors.white.withOpacity(0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAssetImage(
    String path, {
    required bool useContainedFit,
  }) {
    final isPscsDark = path == _pscsOverlayLogoAsset &&
        widget.colorScheme.brightness == Brightness.dark;
    final resolvedFit = isPscsDark
        ? BoxFit.cover
        : (useContainedFit ? BoxFit.contain : BoxFit.cover);

    if (path.endsWith('.mp4')) {
      final controller = _videoController;
      if (controller == null || !controller.value.isInitialized) {
        return const SizedBox.shrink();
      }
      return FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.center,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
    }
    if (path.endsWith('.svg')) {
      final svg = SvgPicture.asset(
        path,
        fit: resolvedFit,
        alignment: Alignment.center,
      );
      if (isPscsDark) {
        return Transform.scale(scale: 1.16, child: svg);
      }
      return svg;
    }
    final image = Image.asset(
      path,
      fit: resolvedFit,
      filterQuality: FilterQuality.medium,
      isAntiAlias: true,
      alignment: Alignment.center,
      errorBuilder: (_, __, ___) => Icon(
        Icons.school_rounded,
        size: math.min(widget.width, widget.height) * 0.56,
        color: widget.colorScheme.primary,
      ),
    );
    Widget result = image;
    if (isPscsDark) {
      // The PSCS artwork has transparent margins; scale in dark mode so it
      // visually fills the circular mask like intended.
      result = Transform.scale(scale: 1.16, child: result);
    }
    if (!useContainedFit || isPscsDark) {
      return result;
    }
    const paddingFactor = 0.06;
    return Padding(
      padding: EdgeInsets.all(
        math.min(widget.width, widget.height) * paddingFactor,
      ),
      child: result,
    );
  }
}

