import 'package:flutter/material.dart';
import 'screens/rules_screen.dart';

class BlindArtistApp extends StatelessWidget {
  const BlindArtistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Слепой художник',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D1A),
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'PixelFont',
          bodyColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: const Color(0xFF26264D),
            foregroundColor: Colors.white,
            shadowColor: Colors.black,
            elevation: 6,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        cardTheme: const CardThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          color: Color(0xFF1A1A2E),
          elevation: 4,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const RulesScreen(),
    );
  }
}
