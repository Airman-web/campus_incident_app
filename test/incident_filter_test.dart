import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_filter.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:flutter_test/flutter_test.dart';

Incident makeIncident({
  String title = 'Water shortage',
  String location = 'Student Residence',
  IncidentCategory category = IncidentCategory.water,
  IncidentStatus status = IncidentStatus.submitted,
}) {
  final now = DateTime(2026, 11, 1);
  return Incident(
    id: title,
    title: title,
    description: 'No water since this morning.',
    location: location,
    category: category,
    status: status,
    reporterId: 'student-1',
    reporterName: 'Test Student',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final water = makeIncident();
  final projector = makeIncident(
    title: 'Broken projector',
    location: 'Block B',
    category: IncidentCategory.electricity,
    status: IncidentStatus.inProgress,
  );
  final bin = makeIncident(
    title: 'Overflowing bin',
    location: 'Cafeteria',
    category: IncidentCategory.sanitation,
    status: IncidentStatus.resolved,
  );
  final all = [water, projector, bin];

  test('an empty filter shows everything', () {
    const filter = IncidentFilter();
    expect(all.where(filter.matches), all);
    expect(filter.isActive, isFalse);
  });

  test('filters by status', () {
    const filter = IncidentFilter(status: IncidentStatus.inProgress);
    expect(all.where(filter.matches), [projector]);
  });

  test('filters by category', () {
    const filter = IncidentFilter(category: IncidentCategory.sanitation);
    expect(all.where(filter.matches), [bin]);
  });

  test('search matches title or location, ignoring case', () {
    expect(all.where(const IncidentFilter(query: 'PROJECTOR').matches), [projector]);
    expect(all.where(const IncidentFilter(query: 'cafeteria').matches), [bin]);
  });

  test('search and filters combine', () {
    const filter = IncidentFilter(query: 'b', status: IncidentStatus.resolved);
    expect(all.where(filter.matches), [bin]);
  });

  test('summary counts each status', () {
    final summary = IncidentSummary.fromIncidents(all);
    expect(summary.total, 3);
    expect(summary.submitted, 1);
    expect(summary.inProgress, 1);
    expect(summary.resolved, 1);
  });
}
