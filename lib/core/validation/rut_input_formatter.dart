import 'package:flutter/services.dart';

/// Displays a Chilean RUT while keeping the input limited to eight digits
/// plus a numeric or K verification digit.
class RutInputFormatter extends TextInputFormatter {
  const RutInputFormatter();

  static String _clean(String value) {
    final filtered = value.toUpperCase().replaceAll(RegExp(r'[^0-9K]'), '');
    final digits = filtered.replaceAll('K', '');
    final result = '$digits${filtered.endsWith('K') ? 'K' : ''}';
    return result.length > 9 ? result.substring(0, 9) : result;
  }

  static String _format(String value) {
    if (value.isEmpty) return '';
    final hasVerifier = value.length >= 8 || value.endsWith('K');
    final body = hasVerifier ? value.substring(0, value.length - 1) : value;
    final verifier = hasVerifier ? value.substring(value.length - 1) : '';
    final buffer = StringBuffer();
    for (var index = 0; index < body.length; index++) {
      if (index > 0 && (body.length - index) % 3 == 0) buffer.write('.');
      buffer.write(body[index]);
    }
    if (hasVerifier) buffer.write('-$verifier');
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.composing.isCollapsed) return newValue;

    var clean = _clean(newValue.text);
    final oldClean = _clean(oldValue.text);
    final baseOffset = newValue.selection.baseOffset.clamp(
      0,
      newValue.text.length,
    );
    var rawCaret = _clean(newValue.text.substring(0, baseOffset)).length;

    // Backspace on a separator should remove the preceding digit as well.
    if (newValue.text.length < oldValue.text.length &&
        clean == oldClean &&
        rawCaret > 0) {
      clean = clean.replaceRange(rawCaret - 1, rawCaret, '');
      rawCaret--;
    }

    final formatted = _format(clean);
    rawCaret = rawCaret.clamp(0, clean.length);
    var seen = 0;
    var caret = 0;
    while (caret < formatted.length && seen < rawCaret) {
      if (RegExp(r'[0-9K]').hasMatch(formatted[caret])) seen++;
      caret++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: caret),
    );
  }
}
