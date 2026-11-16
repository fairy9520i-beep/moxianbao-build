import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// 设计系统色板 — 魔仙堡（粉紫 × 薄荷玻璃拟态）
class AppColors {
  // Primary
  // 与豆瓣「魔仙堡」主题的玻璃界面同源：主色是魔仙粉，辅色是薄荷。
  // 浅/深变体沿用 Element Plus 的 light-9 / dark-2 配方（与主题色同源派生），
  // 保证徽章、状态点、按钮的派生色不会分裂成第二套粉。
  static const primary = Color(0xFFFF7AB6); // 魔仙粉
  static const primaryLight = Color(0xFFFFF1F7); // light-9
  static const primaryDark = Color(0xFFCC6192); // dark-2（≈ primary × 0.8）

  /// 薄荷辅色：渐变收尾、次要强调、登录页流光。
  static const mint = Color(0xFF5EEAD4);
  static const mintDark = Color(0xFF4BBBAA);

  // 紫灰体系（原 Slate）。色相统一压到 280°，明度梯度与 Tailwind Slate 对齐，
  // 这样原本按 slateX 写的深浅层次原封不动，只是整体从蓝灰变成了紫灰。
  static const slate50 = Color(0xFFFAF7FB);
  static const slate100 = Color(0xFFF4EFF7);
  static const slate200 = Color(0xFFE8DFEF);
  static const slate300 = Color(0xFFD4C6E0);
  static const slate400 = Color(0xFFAE9CC0);
  static const slate500 = Color(0xFF8C789E);
  static const slate600 = Color(0xFF6F5C80);
  static const slate700 = Color(0xFF4E4060);
  static const slate800 = Color(0xFF2A1F38);
  static const slate900 = Color(0xFF140D1E);
  static const slate950 = Color(0xFF0A0611);

