import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/auth/auth_provider.dart';
import '../../../core/router/default_landing_page.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/app_snack.dart';

/// 登录页直接复用 Web 面板的登录界面（外观工坊那套粉紫玻璃），
/// 原生这边只做一件事：把 Web 里拿到的 token 存下来，然后进主界面。
///
/// 为什么不用原生登录页：面板的登录链路里还有滑块验证、两步验证、
/// 登录失败计数等一整套逻辑，原生重写一遍等于把后端契约再抄一次，
/// 而 Web 那套已经在真机上验证过能登进去。
class LoginWebPage extends ConsumerStatefulWidget {
  const LoginWebPage({super.key});

  @override
  ConsumerState<LoginWebPage> createState() => _LoginWebPageState();
}

class _LoginWebPageState extends ConsumerState<LoginWebPage> {
  WebViewController? _controller;
  bool _loading = true;
  bool _handling = false;
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
      context.go('/server-config?manual=1');
      return;
    }

    final base = serverUrl.trim().replaceAll(RegExp(r'/+$'), '');
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.slate950)
      ..addJavaScriptChannel('NeoAuth', onMessageReceived: _onMessage)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
            _watchToken();
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _error = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse('$base/login'));

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  /// SPA 登录成功后是前端路由跳转，不会触发 onPageFinished，
  /// 所以用定时器盯着 localStorage 里的 token。
  Future<void> _watchToken() async {
    final controller = _controller;
    if (controller == null) return;
    try {
      await controller.runJavaScript('''
(function () {
  if (window.__neoAuthBound) return;
  window.__neoAuthBound = true;
  var last = '';
  function send() {
    try {
      var a = localStorage.getItem('access_token');
      var r = localStorage.getItem('refresh_token');
      if (!a) return;
      var key = a + '|' + (r || '');
      if (key === last) return;
      last = key;
      NeoAuth.postMessage(JSON.stringify({ access: a, refresh: r || '' }));
    } catch (e) {}
  }
  setInterval(send, 1200);
  setTimeout(send, 400);
})();
''');
    } catch (_) {}
  }

  Future<void> _onMessage(JavaScriptMessage message) async {
    if (_handling) return;
    Map<String, dynamic>? data;
    try {
      data = jsonDecode(message.message) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final access = (data['access'] ?? '').toString();
    if (access.isEmpty) return;

    _handling = true;
    final refresh = (data['refresh'] ?? '').toString();
    await SecureStorage.saveTokens(accessToken: access, refreshToken: refresh);
    await ref.read(authProvider.notifier).checkAuthStatus();
    if (!mounted) return;

    if (ref.read(authProvider).status == AuthStatus.authenticated) {
      context.go(DefaultLandingPage.route);
    } else {
      _handling = false;
      AppSnack.error(context, '登录状态校验失败，请重试');
    }
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
        title: const Text('登录魔仙堡'),
        actions: [
          IconButton(
            onPressed: () => _controller?.reload(),
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
          ),
          IconButton(
            onPressed: () => context.go('/server-config?manual=1'),
            icon: const Icon(Icons.dns_outlined),
            tooltip: '切换服务器',
          ),
        ],
      ),
      body: controller == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
              children: [
                WebViewWidget(controller: controller),
                if (_loading)
                  const LinearProgressIndicator(
                    minHeight: 2,
                    color: AppColors.primary,
                  ),
                if (_error != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: Material(
                      color: AppColors.slate800,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.onGlassStrong,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}