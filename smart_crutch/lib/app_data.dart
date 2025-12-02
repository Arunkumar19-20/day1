import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AppData extends ChangeNotifier {
  int steps = 1234;
  double distance = 0.9; // km
  int battery = 84;
  List<String> alerts = [];

  List<FlSpot> get stepsData => List.generate(7, (i) => FlSpot(i.toDouble(), (1000 + i*200).toDouble()));

  void addAlert(String alert) {
    alerts.add(alert);
    notifyListeners();
  }

  void simulateStep() {
    steps += 50;
    distance += 0.05;
    notifyListeners();
  }

  void updateBattery(int val) {
    battery = val;
    notifyListeners();
  }
}
