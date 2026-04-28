import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/verification_upload_image.dart';

class VerificationImageEditorScreen extends StatefulWidget {
  const VerificationImageEditorScreen({
    super.key,
    required this.sourceImage,
  });

  final XFile sourceImage;

  @override
  State<VerificationImageEditorScreen> createState() =>
      _VerificationImageEditorScreenState();
}

class _VerificationImageEditorScreenState
    extends State<VerificationImageEditorScreen> {
  final CropController _cropController = CropController();

  Uint8List? _imageBytes;
  double? _originalRatio; 
  // false = ratio original (Instagram style: ver toda la foto al entrar)
  // true = ratio 2:3 (formato de referencia)
  bool _useDefault = false; 
  static const double _defaultRatio = 210 / 320; 
  bool _cropping = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.sourceImage.readAsBytes();
    if (!mounted) return;

    final codec = await ui.instantiateImageCodec(bytes, targetWidth: 200);
    final frame = await codec.getNextFrame();
    final w = frame.image.width;
    final h = frame.image.height;
    frame.image.dispose();
    codec.dispose();

    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _originalRatio = w / h;
    });
  }

  double get _currentRatio =>
      _useDefault ? _defaultRatio : (_originalRatio ?? 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageBytes = _imageBytes;
    final originalRatio = _originalRatio;
    
    // Botón visible si la foto no es ya un 2:3 portrait
    final showExpandButton = originalRatio != null &&
        (originalRatio - _defaultRatio).abs() > 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Editar imagen'),
        actions: [
          TextButton(
            onPressed: (_cropping || imageBytes == null) ? null : _cropImage,
            child: Text(
              _cropping ? '...' : 'LISTO',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
      body: imageBytes == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white24))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      // Eliminamos padding para que se vea grande
                      Crop(
                        image: imageBytes,
                        controller: _cropController,
                        aspectRatio: _currentRatio,
                        initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                          size: 1.0, // Ocupar todo el espacio
                          aspectRatio: _currentRatio,
                        ),
                        interactive: true,
                        fixCropRect: true,
                        radius: 0, // Bordes rectos para máxima visibilidad
                        baseColor: Colors.black,
                        maskColor: Colors.black.withValues(alpha: 0.75),
                        progressIndicator: const CircularProgressIndicator(color: Colors.white),
                        cornerDotBuilder: (size, edgeAlignment) => const SizedBox.shrink(),
                        overlayBuilder: (context, rect) => const _CleanFrameOverlay(),
                        onCropped: (result) {
                          if (!mounted) return;
                          switch (result) {
                            case CropSuccess(:final croppedImage):
                              Navigator.of(context).pop(
                                VerificationUploadImage(
                                  bytes: croppedImage,
                                  fileName: _buildCroppedName(
                                    widget.sourceImage.name,
                                  ),
                                ),
                              );
                            case CropFailure(:final cause):
                              setState(() => _cropping = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $cause')),
                              );
                          }
                        },
                      ),
                      // Botón estilo Instagram para alternar ratio
                      if (showExpandButton)
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: GestureDetector(
                            onTap: () {
                              final next = !_useDefault;
                              setState(() => _useDefault = next);
                              _cropController.aspectRatio =
                                  next ? _defaultRatio : originalRatio;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _useDefault 
                                  ? Icons.expand_rounded 
                                  : Icons.unfold_less_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: SafeArea(
                    top: false,
                    child: Text(
                      'Pellizcá para hacer zoom o arrastrá para encuadrar.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _cropImage() {
    setState(() => _cropping = true);
    _cropController.crop();
  }

  String _buildCroppedName(String sourceName) {
    final parts = sourceName.split('.');
    final ext = parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
    return 'crop_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }
}

class _CleanFrameOverlay extends StatelessWidget {
  const _CleanFrameOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
        ),
      ),
    );
  }
}
