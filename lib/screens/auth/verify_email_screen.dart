import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../utils/snackbars.dart';

/// Shown after sign up until the user clicks the link in their email.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _timer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Check every 5 seconds, so the app moves on by itself once verified.
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _check(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _check({bool silent = false}) async {
    if (_checking) return;
    _checking = true;
    final verified =
        await ref.read(authControllerProvider.notifier).checkEmailVerified();
    _checking = false;
    if (!verified && !silent && mounted) {
      showMessage(context, 'Not verified yet. Open the link in your email, then try again.');
    }
  }

  Future<void> _resend() async {
    final success =
        await ref.read(authControllerProvider.notifier).resendVerificationEmail();
    if (!mounted) return;
    if (success) {
      showMessage(context, 'Verification email sent again.');
    } else {
      showError(context, ref.read(authControllerProvider).error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authStateProvider).value?.email ?? 'your email';
    final isLoading = ref.watch(authControllerProvider).isLoading;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.mark_email_unread_outlined, size: 80, color: primary),
                const SizedBox(height: 24),
                const Text(
                  'Verify your email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a verification link to\n$email\n\n'
                  'Open it to activate your account. If you cannot find it, '
                  'check your spam folder.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => _check(),
                  child: const Text('I have verified my email'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: isLoading ? null : _resend,
                  child: const Text('Resend email'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).logout(),
                  child: const Text('Use a different account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
