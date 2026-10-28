import 'package:flutter_test/flutter_test.dart';
import 'package:shadesmaster/utils/int_to_letter.dart';

void main() {
  test('intToLetter converts to spreadsheet-style column letters', () {
    expect(intToLetter(1), 'A');
    expect(intToLetter(26), 'Z');
    expect(intToLetter(27), 'AA');
    expect(intToLetter(702), 'ZZ');
    expect(intToLetter(703), 'AAA');
  });

  test('intToLetter rejects numbers below 1', () {
    expect(() => intToLetter(0), throwsArgumentError);
  });
}
