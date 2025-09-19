import 'package:intl/intl.dart';

class DetailsMSMovingAveModel {
  final String div;
  final String groupName;
  final String machineCode;
  final String machineType;
  final String refNo;
  final String reason;
  final DateTime? confirmDate;
  final String? sendTime;
  final String? startTime;
  final String? finishTime;
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

  /// 👉 format confirmDate thành yyyy-MM-dd
  String get confirmDateFormatted {
    if (confirmDate == null) return '';
    return DateFormat('yyyy-MM-dd').format(confirmDate!);
  }

  factory DetailsMSMovingAveModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['confirmDate'] != null) {
      // Nếu chuỗi ngày không đúng format thì vẫn tránh crash
      parsedDate = DateTime.tryParse(json['confirmDate'].toString());
    }

    return DetailsMSMovingAveModel(
      div: json['div'] ?? '',
      groupName: json['groupName'] ?? '',
      machineCode: json['machineCode'] ?? '',
      machineType: json['machineType'] ?? '',
      refNo: json['refNo'] ?? '',
      reason: json['reason'] ?? '',
      confirmDate: parsedDate,
      sendTime: _formatDateTime(json['sendTime'].toString()) ?? '',
      startTime: _formatDateTime(json['startTime'].toString()) ?? '',
      finishTime: _formatDateTime(json['finishTime'].toString()) ?? '',
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
      // Xuất confirmDate theo format yyyy-MM-dd
      'confirmDate':
          confirmDate != null
              ? DateFormat('yyyy-MM-dd').format(confirmDate!)
              : null,
      'sendTime': sendTime,
      'startTime': startTime,
      'finishTime': finishTime,
      'tempRun': tempRun,
      'stopHour': stopHour,
      'issueStatus': issueStatus,
    };
  }

  String? get formattedSendTime => _formatDateTime(sendTime);
  String? get formattedStartTime => _formatDateTime(startTime);
  String? get formattedFinishTime => _formatDateTime(finishTime);

  static String? _formatDateTime(dynamic raw) {
    if (raw == null || raw.toString().trim().isEmpty) {
      return '';
    }
    try {
      final dateTime = DateTime.parse(raw.toString());
      return '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
