class MachineData {
  final String macGrp;
  final String macId;
  final String macName;
  final double act;

  MachineData({
    required this.macGrp,
    required this.macId,
    required this.macName,
    required this.act,
  });

  // Constructor từ JSON
  factory MachineData.fromJson(Map<String, dynamic> json) {
    return MachineData(
      macGrp: json['macGrp'] ?? '',
      macId: json['macId'] ?? '',
      macName: json['macName'] ?? '',
      act: (json['act'] ?? 0).toDouble(),
    );
  }

  // Gửi lại dữ liệu lên API nếu cần
  Map<String, dynamic> toJson() {
    return {'MacGrp': macGrp, 'MacID': macId, 'Repair Fee \$': act};
  }
}
