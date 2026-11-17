import 'dart:convert';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题模式选择。
enum AppThemeChoice { system, light, dark }

/// App 自己的外观配置：只影响原生界面，和 Web 面板的 /neo/ 配置完全隔离。
class AppAppearance {
  // 背景
  final bool showBackground;
  final double backgroundOpacity;
  final double backgroundBlur;

  // 卡片
  final double cardOpacity;
  final double cardRadius;
  final double borderOpacity;

  // 底部导航
  final double navOpacity;
  final double navBlur;
  final double navRadius;
  final bool navFloating;

  // 全局
  final double fontScale;
  final AppThemeChoice themeChoice;

  const AppAppearance({
    this.showBackground = true,
    this.backgroundOpacity = 0.28,
    this.backgroundBlur = 6,
    this.cardOpacity = 1,
    this.cardRadius = 14,
    this.borderOpacity = 1,
    this.navOpacity = 0.9,
    this.navBlur = 20,
    this.navRadius = 0,
    this.navFloating = false,
    this.fontScale = 1,
    this.themeChoice = AppThemeChoice.system,
  });

  ThemeMode get themeMode => switch (themeChoice) {
    AppThemeChoice.system => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark => ThemeMode.dark,
  };

  AppAppearance copyWith({
    bool? showBackground,
    double? backgroundOpacity,
    double? backgroundBlur,
    double? cardOpacity,
    double? cardRadius,
    double? borderOpacity,
    double? navOpacity,
    double? navBlur,
    double? navRadius,
    bool? navFloating,
    double? fontScale,
    AppThemeChoice? themeChoice,
  }) {
    return AppAppearance(
      showBackground: showBackground ?? this.showBackground,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      cardRadius: cardRadius ?? this.cardRadius,
      borderOpacity: borderOpacity ?? this.borderOpacity,
      navOpacity: navOpacity ?? this.navOpacity,
      navBlur: navBlur ?? this.navBlur,
      navRadius: navRadius ?? this.navRadius,
      navFloating: navFloating ?? this.navFloating,
      fontScale: fontScale ?? this.fontScale,
      themeChoice: themeChoice ?? this.themeChoice,
    );
  }

  Map<String, dynamic> toJson() => {
    'showBackground': showBackground,
    'backgroundOpacity': backgroundOpacity,
    'backgroundBlur': backgroundBlur,
    'cardOpacity': cardOpacity,
    'cardRadius': cardRadius,
    'borderOpacity': borderOpacity,
    'navOpacity': navOpacity,
    'navBlur': navBlur,
    'navRadius': navRadius,
    'navFloating': navFloating,
    'fontScale': fontScale,
    'themeChoice': themeChoice.name,
  };

  factory AppAppearance.fromJson(Map<String, dynamic> json) {
    double read(String key, double fallback) {
      final value = json[key];
      return value is num ? value.toDouble() : fallback;
    }

    bool readBool(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;

    final choice = AppThemeChoice.values.firstWhere(
      (item) => item.name == json['themeChoice'],
      orElse: () => AppThemeChoice.system,
    );

    return AppAppearance(
      showBackground: readBool('showBackground', true),
      backgroundOpacity: read('backgroundOpacity', 0.28).clamp(0.0, 1.0),
      backgroundBlur: read('backgroundBlur', 6).clamp(0.0, 24.0),
      cardOpacity: read('cardOpacity', 1).clamp(0.5, 1.0),
      cardRadius: read('cardRadius', 14).clamp(0.0, 32.0),
      borderOpacity: read('borderOpacity', 1).clamp(0.0, 1.0),
      navOpacity: read('navOpacity', 0.9).clamp(0.3, 1.0),
      navBlur: read('navBlur', 20).clamp(0.0, 40.0),
      navRadius: read('navRadius', 0).clamp(0.0, 32.0),
      navFloating: readBool('navFloating', false),
      fontScale: read('fontScale', 1).clamp(0.85, 1.2),
      themeChoice: choice,
    );
  }
}

class AppAppearanceNotifier extends StateNotifier<AppAppearance> {
  AppAppearanceNotifier() : super(const AppAppearance()) {
    _load();
  }

  static const _key = 'app_appearance_v2';

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