/// Extension methods on [String] for common transformations.
extension StringExtensions on String {
  /// Capitalises first letter: "hello" → "Hello"
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Converts snake_case to Title Case: "group_leader" → "Group Leader"
  String fromSnakeCase() => split('_').map((w) => w.capitalize()).join(' ');

  /// Returns true if this string is a valid email.
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  /// Returns true if not null or empty after trim.
  bool get isNotBlank => trim().isNotEmpty;

  /// Truncates to [maxLength] chars, appending '…' if cut.
  String truncate(int maxLength) =>
      length > maxLength ? '${substring(0, maxLength)}…' : this;
}

/// Extension methods on nullable [String].
extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}

/// Extension methods on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());
}

/// Extension methods on [List].
extension ListExtensions<T> on List<T> {
  /// Returns null if list is empty, otherwise the first element.
  T? get firstOrNull => isEmpty ? null : first;

  /// Chunks the list into sub-lists of [size].
  List<List<T>> chunked(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, i + size > length ? length : i + size));
    }
    return result;
  }
}
