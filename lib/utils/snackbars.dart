import 'package:flutter/material.dart';

import 'app_exception.dart';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showError(BuildContext context, Object? error) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(friendlyError(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
}
