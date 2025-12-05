// StudyFlow Uygulamasının Ana Dosyası

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

// Uygulamanın ana giriş noktası
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StudyFlowApp());
}

class StudyFlowApp extends StatelessWidget {
  // Ana uygulama widget'ı
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema başlangıç rengini tanımla
    final seed = const Color(0xFF1E88E5);

    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'StudyFlow',
            theme: _buildLightTheme(seed),
            darkTheme: _buildDarkTheme(seed),
            // Uygulama tema modunu ayarla
            themeMode: appState.darkModeEnabled
                ? ThemeMode.dark
                : ThemeMode.light,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }

  // Açık tema oluştur
  ThemeData _buildLightTheme(Color seed) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      appBarTheme: AppBarTheme(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(minimumSize: const Size(120, 48)),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Koyu tema oluştur
  ThemeData _buildDarkTheme(Color seed) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: seed.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 48),
          backgroundColor: seed,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );
  }
}
