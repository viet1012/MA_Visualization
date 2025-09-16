class RankConverter {
  static const monthMap = {
    "jan": "01",
    "feb": "02",
    "mar": "03",
    "apr": "04",
    "may": "05",
    "jun": "06",
    "jul": "07",
    "aug": "08",
    "sep": "09",
    "oct": "10",
    "nov": "11",
    "dec": "12",
  };

  /// Convert rank -> {monthFrom, monthTo}
  /// currentYear: năm tham chiếu (ví dụ: 2025)
  static Map<String, String>? convertRankToMonthRange(
    String rank,
    int currentYear,
  ) {
    rank = rank.toLowerCase().trim();

    // Case 1: Rank dạng "Apr-Jun"
    if (rank.contains("-")) {
      final parts = rank.split("-");
      if (parts.length == 2) {
        final from = monthMap[parts[0].trim()]!;
        final to = monthMap[parts[1].trim()]!;
        return {"monthFrom": "$currentYear$from", "monthTo": "$currentYear$to"};
      }
    }

    // Case 2: Rank dạng "Ave: 12M"
    if (rank.contains("12m")) {
      // ví dụ: 12 tháng gần nhất
      final now = DateTime.now();
      final fromDate = DateTime(now.year, now.month - 11, 1);
      final toDate = DateTime(now.year, now.month, 1);

      String fromMonth =
          "${fromDate.year}${fromDate.month.toString().padLeft(2, '0')}";
      String toMonth =
          "${toDate.year}${toDate.month.toString().padLeft(2, '0')}";

      return {"monthFrom": fromMonth, "monthTo": toMonth};
    }

    return null;
  }
}
