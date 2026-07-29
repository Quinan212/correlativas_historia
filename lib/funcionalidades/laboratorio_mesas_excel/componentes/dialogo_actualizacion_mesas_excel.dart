import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../controladores/controlador_mesas_excel.dart';
import '../modelos/modelos_mesas_excel.dart';

Future<void> mostrarDialogoActualizacionMesasExcel({
  required BuildContext context,
  required ControladorMesasExcel controller,
}) async {
  if (controller.estaComprobando) return;

  final atlassianTheme = temaLaboratorioAtlassian(context);
  await showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierLabel: 'Actualizando mesas oficiales',
    barrierColor: atlassianTheme.colorScheme.scrim.withValues(alpha: 0.36),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Theme(
        data: atlassianTheme,
        child: _DialogoActualizacionMesasExcel(controller: controller),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _DialogoActualizacionMesasExcel extends StatefulWidget {
  const _DialogoActualizacionMesasExcel({required this.controller});

  final ControladorMesasExcel controller;

  @override
  State<_DialogoActualizacionMesasExcel> createState() =>
      _DialogoActualizacionMesasExcelState();
}

class _DialogoActualizacionMesasExcelState
    extends State<_DialogoActualizacionMesasExcel> {
  bool _finished = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runUpdate());
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _runUpdate() async {
    await widget.controller.actualizar(force: true);
    if (!mounted) return;

    final status = widget.controller.estado;
    final success =
        status == EstadoFuenteMesasExcel.disponible ||
        status == EstadoFuenteMesasExcel.sinCambios;
    setState(() {
      _finished = true;
      _success = success;
    });

    if (success) {
      await Future<void>.delayed(const Duration(milliseconds: 650));
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  String get _stageMessage {
    return switch (widget.controller.etapaActualizacion) {
      EtapaActualizacionMesasExcel.descargando =>
        'Consultando mesas oficiales...',
      EtapaActualizacionMesasExcel.interpretando =>
        'Organizando fechas, horarios y materias...',
      EtapaActualizacionMesasExcel.validando =>
        'Verificando mesas, coloquios y actas...',
      EtapaActualizacionMesasExcel.guardando =>
        'Actualizando la información disponible...',
      EtapaActualizacionMesasExcel.inactiva => 'Preparando la consulta...',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = !_finished
        ? 'Actualizar mesas'
        : _success
        ? 'Mesas actualizadas'
        : 'No se pudo actualizar';
    final message = !_finished
        ? _stageMessage
        : _success
        ? 'Las mesas oficiales están actualizadas.'
        : 'No fue posible consultar las mesas oficiales. '
              'Intentá nuevamente.';

    return PopScope(
      canPop: _finished && !_success,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 410),
            child: Dialog(
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              backgroundColor: scheme.surface,
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(RadioAtlassian.large),
                side: BorderSide(color: scheme.outlineVariant),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      EspacioAtlassian.md,
                      EspacioAtlassian.md,
                      EspacioAtlassian.md,
                      EspacioAtlassian.sm,
                    ),
                    child: Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: scheme.outlineVariant),
                  Padding(
                    padding: const EdgeInsets.all(EspacioAtlassian.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _buildStatusVisual(theme),
                        ),
                        const SizedBox(width: EspacioAtlassian.md),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: Text(
                              message,
                              key: ValueKey(message),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_finished && !_success) ...[
                    Divider(height: 1, color: scheme.outlineVariant),
                    Padding(
                      padding: const EdgeInsets.all(EspacioAtlassian.sm),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: BotonAtlassian(
                          label: 'Cerrar',
                          primary: true,
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusVisual(ThemeData theme) {
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    if (!_finished) {
      return IndicadorCuadradoMesas(
        key: const ValueKey('loading'),
        color: scheme.primary,
        size: 58,
        strokeWidth: 5,
      );
    }

    final background = _success
        ? (dark
              ? PaletaAtlassian.successSubtleDark
              : PaletaAtlassian.successSubtle)
        : (dark
              ? PaletaAtlassian.dangerSubtleDark
              : PaletaAtlassian.dangerSubtle);
    final foreground = _success
        ? (dark ? const Color(0xFFBAF3DB) : const Color(0xFF164B35))
        : (dark ? const Color(0xFFFFD2CC) : const Color(0xFF5D1F1A));

    return Container(
      key: ValueKey(_success),
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RadioAtlassian.medium),
        border: Border.all(color: foreground.withValues(alpha: 0.22)),
      ),
      alignment: Alignment.center,
      child: Icon(
        _success ? Icons.check_rounded : Icons.error_outline_rounded,
        size: 31,
        color: foreground,
      ),
    );
  }
}

class IndicadorCuadradoMesas extends StatefulWidget {
  const IndicadorCuadradoMesas({
    super.key,
    required this.color,
    this.size = 58,
    this.strokeWidth = 5,
  });

  final Color color;
  final double size;
  final double strokeWidth;

  @override
  State<IndicadorCuadradoMesas> createState() => _IndicadorCuadradoMesasState();
}

class _IndicadorCuadradoMesasState extends State<IndicadorCuadradoMesas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Actualizando mesas',
      liveRegion: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _SquareLoaderPainter(
                progress: _controller.value,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
              ),
              child: child,
            );
          },
          child: Center(
            child: Icon(
              Icons.event_note_rounded,
              size: 20,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareLoaderPainter extends CustomPainter {
  const _SquareLoaderPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final inset = strokeWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()..addRect(rect);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.miter
      ..color = color.withValues(alpha: 0.10);
    canvas.drawPath(path, trackPaint);

    final metric = path.computeMetrics().first;
    final length = metric.length;
    final dashLength = length * 0.25;
    final start = progress * length;
    final end = start + dashLength;
    final carPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..color = color;

    if (end <= length) {
      canvas.drawPath(metric.extractPath(start, end), carPaint);
      return;
    }

    canvas.drawPath(metric.extractPath(start, length), carPaint);
    canvas.drawPath(
      metric.extractPath(0, math.min(end - length, length)),
      carPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SquareLoaderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
