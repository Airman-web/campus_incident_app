import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../providers/navigation_provider.dart';
import '../utils/app_exception.dart';
import '../utils/snackbars.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/empty_state.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'report_form/report_form_screen.dart';
import 'reports/reports_screen.dart';

/// The logged-in part of the app: three tabs and the bottom bar.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => _ProfileProblem(message: friendlyError(error)),
      data: (profile) {
        if (profile == null) {
          return const _ProfileProblem(
            message: 'We could not find your account details.',
          );
        }

        final tab = ref.watch(selectedTabProvider);
        return Scaffold(
          // IndexedStack keeps each tab alive, so scroll position and
          // search text are not lost when switching tabs.
          body: IndexedStack(
            index: tab,
            children: const [HomeScreen(), ReportsScreen(), ProfileScreen()],
          ),
          bottomNavigationBar: AppBottomNav(
            currentIndex: tab,
            onTabSelected: ref.read(selectedTabProvider.notifier).select,
            onReportPressed: () => Navigator.of(context).push(ReportFormScreen.route()),
          ),
        );
      },
    );
  }
}

class _ProfileProblem extends ConsumerWidget {
  const _ProfileProblem({required this.message});

  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(authControllerProvider.notifier);

    return Scaffold(
      body: EmptyState(
        icon: Icons.person_off_outlined,
        title: 'Account problem',
        message: message,
        action: Column(
          children: [
            FilledButton(
              onPressed: () async {
                final success = await controller.repairProfile();
                if (!success && context.mounted) {
                  showError(context, ref.read(authControllerProvider).error);
                }
              },
              child: const Text('Try again'),
            ),
            TextButton(onPressed: controller.logout, child: const Text('Log out')),
          ],
        ),
      ),
    );
  }
}
