import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'modelos_media_remota.dart';

class CacheMediaRemota {
  CacheMediaRemota({http.Client? client}) : _client = client ?? http.Client();

  factory CacheMediaRemota.withRootDirectory({
    http.Client? client,
    required Directory rootDirectory,
  }) {
    final cache = CacheMediaRemota(client: client);
    cache._rootDirectory = rootDirectory;
    return cache;
  }

  final http.Client _client;
  final Map<String, Future<File?>> _inFlight = <String, Future<File?>>{};
  final List<Completer<void>> _waiters = <Completer<void>>[];
  int _activeDownloads = 0;
  Directory? _rootDirectory;

  Future<Directory> _root() async {
    final cached = _rootDirectory;
    if (cached != null) return cached;

    final support = await getApplicationSupportDirectory();
    final root = Directory(
      '${support.path}${Platform.pathSeparator}media_cache',
    );
    await root.create(recursive: true);
    _rootDirectory = root;
    return root;
  }

  Future<File> manifestFile() async {
    final root = await _root();
    return File('${root.path}${Platform.pathSeparator}media_manifest.json');
  }

  Future<File> pendingManifestFile() async {
    final root = await _root();
    return File(
      '${root.path}${Platform.pathSeparator}media_manifest.pending.json',
    );
  }

  Future<File> _fileFor(MediaManifestEntry entry) async {
    final root = await _root();
    final extension = _extensionOf(entry.path);
    return File(
      '${root.path}${Platform.pathSeparator}${entry.sha256}$extension',
    );
  }

  Future<String> sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  Future<File?> ensure(MediaManifestEntry entry, String publicUrl) {
    final existing = _inFlight[entry.sha256];
    if (existing != null) return existing;

    final future = _ensure(entry, publicUrl);
    _inFlight[entry.sha256] = future;
    future.then<void>(
      (_) => _inFlight.remove(entry.sha256),
      onError: (Object _, StackTrace __) {
        _inFlight.remove(entry.sha256);
      },
    );
    return future;
  }

  Future<File?> _ensure(MediaManifestEntry entry, String publicUrl) async {
    final target = await _fileFor(entry);
    if (await _isValid(target, entry)) return target;

    return _withDownloadSlot(() async {
      if (await _isValid(target, entry)) return target;

      final temporary = File('${target.path}.part');
      await temporary.parent.create(recursive: true);
      if (await temporary.exists()) await temporary.delete();

      try {
        final request = http.Request('GET', Uri.parse(publicUrl));
        final response = await _client
            .send(request)
            .timeout(const Duration(seconds: 45));
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Descarga de media remota fallida: HTTP ${response.statusCode}.',
          );
        }

        final sink = temporary.openWrite();
        try {
          await response.stream.listen(sink.add).asFuture<void>();
          await sink.flush();
        } finally {
          await sink.close();
        }

        if (!await _isValid(temporary, entry)) {
          throw const FormatException(
            'La media descargada no coincide con el manifiesto.',
          );
        }

        if (await target.exists()) await target.delete();
        return temporary.rename(target.path);
      } catch (_) {
        if (await temporary.exists()) await temporary.delete();
        return null;
      }
    });
  }

  Future<bool> _isValid(File file, MediaManifestEntry entry) async {
    if (!await file.exists()) return false;
    if (await file.length() != entry.size) return false;
    return (await sha256Of(file)) == entry.sha256;
  }

  Future<T> _withDownloadSlot<T>(Future<T> Function() action) async {
    if (_activeDownloads >= 2) {
      final waiter = Completer<void>();
      _waiters.add(waiter);
      await waiter.future;
    }

    _activeDownloads++;
    try {
      return await action();
    } finally {
      _activeDownloads--;
      if (_waiters.isNotEmpty) {
        _waiters.removeAt(0).complete();
      }
    }
  }

  Future<void> writeManifestAtomically(String contents) async {
    await writePendingManifestAtomically(contents);
    await promotePendingManifest();
  }

  Future<void> writePendingManifestAtomically(String contents) async {
    final target = await pendingManifestFile();
    final temporary = File('${target.path}.part');
    await temporary.writeAsString(contents, flush: true);
    if (await target.exists()) await target.delete();
    await temporary.rename(target.path);
  }

  Future<void> promotePendingManifest() async {
    final pending = await pendingManifestFile();
    if (!await pending.exists()) {
      throw const FileSystemException('No existe manifiesto pendiente.');
    }

    final active = await manifestFile();
    try {
      await pending.rename(active.path);
    } catch (_) {
      // Android reemplaza el destino en la misma operación. Si la plataforma
      // no lo permite, conservamos una copia del activo antes de reemplazarlo
      // y lo restauramos si la promoción falla.
      final backup = File('${active.path}.previous');
      if (await backup.exists()) await backup.delete();
      if (await active.exists()) await active.copy(backup.path);
      final contents = await pending.readAsString();
      final temporary = File('${active.path}.part');
      await temporary.writeAsString(contents, flush: true);
      try {
        if (await active.exists()) await active.delete();
        await temporary.rename(active.path);
        if (await backup.exists()) await backup.delete();
        if (await pending.exists()) await pending.delete();
      } catch (_) {
        if (await temporary.exists()) await temporary.delete();
        if (!await active.exists() && await backup.exists()) {
          await backup.rename(active.path);
        }
        rethrow;
      }
    }
  }

  Future<void> discardPendingManifest() async {
    final pending = await pendingManifestFile();
    final temporary = File('${pending.path}.part');
    if (await pending.exists()) await pending.delete();
    if (await temporary.exists()) await temporary.delete();
  }

  Future<String?> readCachedManifest() async {
    final file = await manifestFile();
    if (!await file.exists()) return null;
    return file.readAsString();
  }

  Future<void> prune(MediaManifest manifest) async {
    final root = await _root();
    final allowed = <String>{
      for (final entry in manifest.assets)
        '${entry.sha256}${_extensionOf(entry.path)}',
    };

    await for (final entity in root.list()) {
      if (entity is! File) continue;
      if (entity.path.endsWith('media_manifest.json') ||
          entity.path.endsWith('media_manifest.pending.json') ||
          entity.path.endsWith('media_manifest.json.previous') ||
          entity.path.endsWith('.part')) {
        continue;
      }
      if (!allowed.contains(_fileName(entity.path))) {
        await entity.delete();
      }
    }
  }

  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0) return '.bin';
    return path.substring(dot).toLowerCase();
  }

  static String _fileName(String path) {
    final separator = path.lastIndexOf(Platform.pathSeparator);
    return separator < 0 ? path : path.substring(separator + 1);
  }
}
