import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/router/default_landing_page.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../shared/widgets/app_notice.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../widgets/geetest_captcha_dialog.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _needsInit = false;
  bool _needsTotp = false;
  bool _rememberPassword = false;
  bool _autoLogin = false;
  String? _error;
  String? _currentUrl;
  List<PanelConfig> _panels = [];
  PanelConfig? _selectedPanel;

  Future<Map<String, dynamic>?> _prepareCaptchaIfEnabled(
    String username,
  ) async {
    final config = await ref
        .read(authProvider.notifier)
        .captchaConfig(username: username);
    final enabled = config['enabled'] == true;
    if (!enabled) {
      return null;
    }

    final captchaId = config['captcha_id']?.toString().trim() ?? '';
    if (captchaId.isEmpty || config['configured'] == false) {
      throw _LoginFlowMessage(
        config['message']?.toString() ?? '验证码未配置完整，请先在 Web 端检查极验配置',
      );
    }

    if (!mounted) {
      throw const _LoginFlowMessage('登录页面已关闭');
    }
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GeeTestCaptchaDialog(captchaId: captchaId),
    );
    if (result == null) {
      throw _LoginFlowMessage('请先完成滑块验证');
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _initCheck();
  }

  Future<void> _initCheck() async {
    final serverUrl = await SecureStorage.getServerUrl();
    if (serverUrl == null || serverUrl.isEmpty) {
      if (mounted) context.go('/server-config');
      return;
    }
    _currentUrl = serverUrl;
    DioClient.instance.setBaseUrl(serverUrl);

    _panels = await SecureStorage.getPanels();
    _selectedPanel = _panels.where((p) => p.url == serverUrl).firstOrNull;

    if (_selectedPanel != null) {
      _rememberPassword = _selectedPanel!.rememberPassword;
      _autoLogin =
          _selectedPanel!.rememberPassword && _selectedPanel!.autoLogin;
      if (_selectedPanel!.rememberPassword &&
          _selectedPanel!.username != null) {
        _usernameController.text = _selectedPanel!.username!;
        if (_selectedPanel!.password != null) {
          _passwordController.text = _selectedPanel!.password!;
        }
      }
    }

    // 被 AuthInterceptor 踢回登录页时（token 续期失败），把原因显示出来。
    final sessionError = ref.read(authProvider).error;
    if (sessionError != null && sessionError.trim().isNotEmpty) {
      _error = sessionError;
    }

    if (mounted) setState(() {});

    if (ref.read(authProvider).status == AuthStatus.authenticated) {
      if (mounted) {
        // 落到「默认打开页面」（APP #24），没设过就是主页
        context.go(DefaultLandingPage.route);
      }
      return;
    }

    try {
      final auth = ref.read(authProvider.notifier);
      await auth.checkInit();
      final authState = ref.read(authProvider);
      if (mounted) setState(() => _needsInit = authState.needsInit);
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = ref.read(authProvider.notifier);
    final initializing = _needsInit;

    try {
      if (initializing) {
        try {
          await auth.initAdmin(
            _usernameController.text.trim(),
            _passwordController.text,
          );
        } catch (_) {}
        setState(() => _needsInit = false);
      }

      final captcha = initializing
          ? null
          : await _prepareCaptchaIfEnabled(_usernameController.text.trim());
      if (!mounted) {
        return;
      }

      final result = await auth.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        totpCode: _needsTotp ? _totpController.text.trim() : null,
        captcha: captcha,
      );

      if (result['two_factor_required'] == true) {
        setState(() {
          _needsTotp = true;
          _error = result['error']?.toString() ?? '请输入两步验证码';
          _loading = false;
        });
        return;
      }

      if (result['captcha_required'] == true) {
        setState(() {
          _error = result['error']?.toString() ?? '验证码已失效，请重新完成滑块验证';
          _loading = false;
        });
        return;
      }

      // 保存偏好
      if (_currentUrl != null) {
        await SecureStorage.savePanel(
          PanelConfig(
            url: _currentUrl!,
            name: _selectedPanel?.name.isNotEmpty == true
                ? _selectedPanel!.name
                : _currentUrl!,
            username: _rememberPassword
                ? _usernameController.text.trim()
                : null,
            password: _rememberPassword ? _passwordController.text : null,
            rememberPassword: _rememberPassword,
            autoLogin: _rememberPassword && _autoLogin,
          ),
        );
      }

      try {
        ref.invalidate(dashboardProvider);
        await ref.read(dashboardProvider.notifier).load();
      } catch (_) {}

      if (mounted) {
        context.go(DefaultLandingPage.route);
      }
    } catch (e) {
      setState(() {
        _error = e is _LoginFlowMessage
            ? e.message
            : ref.read(authProvider).error ?? '登录失败';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _switchPanel(PanelConfig panel) {
    setState(() {
      _selectedPanel = panel;
      _currentUrl = panel.url;
      _rememberPassword = panel.rememberPassword;
      _autoLogin = panel.rememberPassword && panel.autoLogin;
      if (panel.rememberPassword && panel.username != null) {
        _usernameController.text = panel.username!;
        _passwordController.text = panel.password ?? '';
      } else {
        _usernameController.clear();
        _passwordController.clear();
      }
    });
    DioClient.instance.setBaseUrl(panel.url);
    SecureStorage.saveServerUrl(panel.url);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate950,
      // 登录页固定深色玻璃，不跟系统明暗走：背景图 + 粉紫压层在两种系统主题下
      // 必须是同一个样子，否则「逐字浮现的咒语」会落在白底上。
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          // 深紫 → 品红 → 深墨绿的压层：背景图退到「能看出是她，但不抢字」。
          // 与 Web 端登录页的粉 → 薄荷流动同源。
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.loginBackdrop,
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                child: Image.asset(
                                  'assets/background.jpg',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Spacer(),
                              const Text(
                                '魔仙堡 v9.9.9',
                                style: TextStyle(
                                  fontFamily: 'MoxianMagic',
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                  color: AppColors.onGlassFaint,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 标题用毛笔体逐字浮现 —— 与 Web 端登录页的「咒语」一致。
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: const _MagicTitle('从前有个魔仙堡'),
                          ),
                          const SizedBox(height: 10),
                          if (_needsInit)
                            const Text(
                              '首次使用，请创建管理员账号。',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.onGlassSoft,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            const Text(
                              '有个女王不得了',
                              style: TextStyle(
                                fontFamily: 'MoxianMagic',
                                fontSize: 19,
                                letterSpacing: 2,
                                color: AppColors.onGlassStrong,
                              ),
                            ),
                          const SizedBox(height: 26),

                          // Server selector
                          if (_panels.isNotEmpty && !_needsInit) ...[
                            _FieldLabel('服务器'),
                            const SizedBox(height: 6),
                            _IconInput(
                              icon: Icons.dns_outlined,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _currentUrl,
                                  isExpanded: true,
                                  isDense: false,
                                  dropdownColor: AppColors.slate800,
                                  icon: const Icon(
                                    Icons.expand_more,
                                    size: 20,
                                    color: AppColors.onGlassMuted,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onGlass,
                                  ),
                                  items: _panels.map((p) {
                                    return DropdownMenuItem(
                                      value: p.url,
                                      child: Text(
                                        '${p.name.isNotEmpty ? p.name : "面板"} (${_shortUrl(p.url)})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (url) {
                                    final panel = _panels
                                        .where((p) => p.url == url)
                                        .first;
                                    _switchPanel(panel);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Username
                          _FieldLabel('用户名'),
                          const SizedBox(height: 6),
                          _IconInput(
                            icon: Icons.person_outline,
                            child: TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onGlass,
                              ),
                              cursorColor: AppColors.primary,
                              decoration: const InputDecoration(
                                hintText: 'admin',
                                hintStyle: TextStyle(
                                  color: AppColors.onGlassDim,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty
                                  ? '请输入用户名'
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _FieldLabel('密码'),
                          const SizedBox(height: 6),
                          _IconInput(
                            icon: Icons.lock_outline,
                            suffix: GestureDetector(
                              onTap: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                              child: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: const AppColors.onGlassMuted,
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onGlass,
                              ),
                              cursorColor: AppColors.primary,
                              decoration: const InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  color: AppColors.onGlassDim,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                              textAlignVertical: TextAlignVertical.center,
                              obscureText: _obscurePassword,
                              textInputAction: _needsTotp
                                  ? TextInputAction.next
                                  : TextInputAction.go,
                              onFieldSubmitted: _needsTotp
                                  ? null
                                  : (_) => _submit(),
                              validator: (v) =>
                                  v == null || v.isEmpty ? '请输入密码' : null,
                            ),
                          ),

                          // TOTP
                          if (_needsTotp) ...[
                            const SizedBox(height: 16),
                            _FieldLabel('两步验证码'),
                            const SizedBox(height: 6),
                            _IconInput(
                              icon: Icons.security,
                              suffix: SizedBox(
                                width: 40,
                                child: Text(
                                  '${_totpController.text.trim().length}/6',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onGlassMuted,
                                  ),
                                ),
                              ),
                              child: TextFormField(
                                controller: _totpController,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onGlass,
                                ),
                                cursorColor: AppColors.primary,
                                decoration: const InputDecoration(
                                  hintText: '6位数字验证码',
                                  hintStyle: TextStyle(
                                    color: AppColors.onGlassDim,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                buildCounter:
                                    (
                                      BuildContext context, {
                                      required int currentLength,
                                      required bool isFocused,
                                      required int? maxLength,
                                    }) => null,
                                textInputAction: TextInputAction.go,
                                onChanged: (_) => setState(() {}),
                                onFieldSubmitted: (_) => _submit(),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return '请输入验证码';
                                  }
                                  if (v.trim().length != 6) {
                                    return '验证码为6位数字';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],

                          // Remember + AutoLogin
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _CompactCheck(
                                value: _rememberPassword,
                                label: '记住密码',
                                onChanged: (v) {
                                  setState(() {
                                    _rememberPassword = v;
                                    if (!v) _autoLogin = false;
                                  });
                                },
                              ),
                              const SizedBox(width: 16),
                              _CompactCheck(
                                value: _autoLogin,
                                label: '自动登录',
                                enabled: _rememberPassword,
                                onChanged: (v) =>
                                    setState(() => _autoLogin = v),
                              ),
                            ],
                          ),

                          // Error
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            AppNotice(
                              color: AppColors.danger,
                              text: _error!,
                              accentText: true,
                              textAlign: TextAlign.center,
                            ),
                          ],

                          // Login Button
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                gradient: const LinearGradient(
                                  colors: AppColors.buttonGradient,
                                ),
                              ),
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: AppColors.slate950,
                                  disabledBackgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                  ),
                                ),
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.slate950,
                                        ),
                                      )
                                    : Text(
                                        _needsInit ? '创建并登录' : '连接并登录',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          // Switch panel
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton.icon(
                              onPressed: () =>
                                  context.go('/server-config?manual=1'),
                              icon: const Icon(
                                Icons.swap_horiz,
                                size: 18,
                                color: AppColors.onGlassMuted,
                              ),
                              label: const Text(
                                '管理面板',
                                style: TextStyle(
                                  color: AppColors.onGlassMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortUrl(String url) {
    return url.replaceAll('http://', '').replaceAll('https://', '');
  }
}

class _LoginFlowMessage implements Exception {
  final String message;

  const _LoginFlowMessage(this.message);
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.onGlassStrong,
        ),
      ),
    );
  }
}

class _IconInput extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final Widget? suffix;

  const _IconInput({required this.icon, required this.child, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        // 登录页固定深色玻璃，输入框不再跟随明暗主题取 white / slate900。
        color: const AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const AppColors.fieldBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const AppColors.onGlassMuted),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (suffix != null) ...[const SizedBox(width: 8), suffix!],
        ],
      ),
    );
  }
}

class _CompactCheck extends StatelessWidget {
  final bool value;
  final String label;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _CompactCheck({
    required this.value,
    required this.label,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? const AppColors.onGlassCheck : const AppColors.onGlassDisabled;

    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Checkbox(
              value: value,
              onChanged: enabled ? (v) => onChanged(v ?? false) : null,
              activeColor: AppColors.primary,
              checkColor: AppColors.slate950,
              // 圆角已由 checkboxTheme 统一供给（AppRadius.control，同为 4），
              // 本地覆盖删除，全库勾选框不再各写各的。
              side: const BorderSide(color: AppColors.onGlassDim, width: 1.5),
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    // 无外部投影（与 Web 端一致）：边界只靠 1px 高光描边，避免灰雾感。
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          decoration: BoxDecoration(
            color: const AppColors.glassFill,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const AppColors.glassBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// 逐字浮现的标题：每个字以 0.16s 的间隔从下方「浮」上来，整行套粉→薄荷渐变。
/// 每 9 秒重播一次，与 Web 端登录页的「咒语」节奏一致。
class _MagicTitle extends StatefulWidget {
  final String text;
  const _MagicTitle(this.text);

  @override
  State<_MagicTitle> createState() => _MagicTitleState();
}

class _MagicTitleState extends State<_MagicTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<String> _chars;
  late final List<Animation<double>> _anims;
  Timer? _replay;

  @override
  void initState() {
    super.initState();
    _chars = widget.text.split('');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    final n = _chars.length;
    _anims = [
      for (var i = 0; i < n; i++)
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (i / n) * 0.55,
            ((i / n) * 0.55) + 0.45,
            curve: Curves.easeOutCubic,
          ),
        ),
    ];

    _replay = Timer.periodic(const Duration(seconds: 9), (_) {
      if (!mounted) return;
      _controller
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _replay?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: AppColors.titleGradient,
      ).createShader(rect),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _chars.length; i++)
            AnimatedBuilder(
              animation: _anims[i],
              builder: (context, child) {
                final t = _anims[i].value;
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 14),
                    child: child,
                  ),
                );
              },
              child: Text(
                _chars[i],
                style: const TextStyle(
                  fontFamily: 'MoxianMagic',
                  fontSize: 33,
                  height: 1.2,
                  letterSpacing: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
