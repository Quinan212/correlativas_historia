import 'dart:async';

import 'package:flutter/widgets.dart';

import 'repositorio_media_remota.dart';

class _PrecargaMediaLifecycleObserver extends WidgetsBindingObserver {
  bool _refreshInProgress = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _refreshInProgress) return;

    _refreshInProgress = true;
    repositorioMediaRemota.refreshAndPreload().whenComplete(() {
      _refreshInProgress = false;
    });
  }
}

final _lifecycleObserver = _PrecargaMediaLifecycleObserver();
bool _lifecycleObserverRegistered = false;

void iniciarPrecargaMediaRemota() {
  if (!_lifecycleObserverRegistered) {
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _lifecycleObserverRegistered = true;
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(repositorioMediaRemota.preload());
  });
}
