class MachineStopReasonModel {
  final String div;
  final String reason1;
  final String reason2;
  final int stopCase;
  final double stopHour;

  MachineStopReasonModel({
    required this.div,
    required this.reason1,
    required this.reason2,
    required this.stopCase,
    required this.stopHour,
  });

  /// Tạo object từ JSON
  factory MachineStopReasonModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null || value == '') return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int parseInt(dynamic value) {
      if (value == null || value == '') return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return MachineStopReasonModel(
      div: json['div'] ?? '',
      reason1: json['reason1'] ?? '',
      reason2: json['reason2'] ?? '',
      stopCase: parseInt(json['stopCase']),
      stopHour: parseDouble(json['stopHour']),
    );
  }

  /// Chuyển object -> JSON
  Map<String, dynamic> toJson() {
    return {
      'div': div,
      'reason1': reason1,
      'reason2': reason2,
      'stopCase': stopCase,
      'stopHour': stopHour,
    };
  }

  /// Hàm tiện ích: parse list từ JSON array
  static List<MachineStopReasonModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((e) => MachineStopReasonModel.fromJson(e)).toList();
  }
}
