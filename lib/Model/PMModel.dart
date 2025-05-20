class PMModel {
  final DateTime date;
  final String dept;
  final double act;
  final double fcMonth;
  final double fcDay;

  PMModel({
    required this.date,
    required this.dept,
    required this.act,
    required this.fcMonth,
    required this.fcDay,
  });

  factory PMModel.fromJson(Map<String, dynamic> json) {
    return PMModel(
      date: DateTime.parse(json['date'] ?? '1970-01-01'),
      dept: json['dept'] ?? '',
      act: (json['act'] ?? 0).toDouble(),
      fcMonth: (json['fc_Month'] ?? 0).toDouble(),
      fcDay: (json['fc_Day'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'dept': dept,
      'act': act,
      'fc_Month': fcMonth,
      'fc_Day': fcDay,
    };
  }

  PMModel copyWith({
    DateTime? date,
    String? dept,
    double? act,
    double? fcMonth,
    double? fcDay,
  }) {
    return PMModel(
      date: date ?? this.date,
      dept: dept ?? this.dept,
      act: act ?? this.act,
      fcMonth: fcMonth ?? this.fcMonth,
      fcDay: fcDay ?? this.fcDay,
    );
  }
}
