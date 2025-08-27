class MachineAnalysis {
  final String div;
  final String macName;
  final String rank;
  final double stopCase;
  final double stopHour;
  final double repairFee;

  MachineAnalysis({
    required this.div,
    required this.macName,
    required this.rank,
    required this.stopCase,
    required this.stopHour,
    required this.repairFee,
  });

  factory MachineAnalysis.fromJson(Map<String, dynamic> json) {
    return MachineAnalysis(
      div: json['div'] ?? '',
      macName: json['macName'] ?? '',
      rank: json['rank'] ?? '',
      stopCase: (json['stopCase'] ?? 0).toDouble(),
      stopHour: (json['stopHour'] ?? 0).toDouble(),
      repairFee: (json['repairFee'] ?? 0).toDouble(),
    );
  }

  static void sortByRank(List<MachineAnalysis> list) {
    const monthOrder = {
      "jan": 1,
      "feb": 2,
      "mar": 3,
      "apr": 4,
      "may": 5,
      "jun": 6,
      "jul": 7,
      "aug": 8,
      "sep": 9,
      "oct": 10,
      "nov": 11,
      "dec": 12,
    };

    int? getMonthValue(String rank) {
      // ví dụ: "Apr-Jun" -> ["Apr", "Jun"]
      final parts = rank.split(RegExp(r'[-\s]'));
      if (parts.isNotEmpty) {
        final first = parts.first.toLowerCase();
        return monthOrder[first];
      }
      return null;
    }

    list.sort((a, b) {
      final numA = int.tryParse(a.rank);
      final numB = int.tryParse(b.rank);

      if (numA != null && numB != null) {
        return numA.compareTo(numB); // so sánh số
      }

      final monthA = getMonthValue(a.rank);
      final monthB = getMonthValue(b.rank);

      if (monthA != null && monthB != null) {
        return monthA.compareTo(monthB); // so sánh theo tháng
      }

      if (numA == null && numB == null) {
        return a.rank.toLowerCase().compareTo(
          b.rank.toLowerCase(),
        ); // fallback alphabet
      }

      return numA != null ? -1 : 1; // số đứng trước
    });
  }

  Map<String, dynamic> toJson() {
    return {
      'Div': div,
      'MacName': macName,
      'Rank': rank,
      'StopCase': stopCase,
      'StopHour': stopHour,
      'RepairFee': repairFee,
    };
  }
}
