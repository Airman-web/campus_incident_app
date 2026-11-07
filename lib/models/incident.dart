import 'package:cloud_firestore/cloud_firestore.dart';

import 'incident_category.dart';
import 'incident_status.dart';

DateTime _toDate(Object? value) =>
    value is Timestamp ? value.toDate() : DateTime.now();

/// One entry in a report's history, for example "moved to In Progress".
class StatusChange {
  const StatusChange({
    required this.status,
    required this.changedByName,
    required this.changedAt,
    this.note,
  });

  final IncidentStatus status;
  final String changedByName;
  final DateTime changedAt;
  final String? note;

  factory StatusChange.fromMap(Map<String, dynamic> map) => StatusChange(
        status: IncidentStatus.fromName(map['status'] as String?),
        changedByName: map['changedByName'] as String? ?? '',
        changedAt: _toDate(map['changedAt']),
        note: map['note'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'status': status.name,
        'changedByName': changedByName,
        'changedAt': Timestamp.fromDate(changedAt),
        'note': note,
      };
}

/// A report, stored in Firestore at incidents/{id}.
class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.reporterId,
    required this.reporterName,
    required this.createdAt,
    required this.updatedAt,
    this.photoUrl,
    this.photoPath,
    this.history = const [],
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final IncidentCategory category;
  final IncidentStatus status;
  final String reporterId;
  final String reporterName;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Link used to show the photo.
  final String? photoUrl;

  /// Where the photo lives in Firebase Storage, so it can be deleted.
  final String? photoPath;

  final List<StatusChange> history;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;

  /// The most recent time the report reached [status], if it ever did.
  DateTime? lastChangeFor(IncidentStatus status) {
    for (final change in history.reversed) {
      if (change.status == status) return change.changedAt;
    }
    return null;
  }

  factory Incident.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawHistory = data['statusHistory'] as List<dynamic>? ?? const [];
    return Incident(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      category: IncidentCategory.fromName(data['category'] as String?),
      status: IncidentStatus.fromName(data['status'] as String?),
      reporterId: data['reporterId'] as String? ?? '',
      reporterName: data['reporterName'] as String? ?? '',
      createdAt: _toDate(data['createdAt']),
      updatedAt: _toDate(data['updatedAt']),
      photoUrl: data['photoUrl'] as String?,
      photoPath: data['photoPath'] as String?,
      history: rawHistory
          .whereType<Map>()
          .map((entry) => StatusChange.fromMap(Map<String, dynamic>.from(entry)))
          .toList(),
    );
  }
}
