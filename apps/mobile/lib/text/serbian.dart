String pluralize(int count, {required String one, required String few, required String many}) {
  final lastDigit = count % 10;
  final lastTwoDigits = count % 100;
  if (lastDigit == 1 && lastTwoDigits != 11) return one;
  if (lastDigit >= 2 && lastDigit <= 4 && (lastTwoDigits < 12 || lastTwoDigits > 14)) return few;
  return many;
}

const _months = [
  'januar', 'februar', 'mart', 'april', 'maj', 'jun',
  'jul', 'avgust', 'septembar', 'oktobar', 'novembar', 'decembar'
];

String _twoDigits(int value) => value.toString().padLeft(2, '0');

String formatDate(DateTime date) => '${date.day}. ${_months[date.month - 1]} ${date.year}.';
String formatTime(DateTime date) => '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
String formatDateAndTime(DateTime date) => '${formatDate(date)} u ${formatTime(date)}';
String capitalize(String text) => text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);