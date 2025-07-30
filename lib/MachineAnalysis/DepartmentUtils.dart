import 'package:flutter/material.dart';

class DepartmentUtils {
  static const Map<String, Color> _departmentColors = {
    'PRESS': Color(0xFF1565C0), // Blue.shade800
    'MOLD': Color(0xFFEF6C00), // Orange.shade800
    'GUIDE': Color(0xFF2E7D32), // Green.shade800
    'KVH': Color(0xFF7B1FA2), // Purple
  };

  static Color getDepartmentColor(String div) {
    return _departmentColors[div.toUpperCase()] ?? const Color(0xFF424242);
  }
}
