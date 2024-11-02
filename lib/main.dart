// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/typing_game_screen.dart';
import 'services/word_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WordList.initialize();
  runApp(const TypingApp());
}

class TypingApp extends StatefulWidget {
  const TypingApp({super.key});

  @override
  State<TypingApp> createState() => _TypingAppState();
}

class _TypingAppState extends State<TypingApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  double _fontSize = 24.0;
  String _fontFamily = 'Roboto Mono';

  void _updateThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _updateFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
  }

  void _updateFontFamily(String font) {
    setState(() {
      _fontFamily = font;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Typing Game',
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: TypingGameScreen(
        onThemeModeChanged: _updateThemeMode,
        themeMode: _themeMode,
        fontSize: _fontSize,
        onFontSizeChanged: _updateFontSize,
        fontFamily: _fontFamily,
        onFontFamilyChanged: _updateFontFamily,
      ),
    );
  }
}