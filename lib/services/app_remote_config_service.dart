import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppRemoteConfigService {
  AppRemoteConfigService._();

  static final AppRemoteConfigService instance = AppRemoteConfigService._();

  static const String primaryColorHexKey = 'app_primary_color_hex';
  static const String defaultPrimaryColorHex = '#0AD9D9';

  final ValueNotifier<Color> accentColor = ValueNotifier<Color>(
    const Color(0xFF0AD9D9),
  );

  StreamSubscription<RemoteConfigUpdate>? _updatesSubscription;

  Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 30),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 1)
            : const Duration(hours: 1),
      ),
    );

    await remoteConfig.setDefaults(const {
      primaryColorHexKey: defaultPrimaryColorHex,
    });

    await remoteConfig.fetchAndActivate();
    _applyPrimaryColor(remoteConfig);

    await _updatesSubscription?.cancel();
    _updatesSubscription = remoteConfig.onConfigUpdated.listen((_) async {
      await remoteConfig.activate();
      _applyPrimaryColor(remoteConfig);
    });
  }

  Future<void> refresh() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    _applyPrimaryColor(remoteConfig);
  }

  void dispose() {
    _updatesSubscription?.cancel();
    accentColor.dispose();
  }

  void _applyPrimaryColor(FirebaseRemoteConfig remoteConfig) {
    final raw = remoteConfig.getString(primaryColorHexKey);
    accentColor.value = _parseHexColor(raw) ?? const Color(0xFF0AD9D9);
  }

  Color? _parseHexColor(String value) {
    final normalized = value.replaceAll('#', '').trim();
    if (normalized.length != 6) {
      return null;
    }

    final parsed = int.tryParse('FF$normalized', radix: 16);
    if (parsed == null) {
      return null;
    }

    return Color(parsed);
  }
}
