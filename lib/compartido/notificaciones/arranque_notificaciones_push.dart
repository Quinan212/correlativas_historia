import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../identidad_dispositivo/identidad_dispositivo.dart';
import '../presencia/repositorio_presencia_dispositivo.dart';
import '../supabase/supabase.dart';
import 'servicio_notificaciones_push.dart';

class ArranqueNotificacionesPush extends ConsumerStatefulWidget {
  const ArranqueNotificacionesPush({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<ArranqueNotificacionesPush> createState() =>
      _ArranqueNotificacionesPushState();
}

class _ArranqueNotificacionesPushState
    extends ConsumerState<ArranqueNotificacionesPush>
    with WidgetsBindingObserver {
  bool _bootstrapped = false;
  final RepositorioPresenciaDispositivo _presenceRepository =
      const RepositorioPresenciaDispositivo();
  final RepositorioPerfilDispositivo _profileRepository =
      const RepositorioPerfilDispositivo();
  String? _deviceId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final client = ref.read(proveedorClienteSupabase);
    final deviceId = await ref.read(proveedorIdDispositivo.future);
    final deviceLabel = await ref.read(proveedorEtiquetaDispositivo.future);
    _deviceId = deviceId;
    if (client != null) {
      await _profileRepository.ensureProfileShell(
        client: client,
        deviceId: deviceId,
        deviceLabel: deviceLabel,
      );
    }
    await ServicioNotificacionesPush.instance.initialize(
      deviceId: deviceId,
      client: client,
    );
    await _markPresence();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markPresence();
    }
  }

  Future<void> _markPresence() async {
    final client = ref.read(proveedorClienteSupabase);
    final deviceId = _deviceId;
    if (client == null || deviceId == null) return;
    await _presenceRepository.markActive(
      client: client,
      deviceId: deviceId,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
