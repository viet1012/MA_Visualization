class ChartMSMovingAveModel {
  final String month;
  final int stopCase;
  final double stopHour;

  ChartMSMovingAveModel({
    required this.month,
    required this.stopHour,
    required this.stopCase,
  });

  factory ChartMSMovingAveModel.fromJson(Map<String, dynamic> json) {
    return ChartMSMovingAveModel(
      month: json['month'] ?? '',
      stopCase: json['stopCase'] ?? 0,
      stopHour: (json['stopHour'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'stopCase': stopCase, 'stopHour': stopHour};
  }
}
