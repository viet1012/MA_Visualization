class DetailsDataModel {
  final String dept;
  final String matnr;
  final String maktx;
  final String kostl;
  final String konto;
  final String bktxt;
  final String useDate;
  final String xblnr2;
  final double qty;
  final String unit;
  final double amount; // mapped from 'act'

  DetailsDataModel({
    required this.dept,
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
  });

  factory DetailsDataModel.fromJson(Map<String, dynamic> json) {
    return DetailsDataModel(
      dept: json['dept'] ?? '',
      matnr: json['matnr'] ?? '',
      maktx: json['maktx'] ?? '',
      useDate: json['useDate'] ?? '',
      kostl: json['kostl'] ?? '',
      konto: json['konto'] ?? '',
      xblnr2: json['xblnr2'] ?? '',
      amount: double.parse(
        ((json['act'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(0),
      ),

      bktxt: json['bktxt'] ?? '',
      qty: (json['qty'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dept': dept,
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
    };
  }
}
