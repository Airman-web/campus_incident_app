import 'constants.dart';

/// Form validators. Each one returns null when the value is fine,
/// or an error message to show under the field.
class Validators {
  Validators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isAluEmail(String email) {
    final value = email.trim().toLowerCase();
    if (!_emailPattern.hasMatch(value)) return false;
    final domain = value.split('@').last;
    return allowedEmailDomains.contains(domain);
  }

  static bool isStaffEmail(String email) =>
      isAluEmail(email) && email.trim().toLowerCase().endsWith('@$staffEmailDomain');

  static String? aluEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
    if (!isAluEmail(email)) {
      return 'Use your ALU email (@$studentEmailDomain or @$staffEmailDomain)';
    }
    return null;
  }

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Please enter your full name';
    if (name.length < 2) return 'Name is too short';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  /// Checks a required text field, such as a report title.
  static String? text(
    String? value, {
    required String label,
    int min = 1,
    int max = 500,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label is required';
    if (text.length < min) return '$label must be at least $min characters';
    if (text.length > max) return '$label must be at most $max characters';
    return null;
  }
}
