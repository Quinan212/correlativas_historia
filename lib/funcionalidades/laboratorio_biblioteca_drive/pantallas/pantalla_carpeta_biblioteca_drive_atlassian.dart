import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../acceso_estudiante/pantallas/pantalla_visor_pdf_sage.dart';
import '../../laboratorio_atlassian/componentes/componentes_atlassian.dart';
import '../../laboratorio_atlassian/tema/tema_atlassian.dart';
import '../controladores/controlador_carpeta_biblioteca_drive.dart';
import '../datos/repositorio_biblioteca_drive.dart';
import '../modelos/modelos_biblioteca_drive.dart';
import '../servicios/exportador_archivos_biblioteca_drive.dart';

class PantallaCarpetaBibliotecaDriveAtlassian extends StatefulWidget {
  const PantallaCarpetaBibliotecaDriveAtlassian({
    super.key,
    required this.repository,
    required this.folderId,
    required this.title,
    required this.routeSegments,
    this.resourceKey,
  });

  final RepositorioBibliotecaDrive repository;
  final String folderId;
  final String? resourceKey;
  final String title;
  final List<SegmentoRutaBibliotecaDrive> routeSegments;

  @override
  State<PantallaCarpetaBibliotecaDriveAtlassian> createState() =>
      _PantallaCarpetaBibliotecaDriveAtlassianState();
}

