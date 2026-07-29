import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../../trayectoria_sage_laboratorio/sage/estilo_visual_sage.dart';

class PantallaVisorPdfSage extends StatefulWidget {
  const PantallaVisorPdfSage({
    super.key,
    required this.rutaArchivo,
    required this.nombreArchivo,
  });

  final String rutaArchivo;
  final String nombreArchivo;

  @override
  State<PantallaVisorPdfSage> createState() => _PantallaVisorPdfSageState();
}

class _PantallaVisorPdfSageState extends State<PantallaVisorPdfSage> {
  late final PdfControllerPinch _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(document: _openValidatedDocument());
  }

  Future<PdfDocument> _openValidatedDocument() async {
    final file = File(widget.rutaArchivo);
    if (!await file.exists()) {
      throw const FormatException('Archivo no disponible.');
    }
    final stat = await file.stat();
    if (stat.type != FileSystemEntityType.file ||
        stat.size <= 0 ||
        !file.path.toLowerCase().endsWith('.pdf') ||
        !await _isControlledPath(file)) {
      throw const FormatException('Documento no válido.');
    }
    return PdfDocument.openFile(file.path);
  }

  Future<bool> _isControlledPath(File file) async {
    final resolvedFile = await file.resolveSymbolicLinks();
    final allowedDirectories = <Directory>[];
    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectories(
        type: StorageDirectory.downloads,
      );
      if (external != null) allowedDirectories.addAll(external);
    }
    allowedDirectories.add(await getApplicationDocumentsDirectory());
    final filePath = _normalisePath(resolvedFile);
    for (final directory in allowedDirectories) {
      final resolvedDirectory = await directory.resolveSymbolicLinks();
      final directoryPath = _normalisePath(resolvedDirectory);
      if (filePath == directoryPath || filePath.startsWith('$directoryPath/')) {
        return true;
      }
    }
    return false;
  }

  String _normalisePath(String value) {
    var result = value.replaceAll(String.fromCharCode(92), '/').toLowerCase();
    while (result.endsWith('/')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  Future<void> _share() async {
    final file = File(widget.rutaArchivo);
    if (!await file.exists() || !mounted) return;
    try {
      await SharePlus.instance.share(
        ShareParams(title: widget.nombreArchivo, files: [XFile(file.path)]),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo compartir el PDF.')),
        );
      }
    }
  }

  Future<void> _openExternally() async {
    final result = await OpenFilex.open(widget.rutaArchivo);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay un visor de PDF disponible.')),
      );
    }
  }

  Future<void> _retryDocument() async {
    await _pdfController.loadDocument(_openValidatedDocument());
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: construirAppBarSage(
        context,
        title: widget.nombreArchivo,
        toolbarHeight: 72,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            tooltip: 'Compartir',
            onPressed: _share,
            icon: const Icon(Icons.share_rounded),
          ),
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (value) {
              if (value == 'external') _openExternally();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'external',
                child: Text('Abrir con otra aplicación'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          PdfViewPinch(
            controller: _pdfController,
            backgroundDecoration: BoxDecoration(color: scheme.surface),
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              pageLoaderBuilder: (_) =>
                  const Center(child: CircularProgressIndicator()),
              errorBuilder: (context, error) => _PdfErrorView(
                onRetry: _retryDocument,
                onOpenExternally: _openExternally,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfErrorView extends StatelessWidget {
  const _PdfErrorView({required this.onRetry, required this.onOpenExternally});

  final VoidCallback onRetry;
  final VoidCallback onOpenExternally;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudo mostrar el documento'),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Reintentar'),
                ),
                OutlinedButton(
                  onPressed: onOpenExternally,
                  child: const Text('Abrir con otra aplicación'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
