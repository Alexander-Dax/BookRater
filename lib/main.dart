import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/home_screen.dart';

void main() {
  // Initialisiere sqflite für Desktop-Plattformen
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const BookRaterApp());
}

class BookRaterApp extends StatefulWidget {
  const BookRaterApp({super.key});

  @override
  State<BookRaterApp> createState() => _BookRaterAppState();
}

class _BookRaterAppState extends State<BookRaterApp> {
  ThemeMode _themeMode = ThemeMode.system;

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

      // Light Theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7a5c3e), // Braun
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'serif',
      ),

      // Dark Theme
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7a5c3e), // Braun
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'serif',
      ),

      home: HomeScreen(onToggleTheme: _toggleTheme),
    );
  }
}
