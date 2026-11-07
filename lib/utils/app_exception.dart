import 'package:firebase_core/firebase_core.dart';

/// An error with a message that is safe to show to the user.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Turns any error into a short message for a snack bar or error screen.
String friendlyError(Object? error) {
  if (error is AppException) return error.message;
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'You do not have permission to do that.';
    }
    if (error.code == 'unavailable') {
      return 'Cannot reach the server. Check your internet connection.';
    }
    return error.message ?? 'Something went wrong (${error.code}).';
  }
  return 'Something went wrong. Please try again.';
}
