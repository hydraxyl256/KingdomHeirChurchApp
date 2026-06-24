import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kingdom_heir/core/di/providers.dart';
import 'package:logger/logger.dart';

final presenceServiceProvider = Provider<PresenceService>((ref) {
  return PresenceService(ref);
});

class PresenceService with WidgetsBindingObserver {
  PresenceService(this._ref);

  final Ref _ref;
  Timer? _heartbeatTimer;
  final _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    _startHeartbeat();
  }

  void dispose() {
    _stopHeartbeat();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _startHeartbeat() {
    _pingPresence(true); // Ping immediately
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _pingPresence(true);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _pingPresence(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startHeartbeat();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopHeartbeat();
    }
  }

  Future<void> _pingPresence(bool isOnline) async {
    try {
      final supabase = _ref.read(supabaseClientProvider);
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final platform = Platform.operatingSystem;
      String? deviceModel;

      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceModel = info.model;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceModel = info.utsname.machine;
      }

      await supabase.from('user_presence').upsert(
        {
          'user_id': user.id,
          'is_online': isOnline,
          'last_seen': DateTime.now().toIso8601String(),
          'device_type': deviceModel ?? 'Unknown',
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict:
            'user_id', // UPDATE existing row instead of failing on duplicate
      );
    } catch (e) {
      _logger.d('Failed to update presence: $e');
    }
  }
}
