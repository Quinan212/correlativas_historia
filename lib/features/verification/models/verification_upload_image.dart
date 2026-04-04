import 'dart:typed_data';

class VerificationUploadImage {
  const VerificationUploadImage({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}
