import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/validation/app_validators.dart';

void main() {
  group('AppValidators', () {
    test('validates names without allowing digits or symbols', () {
      expect(AppValidators.isValidPersonName('María José'), isTrue);
      expect(AppValidators.isValidPersonName("O'Connor"), isTrue);
      expect(AppValidators.isValidPersonName('A'), isFalse);
      expect(AppValidators.isValidPersonName('Felipe123'), isFalse);
    });

    test('validates complete email addresses', () {
      expect(AppValidators.isValidEmail('alumno@gym.cl'), isTrue);
      expect(AppValidators.isValidEmail('alumno@'), isFalse);
      expect(AppValidators.isValidEmail('alumno@gym'), isFalse);
    });

    test('normalizes and validates Chilean mobile phones', () {
      expect(
        AppValidators.normalizeChileanPhone('+569 1234 5678'),
        '+56912345678',
      );
      expect(AppValidators.isValidChileanMobile('+569 1234 5678'), isTrue);
      expect(AppValidators.isValidChileanMobile('+562 1234 5678'), isFalse);
      expect(AppValidators.isValidChileanMobile('+569ABC'), isFalse);
    });

    test('parses dates strictly and rejects impossible dates', () {
      expect(
        AppValidators.parseStrictDate('29-02-2024'),
        DateTime(2024, 2, 29),
      );
      expect(AppValidators.parseStrictDate('31-02-2024'), isNull);
      expect(AppValidators.parseStrictDate('1-2-2024'), isNull);
    });

    test('rejects non-finite decimals and values outside range', () {
      expect(AppValidators.parseDecimal('70,5'), 70.5);
      expect(AppValidators.parseDecimal('NaN'), isNull);
      expect(AppValidators.isDecimalInRange('75', min: 20, max: 400), isTrue);
      expect(AppValidators.isDecimalInRange('-1', min: 0, max: 100), isFalse);
    });
  });
}
