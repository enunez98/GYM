class AppValidators {
  AppValidators._();

  static final RegExp _emailPattern = RegExp(
    r"^[A-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?(?:\.[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?)+$",
    caseSensitive: false,
  );
  static final RegExp _personNamePattern = RegExp(
    r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ' -]+$",
  );

  static bool isValidEmail(String value) {
    final email = value.trim();
    return email.length <= 254 && _emailPattern.hasMatch(email);
  }

  static bool isValidPersonName(String value) {
    final name = value.trim();
    return name.length >= 2 &&
        name.length <= 60 &&
        _personNamePattern.hasMatch(name);
  }

  static String normalizeChileanPhone(String value) {
    final clean = value.replaceAll(RegExp(r'[\s()-]'), '');
    if (clean.startsWith('9') && clean.length == 9) return '+56$clean';
    if (clean.startsWith('569') && clean.length == 11) return '+$clean';
    return clean;
  }

  static bool isValidChileanMobile(String value) {
    return RegExp(r'^\+569\d{8}$').hasMatch(normalizeChileanPhone(value));
  }

  static DateTime? parseStrictDate(String value) {
    final match = RegExp(
      r'^(\d{2})[-/](\d{2})[-/](\d{4})$',
    ).firstMatch(value.trim());
    if (match == null) return null;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.day != day || date.month != month || date.year != year) {
      return null;
    }
    return date;
  }

  static double? parseDecimal(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    if (normalized.isEmpty) return null;
    final parsed = double.tryParse(normalized);
    if (parsed == null || !parsed.isFinite) return null;
    return parsed;
  }

  static bool isDecimalInRange(
    String value, {
    required double min,
    required double max,
  }) {
    final parsed = parseDecimal(value);
    return parsed != null && parsed >= min && parsed <= max;
  }

  static bool isIntegerInRange(
    String value, {
    required int min,
    required int max,
  }) {
    final parsed = int.tryParse(value.trim());
    return parsed != null && parsed >= min && parsed <= max;
  }
}
