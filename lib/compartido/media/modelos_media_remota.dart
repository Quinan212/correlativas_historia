String normalizarFuenteMedia(String value) {
  var normalized = value.trim().replaceAll('\\', '/');

  normalized = normalized.replaceAll(RegExp(r'/+'), '/');

  while (normalized.startsWith('./')) {
    normalized = normalized.substring(2);
  }

  while (normalized.startsWith('/')) {
    normalized = normalized.substring(1);
  }

  if (normalized.startsWith('assets/')) {
    normalized = normalized.substring('assets/'.length);
  }

  return normalized;
}

bool debePrecargarMedia(MediaManifestEntry entry) {
  return !normalizarFuenteMedia(entry.source).endsWith('_ancho.webp');
}

bool esMediaPrioritariaParaPromocion(MediaManifestEntry entry) {
  if (entry.type == 'video') return true;
  if (entry.type != 'image') return false;

  final source = normalizarFuenteMedia(entry.source);
  if (source.startsWith('banners/historia/recorrido/') &&
      source.endsWith('.jpg')) {
    return true;
  }
  return source.endsWith('.webp') && !source.endsWith('_ancho.webp');
}

class MediaManifestEntry {
  const MediaManifestEntry({
    required this.type,
    required this.path,
    required this.sha256,
    required this.size,
    required this.preloadPriority,
    required this.source,
  });

  factory MediaManifestEntry.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    final path = json['path'];
    final sha256 = json['sha256'];
    final size = json['size'];
    final priority = json['preloadPriority'];
    final source = json['source'];

    if (type is! String ||
        path is! String ||
        sha256 is! String ||
        size is! num ||
        priority is! num ||
        source is! String ||
        sha256.length != 64 ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(sha256) ||
        size <= 0 ||
        size != size.toInt() ||
        priority != priority.toInt() ||
        source.trim().isEmpty) {
      throw const FormatException('Entrada de media remota inválida.');
    }

    return MediaManifestEntry(
      type: type,
      path: path,
      sha256: sha256.toLowerCase(),
      size: size.toInt(),
      preloadPriority: priority.toInt(),
      source: source,
    );
  }

  final String type;
  final String path;
  final String sha256;
  final int size;
  final int preloadPriority;
  final String source;
}

class MediaManifest {
  const MediaManifest({
    required this.schemaVersion,
    required this.contentVersion,
    required this.generatedAt,
    required this.assets,
  });

  factory MediaManifest.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    final contentVersion = json['contentVersion'];
    final generatedAt = json['generatedAt'];
    final rawAssets = json['assets'];

    if (schemaVersion is! num ||
        contentVersion is! String ||
        generatedAt is! String ||
        rawAssets is! Map ||
        rawAssets.isEmpty ||
        schemaVersion < 1 ||
        schemaVersion != schemaVersion.toInt() ||
        contentVersion.trim().isEmpty ||
        DateTime.tryParse(generatedAt) == null) {
      throw const FormatException('Manifiesto de media remota inválido.');
    }

    final assets = <MediaManifestEntry>[];
    final seenSources = <String>{};
    final seenHashes = <String>{};
    for (final raw in rawAssets.values) {
      if (raw is! Map) {
        throw const FormatException('Entrada de manifiesto inválida.');
      }
      final entry = MediaManifestEntry.fromJson(Map<String, dynamic>.from(raw));
      if (!seenSources.add(normalizarFuenteMedia(entry.source)) ||
          !seenHashes.add(entry.sha256)) {
        throw const FormatException('Manifiesto de media remoto duplicado.');
      }
      assets.add(entry);
    }

    return MediaManifest(
      schemaVersion: schemaVersion.toInt(),
      contentVersion: contentVersion,
      generatedAt: generatedAt,
      assets: List<MediaManifestEntry>.unmodifiable(assets),
    );
  }

  final int schemaVersion;
  final String contentVersion;
  final String generatedAt;
  final List<MediaManifestEntry> assets;

  MediaManifestEntry? findBySource(String source) {
    final normalizedSource = normalizarFuenteMedia(source);

    for (final entry in assets) {
      if (normalizarFuenteMedia(entry.source) == normalizedSource) {
        return entry;
      }
    }
    return null;
  }
}
