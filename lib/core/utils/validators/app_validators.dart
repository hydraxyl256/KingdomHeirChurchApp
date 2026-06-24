/// Form field validators for Kingdom Heir.
abstract final class AppValidators {
  /// Returns an error string if [value] is null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Returns an error string if [value] is not a valid email.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  /// Returns an error string if [value] is shorter than [minLength].
  static String? minLength(String? value, int minLength,
      [String fieldName = 'Password',]) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Returns an error string if [value] does not match [other].
  static String? confirmPassword(String? value, String other) {
    if (value != other) return 'Passwords do not match';
    return null;
  }

  /// Returns an error string if [value] is not a valid phone number.
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    final regex = RegExp(r'^\+?[\d\s\-\(\)]{7,15}$');
    if (!regex.hasMatch(value)) return 'Enter a valid phone number';
    return null;
  }

  /// Returns an error string if [value] is not a positive number.
  static String? positiveAmount(String? value) {
    if (value == null || value.isEmpty) return 'Amount is required';
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }
}
