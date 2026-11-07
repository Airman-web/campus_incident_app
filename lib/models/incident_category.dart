import 'package:flutter/material.dart';

/// The kinds of problems a student can report.
enum IncidentCategory {
  facilities('Facilities', Icons.apartment_outlined),
  water('Water', Icons.water_drop_outlined),
  electricity('Electricity', Icons.bolt_outlined),
  furniture('Furniture', Icons.chair_outlined),
  sanitation('Sanitation', Icons.cleaning_services_outlined),
  safety('Safety', Icons.shield_outlined),
  other('Other', Icons.more_horiz);

  const IncidentCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  static IncidentCategory fromName(String? name) {
    return IncidentCategory.values.firstWhere(
      (category) => category.name == name,
      orElse: () => IncidentCategory.other,
    );
  }
}
