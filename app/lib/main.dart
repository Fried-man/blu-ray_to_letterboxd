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
      theme: _buildUnderwaterTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildUnderwaterTheme() {
    // Underwater-inspired color scheme
    const Color oceanBlue = Color(0xFF006994); // Deep ocean blue - primary
    const Color deepNavy = Color(0xFF0A1929); // Very dark navy background
    const Color darkerNavy = Color(0xFF06101A); // Even darker for cards
    const Color aquaAccent = Color(0xFF00CED1); // Turquoise accent
    const Color waveGray = Color(0xFF9CA3AF); // Light gray text
    const Color seafoamGray = Color(0xFFD1D5DB); // Lighter gray for secondary text

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: oceanBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF003d5c), // Darker ocean blue container
        onPrimaryContainer: seafoamGray,
        secondary: Color(0xFF1e3a5f), // Dark teal
        onSecondary: seafoamGray,
        tertiary: aquaAccent,
        onTertiary: Colors.white,
        surface: deepNavy,
        onSurface: Colors.white,
        surfaceVariant: darkerNavy,
        onSurfaceVariant: waveGray,
        background: deepNavy,
        onBackground: Colors.white,
        error: Color(0xFFEF4444),
        onError: Colors.white,
        outline: Color(0xFF4B5563),
        outlineVariant: Color(0xFF1e3a5f),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Colors.white,
        onInverseSurface: deepNavy,
        inversePrimary: oceanBlue,
        surfaceTint: deepNavy,
      ),

      // Scaffold background
      scaffoldBackgroundColor: deepNavy,

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: darkerNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: oceanBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: seafoamGray,
          side: const BorderSide(color: Color(0xFF1e3a5f)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0f1a2a), // Dark ocean input background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1e3a5f)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1e3a5f)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: aquaAccent),
        ),
        labelStyle: const TextStyle(color: waveGray),
        hintStyle: const TextStyle(color: Color(0xFF64748b)),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF0f1a2a),
        selectedColor: aquaAccent.withOpacity(0.2),
        checkmarkColor: aquaAccent,
        deleteIconColor: waveGray,
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: waveGray),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: Color(0xFF1e3a5f)),
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
        bodyMedium: TextStyle(color: seafoamGray, fontWeight: FontWeight.w400),
        bodySmall: TextStyle(color: waveGray, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: seafoamGray, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: waveGray, fontWeight: FontWeight.w500),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: seafoamGray,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: aquaAccent,
        linearTrackColor: Color(0xFF1e3a5f),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF1e3a5f),
        thickness: 1,
      ),

      // SnackBar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkerNavy,
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: aquaAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkerNavy,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkerNavy,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