  // ── 登录页玻璃（固定深色，不随系统明暗切换）─────────────
  //
  // 登录页是唯一「背景图 + 毛玻璃」的页面：它不跟 ThemeMode 走，
  // 所以这些半透明白与渐变色既不能挂在 ColorScheme 上，也不该散落在页面里。
  // 全部收在这里，改一处就能整体调浓淡。
  static const glassFill = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x2EFFFFFF);
  static const fieldFill = Color(0x1AFFFFFF);
  static const fieldBorder = Color(0x33FFFFFF);

  static const onGlass = Color(0xFFFFFFFF);
  static const onGlassCheck = Color(0xCCFFFFFF);
  static const onGlassStrong = Color(0xB3FFFFFF);
  static const onGlassSoft = Color(0xA6FFFFFF);
  static const onGlassMuted = Color(0x99FFFFFF);
  static const onGlassFaint = Color(0x8CFFFFFF);
  static const onGlassDim = Color(0x66FFFFFF);
  static const onGlassDisabled = Color(0x59FFFFFF);

  /// 背景图压层：深紫 → 品红 → 深墨绿。
  static const loginBackdrop = [
    Color(0xC80A0611),
    Color(0x962A0B2E),
    Color(0xC006110F),
  ];

  /// 标题的粉 → 薄荷渐变。
  static const titleGradient = [
    Color(0xFFFFC9E0),
    Color(0xFFFF7AB6),
    Color(0xFF5EEAD4),
  ];

  /// 主按钮的粉 → 紫 → 薄荷渐变。
  static const buttonGradient = [
    Color(0xFFFFA8CE),
    Color(0xFFC47BE8),
    Color(0xFF6FE3D4),
  ];

  /// 启动页渐变（与登录页同源，避免白色闪屏）。
  static const bootGradient = [Color(0xFF2A0B2E), Color(0xFF0A0611)];

  // 功能色
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue100 = Color(0xFFDBEAFE);
  static const purple500 = Color(0xFF8B5CF6);
  static const purple600 = Color(0xFF7C3AED);
  static const purple100 = Color(0xFFEDE9FE);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red100 = Color(0xFFFEE2E2);
  static const red50 = Color(0xFFFEF2F2);
  static const amber500 = Color(0xFFF59E0B);

  // ── 语义状态色 ────────────────────────────────────────
  // 主色从 Emerald 绿换成 Element Plus 蓝之后，「成功 / 已启用」不能再借用 primary
  // 表达，否则与「运行中 / 进行中」的蓝完全同色。这里给四态各自的专属色，
  // 页面只引用这些语义名，不再直接挑 primary / blue500 当状态色。
  //
  // 绿色取面板 Element Plus 的 --el-color-success 全家桶，与主色同源；
  // warning / danger 复用已有的 amber / red，只建立语义别名，避免无谓的视觉变动。

  /// 成功 / 已启用 / 已安装。用作状态圆点与深色模式前景。
  static const success = Color(0xFF67C23A); // el-color-success

  /// 浅色模式下的成功前景（徽章文字）。
  static const successDark = Color(0xFF529B2E); // el success-dark-2

  /// 浅色模式下的成功淡底（徽章背景）。
  static const successLight = Color(0xFFF0F9EB); // el success-light-9

  /// 运行中 / 进行中 / 信息。蓝色语义就是主色语义，直接等同 primary。
  static const info = primary;
  static const infoDark = primaryDark;
  static const infoLight = primaryLight;

  /// 失败 / 危险。沿用既有 red，只给语义名。
  static const danger = red500;
  static const dangerDark = red600;
  static const dangerLight = red100;

  /// 排队中 / 警告。沿用既有 amber，只给语义名。
  static const warning = amber500;

  /// 已禁用 / 已取消等中性态前景。
  static const neutral = slate500;

  // ── 代码编辑器 ────────────────────────────────────────
  //
  // 取值全部对齐面板 Web 的 CodeMirror 主题（web/src/utils/codeEditor.ts），
  // 两端观感才是同一个产品。
  //
  // ⚠️ 这里的黄是 `#EAB308`（Tailwind yellow-500），**不是** [amber500] 的
  // `#F59E0B`（Tailwind amber-500）。它们不是同一个黄，别顺手复用 amber500。

  /// 搜索命中：全部命中的弱高亮底色（= `rgba(234,179,8,0.35)`）。
  static const searchMatch = Color(0x59EAB308);

  /// 搜索命中：当前那一个的强高亮底色（= `rgba(234,179,8,0.6)`）。
  static const searchMatchCurrent = Color(0x99EAB308);

  /// 行号栏文字，**深底**时用（面板 Web gutter 深色 `#6b7280`）。
  ///
  /// 选深色还是浅色看的是**编辑器底色**而不是 App 主题：editor_background_color
  /// 是用户在面板里自定义的，深色模式配浅底、浅色模式配深底都合法。
  static const editorGutterOnDark = Color(0xFF6B7280);

  /// 行号栏文字，**浅底**时用。取值与面板 Web gutter 浅色 `#94a3b8` 完全一致。
  static const editorGutterOnLight = slate400;

  // 日志终端
  //
  // 面板的 log_background_color 出厂默认是空串，注册说明写的是「留空跟随当前主题」
  // （server/model/system_config_registry.go）。所以这两个值是「面板没配色时」的兜底，
  // 取值直接对齐面板 Web 的 DEFAULT_LOG_BACKGROUND_COLOR_LIGHT/DARK
  // （web/src/utils/panelAppearance.ts），两端观感才是同一个产品。
  //
  // 别再写回 Colors.white / 纯黑：旧版只有一个恒定白底的 termBg，深色模式下日志就是刺眼的白，
  // 这正是 issue #2 的根因。
  static const termBgLight = Color(0xFFF8FAFC); // = slate50
  static const termBgDark = Color(0xFF0F172A); // = slate900
  static const termText = Color(0xFF0F172A); // slate-900
  static const termBlue = Color(0xFF60A5FA); // blue-400
  static const termGreen = Color(0xFF34D399); // emerald-400
  static const termRed = Color(0xFFF87171); // red-400
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.slate950,
      secondary: AppColors.mint,
      surface: AppColors.slate50,
      onSurface: AppColors.slate900,
      onSurfaceVariant: AppColors.slate500,
      outline: AppColors.slate200,
      outlineVariant: AppColors.slate100,
      error: AppColors.red500,
      surfaceContainerHighest: AppColors.slate100,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.slate950,
      secondary: AppColors.mint,
      surface: AppColors.slate950,
      onSurface: AppColors.slate50,
      onSurfaceVariant: AppColors.slate400,
      outline: AppColors.slate800,
      outlineVariant: AppColors.slate800,
      error: AppColors.red500,
      surfaceContainerHighest: AppColors.slate900,
    );
    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme cs) {
    final isLight = cs.brightness == Brightness.light;
    final cardColor = isLight ? Colors.white : AppColors.slate900;
    final borderColor = isLight ? AppColors.slate200 : AppColors.slate800;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          // 区块级大卡片，与 AppCard 同档 —— 全库只有 6 处走 Flutter Card，
          // 其中 3 处是 backup_page 的整页结构面板，这一档在那一页上是看得见的。
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: borderColor, width: 1),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      // ⚠️ 下面 border / enabledBorder / focusedBorder 三处圆角**必须同值**。
      // 聚焦是三个 border 之间的插值动画，任何一处不一致都会让动画中途出现
      // 角忽大忽小的抖动 —— 静态截图看不出来，只有点进输入框的那一瞬间才有。
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: isLight ? AppColors.slate300 : AppColors.slate600,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.slate950,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          side: BorderSide(color: borderColor),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : isLight
              ? AppColors.slate300
              : AppColors.slate700;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.transparent
              : isLight
              ? AppColors.slate400
              : AppColors.slate600;
        }),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 0,
      ),
      // 零像素变化：Chip 默认高 32，圆角在绘制时会被 clamp 到高的一半（16），
      // 原先写的 20 从来没有生效过 —— 它渲染出来本来就是胶囊，这里只是把
      // 「实际是什么」写成「代码里说的是什么」。
      chipTheme: const ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.pill)),
        ),
      ),
      // Checkbox 走**控件**档，不跟表面档一起收缩，理由见 AppRadius.control。
      // 这一处同时收编两类站点：2 处本地写死 4 的（login / log_list）与
      // 7 处走 Material 默认约 2dp 的，改完 9 个勾选框第一次是同一个圆角。
      checkboxTheme: const CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.control)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        // 扁平化：去掉 M3 给弹出菜单的默认投影，改由 1px 边框做唯一分隔物。
        // 菜单浮在页面之上、没有遮罩，去掉投影后必须补边框，否则与下方内容糊在一起。
        // 这一处一次覆盖全库 7 个 PopupMenuButton。
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: borderColor),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        // 弹窗与底部面板同为「浮在页面上的容器」，统一走 lg，不再一个 20 一个 20
        // 却各写各的。
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      ),
    );
  }

  // 原先这里有一组 successColor / errorColor / warningColor / runningColor /
  // disabledColor 常量，全库零引用，且主色换蓝之后 successColor 与 runningColor
  // 双双等于 AppColors.primary —— 一组既没人用、语义又是错的假常量。
  // 已删除，状态色统一由 AppColors.success / info / danger / warning / neutral 提供，
  // 并在各状态判断处真正使用。
}
