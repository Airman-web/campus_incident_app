import 'package:flutter/material.dart';

/// The stages a report goes through, in order.
enum IncidentStatus {
  submitted('Submitted', Color(0xFFE09A00), Icons.send_outlined),
  inProgress('In Progress', Color(0xFF6C4CF1), Icons.autorenew),
  resolved('Resolved', Color(0xFF2E9E5B), Icons.check_circle_outline);

  const IncidentStatus(this.label, this.color, this.icon);

  final String label;
  final Color color;
  final IconData icon;

  /// Reads the value saved in Firestore, for example "inProgress".
  static IncidentStatus fromName(String? name) {
    return IncidentStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => IncidentStatus.submitted,
    );
  }
}
