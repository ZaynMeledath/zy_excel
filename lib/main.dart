import 'package:flutter/material.dart';
import 'package:zy_excel/screens/column_selection_screen.dart';
import 'package:zy_excel/screens/home_screen.dart';
import 'package:zy_excel/screens/modification_screen.dart';
import 'package:zy_excel/utils/screen_size.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFF64FFDA),
      onPrimary: const Color(0xFF003730),
      primaryContainer: const Color(0xFF00504A),
      onPrimaryContainer: const Color(0xFF80FFE3),
      secondary: const Color(0xFF82B1FF),
      onSecondary: const Color(0xFF002F6C),
      secondaryContainer: const Color(0xFF004BA0),
      onSecondaryContainer: const Color(0xFFB6D4FF),
      tertiary: const Color(0xFFB388FF),
      surface: const Color(0xFF0F1923),
      onSurface: const Color(0xFFE1E3E6),
      surfaceContainerHighest: const Color(0xFF1A2733),
      error: const Color(0xFFFF5252),
      onError: Colors.white,
    );

    return MaterialApp(
      title: 'ZY Excel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0F1923),
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F1923),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: colorScheme.primary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A2733),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary.withAlpha(60)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withAlpha(25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
          ),
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withAlpha(100),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A2733),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withAlpha(15)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF1A2733),
          contentTextStyle: TextStyle(color: colorScheme.onSurface),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          getInitialScreenSize(context: context);
          return const HomeScreen();
        },
      ),
      routes: {
        '/column-selection': (context) => const ColumnSelectionScreen(),
        '/modification': (context) => const ModificationScreen(),
      },
    );
  }
}
