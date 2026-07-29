import 'dart:io';

import 'package:flutter/services.dart';

class ExcepcionExportacionBibliotecaDrive implements Exception {
  const ExcepcionExportacionBibliotecaDrive(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExportadorArchivosBibliotecaDrive {
  const ExportadorArchivosBibliotecaDrive._();

  static const MethodChannel _channel = MethodChannel(
    'ar.maillet.correlativas_historia/biblioteca_files',
  );

  static Future<bool> guardarEnDispositivo({
    required File source,
    required String fileName,
    required String mimeType,
  }) async {
    if (!Platform.isAndroid) {
      throw const ExcepcionExportacionBibliotecaDrive(
        'Guardar en el dispositivo está disponible en Android.',
      );
    }
    if (!await source.exists() || await source.length() <= 0) {
      throw const ExcepcionExportacionBibliotecaDrive(
        'La copia local del archivo no está disponible.',
      );
    }

    try {
      final saved = await _channel.invokeMethod<bool>(
        'saveFileToDevice',
        <String, Object>{
          'sourcePath': source.path,
          'fileName': fileName,
          'mimeType': mimeType.trim().isEmpty
              ? 'application/octet-stream'
              : mimeType,
        },
      );
      return saved ?? false;
    } on MissingPluginException {
      throw const ExcepcionExportacionBibliotecaDrive(
        'La función para guardar archivos todavía no está disponible.',
      );
    } on PlatformException catch (error) {
      final message = error.message?.trim();
      throw ExcepcionExportacionBibliotecaDrive(
        message?.isNotEmpty == true
            ? message!
            : 'No se pudo guardar el archivo en el dispositivo.',
      );
    }
  }
}
