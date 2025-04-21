// lib/controllers/wheel_controller.dart
import 'package:flutter/material.dart';

class WheelController with ChangeNotifier {
  double _angle = 0.0;

  double get angle => _angle;

  void spin() {
    // 模拟旋转
    _angle = 360.0; // 你可以在这里添加更复杂的动画逻辑
    notifyListeners();
  }
}