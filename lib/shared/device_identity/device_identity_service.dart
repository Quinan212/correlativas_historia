import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceIdentityService {
  const DeviceIdentityService();

  static const _prefsKey = 'device_identity.v1';
  static const _channel = MethodChannel(
    'ar.maillet.correlativas_historia/device_identity',
  );

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    if (Platform.isAndroid) {
      final platformId = await _readAndroidDeviceId();
      if (platformId != null) {
        await prefs.setString(_prefsKey, platformId);
        return platformId;
      }
    }

    final existing = prefs.getString(_prefsKey)?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final created = _generateDeviceId();
    await prefs.setString(_prefsKey, created);
    return created;
  }

  Future<String> getCurrentDeviceLabel() async {
    if (Platform.isAndroid) {
      final label = await _readAndroidDeviceLabel();
      if (label != null) return label;
      return 'Dispositivo Android';
    }

    final system = Platform.operatingSystem;
    return system.isEmpty ? 'Dispositivo' : _titleCase(system);
  }

  String _generateDeviceId() {
    final millis = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
    return 'dev_$millis';
  }

  Future<String?> _readAndroidDeviceId() async {
    try {
      final result = await _channel.invokeMethod<String>('getAndroidDeviceId');
      final cleaned = result?.trim();
      if (cleaned == null || cleaned.isEmpty) {
        return null;
      }
      if (cleaned.startsWith('emu_') || cleaned.startsWith('and_')) {
        return cleaned;
      }
      return 'and_$cleaned';
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<String?> _readAndroidDeviceLabel() async {
    try {
      final result = await _channel.invokeMethod<String>('getAndroidDeviceLabel');
      final cleaned = result?.trim();
      if (cleaned == null || cleaned.isEmpty) {
        return null;
      }
      return cleaned;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
