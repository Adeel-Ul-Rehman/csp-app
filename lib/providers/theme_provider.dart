// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:css_mastery_app/core/constants/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'theme_color_name';

  ThemeMode _themeMode = ThemeMode.dark;
  String _colorName = 'Blue';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get colorName => _colorName;

  ThemeProvider() {
    _loadTheme();
  }

  // Load saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 1; // Default dark
    _colorName = prefs.getString(_colorKey) ?? 'Blue'; // Default Blue

    switch (themeIndex) {
      case 0:
        _themeMode = ThemeMode.light;
        break;
      case 1:
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    _applyThemeColor(_colorName);
    notifyListeners();
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    final prefs = await SharedPreferences.getInstance();
    final themeIndex = _themeMode == ThemeMode.dark ? 1 : 0;
    await prefs.setInt(_themeKey, themeIndex);

    notifyListeners();
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = mode == ThemeMode.dark
        ? 1
        : mode == ThemeMode.light
            ? 0
            : 2;
    await prefs.setInt(_themeKey, themeIndex);
    notifyListeners();
  }

  // Set theme color name
  Future<void> setThemeColor(String name) async {
    _colorName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_colorKey, name);
    _applyThemeColor(name);
    notifyListeners();
  }

  void _applyThemeColor(String name) {
    switch (name) {
      case 'Purple':
        AppColors.primaryBlue = const Color(0xFF8E24AA);
        AppColors.primaryBlueDark = const Color(0xFF5E35B1);
        AppColors.primaryBlueLight = const Color(0xFFF3E5F5);
        AppColors.primaryBlueAccent = const Color(0xFFAB47BC);
        AppColors.primaryGradient = const LinearGradient(
          colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'Green':
        AppColors.primaryBlue = const Color(0xFF2E7D32);
        AppColors.primaryBlueDark = const Color(0xFF1B5E20);
        AppColors.primaryBlueLight = const Color(0xFFE8F5E9);
        AppColors.primaryBlueAccent = const Color(0xFF4CAF50);
        AppColors.primaryGradient = const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'Orange':
        AppColors.primaryBlue = const Color(0xFFEF6C00);
        AppColors.primaryBlueDark = const Color(0xFFE65100);
        AppColors.primaryBlueLight = const Color(0xFFFFF3E0);
        AppColors.primaryBlueAccent = const Color(0xFFFF9800);
        AppColors.primaryGradient = const LinearGradient(
          colors: [Color(0xFFEF6C00), Color(0xFFE65100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'Red':
        AppColors.primaryBlue = const Color(0xFFD32F2F);
        AppColors.primaryBlueDark = const Color(0xFFB71C1C);
        AppColors.primaryBlueLight = const Color(0xFFFFEBEE);
        AppColors.primaryBlueAccent = const Color(0xFFE57373);
        AppColors.primaryGradient = const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
      case 'Blue':
      default:
        AppColors.primaryBlue = const Color(0xFF1A73E8);
        AppColors.primaryBlueDark = const Color(0xFF1557B0);
        AppColors.primaryBlueLight = const Color(0xFFE8F0FE);
        AppColors.primaryBlueAccent = const Color(0xFF4285F4);
        AppColors.primaryGradient = const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF1557B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        break;
    }
  }
}
