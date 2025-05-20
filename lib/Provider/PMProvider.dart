import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ma_visualization/Model/PMModel.dart';

import '../API/ApiService.dart';

class PMProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PMModel> _data = [];
  DateTime? _lastLoadedDate;
  String? _lastLoadedMonth; // Thêm dòng này
  bool _isLoading = false;

  List<PMModel> get data => _data;
  bool get isLoading => _isLoading;
  PMModel? selectedItem;

  DateTime _lastFetchedDate = DateTime.now();
  Timer? _dailyTimer;

  DateTime get lastFetchedDate => _lastFetchedDate;

  PMProvider() {
    _initTimer();
  }

  void _initTimer() {
    _dailyTimer = Timer.periodic(Duration(minutes: 60), (timer) {
      final now = DateTime.now();
      if (!_isSameDate(now, _lastFetchedDate)) {
        print("[DATE CHANGED] Detected date change! Refreshing...");
        _lastFetchedDate = now;
        final month = "${now.year}-${now.month.toString().padLeft(2, '0')}";
        fetchRepairFee(month);
      }
    });
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  void dispose() {
    _dailyTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchRepairFee(String month) async {
    final now = DateTime.now();

    // Sửa điều kiện: nếu đã tải hôm nay VÀ cùng tháng thì không cần gọi lại
    if (_lastLoadedDate != null &&
        _lastLoadedMonth == month &&
        _lastLoadedDate!.day == now.day &&
        _lastLoadedDate!.month == now.month &&
        _lastLoadedDate!.year == now.year) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _apiService.fetchPM(month);
    _data = result;
    _lastLoadedDate = now;
    _lastLoadedMonth = month; // Cập nhật tháng

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _data = [];
    _lastLoadedDate = null;
    _lastLoadedMonth = null; // reset tháng
    notifyListeners();
  }
}
