import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../firebase/app_firebase.dart';
import '../navegacion/navegador_app.dart';
import 'repositorio_token_push_dispositivo.dart';

const AndroidNotificationChannel _verificationUpdatesChannel =
    AndroidNotificationChannel(
  'verification_updates',
  'Actualizaciones de verificación',
  description:
      'Avisos cuando una captura quedó revisada o cuando llega una nueva solicitud para revisar.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!_supportsPushNotifications) return;
  await asegurarAppFirebase();
}

class ServicioNotificacionesPush {
  ServicioNotificacionesPush._();

  static final ServicioNotificacionesPush instance =
      ServicioNotificacionesPush._();

  static const String _permissionNoticePrefsKey =
      'push_notifications.permission_notice.v2';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final RepositorioTokenPushDispositivo _tokenRepository =
      const RepositorioTokenPushDispositivo();

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessagesSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  String? _deviceId;
  SupabaseClient? _client;

  Future<void> initialize({
    required String deviceId,
    required SupabaseClient? client,
  }) async {
    if (!_supportsPushNotifications || _initialized) return;

    _deviceId = deviceId;
    _client = client;

    await asegurarAppFirebase();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initializeLocalNotifications();

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (_isPermissionGranted(settings)) {
      await _requestAndroidNotificationsPermission();
      await _syncCurrentToken();
    }

    _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) async {
      final currentClient = _client;
      final currentDeviceId = _deviceId;
      if (currentClient == null || currentDeviceId == null) return;
      await _tokenRepository.upsertToken(
        client: currentClient,
        deviceId: currentDeviceId,
        pushToken: token,
      );
    });

    _foregroundMessagesSubscription =
        FirebaseMessaging.onMessage.listen((message) async {
      await _showForegroundNotification(message);
    });

    _messageOpenedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessageTap);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessageTap(initialMessage);
    }

    _initialized = true;
  }

  Future<void> ensurePermissionForVerification({
    required BuildContext context,
  }) async {
    if (!_supportsPushNotifications) return;

    await asegurarAppFirebase();

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.getNotificationSettings();
    if (_isPermissionGranted(settings)) {
      await _requestAndroidNotificationsPermission();
      await _syncCurrentToken();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final noticeAlreadyShown =
        prefs.getBool(_permissionNoticePrefsKey) ?? false;

    bool shouldContinue = true;
    if (!noticeAlreadyShown) {
      if (!context.mounted) return;
      shouldContinue = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Activa las notificaciones'),
              content: const Text(
                'Si las activas, te avisamos cuando tu verificación fue revisada. Así la devolución puede llegarte a tiempo, sin tener que entrar a la app para enterarte.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Ahora no'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ) ??
          false;
      await prefs.setBool(_permissionNoticePrefsKey, true);
    }

    if (!shouldContinue) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Puedes activarlas después desde Ajustes si quieres recibir la devolución en el momento.',
            ),
          ),
        );
      }
      return;
    }

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    await _requestAndroidNotificationsPermission();

    final refreshedSettings = await messaging.getNotificationSettings();
    if (_isPermissionGranted(refreshedSettings)) {
      await _syncCurrentToken();
    }
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _foregroundMessagesSubscription?.cancel();
    await _messageOpenedAppSubscription?.cancel();
    _tokenRefreshSubscription = null;
    _foregroundMessagesSubscription = null;
    _messageOpenedAppSubscription = null;
    _initialized = false;
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
      ),
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    final androidNotifications =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidNotifications?.createNotificationChannel(
      _verificationUpdatesChannel,
    );
  }

  Future<void> _requestAndroidNotificationsPermission() async {
    final androidNotifications =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidNotifications?.requestNotificationsPermission();
  }

  Future<void> _syncCurrentToken() async {
    final currentClient = _client;
    final currentDeviceId = _deviceId;
    if (currentClient == null || currentDeviceId == null) return;

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.trim().isEmpty) return;

    await _tokenRepository.upsertToken(
      client: currentClient,
      deviceId: currentDeviceId,
      pushToken: token,
    );
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _verificationUpdatesChannel.id,
          _verificationUpdatesChannel.name,
          channelDescription: _verificationUpdatesChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
            summaryText: _verificationUpdatesChannel.name,
          ),
        ),
      ),
      payload: _buildPayload(message.data),
    );
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    _openFromPayload(payload);
  }

  void _handleRemoteMessageTap(RemoteMessage message) {
    _openFromPayload(_buildPayload(message.data));
  }

  void _openFromPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return;

      final screen = (decoded['screen'] ?? '').toString().trim();
      if (screen == 'verification' || screen == 'admin_verification') {
        abrirPantallaVerificacion();
      }
    } catch (_) {
      // Ignore malformed payloads.
    }
  }

  String _buildPayload(Map<String, dynamic> data) {
    return jsonEncode(<String, dynamic>{
      'screen': data['screen']?.toString() ?? 'verification',
      'requestId': data['requestId']?.toString(),
      'matterId': data['matterId']?.toString(),
      'status': data['status']?.toString(),
    });
  }

  bool _isPermissionGranted(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}

bool get _supportsPushNotifications =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