class _PantallaCarpetaBibliotecaDriveAtlassianState
    extends State<PantallaCarpetaBibliotecaDriveAtlassian> {
  late final ControladorCarpetaBibliotecaDrive _controller;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _downloadedItemIds = <String>{};
  String _query = '';
  String _lastDownloadProbeSignature = '';

  @override
  void initState() {
    super.initState();
    _controller = ControladorCarpetaBibliotecaDrive(
      folderId: widget.folderId,
      resourceKey: widget.resourceKey,
      repository: widget.repository,
    )..addListener(_handleControllerChanged);
    _searchController.addListener(_handleSearchChanged);
    unawaited(_controller.initialize());
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _controller.dispose();
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    setState(() {});
    unawaited(_refreshDownloadedStates());
  }

  Future<void> _refreshDownloadedStates({bool force = false}) async {
    final files = _controller.items
        .where(
          (item) =>
              !item.isFolder &&
              !item.isGoogleWorkspaceFile &&
              item.canDownload,
        )
        .toList(growable: false);
    final signature = files
        .map(
          (item) =>
              '${item.id}:${item.size ?? -1}:'
              '${item.modifiedTime?.millisecondsSinceEpoch ?? -1}',
        )
        .join('|');
    if (!force && signature == _lastDownloadProbeSignature) return;
    _lastDownloadProbeSignature = signature;

    final states = await Future.wait(
      files.map((item) => widget.repository.estaDescargado(item)),
    );
    if (!mounted || signature != _lastDownloadProbeSignature) return;

    final downloadedIds = <String>{};
    for (var index = 0; index < files.length; index++) {
      if (states[index]) downloadedIds.add(files[index].id);
    }
    setState(() {
      _downloadedItemIds
        ..clear()
        ..addAll(downloadedIds);
    });
  }

  void _handleSearchChanged() {
    final next = _searchController.text;
    if (next == _query) return;
    setState(() => _query = next);
  }

  Future<void> _openFolder(ElementoBibliotecaDrive item) async {
    final route = <SegmentoRutaBibliotecaDrive>[
      ...widget.routeSegments,
      SegmentoRutaBibliotecaDrive(id: item.id, name: item.visibleName),
    ];
    await Navigator.of(context).push<void>(
      rutaAtlassian<void>(
        builder: (_) => PantallaCarpetaBibliotecaDriveAtlassian(
          repository: widget.repository,
          folderId: item.id,
          resourceKey: item.resourceKey,
          title: item.visibleName,
          routeSegments: route,
        ),
      ),
    );
  }

  Future<void> _openFile(ElementoBibliotecaDrive item) async {
    if (item.isGoogleWorkspaceFile || !item.canDownload) {
      await _openWebFile(item);
      return;
    }

    final file = await _obtenerArchivoLocal(item);
    if (file == null || !mounted) return;
    await _openLocalFile(file, item);
  }

  Future<File?> _obtenerArchivoLocal(ElementoBibliotecaDrive item) async {
    final alreadyDownloaded = _downloadedItemIds.contains(item.id);
    var dialogVisible = false;
    if (mounted && !alreadyDownloaded) {
      dialogVisible = true;
      unawaited(
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _DialogoDescargaBiblioteca(),
        ),
      );
    }

    try {
      final file = await widget.repository.descargarArchivo(item);
      if (!mounted) return null;
      if (!_downloadedItemIds.contains(item.id)) {
        setState(() => _downloadedItemIds.add(item.id));
      }
      _closeDownloadDialog(dialogVisible);
      return file;
    } on ExcepcionBibliotecaDrive catch (error) {
      if (!mounted) return null;
      _closeDownloadDialog(dialogVisible);
      _showMessage(error.message);
      return null;
    } catch (_) {
      if (!mounted) return null;
      _closeDownloadDialog(dialogVisible);
      _showMessage('No se pudo descargar el archivo.');
      return null;
    }
  }

  void _closeDownloadDialog(bool dialogVisible) {
    if (!dialogVisible || !mounted) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) navigator.pop();
  }

  Future<void> _openWebFile(ElementoBibliotecaDrive item) async {
    final raw = item.webViewLink;
    final uri = raw == null ? null : Uri.tryParse(raw);
    if (uri == null) {
      _showMessage('El archivo no tiene una dirección disponible.');
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showMessage('No se pudo abrir el archivo en Google Drive.');
    }
  }

  Future<void> _openLocalFile(
    File file,
    ElementoBibliotecaDrive item,
  ) async {
    if (item.extension == 'pdf') {
      await Navigator.of(context).push<void>(
        rutaAtlassian<void>(
          builder: (_) => PantallaVisorPdfSage(
            rutaArchivo: file.path,
            nombreArchivo: item.visibleName,
          ),
        ),
      );
      return;
    }

    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done && mounted) {
      _showMessage('No hay una aplicación compatible con este archivo.');
    }
  }

  Future<void> _openFileActions(
    ElementoBibliotecaDrive item,
    Offset anchorPosition,
  ) async {
    if (item.isFolder) return;
    final atlassianTheme = temaLaboratorioAtlassian(context);
    final action = await showGeneralDialog<_AccionArchivoBiblioteca>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierLabel: 'Cerrar acciones de archivo',
      barrierColor: atlassianTheme.colorScheme.scrim.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Theme(
          data: atlassianTheme,
          child: _MenuFlotanteAccionesArchivoBiblioteca(
            item: item,
            downloaded: _downloadedItemIds.contains(item.id),
            anchorPosition: anchorPosition,
            animation: animation,
          ),
        );
      },
    );
    if (action == null || !mounted) return;

    switch (action) {
      case _AccionArchivoBiblioteca.abrir:
        await _openFile(item);
        break;
      case _AccionArchivoBiblioteca.guardarEnDispositivo:
        await _saveFileToDevice(item);
        break;
      case _AccionArchivoBiblioteca.compartir:
        await _shareFile(item);
        break;
      case _AccionArchivoBiblioteca.eliminarDescarga:
        await _deleteOfflineDownload(item);
        break;
    }
  }

  Future<void> _saveFileToDevice(ElementoBibliotecaDrive item) async {
    if (item.isGoogleWorkspaceFile || !item.canDownload) {
      _showMessage('Este archivo no admite una copia directa.');
      return;
    }
    final file = await _obtenerArchivoLocal(item);
    if (file == null || !mounted) return;

    try {
      final saved =
          await ExportadorArchivosBibliotecaDrive.guardarEnDispositivo(
            source: file,
            fileName: file.path.split(Platform.pathSeparator).last,
            mimeType: item.mimeType,
          );
      if (saved && mounted) {
        _showMessage('Archivo guardado en el dispositivo.');
      }
    } on ExcepcionExportacionBibliotecaDrive catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('No se pudo guardar el archivo en el dispositivo.');
    }
  }

  Future<void> _shareFile(ElementoBibliotecaDrive item) async {
    try {
      if (item.isGoogleWorkspaceFile || !item.canDownload) {
        final link = item.webViewLink?.trim() ?? '';
        if (link.isEmpty) {
          _showMessage('El archivo no tiene una dirección para compartir.');
          return;
        }
        await SharePlus.instance.share(
          ShareParams(title: item.visibleName, text: link),
        );
        return;
      }

      final file = await _obtenerArchivoLocal(item);
      if (file == null || !mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          title: item.visibleName,
          files: <XFile>[XFile(file.path)],
        ),
      );
    } catch (_) {
      _showMessage('No se pudo compartir el archivo.');
    }
  }

  Future<void> _deleteOfflineDownload(ElementoBibliotecaDrive item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar descarga'),
        content: const Text(
          'Se eliminará la copia sin conexión guardada dentro de la app. '
          'Las copias exportadas al teléfono no se modificarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final deleted = await widget.repository.eliminarDescarga(item);
      if (!mounted) return;
      setState(() => _downloadedItemIds.remove(item.id));
      _showMessage(
        deleted
            ? 'Descarga sin conexión eliminada.'
            : 'La descarga ya no estaba disponible.',
      );
    } catch (_) {
      _showMessage('No se pudo eliminar la descarga sin conexión.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _controller.filter(_query);
    final subtitle = _routeText();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            EncabezadoPaginaAtlassian(
              title: widget.title,
              subtitle: subtitle,
              centerTitle: true,
              leading: IconButton(
                tooltip: 'Volver',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              actions: [
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _controller.refreshing
                      ? null
                      : () => unawaited(_controller.refresh()),
                  icon: _controller.refreshing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _controller.refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: _SearchFieldBiblioteca(
                          controller: _searchController,
                        ),
                      ),
                    ),
                    if (_controller.usingCache ||
                        _controller.errorMessage != null ||
                        _controller.lastUpdated != null)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverToBoxAdapter(
                          child: _EstadoBibliotecaDrive(
                            usingCache: _controller.usingCache,
                            errorMessage: _controller.errorMessage,
                            lastUpdated: _controller.lastUpdated,
                          ),
                        ),
                      ),
                    if (_controller.loadingInitial && !_controller.hasItems)
                      const SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                        sliver: SliverToBoxAdapter(
                          child: _SkeletonBibliotecaDrive(),
                        ),
                      )
                    else if (filtered.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyBibliotecaDrive(
                          hasQuery: _query.trim().isNotEmpty,
                          errorMessage: _controller.errorMessage,
                          onRetry: () => unawaited(_controller.refresh()),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index.isOdd) {
                                return const SizedBox(height: 8);
                              }
                              final item = filtered[index ~/ 2];
                              return _FilaElementoBibliotecaDrive(
                                item: item,
                                downloaded: _downloadedItemIds.contains(item.id),
                                onTap: item.isFolder
                                    ? () => _openFolder(item)
                                    : () => _openFile(item),
                                onLongPressStart: item.isFolder
                                    ? null
                                    : (details) => unawaited(
                                        _openFileActions(
                                          item,
                                          details.globalPosition,
                                        ),
                                      ),
                              );
                            },
                            childCount: filtered.length * 2 - 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _routeText() {
    if (widget.routeSegments.isEmpty) return 'Google Drive público';
    final names = widget.routeSegments.map((segment) => segment.name).toList();
    if (names.length <= 2) return names.join('  ›  ');
    return '${names[names.length - 2]}  ›  ${names.last}';
  }
}

class _SearchFieldBiblioteca extends StatelessWidget {
  const _SearchFieldBiblioteca({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar en esta carpeta',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Limpiar',
              onPressed: controller.clear,
              icon: const Icon(Icons.close_rounded),
            );
          },
        ),
      ),
    );
  }
}

