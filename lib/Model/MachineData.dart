class MachineDataByGroup {
  final String macGrp;
  final String macId;
  final String macName;
  final double act;

  MachineDataByGroup({
    required this.macGrp,
    required this.macId,
    required this.macName,
    required this.act,
  });

  // Constructor từ JSON
  factory MachineDataByGroup.fromJson(Map<String, dynamic> json) {
    return MachineDataByGroup(
      macGrp: json['macGrp'] ?? 'Null',
      macId: json['macId'] ?? 'Null',
      macName: json['macName'] ?? 'Null',
      act: (json['act'] ?? 0).toDouble(),
    );
  }

  // Gửi lại dữ liệu lên API nếu cần
  Map<String, dynamic> toJson() {
    return {'MacGrp': macGrp, 'MacID': macId, 'Repair Fee \$': act};
  }
}

class MachineDataByCate {
  final String cate;
  final String macId;
  final String macName;
  final double act;

  MachineDataByCate({
    required this.cate,
    required this.macId,
    required this.macName,
    required this.act,
  });

  // Constructor từ JSON
  factory MachineDataByCate.fromJson(Map<String, dynamic> json) {
    return MachineDataByCate(
      cate: json['cate'] ?? 'Null',
      macId: json['macId'] ?? 'Null',
      macName: json['macName'] ?? 'Null',
      act: (json['act'] ?? 0).toDouble(),
    );
  }

  // Gửi lại dữ liệu lên API nếu cần
  Map<String, dynamic> toJson() {
    return {'cate': cate, 'MacID': macId, 'Repair Fee \$': act};
  }
}
