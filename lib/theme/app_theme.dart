import 'package:flutter/material.dart';

// ─── Color Palettes ──────────────────────────────────────────────────────────
// "Blue Business" palette — light, clean fintech/dashboard style.
// Primary Blue #5B7FFF → Deep Blue-Violet #4A5FE8, Mint Green #4CD9A8,
// Soft Lavender #EDEFFF, Charcoal #2E2E3A, Gray #9A9BA8, Coral Pink #FF6B81,
// Sky Blue #4FC3F7.

class AppPalette {
  // Blue Primary
  static const primary50 = Color(0xFFF3F5FF);
  static const primary100 = Color(0xFFE3E8FF);
  static const primary200 = Color(0xFFC7D2FF);
  static const primary300 = Color(0xFFA3B1FF);
  static const primary400 = Color(0xFF7B8CFF);
  static const primary500 = Color(0xFF5B7FFF);
  static const primary600 = Color(0xFF4A5FE8);
  static const primary700 = Color(0xFF3A4BC0);
  static const primary800 = Color(0xFF2E3B99);
  static const primary900 = Color(0xFF232D73);

  // Mint Secondary
  static const teal50 = Color(0xFFEAFBF5);
  static const teal100 = Color(0xFFCDF6E7);
  static const teal200 = Color(0xFF9BEDCE);
  static const teal300 = Color(0xFF6FE4B9);
  static const teal400 = Color(0xFF4CD9A8);
  static const teal500 = Color(0xFF34C795);
  static const teal600 = Color(0xFF22A67D);
  static const teal700 = Color(0xFF1B8566);
  static const teal800 = Color(0xFF166B54);
  static const teal900 = Color(0xFF124F3F);

  // Slate Neutral (charcoal / gray / soft lavender)
  static const slate50 = Color(0xFFF8F9FD);
  static const slate100 = Color(0xFFEDEFFF);
  static const slate200 = Color(0xFFDBDEF0);
  static const slate300 = Color(0xFFC2C4D6);
  static const slate400 = Color(0xFF9A9BA8);
  static const slate500 = Color(0xFF7D7E8C);
  static const slate600 = Color(0xFF5F6070);
  static const slate700 = Color(0xFF454654);
  static const slate800 = Color(0xFF2E2E3A);
  static const slate850 = Color(0xFF23232D);
  static const slate900 = Color(0xFF1A1A22);
  static const slate950 = Color(0xFF12121A);

  // Semantic
  static const success = Color(0xFF4CD9A8);
  static const successLight = Color(0xFFCDF6E7);
  static const successDark = Color(0xFF124F3F);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFF78350F);
  static const error = Color(0xFFFF6B81);
  static const errorLight = Color(0xFFFFE1E6);
  static const errorDark = Color(0xFF7A1F3D);
  static const info = Color(0xFF4FC3F7);
  static const infoLight = Color(0xFFE1F5FE);
  static const infoDark = Color(0xFF1B4B66);

  // Accent
  static const pink = Color(0xFFFF6B81);
  static const purple = Color(0xFF7B8CFF);
  static const orange = Color(0xFFF97316);
  static const amber = Color(0xFFF59E0B);
}

// ─── Backward-compatible AppColors ───────────────────────────────────────────

class AppColors {
  static const background = AppPalette.slate50;
  static const card = Colors.white;
  static const surface = AppPalette.slate100;
  static const surfaceElevated = Colors.white;
  static const primary = AppPalette.primary500;
  static const primaryHover = AppPalette.primary400;
  static const primaryPressed = AppPalette.primary600;
  static const primaryContainer = AppPalette.primary100;
  static const textPrimary = AppPalette.slate800;
  static const textSecondary = AppPalette.slate400;
  static const textDisabled = AppPalette.slate300;
  static const inputBg = Colors.white;
  static const inputBorder = AppPalette.slate200;
  static const success = AppPalette.success;
  static const error = AppPalette.error;
  static const warning = AppPalette.warning;
  static const info = AppPalette.info;
  static const accentPink = AppPalette.pink;
  static const accentTeal = AppPalette.teal400;
  static const accentPurple = AppPalette.purple;
  static const tealDark = AppPalette.teal800;
  static const tealDarkest = AppPalette.teal900;
  static const divider = AppPalette.slate200;
  static const overlay = Color(0x0A000000);

