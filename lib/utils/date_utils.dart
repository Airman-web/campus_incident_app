import 'package:intl/intl.dart';

/// Short relative time, for example "2 hours ago".
String timeAgo(DateTime date, {DateTime? now}) {
  final difference = (now ?? DateTime.now()).difference(date);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }
  if (difference.inDays < 7) {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  }
  return DateFormat('d MMM yyyy').format(date);
}

/// Full date and time, for example "15 Oct 2026, 10:24 AM".
String formatDateTime(DateTime date) =>
    DateFormat('d MMM yyyy, h:mm a').format(date);

/// Short date and time for the timeline, for example "15 Oct, 10:24 AM".
String formatShortDate(DateTime date) => DateFormat('d MMM, h:mm a').format(date);