class _EstadoBibliotecaDrive extends StatelessWidget {
  const _EstadoBibliotecaDrive({
    required this.usingCache,
    required this.errorMessage,
    required this.lastUpdated,
  });

  final bool usingCache;
  final String? errorMessage;
  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final message = usingCache
        ? 'Mostrando la última copia disponible'
        : errorMessage ?? _formatUpdate(lastUpdated);
    final icon = usingCache || errorMessage != null
        ? Icons.cloud_off_outlined
        : Icons.cloud_done_outlined;
    final color = usingCache || errorMessage != null
        ? scheme.tertiary
        : scheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  String _formatUpdate(DateTime? value) {
    if (value == null) return 'Biblioteca conectada a Google Drive';
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Actualizado $day/$month · $hour:$minute';
  }
}

enum _AccionArchivoBiblioteca {
  abrir,
  guardarEnDispositivo,
  compartir,
  eliminarDescarga,
}

class _MenuFlotanteAccionesArchivoBiblioteca extends StatelessWidget {
  const _MenuFlotanteAccionesArchivoBiblioteca({
    required this.item,
    required this.downloaded,
    required this.anchorPosition,
    required this.animation,
  });

  final ElementoBibliotecaDrive item;
  final bool downloaded;
  final Offset anchorPosition;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final canDownload = !item.isGoogleWorkspaceFile && item.canDownload;
    final canSaveToDevice = canDownload && Platform.isAndroid;
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final scaleAlignment = anchorPosition.dy > media.size.height / 2
        ? Alignment.bottomLeft
        : Alignment.topLeft;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: _MenuFlotanteArchivoLayoutDelegate(
                anchorPosition: anchorPosition,
                safePadding: media.padding,
              ),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.98, end: 1).animate(
                    curvedAnimation,
                  ),
                  alignment: scaleAlignment,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(
                        RadioAtlassian.medium,
                      ),
                      border: Border.all(color: scheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.shadow.withValues(
                            alpha: dark ? 0.34 : 0.14,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        RadioAtlassian.medium,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(
                              EspacioAtlassian.xs,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _OpcionArchivoBiblioteca(
                                  icon: Icons.open_in_new_rounded,
                                  label: 'Abrir',
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pop(_AccionArchivoBiblioteca.abrir),
                                ),
                                if (canSaveToDevice)
                                  _OpcionArchivoBiblioteca(
                                    icon: Icons.save_alt_rounded,
                                    label: 'Guardar en el dispositivo',
                                    onTap: () => Navigator.of(context).pop(
                                      _AccionArchivoBiblioteca
                                          .guardarEnDispositivo,
                                    ),
                                  ),
                                _OpcionArchivoBiblioteca(
                                  icon: Icons.share_rounded,
                                  label: 'Compartir',
                                  onTap: () => Navigator.of(
                                    context,
                                  ).pop(_AccionArchivoBiblioteca.compartir),
                                ),
                                if (canDownload && downloaded) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: EspacioAtlassian.xxs,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      color: scheme.outlineVariant,
                                    ),
                                  ),
                                  _OpcionArchivoBiblioteca(
                                    icon: Icons.delete_outline_rounded,
                                    label:
                                        'Eliminar descarga sin conexión',
                                    foregroundColor: scheme.error,
                                    onTap: () => Navigator.of(context).pop(
                                      _AccionArchivoBiblioteca
                                          .eliminarDescarga,
                                    ),
                                  ),
                                ],
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
          ),
        ],
      ),
    );
  }
}

