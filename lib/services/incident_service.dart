import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_status.dart';

/// Create, read, update and delete for the "incidents" collection.
class IncidentService {
  IncidentService(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  /// Every report on campus. Only staff are allowed to run this query.
  Stream<List<Incident>> watchAll() {
    return _incidents.snapshots().map(_toSortedList);
  }

  /// Only the reports made by one student.
  Stream<List<Incident>> watchByReporter(String uid) {
    return _incidents
        .where('reporterId', isEqualTo: uid)
        .snapshots()
        .map(_toSortedList);
  }

  Future<void> createIncident({
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    required String reporterId,
    required String reporterName,
    String? photoUrl,
    String? photoPath,
  }) async {
    final firstEntry = StatusChange(
      status: IncidentStatus.submitted,
      changedByName: reporterName,
      changedAt: DateTime.now(),
      note: 'Report submitted',
    );

    await _incidents.add({
      'title': title.trim(),
      'description': description.trim(),
      'location': location.trim(),
      'category': category.name,
      'status': IncidentStatus.submitted.name,
      'reporterId': reporterId,
      'reporterName': reporterName,
      'photoUrl': photoUrl,
      'photoPath': photoPath,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': [firstEntry.toMap()],
    });
  }

  /// Staff only: changes the status and adds an entry to the history.
  Future<void> updateStatus({
    required String incidentId,
    required IncidentStatus status,
    required String changedByName,
    String? note,
  }) {
    final change = StatusChange(
      status: status,
      changedByName: changedByName,
      changedAt: DateTime.now(),
      note: note,
    );

    return _incidents.doc(incidentId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusHistory': FieldValue.arrayUnion([change.toMap()]),
    });
  }

  Future<void> deleteIncident(String incidentId) =>
      _incidents.doc(incidentId).delete();

  /// Newest first. Sorting here avoids needing a Firestore index.
  List<Incident> _toSortedList(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final incidents = snapshot.docs.map(Incident.fromFirestore).toList();
    incidents.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return incidents;
  }
}
