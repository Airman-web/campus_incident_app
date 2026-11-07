import 'package:flutter/material.dart';

import '../models/incident.dart';

/// The report photo, or the category icon when there is no photo.
class IncidentThumbnail extends StatelessWidget {
  const IncidentThumbnail({super.key, required this.incident, this.size = 56});

  final Incident incident;
  final double size;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fallback = Container(
      width: size,
      height: size,
      color: primary.withValues(alpha: 0.1),
      child: Icon(incident.category.icon, color: primary, size: size * 0.45),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: incident.hasPhoto
          ? Image.network(
              incident.photoUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
            )
          : fallback,
    );
  }
}
