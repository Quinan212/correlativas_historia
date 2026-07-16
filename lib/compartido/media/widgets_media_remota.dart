import 'dart:io';

import 'package:flutter/material.dart';

import 'repositorio_media_remota.dart';

class ImagenMediaRemota extends StatefulWidget {
  const ImagenMediaRemota({
    required this.source,
    super.key,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.filterQuality = FilterQuality.medium,
    this.isAntiAlias = true,
    this.width,
    this.height,
  });

  final String source;
  final BoxFit fit;
  final Alignment alignment;
  final FilterQuality filterQuality;
  final bool isAntiAlias;
  final double? width;
  final double? height;

  @override
  State<ImagenMediaRemota> createState() => _ImagenMediaRemotaState();
}

class _ImagenMediaRemotaState extends State<ImagenMediaRemota> {
  late Future<File?> _fileFuture;

  @override
  void initState() {
    super.initState();
    _fileFuture = repositorioMediaRemota.fileForSource(widget.source);
  }

  @override
  void didUpdateWidget(covariant ImagenMediaRemota oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _fileFuture = repositorioMediaRemota.fileForSource(widget.source);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File?>(
      future: _fileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _placeholder(context);
        }

        final file = snapshot.data;
        if (file == null) {
          return _placeholder(context);
        }

        return Image.file(
          file,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          alignment: widget.alignment,
          filterQuality: widget.filterQuality,
          isAntiAlias: widget.isAntiAlias,
          errorBuilder: (_, __, ___) => _placeholder(context),
        );
      },
    );
  }

  Widget _placeholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.image_outlined, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
