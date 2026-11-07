import 'incident.dart';
import 'incident_category.dart';
import 'incident_status.dart';

/// The search text and filters chosen on the Reports screen.
/// A null status or category means "show all".
class IncidentFilter {
  const IncidentFilter({this.query = '', this.status, this.category});

  final String query;
  final IncidentStatus? status;
  final IncidentCategory? category;

  bool get isActive => query.trim().isNotEmpty || status != null || category != null;

  bool matches(Incident incident) {
    if (status != null && incident.status != status) return false;
    if (category != null && incident.category != category) return false;

    final search = query.trim().toLowerCase();
    if (search.isEmpty) return true;
    return incident.title.toLowerCase().contains(search) ||
        incident.description.toLowerCase().contains(search) ||
        incident.location.toLowerCase().contains(search) ||
        incident.category.label.toLowerCase().contains(search);
  }
}

/// Counts shown on the home and profile screens.
class IncidentSummary {
  const IncidentSummary({
    this.total = 0,
    this.submitted = 0,
    this.inProgress = 0,
    this.resolved = 0,
  });

  factory IncidentSummary.fromIncidents(List<Incident> incidents) {
    int count(IncidentStatus status) =>
        incidents.where((incident) => incident.status == status).length;
    return IncidentSummary(
      total: incidents.length,
      submitted: count(IncidentStatus.submitted),
      inProgress: count(IncidentStatus.inProgress),
      resolved: count(IncidentStatus.resolved),
    );
  }

  final int total;
  final int submitted;
  final int inProgress;
  final int resolved;
}
