import 'package:flutter/material.dart';

class DepartmentUtils {
  static const Map<String, Color> _departmentColors = {
    'PRESS': Color(0xFF1565C0),
    'MOLD': Color(0xFFEF6C00),
    'GUIDE': Color(0xFF2E7D32),
    'KVH': Color(0xFF00C3FF),
  };

  static const Map<String, Color> _borderColors = {
    'PRESS': Color(0xFF90CAF9),
    'MOLD': Color(0xFFFFB74D),
    'GUIDE': Color(0xFFA5D6A7),
    'KVH': Color(0xFF01579B),
  };

  static Color getDepartmentColor(String div) {
    return _departmentColors[div.toUpperCase()] ?? const Color(0xFF424242);
  }

  static Color getDepartmentBorderColor(String div) {
    return _borderColors[div.toUpperCase()] ?? Colors.white;
  }
}
