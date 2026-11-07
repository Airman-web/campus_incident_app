import 'package:flutter/material.dart';

import '../models/incident.dart';
import '../models/incident_status.dart';
import '../utils/date_utils.dart';

/// Three steps (Submitted, In Progress, Resolved) joined by a line.
/// Steps the report has reached are filled in with the date they happened.
class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.incident});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    const steps = IncidentStatus.values;
    final currentIndex = steps.indexOf(incident.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: _TimelineStep(
              status: steps[i],
              reached: i <= currentIndex,
              isCurrent: i == currentIndex,
              showLeftLine: i > 0,
              showRightLine: i < steps.length - 1,
              rightLineReached: i < currentIndex,
              date: i <= currentIndex ? incident.lastChangeFor(steps[i]) : null,
            ),
          ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.status,
    required this.reached,
    required this.isCurrent,
    required this.showLeftLine,
    required this.showRightLine,
    required this.rightLineReached,
    required this.date,
  });

  final IncidentStatus status;
  final bool reached;
  final bool isCurrent;
  final bool showLeftLine;
  final bool showRightLine;
  final bool rightLineReached;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactive = Colors.grey.shade300;

    Widget line({required bool visible, required bool filled}) => Expanded(
          child: Container(
            height: 3,
            color: !visible ? Colors.transparent : (filled ? primary : inactive),
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            line(visible: showLeftLine, filled: reached),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: reached ? primary : Colors.grey.shade200,
                border: isCurrent
                    ? Border.all(color: primary.withValues(alpha: 0.3), width: 4)
                    : null,
              ),
              child: Icon(
                reached && !isCurrent ? Icons.check : status.icon,
                size: 16,
                color: reached ? Colors.white : Colors.black38,
              ),
            ),
            line(visible: showRightLine, filled: rightLineReached),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          status.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: reached ? Colors.black87 : Colors.black45,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date != null ? formatShortDate(date!) : 'Pending',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.black45),
        ),
      ],
    );
  }
}
