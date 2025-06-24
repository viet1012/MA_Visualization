class DetailsDataModel {
  final String dept;
  final String macName;
  final String macId;
  final String cate;
  final String matnr;
  final String maktx;
  final double kostl;
  final double konto;
  final String bktxt;
  final String useDate;
  final String xblnr2;
  final double qty;
  final String unit;
  final double amount; // mapped from 'act'
  final String note;

  DetailsDataModel({
    required this.dept,
    required this.macName,
    required this.macId,
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
    required this.amount,
    required this.note,
  });

  factory DetailsDataModel.fromJson(Map<String, dynamic> json) {
    return DetailsDataModel(
      dept: json['dept'] ?? '',
      macName: json['macName'] ?? '',
      macId: json['macId'] ?? '',
      cate: json['cate'] ?? '',
      matnr: json['matnr'] ?? '',
      maktx: json['maktx'] ?? '',
      useDate: json['useDate'] ?? '',
      kostl: (json['kostl'] as num?)?.toDouble() ?? 0.0,
      konto: (json['konto'] as num?)?.toDouble() ?? 0.0,
      xblnr2: json['xblnr2'] ?? '',
      amount: double.parse(
        ((json['act'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0),
      ),
      bktxt: json['bktxt'] ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      note: json['note'] ?? '',

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept': dept,
      'macId' : macId,
      'macName': macName ,
      'cate' : cate,
      'matnr': matnr,
      'maktx': maktx,
      'useDate': useDate,
      'kostl': kostl,
      'konto': konto,
      'xblnr2': xblnr2,
      'bktxt': bktxt,
      'qty': qty,
      'unit': unit,
      'act': amount,
      'note': note,
    };
  }
}
