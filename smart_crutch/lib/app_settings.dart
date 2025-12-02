import 'package:flutter/foundation.dart';

class AppSettings extends ChangeNotifier {
  bool useDarkMode = false;
  double alertVolume = 0.5;

  void toggleDarkMode() {
    useDarkMode = !useDarkMode;
    notifyListeners();
  }

  void setAlertVolume(double value) {
    alertVolume = value;
    notifyListeners();
  }

  // ← Add this method
  void resetSettings() {
    useDarkMode = false;
    alertVolume = 0.5;
    notifyListeners();
  }
}
