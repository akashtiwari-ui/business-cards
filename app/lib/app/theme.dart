import 'package:flutter/material.dart';

/// Palette from COLOR-Combination.md.
abstract final class AppColors {
  static const bBlue = Color(0xFF0B5FFF);
  static const midnightNavy = Color(0xFF0A1F44);
  static const skyTint = Color(0xFFE8F0FF);
  static const cloud = Color(0xFFF7F8FB);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF101828);
  static const slate = Color(0xFF667085);
  static const mist = Color(0xFFE4E7EC);
  static const green = Color(0xFF12B76A);
  static const greenTint = Color(0xFFE7F8EF);
  static const mint = Color(0xFF16A34A);
  static const mintTint = Color(0xFFE6F6EA);
  static const amber = Color(0xFFF79009);
  static const amberTint = Color(0xFFFFF1DB);
  static const red = Color(0xFFD92D20);

  // Dark mode
  static const darkBackground = Color(0xFF0B1220);
  static const darkSurface = Color(0xFF151C2C);
  static const darkPrimary = Color(0xFF5B93FF);
  static const darkText = Color(0xFFF2F4F7);

  /// Avatar pastels; text on them is always [ink].
  static const avatarPastels = [
    Color(0xFFFAD1E6), // pink
    Color(0xFFFDEFB2), // yellow
    Color(0xFFE1DBFF), // lavender
    Color(0xFFCDEFD9), // mint
  ];

  /// Stable pastel per name, so a person keeps their colour everywhere.
  static Color avatarFor(String name) {
    var hash = 0;
    for (final unit in name.trim().toLowerCase().codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return avatarPastels[hash % avatarPastels.length];
  }
}

abstract final class AppFonts {
  static const body = 'Inter';
  static const display = 'PlusJakartaSans';
}

/// Semantic colours Material's ColorScheme has no slot for.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.success,
    required this.successContainer,
    required this.partner,
    required this.partnerContainer,
    required this.warning,
    required this.warningContainer,
    required this.brandCard,
    required this.onBrandCard,
    required this.onBrandCardMuted,
  });

  final Color success;
  final Color successContainer;
  final Color partner;
  final Color partnerContainer;
  final Color warning;
  final Color warningContainer;

  /// Midnight Navy surface for the digital card and profile header.
  final Color brandCard;
  final Color onBrandCard;
  final Color onBrandCardMuted;

  static const light = StatusColors(
    success: AppColors.green,
    successContainer: AppColors.greenTint,
    partner: AppColors.mint,
    partnerContainer: AppColors.mintTint,
    warning: Color(0xFFB54708), // amber text darkened to pass AA on its tint
    warningContainer: AppColors.amberTint,
    brandCard: AppColors.midnightNavy,
    onBrandCard: AppColors.white,
    onBrandCardMuted: Color(0xFFB8C4DA),
  );

  static const dark = StatusColors(
    success: Color(0xFF47CD89),
    successContainer: Color(0xFF0E3B27),
    partner: Color(0xFF4ADE80),
    partnerContainer: Color(0xFF103A20),
    warning: Color(0xFFFDB022),
    warningContainer: Color(0xFF3D2A0A),
    brandCard: AppColors.midnightNavy,
    onBrandCard: AppColors.white,
    onBrandCardMuted: Color(0xFFB8C4DA),
  );

  static StatusColors of(BuildContext context) => Theme.of(context).extension<StatusColors>()!;

  @override
  StatusColors copyWith() => this;

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      partner: Color.lerp(partner, other.partner, t)!,
      partnerContainer: Color.lerp(partnerContainer, other.partnerContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      brandCard: Color.lerp(brandCard, other.brandCard, t)!,
      onBrandCard: Color.lerp(onBrandCard, other.onBrandCard, t)!,
      onBrandCardMuted: Color.lerp(onBrandCardMuted, other.onBrandCardMuted, t)!,
    );
  }
}

