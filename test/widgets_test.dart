import 'package:campus_incident_app/models/incident.dart';
import 'package:campus_incident_app/models/incident_category.dart';
import 'package:campus_incident_app/models/incident_status.dart';
import 'package:campus_incident_app/utils/date_utils.dart';
import 'package:campus_incident_app/widgets/status_chip.dart';
import 'package:campus_incident_app/widgets/status_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('StatusChip shows the status label', (tester) async {
    await tester.pumpWidget(wrap(const StatusChip(status: IncidentStatus.inProgress)));
    expect(find.text('In Progress'), findsOneWidget);
  });

  testWidgets('StatusTimeline marks later steps as pending', (tester) async {
    final created = DateTime(2026, 11, 1, 9);
    final incident = Incident(
      id: '1',
      title: 'Leaking tap',
      description: 'Tap in the bathroom is leaking.',
      location: 'Block A',
      category: IncidentCategory.water,
      status: IncidentStatus.inProgress,
      reporterId: 'student-1',
      reporterName: 'Test Student',
      createdAt: created,
      updatedAt: created,
      history: [
        StatusChange(
          status: IncidentStatus.submitted,
          changedByName: 'Test Student',
          changedAt: created,
        ),
        StatusChange(
          status: IncidentStatus.inProgress,
          changedByName: 'Staff',
          changedAt: created.add(const Duration(hours: 2)),
        ),
      ],
    );

    await tester.pumpWidget(wrap(StatusTimeline(incident: incident)));

    expect(find.text('Submitted'), findsOneWidget);
    expect(find.text('In Progress'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
    // Only "Resolved" has not happened yet.
    expect(find.text('Pending'), findsOneWidget);
  });

  test('timeAgo gives readable text', () {
    final now = DateTime(2026, 11, 5, 12);
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now: now), 'Just now');
    expect(timeAgo(now.subtract(const Duration(hours: 2)), now: now), '2 hours ago');
    expect(timeAgo(now.subtract(const Duration(days: 1)), now: now), '1 day ago');
  });
}
