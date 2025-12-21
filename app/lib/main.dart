import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'utils/logger.dart';

void main() {
  // Initialize logger
  logger.i('🚀 Starting Blu-ray to Letterboxd app');

  runApp(
    ProviderScope(
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    logger.logUI('Building MainApp widget');

    return MaterialApp.router(
      title: 'Blu-ray to Letterboxd',
      theme: _buildLetterboxdTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildLetterboxdTheme() {
    // Letterboxd-inspired color scheme
    const Color letterboxdRed = Color(0xFFE74C3C); // Letterboxd's signature red
    const Color letterboxdDark = Color(0xFF14181C); // Very dark background
    const Color letterboxdDarker = Color(0xFF0F1113); // Even darker for cards
    const Color letterboxdGray = Color(0xFF9CA3AF); // Light gray text
    const Color letterboxdLightGray = Color(0xFFD1D5DB); // Lighter gray for secondary text

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: letterboxdRed,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF2A1815), // Dark red container
        onPrimaryContainer: letterboxdLightGray,
        secondary: Color(0xFF374151), // Dark gray
        onSecondary: letterboxdLightGray,
        tertiary: letterboxdRed,
        onTertiary: Colors.white,
        surface: letterboxdDark,
        onSurface: Colors.white,
        surfaceVariant: letterboxdDarker,
        onSurfaceVariant: letterboxdGray,
        background: letterboxdDark,
        onBackground: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        outline: Color(0xFF4B5563),
        outlineVariant: Color(0xFF374151),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Colors.white,
        onInverseSurface: letterboxdDark,
        inversePrimary: letterboxdRed,
        surfaceTint: letterboxdDark,
      ),

      // Scaffold background
      scaffoldBackgroundColor: letterboxdDark,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: letterboxdDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: letterboxdDarker,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: letterboxdRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: letterboxdLightGray,
          side: const BorderSide(color: Color(0xFF4B5563)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F2937), // Dark input background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4B5563)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: letterboxdRed),
        ),
        labelStyle: const TextStyle(color: letterboxdGray),
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1F2937),
        selectedColor: letterboxdRed.withOpacity(0.2),
        checkmarkColor: letterboxdRed,
        deleteIconColor: letterboxdGray,
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: letterboxdGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: Color(0xFF4B5563)),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        bodyMedium: TextStyle(color: letterboxdLightGray, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: letterboxdGray, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: letterboxdLightGray, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: letterboxdGray, fontWeight: FontWeight.w500),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: letterboxdLightGray,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: letterboxdRed,
        linearTrackColor: Color(0xFF4B5563),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF374151),
        thickness: 1,
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: letterboxdDarker,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: letterboxdRed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: letterboxdDarker,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: letterboxdDarker,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
