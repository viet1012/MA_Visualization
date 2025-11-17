class DetailsMSReasonModel {
  final String div;
  final String machineCode;
  final String machineType;
  final String reason1;
  final String reason2;
  final String reason3;
  final double stopHour;
  final String linhKienVi;

  DetailsMSReasonModel({
    required this.div,
    required this.machineCode,
    required this.machineType,
    required this.reason1,
    required this.reason2,
    required this.reason3,
    required this.stopHour,
    required this.linhKienVi,
  });

  factory DetailsMSReasonModel.fromJson(Map<String, dynamic> json) {
    return DetailsMSReasonModel(
      div: json['div'] ?? '',
      machineCode: json['machineCode'] ?? '',
      machineType: json['machineType'] ?? '',
      reason1: json['reason1'] ?? '',
      reason2: json['reason2'] ?? '',
      reason3: json['reason3'] ?? '',
      stopHour: (json['stopHour'] ?? 0).toDouble(),
      linhKienVi: json['linhKienVi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'div': div,
      'machineCode': machineCode,
      'machineType': machineType,
      'reason1': reason1,
      'reason2': reason2,
      'reason3': reason3,
      'stopHour': stopHour,
      'linhKienVi': linhKienVi,
    };
  }
}
