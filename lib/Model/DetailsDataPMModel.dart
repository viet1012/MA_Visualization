class DetailsDataPMModel {
  final String dept;
  final String? startTime;
  final String? issueStatus;
  final String? estime;
  final String? empName;
  final String? actionCode;
  final String? sendTime;
  final String? finishTime;
  final String cLine;
  final String? empNo;
  final String? machineCode;

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
      issueStatus: json['issuestatus'] ?? '',
      estime: _formatDateTime(json['estime']),
      empName: json['empname'] ?? '',
      actionCode: json['actioncode'] ?? '',
      sendTime: _formatDateTime(json['sendtime']),
      startTime: _formatDateTime(json['starttime']),
      finishTime: _formatDateTime(json['finishtime']),
      cLine: json['cline'] ?? '',
      empNo: json['empno'] ?? '',
      machineCode: json['machinecode'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'dept': dept,
      'cline': cLine,
      'empno': empNo,
      'empname': empName,
      'machinecode': machineCode,
      'actioncode': actionCode,
      'sendtime': sendTime,
      'estime': estime,
      'starttime': startTime,
      'finishtime': finishTime,
      'issuestatus': issueStatus,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? get formattedSendTime => _formatDateTime(sendTime);
  String? get formattedStartTime => _formatDateTime(startTime);
  String? get formattedFinishTime => _formatDateTime(finishTime);
  String? get formattedEstime => _formatDateTime(estime);

  static String? _formatDateTime(dynamic raw) {
    if (raw == null) return null;
    try {
      final dateTime = DateTime.parse(raw.toString());
      return '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return raw.toString();
    }
  }
}
