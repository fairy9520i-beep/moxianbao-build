import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_appearance.dart';

/// 原生界面的背景层：背景图 + 透明度 + 模糊。
/// 主题里的 scaffold 背景是透明的，所以卡片之间的空隙会透出这张图。
class AppBackground extends ConsumerWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (appearance.showBackground)
          IgnorePointer(
            child: Opacity(
              opacity: appearance.backgroundOpacity.clamp(0.0, 1.0),
              child: appearance.backgroundBlur > 0
                  ? ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: appearance.backgroundBlur,
                        sigmaY: appearance.backgroundBlur,
                      ),
                      child: Image.asset(
                        'assets/background.jpg',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset('assets/background.jpg', fit: BoxFit.cover),
            ),
          ),
        child,
      ],
    );
  }
}