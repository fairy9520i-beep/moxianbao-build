import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appearance/app_appearance.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/app_card.dart';

/// App 原生外观工坊：背景图、背景透明度、模糊、卡片透明度。
/// 配置存在本地，和 Web 面板的 /neo/ 完全隔离。
class AppWorkshopPage extends ConsumerWidget {
  const AppWorkshopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);
    final notifier = ref.read(appAppearanceProvider.notifier);
    final surfaces = AppSurfaces.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('外观工坊'),
        actions: [
          TextButton(
            onPressed: () => notifier.reset(),
            child: const Text('恢复默认'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            '这几项只影响本 App 的原生界面，Web 面板和登录页不受影响。',
            style: TextStyle(fontSize: 12, color: surfaces.mutedText),
          ),
          const SizedBox(height: 16),

          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示背景图'),
              subtitle: Text(
                '关掉就是纯色底',
                style: TextStyle(fontSize: 12, color: surfaces.mutedText),
              ),
              value: appearance.showBackground,
              activeThumbColor: AppColors.primary,
              onChanged: (value) => notifier.update(
                appearance.copyWith(showBackground: value),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _SliderTile(
            title: '背景透明度',
            value: appearance.backgroundOpacity,
            min: 0.05,
            max: 1,
            divisions: 95,
            display: '${(appearance.backgroundOpacity * 100).round()}%',
            onChanged: (value) => notifier.update(
              appearance.copyWith(backgroundOpacity: value),
            ),
          ),
          const SizedBox(height: 12),

          _SliderTile(
            title: '背景模糊',
            value: appearance.backgroundBlur,
            min: 0,
            max: 24,
            divisions: 24,
            display: appearance.backgroundBlur.round().toString(),
            onChanged: (value) => notifier.update(
              appearance.copyWith(backgroundBlur: value),
            ),
          ),
          const SizedBox(height: 12),

          _SliderTile(
            title: '卡片透明度',
            value: appearance.cardOpacity,
            min: 0.55,
            max: 1,
            divisions: 45,
            display: '${(appearance.cardOpacity * 100).round()}%',
            onChanged: (value) => notifier.update(
              appearance.copyWith(cardOpacity: value),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            '提示：卡片太透会影响文字对比度，建议不低于 75%。',
            style: TextStyle(fontSize: 12, color: surfaces.mutedText),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String display;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = AppSurfaces.of(context);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: surfaces.strongText,
                  ),
                ),
              ),
              Text(
                display,
                style: TextStyle(fontSize: 12, color: surfaces.mutedText),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}