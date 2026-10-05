import 'package:b_card/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('avatar colour is a palette pastel and stable per name', () {
    final colour = AppColors.avatarFor('Aarav Shah');
    expect(AppColors.avatarPastels, contains(colour));
    expect(AppColors.avatarFor('  aarav shah '), colour);
  });

  test('avatar colours spread across the palette', () {
    final used = {for (final n in ['Aarav', 'Priya', 'Rohan', 'Meera', 'Kabir', 'Isha', 'Dev', 'Anya']) AppColors.avatarFor(n)};
    expect(used.length, greaterThan(1));
  });

  test('light and dark themes use the B Card palette', () {
    final light = AppTheme.light;
    expect(light.colorScheme.primary, AppColors.bBlue);
    expect(light.scaffoldBackgroundColor, AppColors.cloud);
    expect(light.colorScheme.onSurface, AppColors.ink);
    expect(light.extension<StatusColors>()!.brandCard, AppColors.midnightNavy);

    final dark = AppTheme.dark;
    expect(dark.colorScheme.primary, AppColors.darkPrimary);
    expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
    expect(dark.colorScheme.surface, AppColors.darkSurface);
    expect(dark.colorScheme.onSurface, AppColors.darkText);
  });

  test('type scale follows the spec', () {
    final text = AppTheme.light.textTheme;
    expect(text.headlineSmall!.fontFamily, AppFonts.display);
    expect(text.headlineSmall!.fontSize, 24);
    expect(text.titleLarge!.fontSize, 22);
    expect(text.titleMedium!.fontWeight, FontWeight.w600);
    expect(text.labelLarge!.fontSize, 15);
    expect(text.bodyMedium!.fontFamily, AppFonts.body);
  });
}
