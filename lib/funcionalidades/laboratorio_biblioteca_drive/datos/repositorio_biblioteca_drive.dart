import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../configuracion/configuracion_biblioteca_drive.dart';
import '../modelos/modelos_biblioteca_drive.dart';

class ExcepcionBibliotecaDrive implements Exception {
  const ExcepcionBibliotecaDrive(
    this.message, {
    this.statusCode,
    this.reason,
  });

  final String message;
  final int? statusCode;
  final String? reason;

  @override
  String toString() => message;
}

class RepositorioBibliotecaDrive {
  RepositorioBibliotecaDrive({
    ConfiguracionBibliotecaDrive? configuration,
    http.Client? client,
  }) : configuration =
           configuration ?? ConfiguracionBibliotecaDrive.current,
       _client = client ?? http.Client();

  final ConfiguracionBibliotecaDrive configuration;
  final http.Client _client;

  Future<List<ElementoBibliotecaDrive>> listarHijos({
    required String folderId,
    String? resourceKey,
  }) async {
    final items = <ElementoBibliotecaDrive>[];
    String? pageToken;

    do {
      final response = await _client
          .get(
            configuration.listChildrenUri(
              folderId: folderId,
              pageToken: pageToken,
            ),
            headers: configuration.requestHeaders(
              fileId: folderId,
              resourceKey: resourceKey,
            ),
          )
          .timeout(configuration.requestTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _decodeApiError(response);
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const ExcepcionBibliotecaDrive(
          'Google Drive devolvió una respuesta incompatible.',
        );
      }
      final json = Map<String, dynamic>.from(decoded);
      final pageItems = (json['files'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (value) => ElementoBibliotecaDrive.fromJson(
              Map<String, dynamic>.from(value),
            ),
          )
          .where((value) => value.id.isNotEmpty)
          .toList(growable: false);
      items.addAll(pageItems);
      pageToken = json['nextPageToken']?.toString().trim();
      if (pageToken != null && pageToken!.isEmpty) pageToken = null;
    } while (pageToken != null);

    return ordenarElementosBibliotecaDrive(items);
  }

  Future<File?> obtenerArchivoDescargado(
    ElementoBibliotecaDrive item,
  ) async {
    if (item.isFolder || item.isGoogleWorkspaceFile || !item.canDownload) {
      return null;
    }

    final declaredSize = item.size;
    final destination = await _destinationFor(item);
    if (await _isValidDownloadedFile(destination, declaredSize)) {
      return destination;
    }

    // Migra una descarga realizada por la primera versión del piloto, que
    // guardaba todos los archivos directamente en biblioteca_drive.
    final legacy = await _legacyDestinationFor(item);
    if (!await _isValidDownloadedFile(legacy, declaredSize)) return null;

    try {
      await destination.parent.create(recursive: true);
      if (await destination.exists()) await destination.delete();
      return legacy.rename(destination.path);
    } on FileSystemException {
      return legacy;
    }
  }

  Future<bool> estaDescargado(ElementoBibliotecaDrive item) async {
    return await obtenerArchivoDescargado(item) != null;
  }

  Future<bool> eliminarDescarga(ElementoBibliotecaDrive item) async {
    if (item.isFolder || item.isGoogleWorkspaceFile || !item.canDownload) {
      return false;
    }

    var deleted = false;
    final destination = await _destinationFor(item);
    if (await destination.exists()) {
      await destination.delete();
      deleted = true;
      final parent = destination.parent;
      if (await parent.exists() && await parent.list().isEmpty) {
        await parent.delete();
      }
    }

    final legacy = await _legacyDestinationFor(item);
    if (await legacy.exists()) {
      await legacy.delete();
      deleted = true;
    }
    return deleted;
  }

  Future<File> descargarArchivo(ElementoBibliotecaDrive item) async {
    if (item.isFolder || item.isGoogleWorkspaceFile || !item.canDownload) {
      throw const ExcepcionBibliotecaDrive(
        'Este elemento no admite descarga directa.',
      );
    }
    final declaredSize = item.size;
    if (declaredSize != null &&
        declaredSize > configuration.maximumDownloadBytes) {
      throw const ExcepcionBibliotecaDrive(
        'El archivo supera el tamaño máximo permitido.',
      );
    }

    final downloaded = await obtenerArchivoDescargado(item);
    if (downloaded != null) return downloaded;

    final destination = await _destinationFor(item);
    await destination.parent.create(recursive: true);
    final temporary = File('${destination.path}.part');
    if (await temporary.exists()) await temporary.delete();

    final request = http.Request('GET', configuration.downloadUri(item.id));
    final headers = configuration.requestHeaders(
      fileId: item.id,
      resourceKey: item.resourceKey,
    );
    headers['Accept'] = 'application/octet-stream';
    request.headers.addAll(headers);

    final response = await _client
        .send(request)
        .timeout(configuration.requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw _decodeStreamedError(response.statusCode, body);
    }

    final contentLength = response.contentLength;
    if (contentLength != null &&
        contentLength > configuration.maximumDownloadBytes) {
      throw const ExcepcionBibliotecaDrive(
        'El archivo supera el tamaño máximo permitido.',
      );
    }

    final sink = temporary.openWrite();
    var received = 0;
    var sinkClosed = false;
    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        if (received > configuration.maximumDownloadBytes) {
          throw const ExcepcionBibliotecaDrive(
            'El archivo supera el tamaño máximo permitido.',
          );
        }
        sink.add(chunk);
      }
      await sink.flush();
      await sink.close();
      sinkClosed = true;
      if (received <= 0) {
        throw const ExcepcionBibliotecaDrive('El archivo recibido está vacío.');
      }
      if (await destination.exists()) await destination.delete();
      return temporary.rename(destination.path);
    } catch (_) {
      if (!sinkClosed) await sink.close();
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }


