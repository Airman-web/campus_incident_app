import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../utils/app_exception.dart';
import '../../widgets/empty_state.dart';
import '../main_shell.dart';
import 'login_screen.dart';
import 'verify_email_screen.dart';

/// Decides the first screen from the login state:
/// logged out -> Login, not verified -> Verify email, verified -> the app.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not check your login',
          message: friendlyError(error),
        ),
      ),
      data: (user) {
        if (user == null) return const LoginScreen();
        if (!user.emailVerified) return const VerifyEmailScreen();
        return const MainShell();
      },
    );
  }
}
