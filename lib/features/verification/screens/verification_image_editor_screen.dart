import 'dart:typed_data';

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
  _AspectOption _selectedAspect = _AspectOption.feedPortrait;
  bool _cropping = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.sourceImage.readAsBytes();
    if (!mounted) return;
    setState(() => _imageBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageBytes = _imageBytes;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Editar imagen'),
        actions: [
          TextButton(
            onPressed: (_cropping || imageBytes == null) ? null : _cropImage,
            child: Text(
              _cropping ? 'Procesando...' : 'Usar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: imageBytes == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: ColoredBox(
                      color: const Color(0xFF05070B),
                      child: Crop(
                        image: imageBytes,
                        controller: _cropController,
                        aspectRatio: _selectedAspect.ratio,
                        initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                          size: 0.92,
                          aspectRatio: _selectedAspect.ratio,
                        ),
                        interactive: true,
                        fixCropRect: true,
                        radius: 12,
                        baseColor: const Color(0xFF05070B),
                        maskColor: Colors.black.withValues(alpha: 0.66),
                        progressIndicator: const CircularProgressIndicator(),
                        cornerDotBuilder: (size, edgeAlignment) =>
                            const SizedBox.shrink(),
                        overlayBuilder: (context, rect) =>
                            const _CleanFrameOverlay(radius: 12),
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
                                SnackBar(
                                  content: Text(
                                    'No se pudo recortar la imagen: $cause',
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0D14),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    minimum: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    child: Column(
                      children: [
                        Text(
                          'Mueve y acerca la imagen para dejar visible la parte importante.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _AspectOption.values
                                .map(
                                  (option) => Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: _AspectChip(
                                      option: option,
                                      selected: option == _selectedAspect,
                                      onTap: () {
                                        setState(
                                            () => _selectedAspect = option);
                                        _cropController.aspectRatio =
                                            option.ratio;
                                      },
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ],
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
    final safeExt = ext.isEmpty ? 'jpg' : ext;
    return 'verification_crop_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
  }
}

enum _AspectOption {
  square('1:1', 1),
  feedPortrait('4:5', 4 / 5),
  wide('16:9', 16 / 9);

  const _AspectOption(this.label, this.ratio);

  final String label;
  final double ratio;
}

class _AspectChip extends StatelessWidget {
  const _AspectChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _AspectOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color:
                selected ? Colors.white : Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Text(
          option.label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CleanFrameOverlay extends StatelessWidget {
  const _CleanFrameOverlay({
    required this.radius,
  });

  final double radius;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FrameOverlayPainter(radius),
        size: Size.infinite,
      ),
    );
  }
}

class _FrameOverlayPainter extends CustomPainter {
  const _FrameOverlayPainter(this.radius);

  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final cropRect = Offset.zero & size;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(cropRect, Radius.circular(radius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FrameOverlayPainter oldDelegate) {
    return oldDelegate.radius != radius;
  }
}