  // Signature hero gradient (Primary Blue → Deep Blue-Violet)
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppPalette.primary500, AppPalette.primary600],
  );

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

// ─── Design Tokens ───────────────────────────────────────────────────────────

class RadiusTokens {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;
}

class SpacingTokens {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

// ─── Theme Extension ─────────────────────────────────────────────────────────

class AppThemeData extends ThemeExtension<AppThemeData> {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color surface;
  final Color onSurface;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurfaceVariant;
  final Color background;
  final Color onBackground;
  final Color outline;
  final Color outlineVariant;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color info;
  final Color infoContainer;
  final Color shadow;

  const AppThemeData({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.surface,
    required this.onSurface,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurfaceVariant,
    required this.background,
    required this.onBackground,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.info,
    required this.infoContainer,
    required this.shadow,
  });

  static const light = AppThemeData(
    primary: AppPalette.primary600,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.primary100,
    onPrimaryContainer: AppPalette.primary900,
    secondary: AppPalette.teal600,
    onSecondary: Colors.white,
    secondaryContainer: AppPalette.teal100,
    onSecondaryContainer: AppPalette.teal900,
    surface: Colors.white,
    onSurface: AppPalette.slate900,
    surfaceContainer: AppPalette.slate50,
    surfaceContainerHigh: AppPalette.slate100,
    surfaceContainerHighest: AppPalette.slate200,
    onSurfaceVariant: AppPalette.slate500,
    background: AppPalette.slate50,
    onBackground: AppPalette.slate900,
    outline: AppPalette.slate200,
    outlineVariant: AppPalette.slate100,
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: AppPalette.errorLight,
    success: AppPalette.success,
    successContainer: AppPalette.successLight,
    warning: AppPalette.warning,
    warningContainer: AppPalette.warningLight,
    info: AppPalette.info,
    infoContainer: AppPalette.infoLight,
    shadow: Color(0x1A000000),
  );

  static const dark = AppThemeData(
    primary: AppPalette.primary400,
    onPrimary: AppPalette.slate900,
    primaryContainer: AppPalette.primary800,
    onPrimaryContainer: AppPalette.primary200,
    secondary: AppPalette.teal400,
    onSecondary: AppPalette.slate900,
    secondaryContainer: AppPalette.teal800,
    onSecondaryContainer: AppPalette.teal200,
    surface: AppPalette.slate900,
    onSurface: AppPalette.slate100,
    surfaceContainer: AppPalette.slate800,
    surfaceContainerHigh: AppPalette.slate850,
    surfaceContainerHighest: AppPalette.slate700,
    onSurfaceVariant: AppPalette.slate400,
    background: AppPalette.slate950,
    onBackground: AppPalette.slate100,
    outline: AppPalette.slate700,
    outlineVariant: AppPalette.slate800,
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: AppPalette.errorDark,
    success: AppPalette.success,
    successContainer: AppPalette.successDark,
    warning: AppPalette.warning,
    warningContainer: AppPalette.warningDark,
    info: AppPalette.info,
    infoContainer: AppPalette.infoDark,
    shadow: Colors.black,
  );

