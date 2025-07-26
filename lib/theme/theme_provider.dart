// lib/theme/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'appSettings';
  static const String _themeKey = 'isDarkMode';

  late Box _settingsBox;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _initTheme();
  }

  Future<void> _initTheme() async {
    _settingsBox = await Hive.openBox(_themeBoxName);
    _isDarkMode = _settingsBox.get(_themeKey, defaultValue: false);
    notifyListeners(); // Notify listeners after initial load
  }

  void toggleTheme(bool isOn) {
    _isDarkMode = isOn;
    _settingsBox.put(_themeKey, _isDarkMode);
    notifyListeners(); // Notify all widgets listening to this provider
  }

  // Define your app's light and dark themes
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.green,
    ),
    // Added more comprehensive theme definitions for light mode
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    canvasColor: Colors.grey[50], // Default for some widgets like Drawer
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black87),
      bodyMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
      titleLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
      titleSmall: TextStyle(color: Colors.black),
      labelLarge: TextStyle(color: Colors.black),
      labelMedium: TextStyle(color: Colors.black87),
      labelSmall: TextStyle(color: Colors.black54),
    ),
    iconTheme: const IconThemeData(color: Colors.black87),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green[800],
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.green[700],
    ),
    // Added more comprehensive theme definitions for dark mode
    scaffoldBackgroundColor: Colors.grey[900],
    cardColor: Colors.grey[800],
    dialogBackgroundColor: Colors.grey[800],
    canvasColor: Colors.grey[850], // Default for some widgets like Drawer
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white70),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white54),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color: Colors.white),
      labelMedium: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white54),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
  );
}