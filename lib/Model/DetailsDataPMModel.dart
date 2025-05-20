class DetailsDataPMModel {
  final String dept;
  final DateTime startTime;
  final String issueStatus;
  final DateTime estime;
  final String empName;
  final String actionCode;
  final DateTime sendTime;
  final DateTime finishTime;
  final String cLine;
  final String empNo;
  final String machineCode;

  DetailsDataPMModel({
    required this.dept,
    required this.startTime,
    required this.issueStatus,
    required this.estime,
    required this.empName,
    required this.actionCode,
    required this.sendTime,
    required this.finishTime,
    required this.cLine,
    required this.empNo,
    required this.machineCode,
  });

  factory DetailsDataPMModel.fromJson(Map<String, dynamic> json) {
    return DetailsDataPMModel(
      dept: json['dept'] ?? '',
      startTime: DateTime.parse(json['starttime']),
      issueStatus: json['issuestatus'] ?? '',
      estime: DateTime.parse(json['estime']),
      empName: json['empname'] ?? '',
      actionCode: json['actioncode'] ?? '',
      sendTime: DateTime.parse(json['sendtime']),
      finishTime: DateTime.parse(json['finishtime']),
      cLine: json['cline'] ?? '',
      empNo: json['empno'] ?? '',
      machineCode: json['machinecode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept': dept,
      'starttime': startTime.toIso8601String(),
      'issuestatus': issueStatus,
      'estime': estime.toIso8601String(),
      'empname': empName,
      'actioncode': actionCode,
      'sendtime': sendTime.toIso8601String(),
      'finishtime': finishTime.toIso8601String(),
      'cline': cLine,
      'empno': empNo,
      'machinecode': machineCode,
    };
  }
}
