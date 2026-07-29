import 'dart:io';

import '../../../firebase_options.dart';

class ConfiguracionBibliotecaDrive {
  const ConfiguracionBibliotecaDrive({
    required this.rootFolderId,
    required this.rootFolderUrl,
    this.rootResourceKey,
    this.requestTimeout = const Duration(seconds: 25),
    this.maximumDownloadBytes = 750 * 1024 * 1024,
  });

  static const current = ConfiguracionBibliotecaDrive(
    rootFolderId: '14qLLT7wkazGeNaJrbBSHwRk4bVI2g-Hz',
    rootFolderUrl:
        'https://drive.google.com/drive/folders/14qLLT7wkazGeNaJrbBSHwRk4bVI2g-Hz',
  );

  final String rootFolderId;
  final String rootFolderUrl;
  final String? rootResourceKey;
  final Duration requestTimeout;
  final int maximumDownloadBytes;

  String get apiKey {
    const override = String.fromEnvironment('GOOGLE_DRIVE_API_KEY');
    final explicit = override.trim();
    if (explicit.isNotEmpty) return explicit;

    try {
      return DefaultFirebaseOptions.currentPlatform.apiKey.trim();
    } catch (_) {
      return '';
    }
  }

  String get androidPackageName {
    const override = String.fromEnvironment('GOOGLE_DRIVE_ANDROID_PACKAGE');
    final explicit = override.trim();
    return explicit.isEmpty
        ? 'ar.maillet.correlativas_historia'
        : explicit;
  }

  String? get androidCertificateSha1 {
    const value = String.fromEnvironment('GOOGLE_DRIVE_ANDROID_SHA1');
    final normalized = value.replaceAll(':', '').trim().toLowerCase();
    return normalized.isEmpty ? null : normalized;
  }

  Uri listChildrenUri({
    required String folderId,
    String? pageToken,
  }) {
    final query = <String, String>{
      'q': "'$folderId' in parents and trashed = false",
      'fields':
          'nextPageToken,files(id,name,mimeType,size,modifiedTime,'
          'webViewLink,webContentLink,resourceKey,capabilities(canDownload))',
      'orderBy': 'folder,name_natural',
      'pageSize': '1000',
      'supportsAllDrives': 'true',
      'includeItemsFromAllDrives': 'true',
    };
    if (apiKey.isNotEmpty) query['key'] = apiKey;
    if (pageToken != null && pageToken.trim().isNotEmpty) {
      query['pageToken'] = pageToken.trim();
    }
    return Uri.https('www.googleapis.com', '/drive/v3/files', query);
  }

  Uri downloadUri(String fileId) {
    final query = <String, String>{'alt': 'media'};
    if (apiKey.isNotEmpty) query['key'] = apiKey;
    return Uri.https(
      'www.googleapis.com',
      '/drive/v3/files/$fileId',
      query,
    );
  }

  Map<String, String> requestHeaders({
    String? fileId,
    String? resourceKey,
  }) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (Platform.isAndroid) {
      headers['X-Android-Package'] = androidPackageName;
      final certificate = androidCertificateSha1;
      if (certificate != null) {
        headers['X-Android-Cert'] = certificate;
      }
    }
    final normalizedFileId = fileId?.trim() ?? '';
    final normalizedResourceKey = resourceKey?.trim() ?? '';
    if (normalizedFileId.isNotEmpty && normalizedResourceKey.isNotEmpty) {
      headers['X-Goog-Drive-Resource-Keys'] =
          '$normalizedFileId/$normalizedResourceKey';
    }
    return headers;
  }
}
