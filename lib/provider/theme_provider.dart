import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode _userTheme;

  ThemeMode get userTheme => _userTheme;

  ThemeProvider(int theme) {
    _userTheme = ThemeMode.values[theme];
  }

  void setThemeMode(ThemeMode theme) {
    _userTheme = theme;
    notifyListeners();
  }
}
