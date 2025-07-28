class MachineTrendModel {
  final double ttl;
  final String macId;
  final String macName;
  final String? cate;
  final double act;
  final String monthUse;
  final int stt;

  MachineTrendModel({
    required this.ttl,
    required this.macId,
    required this.macName,
    required this.cate,
    required this.act,
    required this.monthUse,
    required this.stt,
  });

  factory MachineTrendModel.fromJson(Map<String, dynamic> json) {
    return MachineTrendModel(
      ttl: (json['ttl'] ?? 0).toDouble(),
      macId: json['macId'] ?? '',
      macName: json['macName'] ?? '',
      cate: json['cate'],
      act: (json['act'] ?? 0).toDouble(),
      monthUse: json['monthUse'] ?? '',
      stt: json['stt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ttl': ttl,
      'macId': macId,
      'macName': macName,
      'cate': cate,
      'act': act,
      'monthUse': monthUse,
      'stt': stt,
    };
  }
}
