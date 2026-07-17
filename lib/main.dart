import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';

void main() async {
  // Initialisiere Flutter Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisiere sqflite für Desktop-Plattformen
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialisiere Theme-Service
  await ThemeService().init();

  runApp(const BookRaterApp());
}

class BookRaterApp extends StatefulWidget {
  const BookRaterApp({super.key});

  @override
  State<BookRaterApp> createState() => _BookRaterAppState();
}

class _BookRaterAppState extends State<BookRaterApp> {
  ThemeMode _themeMode = ThemeMode.system;
  final LanguageService _languageService = LanguageService();
  final ThemeService _themeService = ThemeService();

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
    _themeService.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _themeService.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  void _onThemeChanged() {
    setState(() {});
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Rater',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // Light Theme - dynamisch basierend auf Benutzerauswahl
      theme: _themeService.getLightTheme(),

      // Dark Theme - dynamisch basierend auf Benutzerauswahl
      darkTheme: _themeService.getDarkTheme(),

      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        languageService: _languageService,
      ),
    );
  }
}
