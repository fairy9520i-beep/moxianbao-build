import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/appearance/app_appearance.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_section_title.dart';

/// App 原生外观工坊。
/// 配置只存本地，和 Web 面板的 /neo/ 完全隔离；覆盖背景、卡片、
/// 底部导航栏、字体与主题模式。
class AppWorkshopPage extends ConsumerWidget {
  const AppWorkshopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(appAppearanceProvider);
    final notifier = ref.read(appAppearanceProvider.notifier);
    final surfaces = AppSurfaces.of(context);

    void apply(AppAppearance next) => notifier.update(next);

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
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Text(
            '以下设置只影响本 App 的原生界面，Web 面板和登录页不受影响。',
            style: TextStyle(fontSize: 12, color: surfaces.mutedText),
          ),
          const SizedBox(height: 12),

          const AppSectionTitle('背景', padding: EdgeInsets.only(left: 2)),
          const SizedBox(height: 8),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示背景图'),
              subtitle: Text(
                '关掉就是纯色底',
                style: TextStyle(fontSize: 12, color: surfaces.mutedText),
              ),
              value: appearance.showBackground,
              activeThumbColor: AppColors.primary,
              onChanged: (value) =>
                  apply(appearance.copyWith(showBackground: value)),
            ),
          ),
          const SizedBox(height: 10),
          _SliderTile(
            title: '背景透明度',
            value: appearance.backgroundOpacity,
            min: 0.05,
            max: 1,
            divisions: 95,
            display: '${(appearance.backgroundOpacity * 100).round()}%',
            enabled: appearance.showBackground,
            onChanged: (value) =>
                apply(appearance.copyWith(backgroundOpacity: value)),
          ),
          const SizedBox(height: 10),
          _SliderTile(
            title: '背景模糊',
            value: appearance.backgroundBlur,
            min: 0,
            max: 24,
            divisions: 24,
            display: appearance.backgroundBlur.round().toString(),
            enabled: appearance.showBackground,
            onChanged: (value) =>
                apply(appearance.copyWith(backgroundBlur: value)),
          ),

          const SizedBox(height: 20),
          const AppSectionTitle('卡片', padding: EdgeInsets.only(left: 2)),
          const SizedBox(height: 8),
          _SliderTile(
            title: '卡片透明度',
            value: appearance.cardOpacity,
            min: 0.55,
            max: 1,
            divisions: 45,
            display: '${(appearance.cardOpacity * 100).round()}%',
            onChanged: (value) =>
                apply(appearance.copyWith(cardOpacity: value)),
          ),
          const SizedBox(height: 10),
          _SliderTile(
            title: '卡片圆角',
            value: appearance.cardRadius,
            min: 0,
            max: 32,
            divisions: 32,
            display: appearance.cardRadius.round().toString(),
            onChanged: (value) => apply(appearance.copyWith(cardRadius: value)),
          ),
          const SizedBox(height: 10),
          _SliderTile(
            title: '描边透明度',
            value: appearance.borderOpacity,
            min: 0,
            max: 1,
            divisions: 20,
            display: '${(appearance.borderOpacity * 100).round()}%',
            onChanged: (value) =>
                apply(appearance.copyWith(borderOpacity: value)),
          ),

          const SizedBox(height: 20),
          const AppSectionTitle('底部导航栏', padding: EdgeInsets.only(left: 2)),
          const SizedBox(height: 8),
          _SliderTile(
            title: '栏体透明度',
            value: appearance.navOpacity,
            min: 0.3,
            max: 1,
            divisions: 70,
            display: '${(appearance.navOpacity * 100).round()}%',
            onChanged: (value) => apply(appearance.copyWith(navOpacity: value)),
          ),
          const SizedBox(height: 10),
          _SliderTile(
            title: '背景模糊',
            value: appearance.navBlur,
            min: 0,
            max: 40,
            divisions: 40,
            display: appearance.navBlur.round().toString(),
            onChanged: (value) => apply(appearance.copyWith(navBlur: value)),
          ),
          const SizedBox(height: 10),
          _SliderTile(
            title: '圆角',
            value: appearance.navRadius,
            min: 0,
            max: 32,
            divisions: 32,
            display: appearance.navRadius.round().toString(),
            onChanged: (value) => apply(appearance.copyWith(navRadius: value)),
          ),

          const SizedBox(height: 20),
          const AppSectionTitle('全局', padding: EdgeInsets.only(left: 2)),
          const SizedBox(height: 8),
          _SliderTile(
            title: '字体缩放',
            value: appearance.fontScale,
            min: 0.85,
            max: 1.2,
            divisions: 7,
            display: '${(appearance.fontScale * 100).round()}%',
            onChanged: (value) => apply(appearance.copyWith(fontScale: value)),
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '主题模式',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: surfaces.strongText,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<AppThemeChoice>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemeChoice.system,
                      label: Text('跟随系统'),
                    ),
                    ButtonSegment(
                      value: AppThemeChoice.light,
                      label: Text('浅色'),
                    ),
                    ButtonSegment(
                      value: AppThemeChoice.dark,
                      label: Text('深色'),
                    ),
                  ],
                  selected: {appearance.themeChoice},
                  onSelectionChanged: (selection) => apply(
                    appearance.copyWith(themeChoice: selection.first),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
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
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.display,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = AppSurfaces.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: AppCard(
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
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}