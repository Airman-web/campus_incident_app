import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/incident.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../utils/app_exception.dart';
import '../../utils/date_utils.dart';
import '../../utils/snackbars.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_thumbnail.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_timeline.dart';
import 'update_status_sheet.dart';

class IncidentDetailsScreen extends ConsumerWidget {
  const IncidentDetailsScreen({super.key, required this.incidentId});

  final String incidentId;

  static Route<void> route(String incidentId) => MaterialPageRoute(
        builder: (_) => IncidentDetailsScreen(incidentId: incidentId),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentByIdProvider(incidentId));
    final profile = ref.watch(currentUserProfileProvider).value;

    return incidentAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.cloud_off_outlined,
          title: 'Could not load this report',
          message: friendlyError(error),
        ),
      ),
      data: (incident) {
        if (incident == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.delete_outline,
              title: 'Report not found',
              message: 'This report may have been deleted.',
            ),
          );
        }

        final isStaff = profile?.isStaff ?? false;
        final isOwner = incident.reporterId == profile?.uid;
        // Students can delete only while staff have not started on it.
        final canDelete =
            isStaff || (isOwner && incident.status == IncidentStatus.submitted);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Incident Details'),
            actions: [
              if (canDelete)
                IconButton(
                  tooltip: 'Delete report',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, incident),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IncidentThumbnail(incident: incident, size: 64),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incident.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            StatusChip(status: incident.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: incident.category.icon,
                        label: 'Category',
                        value: incident.category.label,
                      ),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: 'Location',
                        value: incident.location,
                      ),
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Submitted',
                        value: formatDateTime(incident.createdAt),
                      ),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Reported by',
                        value: isOwner ? 'You' : incident.reporterName,
                      ),
                    ],
                  ),
                ),
              ),
              const _SectionTitle('Status Timeline'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StatusTimeline(incident: incident),
                ),
              ),
              const _SectionTitle('Description'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(incident.description, style: const TextStyle(height: 1.5)),
                ),
              ),
              if (incident.hasPhoto) ...[
                const _SectionTitle('Attached Photo'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    incident.photoUrl!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 220,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                      height: 120,
                      child: Center(child: Text('Photo could not be loaded')),
                    ),
                  ),
                ),
              ],
              const _SectionTitle('Activity'),
              Card(
                child: Column(
                  children: [
                    for (final change in incident.history.reversed)
                      _ActivityTile(change: change),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isStaff
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Update Status'),
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => UpdateStatusSheet(incident: incident),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This removes the report and its photo. It cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              minimumSize: const Size(88, 44),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await ref.read(incidentControllerProvider.notifier).delete(incident);
    if (success) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted')));
    } else if (context.mounted) {
      showError(context, ref.read(incidentControllerProvider).error);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black45),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.change});

  final StatusChange change;

  @override
  Widget build(BuildContext context) {
    final note = change.note;
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: change.status.color.withValues(alpha: 0.12),
        child: Icon(change.status.icon, size: 18, color: change.status.color),
      ),
      title: Text(change.status.label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        [
          '${change.changedByName} · ${formatDateTime(change.changedAt)}',
          if (note != null && note.isNotEmpty) note,
        ].join('\n'),
      ),
      isThreeLine: note != null && note.isNotEmpty,
    );
  }
}
