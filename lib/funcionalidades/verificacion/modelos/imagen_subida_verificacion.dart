import 'dart:typed_data';

class ImagenSubidaVerificacion {
  const ImagenSubidaVerificacion({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}
