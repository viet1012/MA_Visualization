class RepairFeeDailyModel {
  final DateTime date;
  final String dept;
  final double fcDay;
  final double fcUsd;
  final int wdOffice;
  final int countDayAll;
  final double act;

  RepairFeeDailyModel({
    required this.date,
    required this.dept,
    required this.fcDay,
    required this.fcUsd,
    required this.wdOffice,
    required this.countDayAll,
    required this.act,
  });

  factory RepairFeeDailyModel.fromJson(Map<String, dynamic> json) {
    return RepairFeeDailyModel(
      date: DateTime.parse(json['date'] ?? '1970-01-01'),
      dept: json['dept'] ?? '',
      fcDay: (json['fc_Day'] ?? 0).toDouble(),
      fcUsd: (json['fc_USD'] ?? 0).toDouble(),
      wdOffice: json['wd_Office'] ?? 0,
      countDayAll: json['countDayAll'] ?? 0,
      act: (json['act'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date?.toIso8601String(),
      'dept': dept,
      'fc_Day': fcDay,
      'fc_USD': fcUsd,
      'wd_Office': wdOffice,
      'countDayAll': countDayAll,
      'act': act,
    };
  }

  RepairFeeDailyModel copyWith({
    DateTime? date,
    String? dept,
    double? fcDay,
    double? fcUsd,
    int? wdOffice,
    int? countDayAll,
    double? act,
  }) {
    return RepairFeeDailyModel(
      date: date ?? this.date,
      dept: dept ?? this.dept,
      fcDay: fcDay ?? this.fcDay,
      fcUsd: fcUsd ?? this.fcUsd,
      wdOffice: wdOffice ?? this.wdOffice,
      countDayAll: countDayAll ?? this.countDayAll,
      act: act ?? this.act,
    );
  }
}
