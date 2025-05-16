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
      confirmDate: json['confirmDate']?.toString(),
      sendTime: json['sendTime']?.toString(),
      startTime: json['startTime']?.toString(),
      esTime: json['esTime']?.toString(),
      finishTime: json['finishTime']?.toString(),
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
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
