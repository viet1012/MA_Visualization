import 'package:flutter/material.dart';

class DepartmentUtils {
  static const Map<String, Color> _departmentColors = {
    'PRESS': Color(0xFF0077FF),
    'MOLD': Color(0xFFEF6C00),
    'GUIDE': Color(0xFF2E7D32),
    'KVH': Color(0xFF00C3FF),
  };

  static const Map<String, Color> _borderColors = {
    'PRESS': Color(0xFF5B6870),
    'MOLD': Color(0xFF71695D),
    'GUIDE': Color(0xFF3A403A),
    'KVH': Color(0xFF3B3F42),
  };

  static Color getDepartmentColor(String div) {
    return _departmentColors[div.toUpperCase()] ?? const Color(0xFF424242);
  }

  static Color getDepartmentBorderColor(String div) {
    return _borderColors[div.toUpperCase()] ?? Colors.white;
  }
}
