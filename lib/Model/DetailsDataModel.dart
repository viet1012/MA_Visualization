class DetailsDataModel {
  final String dept;
  final String matnr;
  final String kostl;
  final String konto;
  final String bktxt;
  final double qty;
  final double amount; // mapped from 'act'
  final String useDate;
  final String maktx;
  final String xblnr2;
  final String unit;

  DetailsDataModel({
    required this.dept,
    required this.matnr,
    required this.kostl,
    required this.konto,
    required this.bktxt,
    required this.qty,
    required this.amount,
    required this.useDate,
    required this.maktx,
    required this.xblnr2,
    required this.unit,
  });

  factory DetailsDataModel.fromJson(Map<String, dynamic> json) {
    return DetailsDataModel(
      dept: json['dept'] ?? '',
      matnr: json['matnr'] ?? '',
      kostl: json['kostl'] ?? '',
      konto: json['konto'] ?? '',
      bktxt: json['bktxt'] ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      amount: (json['act'] as num?)?.toDouble() ?? 0.0,
      useDate: json['useDate'] ?? '',
      maktx: json['maktx'] ?? '',
      xblnr2: json['xblnr2'] ?? '',
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept': dept,
      'matnr': matnr,
      'kostl': kostl,
      'konto': konto,
      'bktxt': bktxt,
      'qty': qty,
      'act': amount,
      'useDate': useDate,
      'maktx': maktx,
      'xblnr2': xblnr2,
      'unit': unit,
    };
  }
}
