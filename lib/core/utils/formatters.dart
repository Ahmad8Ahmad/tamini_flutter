/// Formats [value] with thousands separators (e.g. `1234567` -> `"1,234,567"`).
String formatThousands(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buf = StringBuffer(negative ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return buf.toString();
}

/// Display price: whole numbers render without decimals, others keep two, and
/// only the integer part is thousands-separated (e.g. `12` -> `"12"`,
/// `12.5` -> `"12.50"`, `1234.5` -> `"1,234.50"`). Callers append the currency.
String formatPrice(num value) => _groupThousands(formatAmount(value));

/// Raw numeric string for API bodies and form fields: whole numbers drop their
/// decimals, others keep two (e.g. `12` -> `"12"`, `12.5` -> `"12.50"`).
String formatAmount(num value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2);

/// Inserts thousands separators into the integer part of [s] only, leaving any
/// fractional part untouched.
String _groupThousands(String s) {
  final dot = s.indexOf('.');
  final intPart = dot == -1 ? s : s.substring(0, dot);
  final fraction = dot == -1 ? '' : s.substring(dot);
  final negative = intPart.startsWith('-');
  final digits = negative ? intPart.substring(1) : intPart;
  final buf = StringBuffer(negative ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '$buf$fraction';
}
