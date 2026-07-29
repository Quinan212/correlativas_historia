import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../configuracion/configuracion_fuente_mesas_excel.dart';

class ResultadoDescargaMesasExcel {
  const ResultadoDescargaMesasExcel({
    required this.notModified,
    required this.checkedAt,
    this.bytes,
    this.eTag,
    this.lastModified,
    this.sourceUri,
  });

  final bool notModified;
  final DateTime checkedAt;
  final Uint8List? bytes;
  final String? eTag;
  final String? lastModified;
  final Uri? sourceUri;
}

class ExcepcionDescargaMesasExcel implements Exception {
  const ExcepcionDescargaMesasExcel(this.message);

  final String message;

  @override
  String toString() => message;
}

class DescargadorMesasExcel {
  DescargadorMesasExcel({
    http.Client? client,
    this.config = ConfiguracionFuenteMesasExcel.current,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final ConfiguracionFuenteMesasExcel config;

  Future<ResultadoDescargaMesasExcel> descargar({
    String? eTag,
    String? lastModified,
    bool force = false,
  }) async {
    final errors = <String>[];
    for (final candidate in config.downloadCandidates) {
      try {
        final headers = <String, String>{
          'Accept':
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/octet-stream;q=0.9,*/*;q=0.1',
          'User-Agent': 'Correlativas-App-Mesas-Excel/${config.parserVersion}',
        };
        if (!force && (eTag?.trim().isNotEmpty ?? false)) {
          headers['If-None-Match'] = eTag!.trim();
        }
        if (!force && (lastModified?.trim().isNotEmpty ?? false)) {
          headers['If-Modified-Since'] = lastModified!.trim();
        }

        final response = await _client
            .get(candidate, headers: headers)
            .timeout(config.requestTimeout);
        final checkedAt = DateTime.now().toUtc();
        if (response.statusCode == 304) {
          return ResultadoDescargaMesasExcel(
            notModified: true,
            checkedAt: checkedAt,
            eTag: response.headers['etag'] ?? eTag,
            lastModified:
                response.headers['last-modified'] ?? lastModified,
            sourceUri: candidate,
          );
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          errors.add('${candidate.host}: HTTP ${response.statusCode}');
          continue;
        }

        final bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          errors.add('${candidate.host}: respuesta vacía');
          continue;
        }
        if (bytes.length > config.maximumBytes) {
          errors.add(
            '${candidate.host}: archivo de ${bytes.length} bytes supera el límite',
          );
          continue;
        }
        if (!_looksLikeXlsx(bytes)) {
          final contentType = response.headers['content-type'] ?? 'desconocido';
          errors.add(
            '${candidate.host}: contenido no XLSX ($contentType, ${bytes.length} bytes)',
          );
          continue;
        }

        return ResultadoDescargaMesasExcel(
          notModified: false,
          checkedAt: checkedAt,
          bytes: bytes,
          eTag: response.headers['etag'],
          lastModified: response.headers['last-modified'],
          sourceUri: candidate,
        );
      } catch (error) {
        errors.add('${candidate.host}: $error');
      }
    }
    throw ExcepcionDescargaMesasExcel(
      errors.isEmpty
          ? 'No se pudo descargar la fuente institucional.'
          : 'No se pudo descargar la fuente institucional. ${errors.join(' | ')}',
    );
  }

  bool _looksLikeXlsx(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        (bytes[2] == 0x03 || bytes[2] == 0x05 || bytes[2] == 0x07) &&
        (bytes[3] == 0x04 || bytes[3] == 0x06 || bytes[3] == 0x08);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
