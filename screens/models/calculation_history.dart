class CalculationHistory {
  final String id;
  final String title;
  final double usageHours;
  final String costPerMonth;
  final String costPerYear;
  final DateTime date;

  CalculationHistory({
    required this.id,
    required this.title,
    required this.usageHours,
    required this.costPerMonth,
    required this.costPerYear,
    required this.date,
  });
}
