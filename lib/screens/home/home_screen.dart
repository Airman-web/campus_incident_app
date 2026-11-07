import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/app_exception.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../../widgets/report_banner.dart';
import '../../widgets/section_header.dart';
import '../../widgets/summary_tile.dart';
import '../details/incident_details_screen.dart';
import '../report_form/report_form_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final incidentsAsync = ref.watch(incidentsProvider);
    final summary = ref.watch(incidentSummaryProvider);
    final isStaff = profile?.isStaff ?? false;
    final primary = Theme.of(context).colorScheme.primary;

    // Sets the filter and jumps to the Reports tab.
    void openReports(IncidentStatus? status) {
      ref.read(incidentFilterProvider.notifier).showOnly(status);
      ref.read(selectedTabProvider.notifier).select(1);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${profile?.firstName ?? 'there'} 👋',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isStaff
                            ? 'Review and resolve campus reports.'
                            : 'Help make our campus safer.\nReport issues and track their resolution.',
                        style: const TextStyle(color: Colors.black54, height: 1.4),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(selectedTabProvider.notifier).select(2),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    child: Text(
                      profile?.initials ?? '?',
                      style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isStaff)
              ReportBanner(
                title: 'Reports waiting for review',
                subtitle: '${summary.submitted} new ${summary.submitted == 1 ? 'report needs' : 'reports need'} attention.',
                buttonLabel: 'Review new reports',
                buttonIcon: Icons.fact_check_outlined,
                onPressed: () => openReports(IncidentStatus.submitted),
              )
            else
              ReportBanner(
                onPressed: () => Navigator.of(context).push(ReportFormScreen.route()),
              ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Report Summary', onSeeAll: () => openReports(null)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SummaryTile(
                    label: isStaff ? 'All Reports' : 'My Reports',
                    count: summary.total,
                    icon: Icons.description_outlined,
                    color: primary,
                    onTap: () => openReports(null),
                  ),
                ),
                const SizedBox(width: 8),
                for (final status in [
                  IncidentStatus.inProgress,
                  IncidentStatus.resolved,
                  IncidentStatus.submitted,
                ]) ...[
                  Expanded(
                    child: SummaryTile(
                      label: status.label,
                      count: switch (status) {
                        IncidentStatus.submitted => summary.submitted,
                        IncidentStatus.inProgress => summary.inProgress,
                        IncidentStatus.resolved => summary.resolved,
                      },
                      icon: status.icon,
                      color: status.color,
                      onTap: () => openReports(status),
                    ),
                  ),
                  if (status != IncidentStatus.submitted) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Recent Reports', onSeeAll: () => openReports(null)),
            const SizedBox(height: 8),
            incidentsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load reports',
                message: friendlyError(error),
              ),
              data: (incidents) {
                if (incidents.isEmpty) {
                  return EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No reports yet',
                    message: isStaff
                        ? 'New reports from students will show up here.'
                        : 'Tap "Report an Issue" to submit your first report.',
                  );
                }
                return Column(
                  children: [
                    for (final incident in incidents.take(3))
                      IncidentCard(
                        incident: incident,
                        onTap: () => Navigator.of(context)
                            .push(IncidentDetailsScreen.route(incident.id)),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
