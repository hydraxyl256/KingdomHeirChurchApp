import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:kingdom_heir/core/notifications/notification_router.dart';
import 'package:logger/logger.dart';

// Top-level function for handling background/terminated messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Wait until we actually need it, Firebase is already initialized by default mechanism
  Logger().d('Handling a background message: ${message.messageId}');
}

final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref);
});

class PushNotificationService {
  PushNotificationService(this._ref);

  final Ref _ref;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _initialRouteTimer;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Cancel all subscriptions and timers held by this service.
  void dispose() {
    _initialRouteTimer?.cancel();
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
    _tokenRefreshSub?.cancel();
  }

  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      _logger.w('Firebase is not initialized. Skipping PushNotificationService.initialize()');
      return;
    }

    // 1. Request permissions
    final settings = await _fcm.requestPermission();

    _logger.d(
        'User granted notification permission: ${settings.authorizationStatus}',);

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }

    // 2. Setup Foreground Local Notifications (Heads-up)
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
          NotificationRouter.handleNotificationTap(payload);
        }
      },
    );

    // Create an Android Notification Channel for heads up notifications
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Register Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Listen to foreground messages
    _onMessageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.d('Got a message whilst in the foreground!');

      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 5. Handle app opening from a background state (tapped notification)
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.d('A new onMessageOpenedApp event was published!');
      NotificationRouter.handleNotificationTap(message.data);
    });

    // 6. Handle app opening from a terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _logger.d('App opened from terminated state via notification');
      // Delay routing slightly to ensure GoRouter is fully mounted
      _initialRouteTimer = Timer(const Duration(milliseconds: 500), () {
        NotificationRouter.handleNotificationTap(initialMessage.data);
      });
    }

    // 7. Sync Token to Backend
    await syncToken();

    // Listen for token refreshes
    _tokenRefreshSub = _fcm.onTokenRefresh.listen(_syncTokenToSupabase);
  }

  /// Retrieves the current FCM token and syncs it to the `user_devices` table.
  /// Call this on login.
  Future<void> syncToken() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _syncTokenToSupabase(token);
      }
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
    }
  }

  /// Deletes the FCM token from Supabase.
  /// Call this on logout.
  Future<void> removeToken() async {
    if (Firebase.apps.isEmpty) return;
    try {
      final token = await _fcm.getToken();
      final supabase = _ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;

      if (token != null && user != null) {
        await supabase.from('user_devices').delete().eq('fcm_token', token);
        _logger.d('FCM Token removed from Supabase');
      }

      // Optionally delete the token from the device
      await _fcm.deleteToken();
    } catch (e) {
      _logger.e('Error removing FCM token: $e');
    }
  }

  Future<void> _syncTokenToSupabase(String token) async {
    final supabase = _ref.read(supabaseClientProvider);
    final user = supabase.auth.currentUser;

    if (user == null) return;

    try {
      final deviceInfo = DeviceInfoPlugin();
      final platform = Platform.operatingSystem;
      String? deviceModel;

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceModel = info.model;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceModel = info.utsname.machine;
      }

      await supabase.from('user_devices').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'platform': platform,
        'device_model': deviceModel ?? 'Unknown',
        'last_active_at': DateTime.now().toIso8601String(),
      });
      _logger.d('FCM Token synced to Supabase');
    } catch (e) {
      _logger.e('Error syncing FCM token to Supabase: $e');
    }
  }

  // --- Topic Subscriptions ---

  Future<void> subscribeToTopic(String topic) async {
    if (Firebase.apps.isEmpty) return;
    await _fcm.subscribeToTopic(topic);
    _logger.d('Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (Firebase.apps.isEmpty) return;
    await _fcm.unsubscribeFromTopic(topic);
    _logger.d('Unsubscribed from topic: $topic');
  }
}