abstract final class AppTheme {
  static ThemeData get light => _build(
        ColorScheme.fromSeed(seedColor: AppColors.bBlue).copyWith(
          primary: AppColors.bBlue,
          onPrimary: AppColors.white,
          primaryContainer: AppColors.skyTint,
          onPrimaryContainer: AppColors.bBlue,
          secondaryContainer: AppColors.skyTint,
          onSecondaryContainer: AppColors.bBlue,
          tertiary: AppColors.midnightNavy,
          onTertiary: AppColors.white,
          surface: AppColors.white,
          onSurface: AppColors.ink,
          onSurfaceVariant: AppColors.slate,
          surfaceContainerLowest: AppColors.white,
          surfaceContainerLow: AppColors.cloud,
          surfaceContainer: AppColors.cloud,
          surfaceContainerHigh: AppColors.skyTint,
          surfaceContainerHighest: AppColors.mist,
          outline: AppColors.mist,
          outlineVariant: AppColors.mist,
          error: AppColors.red,
          onError: AppColors.white,
          errorContainer: const Color(0xFFFEE4E2),
          onErrorContainer: const Color(0xFF912018),
        ),
        background: AppColors.cloud,
        status: StatusColors.light,
      );

  static ThemeData get dark => _build(
        ColorScheme.fromSeed(seedColor: AppColors.bBlue, brightness: Brightness.dark).copyWith(
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkBackground,
          primaryContainer: const Color(0xFF1A2B4D),
          onPrimaryContainer: AppColors.darkText,
          secondaryContainer: const Color(0xFF1A2B4D),
          onSecondaryContainer: AppColors.darkText,
          tertiary: AppColors.midnightNavy,
          onTertiary: AppColors.white,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          onSurfaceVariant: const Color(0xFF98A2B3),
          surfaceContainerLowest: AppColors.darkBackground,
          surfaceContainerLow: AppColors.darkBackground,
          surfaceContainer: AppColors.darkSurface,
          surfaceContainerHigh: const Color(0xFF1D2639),
          surfaceContainerHighest: const Color(0xFF263045),
          outline: const Color(0xFF2B3548),
          outlineVariant: const Color(0xFF2B3548),
          error: const Color(0xFFF97066),
          onError: AppColors.darkBackground,
          errorContainer: const Color(0xFF55160C),
          onErrorContainer: const Color(0xFFFECDCA),
        ),
        background: AppColors.darkBackground,
        status: StatusColors.dark,
      );

  static ThemeData _build(ColorScheme scheme, {required Color background, required StatusColors status}) {
    // Type scale from COLOR-Combination.md: Inter everywhere, Plus Jakarta
    // Sans for screen titles and the card name.
    const inter = TextStyle(fontFamily: AppFonts.body);
    const jakarta = TextStyle(fontFamily: AppFonts.display, fontWeight: FontWeight.w700);
    final text = TextTheme(
      headlineSmall: jakarta.copyWith(fontSize: 24),
      titleLarge: jakarta.copyWith(fontSize: 22),
      titleMedium: inter.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleSmall: inter.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: inter.copyWith(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: inter.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: inter.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: scheme.onSurfaceVariant),
      labelLarge: inter.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      labelMedium: inter.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: inter.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    const radius12 = BorderRadius.all(Radius.circular(12));
    const radius16 = BorderRadius.all(Radius.circular(16));
    const buttonShape = RoundedRectangleBorder(borderRadius: radius12);
    const buttonSize = Size.fromHeight(52);

    return ThemeData(
      colorScheme: scheme,
      fontFamily: AppFonts.body,
      textTheme: text,
      scaffoldBackgroundColor: background,
      extensions: [status],
      // PRD 5.1: minimum 48 dp touch targets.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),
      // Borders instead of shadows.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radius16, side: BorderSide(color: scheme.outline)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide(color: scheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide(color: scheme.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide(color: scheme.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide(color: scheme.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: radius12, borderSide: BorderSide(color: scheme.error, width: 2)),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, shape: buttonShape, textStyle: text.labelLarge),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: text.labelLarge,
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: buttonShape, textStyle: text.labelLarge),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: scheme.primaryContainer,
        labelStyle: text.labelSmall?.copyWith(color: scheme.onPrimaryContainer),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => text.labelSmall?.copyWith(
              color: states.contains(WidgetState.selected) ? scheme.primary : scheme.onSurfaceVariant,
            )),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, space: 1),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: radius12),
        backgroundColor: AppColors.ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: AppColors.white),
      ),
    );
  }
}
