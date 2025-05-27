class DetailsDataMachineStoppingModel {
  final String? sendDate;
  final String? div;
  final String? groupName;
  final String? machineCode;
  final String? machineType;
  final String? statusCode;
  final String? confirmDate;
  final String? sendTime;
  final String? startTime;
  final String? esTime;
  final String? finishTime;
  final double? stopHour;
  final String? issueStatus;

  DetailsDataMachineStoppingModel({
    this.sendDate,
    this.div,
    this.groupName,
    this.machineCode,
    this.machineType,
    this.statusCode,
    this.confirmDate,
    this.sendTime,
    this.startTime,
    this.esTime,
    this.finishTime,
    this.stopHour,
    this.issueStatus,
  });

  factory DetailsDataMachineStoppingModel.fromJson(Map<String, dynamic> json) {
    return DetailsDataMachineStoppingModel(
      sendDate: json['sendDate']?.toString(),
      div: json['div']?.toString(),
      groupName: json['groupName']?.toString(),
      machineCode: json['machineCode']?.toString(),
      machineType: json['machineType']?.toString(),
      statusCode: json['statusCode']?.toString(),
      confirmDate: _formatDateTime((json['confirmDate'])),
      sendTime: _formatDateTime(json['sendTime']),
      startTime: _formatDateTime(json['startTime']),
      esTime: _formatDateTime(json['esTime']),
      finishTime: _formatDateTime(json['finishTime']),
      stopHour: _toDouble(json['stopHour']),
      issueStatus: json['issueStatus']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sendDate': sendDate,
      'div': div,
      'groupName': groupName,
      'machineCode': machineCode,
      'machineType': machineType,
      'statusCode': statusCode,
      'confirmDate': confirmDate,
      'sendTime': sendTime,
      'startTime': startTime,
      'esTime': esTime,
      'finishTime': finishTime,
      'stopHour': stopHour,
      'issueStatus': issueStatus,
    };
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return double.parse(value.toStringAsFixed(1));
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String? get formattedSendTime => _formatDateTime(sendTime);
  String? get formattedStartTime => _formatDateTime(startTime);
  String? get formattedFinishTime => _formatDateTime(finishTime);
  String? get formattedConfirmDate => _formatDateTime(confirmDate);

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
