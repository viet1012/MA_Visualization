import 'package:flutter/material.dart';

class DateProvider with ChangeNotifier {
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  DateTime get selectedDate => _selectedDate;

  void updateDate(DateTime newDate) {
    _selectedDate = DateTime(newDate.year, newDate.month, 1);
    notifyListeners();
  }

  void updateDateFromUrl(String monthYear) {
    final parts = monthYear.split('-');
    final year = int.tryParse(parts[0]) ?? DateTime.now().year;
    final month = int.tryParse(parts[1]) ?? DateTime.now().month;
    _selectedDate = DateTime(year, month, 1);
    notifyListeners();
  }
}