  @override
  ThemeExtension<AppThemeData> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? surface,
    Color? onSurface,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onSurfaceVariant,
    Color? background,
    Color? onBackground,
    Color? outline,
    Color? outlineVariant,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? info,
    Color? infoContainer,
    Color? shadow,
  }) {
    return AppThemeData(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      secondaryContainer: secondaryContainer ?? this.secondaryContainer,
      onSecondaryContainer: onSecondaryContainer ?? this.onSecondaryContainer,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      background: background ?? this.background,
      onBackground: onBackground ?? this.onBackground,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
      error: error ?? this.error,
      onError: onError ?? this.onError,
      errorContainer: errorContainer ?? this.errorContainer,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  ThemeExtension<AppThemeData> lerp(
    covariant ThemeExtension<AppThemeData>? other,
    double t,
  ) {
    if (other is! AppThemeData) return this;
    return AppThemeData(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      secondaryContainer: Color.lerp(
        secondaryContainer,
        other.secondaryContainer,
        t,
      )!,
      onSecondaryContainer: Color.lerp(
        onSecondaryContainer,
        other.onSecondaryContainer,
        t,
      )!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      surfaceContainerHigh: Color.lerp(
        surfaceContainerHigh,
        other.surfaceContainerHigh,
        t,
      )!,
      surfaceContainerHighest: Color.lerp(
        surfaceContainerHighest,
        other.surfaceContainerHighest,
        t,
      )!,
      onSurfaceVariant: Color.lerp(
        onSurfaceVariant,
        other.onSurfaceVariant,
        t,
      )!,
      background: Color.lerp(background, other.background, t)!,
      onBackground: Color.lerp(onBackground, other.onBackground, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineVariant: Color.lerp(outlineVariant, other.outlineVariant, t)!,
      error: Color.lerp(error, other.error, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

// ─── Context Extension ──────────────────────────────────────────────────────

extension AppThemeContext on BuildContext {
  AppThemeData get appTheme =>
      Theme.of(this).extension<AppThemeData>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? AppThemeData.dark
          : AppThemeData.light);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get surface => appTheme.surface;
  Color get surfaceContainer => appTheme.surfaceContainer;
  Color get surfaceContainerHigh => appTheme.surfaceContainerHigh;
  Color get surfaceContainerHighest => appTheme.surfaceContainerHighest;
  Color get onSurface => appTheme.onSurface;
  Color get onSurfaceVariant => appTheme.onSurfaceVariant;
  Color get primary => appTheme.primary;
  Color get secondary => appTheme.secondary;
  Color get outline => appTheme.outline;
  Color get outlineVariant => appTheme.outlineVariant;
  Color get error => appTheme.error;
  Color get success => appTheme.success;
  Color get warning => appTheme.warning;
  Color get info => appTheme.info;
  Color get background => appTheme.background;
}

// ─── Theme Builder ───────────────────────────────────────────────────────────

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final appTheme = isDark ? AppThemeData.dark : AppThemeData.light;

  final colorScheme = isDark
      ? ColorScheme.dark(
          primary: appTheme.primary,
          onPrimary: appTheme.onPrimary,
          primaryContainer: appTheme.primaryContainer,
          onPrimaryContainer: appTheme.onPrimaryContainer,
          secondary: appTheme.secondary,
          onSecondary: appTheme.onSecondary,
          secondaryContainer: appTheme.secondaryContainer,
          onSecondaryContainer: appTheme.onSecondaryContainer,
          surface: appTheme.surface,
          onSurface: appTheme.onSurface,
          surfaceContainerHighest: appTheme.surfaceContainerHighest,
          onSurfaceVariant: appTheme.onSurfaceVariant,
          error: appTheme.error,
          onError: appTheme.onError,
          errorContainer: appTheme.errorContainer,
          onErrorContainer: appTheme.onError,
          outline: appTheme.outline,
          outlineVariant: appTheme.outlineVariant,
          brightness: Brightness.dark,
        )
      : ColorScheme.light(
          primary: appTheme.primary,
          onPrimary: appTheme.onPrimary,
          primaryContainer: appTheme.primaryContainer,
          onPrimaryContainer: appTheme.onPrimaryContainer,
          secondary: appTheme.secondary,
          onSecondary: appTheme.onSecondary,
          secondaryContainer: appTheme.secondaryContainer,
          onSecondaryContainer: appTheme.onSecondaryContainer,
          surface: appTheme.surface,
          onSurface: appTheme.onSurface,
          surfaceContainerHighest: appTheme.surfaceContainerHighest,
          onSurfaceVariant: appTheme.onSurfaceVariant,
          error: appTheme.error,
          onError: appTheme.onError,
          errorContainer: appTheme.errorContainer,
          onErrorContainer: appTheme.onError,
          outline: appTheme.outline,
          outlineVariant: appTheme.outlineVariant,
          brightness: Brightness.light,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    extensions: [appTheme],
    scaffoldBackgroundColor: appTheme.background,
    cardColor: appTheme.surface,
    dividerColor: appTheme.outlineVariant,
    canvasColor: appTheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: appTheme.surface,
      foregroundColor: appTheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: appTheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: appTheme.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: appTheme.onSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: appTheme.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: appTheme.onSurfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.xl),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appTheme.surfaceContainer,
      hintStyle: TextStyle(
        color: appTheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      labelStyle: TextStyle(
        color: appTheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: appTheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: BorderSide(color: appTheme.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: BorderSide(color: appTheme.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: BorderSide(color: appTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: BorderSide(color: appTheme.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: BorderSide(color: appTheme.error, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
      prefixIconColor: appTheme.onSurfaceVariant,
      suffixIconColor: appTheme.onSurfaceVariant,
    ),
    cardTheme: CardThemeData(
      color: appTheme.surface,
      elevation: 0,
      shadowColor: appTheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        side: BorderSide(color: appTheme.outlineVariant, width: 0.5),
      ),
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: appTheme.primary,
        foregroundColor: appTheme.onPrimary,
        disabledBackgroundColor: appTheme.surfaceContainerHighest,
        disabledForegroundColor: appTheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appTheme.primary,
        disabledForegroundColor: appTheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.sm,
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: appTheme.onSurface,
        disabledForegroundColor: appTheme.onSurfaceVariant,
        side: BorderSide(color: appTheme.outline, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg,
          vertical: SpacingTokens.md,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(appTheme.surfaceContainer),
      dataRowColor: WidgetStatePropertyAll(appTheme.surface),
      dataRowMinHeight: 56,
      dataRowMaxHeight: 64,
      headingRowHeight: 48,
      dividerThickness: 0.5,
      headingTextStyle: TextStyle(
        color: appTheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      dataTextStyle: TextStyle(
        color: appTheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return appTheme.primary;
        return appTheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return appTheme.primary.withValues(alpha: 0.3);
        }
        return appTheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (_) => appTheme.outline,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: appTheme.surfaceContainer,
      selectedColor: appTheme.primaryContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      labelStyle: TextStyle(
        color: appTheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      brightness: brightness,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.full),
        side: BorderSide(color: appTheme.outline),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: appTheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: BorderSide(color: appTheme.outlineVariant),
      ),
      elevation: 8,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.3)
          : Colors.black.withValues(alpha: 0.15),
      textStyle: TextStyle(
        color: appTheme.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: appTheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
        side: BorderSide(color: appTheme.outlineVariant),
      ),
      elevation: 16,
      titleTextStyle: TextStyle(
        color: appTheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      contentTextStyle: TextStyle(
        color: appTheme.onSurfaceVariant,
        fontSize: 14,
        height: 1.5,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: appTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(RadiusTokens.xs),
        border: Border.all(color: appTheme.outlineVariant),
      ),
      textStyle: TextStyle(
        color: appTheme.onSurface,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: appTheme.primary,
      linearTrackColor: appTheme.surfaceContainerHighest,
      circularTrackColor: appTheme.surfaceContainerHighest,
    ),
    dividerTheme: const DividerThemeData(thickness: 0.5, space: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: appTheme.surface,
      indicatorColor: appTheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected)
              ? appTheme.primary
              : appTheme.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? appTheme.primary
              : appTheme.onSurfaceVariant,
          size: 22,
        );
      }),
    ),
  );
}