  Future<File> _destinationFor(ElementoBibliotecaDrive item) async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final itemDirectory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}biblioteca_drive'
      '${Platform.pathSeparator}${_safePathSegment(item.id)}',
    );
    final safeName = _safeFileName(item.name, item.id);
    return File('${itemDirectory.path}${Platform.pathSeparator}$safeName');
  }

  Future<File> _legacyDestinationFor(ElementoBibliotecaDrive item) async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final safeName = _safeFileName(item.name, item.id);
    return File(
      '${baseDirectory.path}${Platform.pathSeparator}biblioteca_drive'
      '${Platform.pathSeparator}$safeName',
    );
  }

  Future<bool> _isValidDownloadedFile(File file, int? declaredSize) async {
    if (!await file.exists()) return false;
    final stat = await file.stat();
    return stat.size > 0 &&
        (declaredSize == null || stat.size == declaredSize);
  }

  String _safePathSegment(String value) {
    final normalized = value.replaceAll(
      RegExp(r'[^A-Za-z0-9_-]'),
      '_',
    );
    return normalized.isEmpty ? 'archivo' : normalized;
  }

  void dispose() => _client.close();

  ExcepcionBibliotecaDrive _decodeApiError(http.Response response) {
    final body = utf8.decode(response.bodyBytes, allowMalformed: true);
    return _decodeStreamedError(response.statusCode, body);
  }

  ExcepcionBibliotecaDrive _decodeStreamedError(int statusCode, String body) {
    String? apiMessage;
    String? reason;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final error = decoded['error'];
        if (error is Map) {
          apiMessage = error['message']?.toString().trim();
          final errors = error['errors'];
          if (errors is List && errors.isNotEmpty && errors.first is Map) {
            reason = (errors.first as Map)['reason']?.toString().trim();
          }
        }
      }
    } catch (_) {
      // La respuesta puede ser HTML o texto plano.
    }

    final message = switch (statusCode) {
      401 => 'Google Drive rechazó la credencial de acceso.',
      403 when reason == 'accessNotConfigured' =>
        'La API de Google Drive todavía no está habilitada para esta aplicación.',
      403 => 'Google Drive rechazó el acceso a la carpeta pública.',
      404 => 'La carpeta o el archivo ya no está disponible.',
      429 => 'Google Drive recibió demasiadas consultas. Intentá nuevamente.',
      _ => apiMessage?.isNotEmpty == true
          ? apiMessage!
          : 'No se pudo consultar Google Drive.',
    };
    return ExcepcionBibliotecaDrive(
      message,
      statusCode: statusCode,
      reason: reason,
    );
  }

  String _safeFileName(String rawName, String fileId) {
    var name = rawName.trim();
    if (name.isEmpty) name = fileId;
    name = name.replaceAll(RegExp(r'[\\/:*?"<>|\u0000-\u001F]'), '_');
    if (name.length > 180) {
      final dot = name.lastIndexOf('.');
      final extension = dot > 0 ? name.substring(dot) : '';
      final maximumBase = 180 - extension.length;
      name = '${name.substring(0, maximumBase.clamp(1, name.length).toInt())}$extension';
    }
    return name;
  }
}