class _MenuFlotanteArchivoLayoutDelegate extends SingleChildLayoutDelegate {
  const _MenuFlotanteArchivoLayoutDelegate({
    required this.anchorPosition,
    required this.safePadding,
  });

  static const double _menuWidth = 292;
  static const double _horizontalMargin = 12;
  static const double _verticalMargin = 12;
  static const double _anchorGap = 10;

  final Offset anchorPosition;
  final EdgeInsets safePadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final availableWidth = constraints.maxWidth - (_horizontalMargin * 2);
    final width = availableWidth < _menuWidth ? availableWidth : _menuWidth;
    final maxHeight = constraints.maxHeight -
        safePadding.vertical -
        (_verticalMargin * 2);
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      minHeight: 0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final safeLeft = _horizontalMargin;
    final safeRight = size.width - _horizontalMargin;
    final safeTop = safePadding.top + _verticalMargin;
    final safeBottom = size.height - safePadding.bottom - _verticalMargin;

    final desiredLeft = anchorPosition.dx - 24;
    final maxLeft = safeRight - childSize.width;
    final left = desiredLeft.clamp(safeLeft, maxLeft).toDouble();

    final spaceBelow = safeBottom - anchorPosition.dy - _anchorGap;
    final spaceAbove = anchorPosition.dy - safeTop - _anchorGap;
    final placeAbove = childSize.height > spaceBelow && spaceAbove > spaceBelow;
    final desiredTop = placeAbove
        ? anchorPosition.dy - childSize.height - _anchorGap
        : anchorPosition.dy + _anchorGap;
    final maxTop = safeBottom - childSize.height;
    final top = desiredTop.clamp(safeTop, maxTop).toDouble();

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_MenuFlotanteArchivoLayoutDelegate oldDelegate) {
    return oldDelegate.anchorPosition != anchorPosition ||
        oldDelegate.safePadding != safePadding;
  }
}

