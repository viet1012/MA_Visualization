class DetailsDataMachineStoppingModel {
  final String? startTime;
  final String? sendTime;
  final String? finishTime;
  final double? stopHour;
  final String? esTime;
  final String? groupName;
  final String? machineCode;
  final String? div;
  final String? confirmDate;
  final String? issueStatus;
  final String? machineType;
  final String? statusCode;

  DetailsDataMachineStoppingModel({
    this.startTime,
    this.sendTime,
    this.finishTime,
    this.stopHour,
    this.esTime,
    this.groupName,
    this.machineCode,
    this.div,
    this.confirmDate,
    this.issueStatus,
    this.machineType,
    this.statusCode,
  });

  factory DetailsDataMachineStoppingModel.fromJson(Map<String, dynamic> json) {
    return DetailsDataMachineStoppingModel(
      startTime: json['startTime']?.toString(),
      sendTime: json['sendTime']?.toString(),
      finishTime: json['finishTime']?.toString(),
      stopHour: _toDouble(json['stopHour']),
      esTime: json['esTime']?.toString(),
      groupName: json['groupName']?.toString(),
      machineCode: json['machineCode']?.toString(),
      div: json['div']?.toString(),
      confirmDate: json['confirmDate']?.toString(),
      issueStatus: json['issueStatus']?.toString(),
      machineType: json['machineType']?.toString(),
      statusCode: json['statusCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'sendTime': sendTime,
      'finishTime': finishTime,
      'stopHour': stopHour,
      'esTime': esTime,
      'groupName': groupName,
      'machineCode': machineCode,
      'div': div,
      'confirmDate': confirmDate,
      'issueStatus': issueStatus,
      'machineType': machineType,
      'statusCode': statusCode,
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
