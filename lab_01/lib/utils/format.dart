const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String twoDigits(int n) => n.toString().padLeft(2, '0');

String formatHm(int hour, int minute) =>
    '${twoDigits(hour)}:${twoDigits(minute)}';

/// 18 Oct, 10:00
String formatDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]}, ${formatHm(d.hour, d.minute)}';

/// 18 Oct 2026
String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatDuration(Duration d) {
  if (d.inDays > 0) return '${d.inDays} d ${d.inHours % 24} h';
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
  return '${d.inMinutes} min';
}
