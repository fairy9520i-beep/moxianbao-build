import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_theme.dart';

/// 外观工坊：直接复用 Web 端的 /neo/ 设置页（背景图、玻璃参数、登录页文案）。
/// App 里不重做一套表单，改完在面板上刷新生效。
class NeoWorkshopPage extends StatefulWidget {
  const NeoWorkshopPage({super.key});

  @override
  State<NeoWorkshopPage> createState() => _NeoWorkshopPageState();
}

class _NeoWorkshopPageState extends State<NeoWorkshopPage> {
  WebViewController? _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final serverUrl = await SecureStorage.getServerUrl();
    if (!mounted) return;
    if (serverUrl == null || serverUrl.trim().isEmpty) {
      setState(() => _error = '还没有配置服务器地址');
      return;
    }

    final base = serverUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.slate950)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (mounted) setState(() => _error = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse('$base/neo/'));

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: AppColors.slate950,
      appBar: AppBar(
        backgroundColor: AppColors.slate950,
        foregroundColor: AppColors.onGlass,
        elevation: 0,
        title: const Text('外观工坊'),
        actions: [
          IconButton(
            onPressed: () => _controller?.reload(),
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
        ],
      ),
      body: controller == null
          ? Center(
              child: Text(
                _error ?? '加载中…',
                style: const TextStyle(color: AppColors.onGlassMuted),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: controller),
                if (_loading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                  ),
              ],
            ),
    );
  }
}