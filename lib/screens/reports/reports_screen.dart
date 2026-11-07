import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/incident_category.dart';
import '../../models/incident_status.dart';
import '../../providers/auth_providers.dart';
import '../../providers/incident_providers.dart';
import '../../utils/app_exception.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/incident_card.dart';
import '../details/incident_details_screen.dart';

/// Browse, search and filter reports.
/// Students see "My Reports", staff see "All Reports".
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(incidentFilterProvider).query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAll() {
    _searchController.clear();
    ref.read(incidentFilterProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    // Keep the search box in sync if the filter is changed from another
    // screen (for example a summary tile on Home).
    ref.listen(incidentFilterProvider.select((filter) => filter.query), (previous, next) {
      if (_searchController.text != next) _searchController.text = next;
    });

    final isStaff = ref.watch(currentUserProfileProvider).value?.isStaff ?? false;
    final filter = ref.watch(incidentFilterProvider);
    final results = ref.watch(filteredIncidentsProvider);
    final filterNotifier = ref.read(incidentFilterProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(isStaff ? 'All Reports' : 'My Reports')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: filterNotifier.setQuery,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search title, location or category',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          filterNotifier.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ChipRow(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filter.status == null,
                onSelected: (_) => filterNotifier.setStatus(null),
              ),
              for (final status in IncidentStatus.values)
                ChoiceChip(
                  label: Text(status.label),
                  selected: filter.status == status,
                  onSelected: (_) => filterNotifier.setStatus(status),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _ChipRow(
            children: [
              ChoiceChip(
                label: const Text('All categories'),
                selected: filter.category == null,
                onSelected: (_) => filterNotifier.setCategory(null),
              ),
              for (final category in IncidentCategory.values)
                ChoiceChip(
                  avatar: Icon(category.icon, size: 16),
                  label: Text(category.label),
                  selected: filter.category == category,
                  onSelected: (_) => filterNotifier.setCategory(category),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load reports',
                message: friendlyError(error),
              ),
              data: (incidents) {
                if (incidents.isEmpty) {
                  return EmptyState(
                    icon: filter.isActive ? Icons.search_off : Icons.inbox_outlined,
                    title: filter.isActive ? 'No matching reports' : 'No reports yet',
                    message: filter.isActive
                        ? 'Try a different search or filter.'
                        : 'Reports you submit will appear here.',
                    action: filter.isActive
                        ? TextButton(onPressed: _clearAll, child: const Text('Clear filters'))
                        : null,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: incidents.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final count = incidents.length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '$count ${count == 1 ? 'report' : 'reports'}',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }
                    final incident = incidents[index - 1];
                    return IncidentCard(
                      incident: incident,
                      onTap: () => Navigator.of(context)
                          .push(IncidentDetailsScreen.route(incident.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of chips that scrolls sideways.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: children.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}
