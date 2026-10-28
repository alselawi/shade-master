/// Dates as year/month/day with Western digits, the same in every language,
/// so laboratories read them without ambiguity.
String formatDate(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}/${two(date.month)}/${two(date.day)}';
}

/// FDI tooth numbers, e.g. "11, 21".
String formatTeeth(List<int> teeth) => teeth.join(', ');
