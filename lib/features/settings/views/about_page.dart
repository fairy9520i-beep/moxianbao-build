import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// 关于页：只留一个标题和版本号。
///
/// 彩蛋：连续点三下显示「外观工坊」入口，连点四下隐藏。
/// 这样工坊就不必在设置列表里常驻（用户要求隐藏入口）。
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  static const _tapWindow = Duration(milliseconds: 900);

  int _taps = 0;
  DateTime? _lastTap;
  bool _showWorkshop = false;

  void _onTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) > _tapWindow) {
      _taps = 0;
    }
    _lastTap = now;
    _taps += 1;

    if (_taps >= 4) {
      setState(() => _showWorkshop = false);
      _taps = 0;
      return;
    }
    if (_taps == 3) {
      setState(() => _showWorkshop = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '魔仙堡',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'v9.9.9',
                style: TextStyle(fontSize: 12, color: AppColors.slate500),
              ),
              if (_showWorkshop) ...[
                const SizedBox(height: 32),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/neo-workshop'),
                  icon: const Icon(Icons.palette_outlined, size: 18),
                  label: const Text('外观工坊'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}