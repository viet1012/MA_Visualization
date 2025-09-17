class DetailsRFMovingAveModel {
  final String div;
  final String macGrp;
  final String macId;
  final String macName;
  final String cate;
  final String matnr;
  final String maktx;
  final String useDate; // nếu cần DateTime thì đổi sang DateTime
  final String kostl;
  final String konto;
  final String xblnr2;
  final String bktxt;
  final double qty;
  final String unit;
  final double act;
  final String? note;

  DetailsRFMovingAveModel({
    required this.div,
    required this.macGrp,
    required this.macId,
    required this.macName,
    required this.cate,
    required this.matnr,
    required this.maktx,
    required this.useDate,
    required this.kostl,
    required this.konto,
    required this.xblnr2,
    required this.bktxt,
    required this.qty,
    required this.unit,
    required this.act,
    this.note,
  });

  factory DetailsRFMovingAveModel.fromJson(Map<String, dynamic> json) {
    return DetailsRFMovingAveModel(
      div: json['div'] ?? '',
      macGrp: json['macGrp'] ?? '',
      macId: json['macId'] ?? '',
      macName: json['macName'] ?? '',
      cate: json['cate'] ?? '',
      matnr: json['matnr'] ?? '',
      maktx: json['maktx'] ?? '',
      useDate: json['useDate'] ?? '',
      kostl: json['kostl'] ?? '',
      konto: json['konto'] ?? '',
      xblnr2: json['xblnr2'] ?? '',
      bktxt: json['bktxt'] ?? '',
      qty: (json['qty'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      act: (json['act'] ?? 0).toDouble(),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'div': div,
      'macGrp': macGrp,
      'macId': macId,
      'macName': macName,
      'cate': cate,
      'matnr': matnr,
      'maktx': maktx,
      'useDate': useDate,
      'kostl': kostl,
      'konto': konto,
      'xblnr2': xblnr2,
      'bktxt': bktxt,
      'qty': qty,
      'unit': unit,
      'act': act,
      'note': note,
    };
  }
}
