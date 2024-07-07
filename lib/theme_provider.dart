import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ThemeProvider() : _themeData = ThemeData.light() {
    _initialize();
  }

  ThemeData get themeData => _themeData;

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    bool isDarkTheme = _prefs.getBool('isDarkTheme') ?? false;
    _themeData = isDarkTheme ? ThemeData.dark() : ThemeData.light();
    _isInitialized = true;
    notifyListeners();
  }

  void toggleTheme() async {
    if (!_isInitialized) return;

    if (_themeData == ThemeData.dark()) {
      _themeData = ThemeData.light();
      await _prefs.setBool('isDarkTheme', false);
    } else {
      _themeData = ThemeData.dark();
      await _prefs.setBool('isDarkTheme', true);
    }
    notifyListeners();
  }
}
