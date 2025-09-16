class DetailsMSMovingAveModel {
  final String div;
  final String groupName;
  final String machineCode;
  final String machineType;
  final String refNo;
  final String reason;
  final DateTime? confirmDate;
  final String sendTime;
  final String startTime;
  final String finishTime;
  final double? tempRun;
  final double? stopHour;
  final String issueStatus;

  DetailsMSMovingAveModel({
    required this.div,
    required this.groupName,
    required this.machineCode,
    required this.machineType,
    required this.refNo,
    required this.reason,
    this.confirmDate,
    required this.sendTime,
    required this.startTime,
    required this.finishTime,
    this.tempRun,
    this.stopHour,
    required this.issueStatus,
  });

  factory DetailsMSMovingAveModel.fromJson(Map<String, dynamic> json) {
    return DetailsMSMovingAveModel(
      div: json['div'] ?? '',
      groupName: json['groupName'] ?? '',
      machineCode: json['machineCode'] ?? '',
      machineType: json['machineType'] ?? '',
      refNo: json['refNo'] ?? '',
      reason: json['reason'] ?? '',
      confirmDate:
          json['confirmDate'] != null
              ? DateTime.tryParse(json['confirmDate'].toString())
              : null,
      sendTime: json['sendTime'] ?? '',
      startTime: json['startTime'] ?? '',
      finishTime: json['finishTime'] ?? '',
      tempRun:
          json['tempRun'] != null ? (json['tempRun'] as num).toDouble() : null,
      stopHour:
          json['stopHour'] != null
              ? (json['stopHour'] as num).toDouble()
              : null,
      issueStatus: json['issueStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'div': div,
      'groupName': groupName,
      'machineCode': machineCode,
      'machineType': machineType,
      'refNo': refNo,
      'reason': reason,
      'confirmDate': confirmDate?.toIso8601String(),
      'sendTime': sendTime,
      'startTime': startTime,
      'finishTime': finishTime,
      'tempRun': tempRun,
      'stopHour': stopHour,
      'issueStatus': issueStatus,
    };
  }
}
