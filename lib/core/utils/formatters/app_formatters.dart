import 'package:intl/intl.dart';

/// Date / time formatters for Kingdom Heir UI.
abstract final class AppDateFormatters {
  /// Formats a [DateTime] as "Mon, Jun 15, 2026"
  static String eventDate(DateTime date) =>
      DateFormat('EEE, MMM d, y').format(date);

  /// Formats a [DateTime] as "Jun 15"
  static String shortDate(DateTime date) => DateFormat('MMM d').format(date);

  /// Formats a [DateTime] as "9:00 AM"
  static String time(DateTime date) => DateFormat('h:mm a').format(date);

  /// Formats a [DateTime] as relative (e.g. "2 hours ago")
  static String relative(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return shortDate(date);
  }
}

/// Currency formatters.
abstract final class AppCurrencyFormatters {
  static final _usd = NumberFormat.currency(symbol: r'$');

  /// Formats a double as "\$1,240.00"
  static String usd(double amount) => _usd.format(amount);

  /// Formats a double as "\$1.2K" for compact display.
  static String compact(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return usd(amount);
  }
}

/// Duration formatters for media playback.
abstract final class AppDurationFormatters {
  /// Formats seconds as "38:05"
  static String fromSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
