import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/about_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/surah_detail_screen.dart';
import 'screens/surah_list_screen.dart';
import 'state/app_settings.dart';
import 'package:provider/provider.dart';

class EquranApp extends StatelessWidget {
  const EquranApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    final seed = const Color(0xFF0B6E4F); // hijau elegan
    final baseText = GoogleFonts.poppinsTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Quran Keren',
      themeMode: settings.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
        textTheme: baseText,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
        textTheme: baseText,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        SurahListScreen.route: (_) => const SurahListScreen(),
        AboutScreen.route: (_) => const AboutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == SurahDetailScreen.route) {
          final args = settings.arguments as SurahDetailArgs;
          return MaterialPageRoute(
            builder: (_) => SurahDetailScreen(args: args),
          );
        }
        return null;
      },
      initialRoute: SplashScreen.route,
    );
  }
}
