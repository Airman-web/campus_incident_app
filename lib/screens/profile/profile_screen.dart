import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../widgets/summary_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    if (profile == null) return const SizedBox.shrink();

    final summary = ref.watch(incidentSummaryProvider);
    final primary = Theme.of(context).colorScheme.primary;
    final isStaff = profile.isStaff;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Text(
                profile.initials,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.role.label,
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SummaryTile(
                  label: isStaff ? 'All Reports' : 'My Reports',
                  count: summary.total,
                  icon: Icons.description_outlined,
                  color: primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  label: IncidentStatus.inProgress.label,
                  count: summary.inProgress,
                  icon: IncidentStatus.inProgress.icon,
                  color: IncidentStatus.inProgress.color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SummaryTile(
                  label: IncidentStatus.resolved.label,
                  count: summary.resolved,
                  icon: IncidentStatus.resolved.icon,
                  color: IncidentStatus.resolved.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.verified_outlined, color: Color(0xFF2E9E5B)),
                  title: Text('Email verified'),
                  subtitle: Text('Your ALU email is confirmed.'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Account type'),
                  subtitle: Text(
                    isStaff
                        ? 'Staff: you can review every report and update its status.'
                        : 'Student: you can submit reports and track their progress.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Privacy'),
                  subtitle: Text(
                    isStaff
                        ? 'Reporter names are visible to staff only. Please keep them confidential.'
                        : 'Only you and campus staff can see your reports.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}
