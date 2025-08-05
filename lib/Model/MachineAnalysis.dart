class MachineAnalysis {
  final String div;
  final String macName;
  final int rank;
  final double stopCase;
  final double stopHour;
  final double repairFee;

  MachineAnalysis({
    required this.div,
    required this.macName,
    required this.rank,
    required this.stopCase,
    required this.stopHour,
    required this.repairFee,
  });

  factory MachineAnalysis.fromJson(Map<String, dynamic> json) {
    return MachineAnalysis(
      div: json['div'] ?? '',
      macName: json['macName'] ?? '',
      rank: json['rank'] ?? 0,
      stopCase: (json['stopCase'] ?? 0).toDouble(),
      stopHour: (json['stopHour'] ?? 0).toDouble(),
      repairFee: (json['repairFee'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Div': div,
      'MacName': macName,
      'Rank': rank,
      'StopCase': stopCase,
      'StopHour': stopHour,
      'RepairFee': repairFee,
    };
  }
}
