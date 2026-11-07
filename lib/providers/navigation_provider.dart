import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

/// Which bottom tab is open: 0 Home, 1 Reports, 2 Profile.
/// It is shared state so the Home screen can switch to the Reports tab.
class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() {
    // Go back to Home whenever a different user logs in.
    ref.watch(authStateProvider.select((auth) => auth.value?.uid));
    return 0;
  }

  void select(int index) => state = index;
}

final selectedTabProvider =
    NotifierProvider<SelectedTabNotifier, int>(SelectedTabNotifier.new);
