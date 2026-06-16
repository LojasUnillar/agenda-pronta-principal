import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Gerencia os temas (Claro e Escuro) da aplicação.
/// Define paleta de cores e estilos globais de componentes.
class AppTheme {
  static final lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brandBlue,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.brandBlue.withValues(alpha: 0.1),
    onPrimaryContainer: AppColors.brandBlue,
    secondary: AppColors.brandBlue,
    onSecondary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.brandBlue,
    tertiary: AppColors.brandBlue,
    onTertiary: AppColors.white,
    surfaceContainer: AppColors.white,
    surfaceContainerLow: const Color(0xFFF8F8F8),
    surfaceContainerHighest: AppColors.white,
    outline: const Color(0xFFE0E0E0),
    outlineVariant: const Color(0xFFF0F0F0),
    error: AppColors.error,
    onError: AppColors.white,
  );

  static final darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.black,
    onPrimary: AppColors.white,
    secondary: AppColors.black,
    onSecondary: AppColors.white,
    surface: AppColors.black,
    onSurface: AppColors.white,
    tertiary: AppColors.white,
    onTertiary: AppColors.black,
    surfaceContainer: AppColors.black,
    surfaceContainerLow: const Color(0xFF1E1E1E),
    surfaceContainerHighest: AppColors.darkGrey,
    outline: const Color(0xFF333333),
    outlineVariant: const Color(0xFF222222),
    error: AppColors.error,
    onError: AppColors.white,
  );

  static ThemeData get lightTheme => _createTheme(lightColorScheme);

  static ThemeData get darkTheme => _createTheme(darkColorScheme);

  static ThemeData _createTheme(ColorScheme colorScheme) {
    bool isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surface,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: isDark ? AppColors.white : AppColors.brandBlue,
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF121212) : AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppColors.white : AppColors.brandBlue,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.tertiary,
          foregroundColor: colorScheme.onTertiary,
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isDark ? AppColors.white : AppColors.brandBlue,
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevation: WidgetStateProperty.all(8),
          padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
          backgroundColor: WidgetStateProperty.all(
            colorScheme.surfaceContainerLow,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
        color: colorScheme.surface,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          elevation: WidgetStateProperty.all(8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
