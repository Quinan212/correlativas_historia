import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../supabase/supabase_config.dart';
import 'cache_media_remota.dart';
import 'modelos_media_remota.dart';

class RepositorioMediaRemota {
  RepositorioMediaRemota({CacheMediaRemota? cache})
    : _cache = cache ?? CacheMediaRemota();

  static const bucket = 'app-media';
  static const manifestPath = 'manifests/media_manifest.json';

  final CacheMediaRemota _cache;
  final http.Client _client = http.Client();
  MediaManifest? _manifest;
  Future<MediaManifest?>? _manifestRequest;

  Future<MediaManifest?> manifest({bool forceRefresh = false}) {
    if (!forceRefresh) {
      final cached = _manifest;
      if (cached != null) return Future<MediaManifest?>.value(cached);
      final pending = _manifestRequest;
      if (pending != null) return pending;
    }

    final request = _loadManifest(forceRefresh: forceRefresh);
    _manifestRequest = request;
    request.whenComplete(() => _manifestRequest = null);
    return request;
  }

  Future<MediaManifest?> _loadManifest({required bool forceRefresh}) async {
    final active = _manifest ?? await _readActiveManifest();
    _manifest ??= active;

    try {
      final response = await _client
          .get(Uri.parse(publicUrlForPath(manifestPath)))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Manifiesto HTTP ${response.statusCode}.');
      }

      final parsed = MediaManifest.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
      if (active != null &&
          active.contentVersion == parsed.contentVersion &&
          active.schemaVersion == parsed.schemaVersion) {
        return active;
      }

      await _cache.writePendingManifestAtomically(response.body);
      final promoted = await _promotePendingManifest(parsed);
      if (!promoted) {
        await _cache.discardPendingManifest();
        return active;
      }

      await _cache.promotePendingManifest();
      _manifest = parsed;
      await _cache.prune(parsed);
      return parsed;
    } catch (_) {
      return active;
    }
  }

  Future<MediaManifest?> _readActiveManifest() async {
    final cached = await _cache.readCachedManifest();
    if (cached == null) return null;

    try {
      return MediaManifest.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _promotePendingManifest(MediaManifest candidate) async {
    final requiredEntries = candidate.assets.where(
      esMediaPrioritariaParaPromocion,
    );
    for (final entry in requiredEntries) {
      final file = await _cache.ensure(entry, publicUrlForPath(entry.path));
      if (file == null) return false;
    }
    return true;
  }

  Future<File?> fileForSource(String source) async {
    final current = await manifest();
    final entry = current?.findBySource(source);
    if (entry == null) return null;
    return _cache.ensure(entry, publicUrlForPath(entry.path));
  }

  Future<void> preload() async {
    final current = await manifest();
    if (current == null) return;

    final entries = [...current.assets]
      ..sort((a, b) {
        final priority = a.preloadPriority.compareTo(b.preloadPriority);
        if (priority != 0) return priority;
        return a.source.compareTo(b.source);
      });

    for (final entry in entries) {
      if (!debePrecargarMedia(entry)) continue;
      await _cache.ensure(entry, publicUrlForPath(entry.path));
    }
  }

  Future<void> refreshAndPreload() async {
    await manifest(forceRefresh: true);
    await preload();
  }

  static String publicUrlForPath(String path) {
    final encoded = path.split('/').map(Uri.encodeComponent).join('/');
    return '${SupabaseConfig.url}/storage/v1/object/public/$bucket/$encoded';
  }
}

final repositorioMediaRemota = RepositorioMediaRemota();
