import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../utils/date_utils.dart';
import 'incident_thumbnail.dart';
import 'status_chip.dart';

/// One row in a report list: picture, title, location, time and status.
class IncidentCard extends StatelessWidget {
  const IncidentCard({super.key, required this.incident, required this.onTap});

  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const greyText = TextStyle(color: Colors.black54, fontSize: 13);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                IncidentThumbnail(incident: incident),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              incident.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: greyText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: Colors.black45),
                          const SizedBox(width: 4),
                          Text(timeAgo(incident.createdAt), style: greyText),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(status: incident.status),
                const Icon(Icons.chevron_right, color: Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
