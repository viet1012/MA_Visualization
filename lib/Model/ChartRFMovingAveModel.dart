class ChartRFMovingAveModel {
  final String month;
  final double repairFee;

  ChartRFMovingAveModel({required this.month, required this.repairFee});

  factory ChartRFMovingAveModel.fromJson(Map<String, dynamic> json) {
    return ChartRFMovingAveModel(
      month: json['month'] ?? '',
      repairFee: json['repairFee'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'repairFee': repairFee};
  }
}
