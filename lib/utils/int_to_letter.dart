/// Converts a positive integer to Excel-style column letters.
///
/// Examples:
/// - 1 → 'A'
/// - 26 → 'Z'
/// - 27 → 'AA'
/// - 702 → 'ZZ'
/// - 703 → 'AAA'
///
/// Throws [ArgumentError] if [number] is less than 1.
String intToLetter(int number) {
  if (number < 1) {
    throw ArgumentError('Number must be a positive integer, got: $number');
  }

  // Use StringBuffer for efficient string building
  final buffer = StringBuffer();

  // Base of our numbering system (A-Z = 26 letters)
  const base = 26;
  const aCode = 65; // ASCII code for 'A'

  int n = number;
  while (n > 0) {
    // Convert to 0-based index (A=0, B=1, ..., Z=25)
    final remainder = (n - 1) % base;

    // Prepend the character to build result from right to left
    buffer.write(String.fromCharCode(aCode + remainder));

    // Move to next "digit" in base-26 system
    n = (n - 1) ~/ base;
  }

  // Reverse the string since we built it backwards
  return buffer.toString().split('').reversed.join();
}
