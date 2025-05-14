class RepairFeeModel {
  final String title;
  final double target;
  final double actual;

  RepairFeeModel({
    required this.title,
    required this.target,
    required this.actual,
  });

  factory RepairFeeModel.fromJson(Map<String, dynamic> json) {
    final model = RepairFeeModel(
      title: json['dept'] ?? '',
      target: (json['tgt_MTD_ORG'] ?? 0) / 1000,
      actual: (json['act'] ?? 0) / 1000,
    );
    return model;
  }
}
