class MachineStoppingModel {
  final double stopHourAct;
  final double stopHourTgtMtd;
  final int countDay;
  final String div;
  final DateTime sendDate;
  final int wdOffice;
  final double stopHourTgt;

  MachineStoppingModel({
    required this.stopHourAct,
    required this.stopHourTgtMtd,
    required this.countDay,
    required this.div,
    required this.sendDate,
    required this.wdOffice,
    required this.stopHourTgt,
  });

  factory MachineStoppingModel.fromJson(Map<String, dynamic> json) {
    return MachineStoppingModel(
      stopHourAct: (json['stopHourAct'] ?? 0).toDouble(),
      stopHourTgtMtd: (json['stopHourTgtMtd'] ?? 0).toDouble(),
      countDay: json['countDay'] ?? 0,
      div: json['div'] ?? '',
      sendDate: DateTime.parse(json['sendDate'] ?? '1970-01-01'),
      wdOffice: json['wdOffice'] ?? 0,
      stopHourTgt: (json['stopHourTgt'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stopHourAct': stopHourAct,
      'stopHourTgtMtd': stopHourTgtMtd,
      'countDay': countDay,
      'div': div,
      'sendDate': sendDate.toIso8601String(),
      'wdOffice': wdOffice,
      'stopHourTgt': stopHourTgt,
    };
  }

  MachineStoppingModel copyWith({
    double? stopHourAct,
    double? stopHourTgtMtd,
    int? countDay,
    String? div,
    DateTime? sendDate,
    int? wdOffice,
    double? stopHourTgt,
  }) {
    return MachineStoppingModel(
      stopHourAct: stopHourAct ?? this.stopHourAct,
      stopHourTgtMtd: stopHourTgtMtd ?? this.stopHourTgtMtd,
      countDay: countDay ?? this.countDay,
      div: div ?? this.div,
      sendDate: sendDate ?? this.sendDate,
      wdOffice: wdOffice ?? this.wdOffice,
      stopHourTgt: stopHourTgt ?? this.stopHourTgt,
    );
  }
}