class _OpcionArchivoBiblioteca extends StatelessWidget {
  const _OpcionArchivoBiblioteca({
    required this.icon,
    required this.label,
    required this.onTap,
    this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = foregroundColor ?? scheme.onSurface;
    final hoverColor = foregroundColor == null
        ? scheme.surfaceContainerHigh
        : scheme.errorContainer.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadioAtlassian.small),
        overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed) ||
              states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return hoverColor;
          }
          return null;
        }),
        child: SizedBox(
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: EspacioAtlassian.sm,
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: color),
                const SizedBox(width: EspacioAtlassian.sm),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilaElementoBibliotecaDrive extends StatelessWidget {
  const _FilaElementoBibliotecaDrive({
    required this.item,
    required this.downloaded,
    required this.onTap,
    this.onLongPressStart,
  });

  final ElementoBibliotecaDrive item;
  final bool downloaded;
  final VoidCallback onTap;
  final GestureLongPressStartCallback? onLongPressStart;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: onLongPressStart,
      child: PanelAtlassian(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.isFolder
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(RadioAtlassian.medium),
              ),
              child: Icon(
                _iconFor(item),
                size: 22,
                color: item.isFolder
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : scheme.primary)
                    : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.visibleName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _secondaryText(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: _trailingTooltip(item),
              child: Icon(
                _trailingIcon(item),
                size: 21,
                color: downloaded && !item.isFolder
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _trailingIcon(ElementoBibliotecaDrive item) {
    if (item.isFolder) return Icons.chevron_right_rounded;
    if (item.isGoogleWorkspaceFile || !item.canDownload) {
      return Icons.open_in_new_rounded;
    }
    return downloaded ? Icons.check_circle_rounded : Icons.download_rounded;
  }

  String _trailingTooltip(ElementoBibliotecaDrive item) {
    if (item.isFolder) return 'Abrir carpeta';
    if (item.isGoogleWorkspaceFile || !item.canDownload) {
      return 'Abrir archivo';
    }
    return downloaded ? 'Disponible sin conexión' : 'Descargar';
  }

  IconData _iconFor(ElementoBibliotecaDrive item) {
    if (item.isFolder) return Icons.folder_rounded;
    return switch (item.extension) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'doc' || 'docx' || 'odt' || 'rtf' => Icons.description_rounded,
      'ppt' || 'pptx' || 'odp' => Icons.slideshow_rounded,
      'xls' || 'xlsx' || 'ods' || 'csv' => Icons.table_chart_rounded,
      'jpg' || 'jpeg' || 'png' || 'webp' || 'gif' => Icons.image_rounded,
      'mp3' || 'wav' || 'm4a' || 'ogg' => Icons.audio_file_rounded,
      'mp4' || 'mkv' || 'webm' || 'mov' => Icons.video_file_rounded,
      'zip' || 'rar' || '7z' => Icons.folder_zip_rounded,
      _ => item.isGoogleWorkspaceFile
          ? Icons.cloud_outlined
          : Icons.insert_drive_file_rounded,
    };
  }

  String _secondaryText(ElementoBibliotecaDrive item) {
    if (item.isFolder) return 'Carpeta';
    final parts = <String>[];
    if (item.extension.isNotEmpty) parts.add(item.extension.toUpperCase());
    final size = item.size;
    if (size != null) parts.add(_formatSize(size));
    final modified = item.modifiedTime;
    if (modified != null) {
      final local = modified.toLocal();
      final day = local.day.toString().padLeft(2, '0');
      final month = local.month.toString().padLeft(2, '0');
      parts.add('$day/$month/${local.year}');
    }
    return parts.isEmpty ? 'Archivo' : parts.join(' · ');
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(gb < 10 ? 1 : 0)} GB';
  }
}

class _SkeletonBibliotecaDrive extends StatelessWidget {
  const _SkeletonBibliotecaDrive();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: List<Widget>.generate(
          7,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PanelAtlassian(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(RadioAtlassian.medium),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nombre de carpeta académica'),
                        SizedBox(height: 4),
                        Text('Carpeta de Google Drive'),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyBibliotecaDrive extends StatelessWidget {
  const _EmptyBibliotecaDrive({
    required this.hasQuery,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool hasQuery;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = errorMessage != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasError
                  ? Icons.cloud_off_outlined
                  : hasQuery
                  ? Icons.search_off_rounded
                  : Icons.folder_open_rounded,
              size: 48,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              hasError
                  ? errorMessage!
                  : hasQuery
                  ? 'No hay coincidencias en esta carpeta.'
                  : 'Esta carpeta todavía está vacía.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (hasError) ...[
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DialogoDescargaBiblioteca extends StatelessWidget {
  const _DialogoDescargaBiblioteca();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: const Text('Abriendo material'),
        content: const Row(
          children: [
            SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(width: 16),
            Expanded(child: Text('Descargando desde Google Drive...')),
          ],
        ),
      ),
    );
  }
}
