class MachineAnalysis {
  final String macName;
  final int rank;
  final double stopCase;
  final double stopHour;
  final double repairFee;

  MachineAnalysis({
    required this.macName,
    required this.rank,
    required this.stopCase,
    required this.stopHour,
    required this.repairFee,
  });

  factory MachineAnalysis.fromJson(Map<String, dynamic> json) {
    return MachineAnalysis(
      macName: json['macName'] ?? '',
      rank: json['rank'] ?? 0,
      stopCase: (json['stop_Case'] ?? 0).toDouble(),
      stopHour: (json['stop_Hour'] ?? 0).toDouble(),
      repairFee: (json['repairFee'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'macName': macName,
      'rank': rank,
      'stop_Case': stopCase,
      'stop_Hour': stopHour,
      'repairFee': repairFee,
    };
  }
}
