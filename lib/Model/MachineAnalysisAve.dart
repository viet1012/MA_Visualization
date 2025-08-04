class MachineAnalysisAve {
  final String div;
  final int rank;
  final String? macName;
  final double repairFee;
  final int countMac;
  final double aveRepairFee;
  final int? stopCase;
  final double? stopHour;
  final double? aveStopHour;

  MachineAnalysisAve({
    required this.div,
    required this.rank,
    required this.macName,
    required this.repairFee,
    required this.countMac,
    required this.aveRepairFee,
    this.stopCase,
    this.stopHour,
    this.aveStopHour,
  });

  factory MachineAnalysisAve.fromJson(Map<String, dynamic> json) {
    return MachineAnalysisAve(
      div: json['div'] as String,
      rank: json['rank'] as int,
      macName: json['macName'] as String?,
      repairFee: (json['repairFee'] as num).toDouble(),
      countMac: json['countMac'] as int,
      aveRepairFee: (json['aveRepairFee'] as num).toDouble(),
      stopCase: json['stopCase'] != null ? json['stopCase'] as int : null,
      stopHour:
          json['stopHour'] != null
              ? (json['stopHour'] as num).toDouble()
              : null,
      aveStopHour:
          json['aveStopHour'] != null
              ? (json['aveStopHour'] as num).toDouble()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'div': div,
      'rank': rank,
      'macName': macName,
      'repairFee': repairFee,
      'countMac': countMac,
      'aveRepairFee': aveRepairFee,
      'stopCase': stopCase,
      'stopHour': stopHour,
      'aveStopHour': aveStopHour,
    };
  }
}
