import 'dart:async';

import 'package:flutter/foundation.dart';

import '../datos/repositorio_biblioteca_drive.dart';
import '../datos/repositorio_cache_biblioteca_drive.dart';
import '../modelos/modelos_biblioteca_drive.dart';

class ControladorCarpetaBibliotecaDrive extends ChangeNotifier {
  ControladorCarpetaBibliotecaDrive({
    required this.folderId,
    required this.repository,
    this.resourceKey,
    RepositorioCacheBibliotecaDrive? cache,
  }) : cache = cache ?? const RepositorioCacheBibliotecaDrive();

  final String folderId;
  final String? resourceKey;
  final RepositorioBibliotecaDrive repository;
  final RepositorioCacheBibliotecaDrive cache;

  List<ElementoBibliotecaDrive> _items = const <ElementoBibliotecaDrive>[];
  bool _loadingInitial = true;
  bool _refreshing = false;
  bool _usingCache = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  bool _disposed = false;

  List<ElementoBibliotecaDrive> get items => _items;
  bool get loadingInitial => _loadingInitial;
  bool get refreshing => _refreshing;
  bool get usingCache => _usingCache;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasItems => _items.isNotEmpty;

  Future<void> initialize() async {
    final localCopy = await cache.cargar(folderId);
    if (_disposed) return;
    if (localCopy != null) {
      _items = ordenarElementosBibliotecaDrive(localCopy.items);
      _lastUpdated = localCopy.fetchedAt;
      _usingCache = true;
      _loadingInitial = false;
      notifyListeners();
    }
    await refresh(manual: false);
  }

  Future<void> refresh({bool manual = true}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (!hasItems) _loadingInitial = true;
    if (manual) _errorMessage = null;
    _notifySafely();

    try {
      final remoteItems = await repository.listarHijos(
        folderId: folderId,
        resourceKey: resourceKey,
      );
      final fetchedAt = DateTime.now();
      _items = remoteItems;
      _lastUpdated = fetchedAt;
      _usingCache = false;
      _errorMessage = null;
      await cache.guardar(
        CopiaCarpetaBibliotecaDrive(
          folderId: folderId,
          items: remoteItems,
          fetchedAt: fetchedAt,
        ),
      );
    } on TimeoutException {
      _errorMessage = 'La consulta a Google Drive tardó demasiado.';
      _usingCache = hasItems;
    } on ExcepcionBibliotecaDrive catch (error) {
      _errorMessage = error.message;
      _usingCache = hasItems;
    } catch (_) {
      _errorMessage = 'No se pudo consultar la biblioteca.';
      _usingCache = hasItems;
    } finally {
      _refreshing = false;
      _loadingInitial = false;
      _notifySafely();
    }
  }

  List<ElementoBibliotecaDrive> filter(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.visibleName.toLowerCase().contains(normalized) ||
              item.extension.contains(normalized),
        )
        .toList(growable: false);
  }

  void _notifySafely() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
