import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/validation/rut_input_formatter.dart';

void main() {
  const formatter = RutInputFormatter();

  TextEditingValue edit(TextEditingValue oldValue, String text, {int? caret}) {
    return formatter.formatEditUpdate(
      oldValue,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: caret ?? text.length),
      ),
    );
  }

  test('agrega puntos y guion mientras se escribe', () {
    var value = TextEditingValue.empty;
    final expected = [
      '1',
      '12',
      '123',
      '1.234',
      '12.345',
      '123.456',
      '1.234.567',
      '1.234.567-8',
      '12.345.678-9',
    ];
    for (var index = 0; index < expected.length; index++) {
      value = edit(value, '${value.text}${index + 1}');
      expect(value.text, expected[index]);
      expect(value.selection.baseOffset, value.text.length);
    }
  });

  test('admite pegado y dígito verificador K', () {
    final value = edit(TextEditingValue.empty, '12.345.678-k');
    expect(value.text, '12.345.678-K');
    expect(edit(value, '${value.text}1').text, '12.345.678-1');
    expect(edit(TextEditingValue.empty, '1234567890').text, '12.345.678-9');
  });

  test('retroceso sobre un separador elimina el dígito anterior', () {
    const oldValue = TextEditingValue(
      text: '12.345',
      selection: TextSelection.collapsed(offset: 3),
    );
    final value = edit(oldValue, '12345', caret: 2);
    expect(value.text, '1.345');
    expect(value.selection.baseOffset, 1);
  });
}
