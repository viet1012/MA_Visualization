class RepairFeeModel {
  final String title;
  final double target_ORG;
  final double target_Adjust;
  final double actual;

  RepairFeeModel({
    required this.title,
    required this.target_ORG,
    required this.target_Adjust,
    required this.actual,
  });

  double adjustMinusOrg = 0;
  double orgMinusAdjust = 0;

  void calculateDiff() {
    if (target_Adjust > target_ORG) {
      adjustMinusOrg = target_Adjust - target_ORG;
      orgMinusAdjust = 0;
    } else {
      orgMinusAdjust = target_ORG - target_Adjust;
      adjustMinusOrg = 0;
    }
  }

  factory RepairFeeModel.fromJson(Map<String, dynamic> json) {
    final model = RepairFeeModel(
      title: json['dept'] ?? '',
      target_ORG: (json['tgt_ORG'] ?? 0) / 1000,
      actual: (json['act'] ?? 0) / 1000,
      target_Adjust: (json['tgt_Adjust'] ?? 0) / 1000,
    );
    model.calculateDiff();
    return model;
  }

  // Method to convert ToolCostModel to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'dept': title,
      'tgt_MTD': target_ORG * 1000, // Chuyển đổi lại nếu cần
      'act': actual * 1000, // Chuyển đổi lại nếu cần
    };
  }
}
