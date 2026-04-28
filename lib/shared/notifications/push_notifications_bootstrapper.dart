import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../device_identity/device_identity.dart';
import '../presence/device_presence_repository.dart';
import '../supabase/supabase.dart';
import 'push_notifications_service.dart';

class PushNotificationsBootstrapper extends ConsumerStatefulWidget {
  const PushNotificationsBootstrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<PushNotificationsBootstrapper> createState() =>
      _PushNotificationsBootstrapperState();
}

class _PushNotificationsBootstrapperState
    extends ConsumerState<PushNotificationsBootstrapper>
    with WidgetsBindingObserver {
  bool _bootstrapped = false;
  final DevicePresenceRepository _presenceRepository =
      const DevicePresenceRepository();
  final DeviceProfileRepository _profileRepository =
      const DeviceProfileRepository();
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
    final client = ref.read(supabaseClientProvider);
    final deviceId = await ref.read(deviceIdProvider.future);
    final deviceLabel = await ref.read(deviceLabelProvider.future);
    _deviceId = deviceId;
    if (client != null) {
      await _profileRepository.ensureProfileShell(
        client: client,
        deviceId: deviceId,
        deviceLabel: deviceLabel,
      );
    }
    await PushNotificationsService.instance.initialize(
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
    final client = ref.read(supabaseClientProvider);
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
