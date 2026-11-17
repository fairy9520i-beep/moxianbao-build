import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App 自己的外观配置：只影响原生界面，和 Web 面板的 /neo/ 配置完全隔离。
class AppAppearance {
  /// 是否在页面底层铺背景图。
  final bool showBackground;

  /// 背景图透明度（0~1），越小越淡。
  final double backgroundOpacity;

  /// 背景图模糊半径（0~24）。
  final double backgroundBlur;

  /// 卡片底色不透明度（0.5~1），越小越透。
  final double cardOpacity;

  const AppAppearance({
    this.showBackground = true,
    this.backgroundOpacity = 0.28,
    this.backgroundBlur = 6,
    this.cardOpacity = 1,
  });

  AppAppearance copyWith({
    bool? showBackground,
    double? backgroundOpacity,
    double? backgroundBlur,
    double? cardOpacity,
  }) {
    return AppAppearance(
      showBackground: showBackground ?? this.showBackground,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      cardOpacity: cardOpacity ?? this.cardOpacity,
    );
  }

  Map<String, dynamic> toJson() => {
    'showBackground': showBackground,
    'backgroundOpacity': backgroundOpacity,
    'backgroundBlur': backgroundBlur,
    'cardOpacity': cardOpacity,
  };

  factory AppAppearance.fromJson(Map<String, dynamic> json) {
    double read(String key, double fallback) {
      final value = json[key];
      return value is num ? value.toDouble() : fallback;
    }

    return AppAppearance(
      showBackground: json['showBackground'] is bool
          ? json['showBackground'] as bool
          : true,
      backgroundOpacity: read('backgroundOpacity', 0.28).clamp(0.0, 1.0),
      backgroundBlur: read('backgroundBlur', 6).clamp(0.0, 24.0),
      cardOpacity: read('cardOpacity', 1).clamp(0.5, 1.0),
    );
  }
}

class AppAppearanceNotifier extends StateNotifier<AppAppearance> {
  AppAppearanceNotifier() : super(const AppAppearance()) {
    _load();
  }

  static const _key = 'app_appearance_v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        state = AppAppearance.fromJson(decoded);
      }
    } catch (_) {
      // 配置坏了就用默认值，不影响启动。
    }
  }

  Future<void> update(AppAppearance next) async {
    state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(next.toJson()));
    } catch (_) {}
  }

  Future<void> reset() => update(const AppAppearance());
}

final appAppearanceProvider =
    StateNotifierProvider<AppAppearanceNotifier, AppAppearance>(
      (ref) => AppAppearanceNotifier(),
    );