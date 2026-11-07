/// A value for one period, used by the Harian/Mingguan/Bulanan segmented card.
class PeriodStat {
  const PeriodStat({
    required this.label,
    required this.opens,
    required this.previousOpens,
  });

  /// "Hari ini", "Minggu ini", "Bulan ini".
  final String label;

  /// How many times social apps were opened in this period.
  final int opens;

  /// The same figure for the preceding period, for the delta badge.
  final int previousOpens;

  /// Change vs the previous period as a ratio; positive means "more".
  double get deltaRatio {
    if (previousOpens <= 0) return opens > 0 ? 1 : 0;
    return (opens - previousOpens) / previousOpens;
  }
}

/// The three periods shown in the usage card.
class PeriodBreakdown {
  const PeriodBreakdown({
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  final PeriodStat daily;
  final PeriodStat weekly;
  final PeriodStat monthly;

  List<PeriodStat> get all => [daily, weekly, monthly];
}
