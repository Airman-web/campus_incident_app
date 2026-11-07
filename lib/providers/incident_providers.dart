import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/incident.dart';
import '../models/incident_category.dart';
import '../models/incident_filter.dart';
import '../models/incident_status.dart';
import '../utils/app_exception.dart';
import 'auth_providers.dart';
import 'service_providers.dart';

/// Live list of reports. Staff get every report, students only their own.
/// Every screen that shows reports reads from here, so a change made on
/// one screen appears on all the others right away.
final incidentsProvider = StreamProvider<List<Incident>>((ref) {
  final user = ref.watch(
    currentUserProfileProvider.select((profile) {
      final value = profile.value;
      return value == null ? null : (uid: value.uid, isStaff: value.isStaff);
    }),
  );
  if (user == null) return Stream.value(const []);

  final service = ref.watch(incidentServiceProvider);
  return user.isStaff ? service.watchAll() : service.watchByReporter(user.uid);
});

/// Holds the search text and filters chosen on the Reports screen.
class IncidentFilterNotifier extends Notifier<IncidentFilter> {
  @override
  IncidentFilter build() {
    // Start fresh whenever a different user logs in.
    ref.watch(authStateProvider.select((auth) => auth.value?.uid));
    return const IncidentFilter();
  }

  void setQuery(String query) => state = IncidentFilter(
        query: query,
        status: state.status,
        category: state.category,
      );

  void setStatus(IncidentStatus? status) => state = IncidentFilter(
        query: state.query,
        status: status,
        category: state.category,
      );

  void setCategory(IncidentCategory? category) => state = IncidentFilter(
        query: state.query,
        status: state.status,
        category: category,
      );

  /// Used by the summary tiles: show only one status and nothing else.
  void showOnly(IncidentStatus? status) => state = IncidentFilter(status: status);

  void clear() => state = const IncidentFilter();
}

final incidentFilterProvider =
    NotifierProvider<IncidentFilterNotifier, IncidentFilter>(IncidentFilterNotifier.new);

/// The report list after the search and filters are applied.
final filteredIncidentsProvider = Provider<AsyncValue<List<Incident>>>((ref) {
  final filter = ref.watch(incidentFilterProvider);
  return ref
      .watch(incidentsProvider)
      .whenData((incidents) => incidents.where(filter.matches).toList());
});

/// Counts for the summary tiles.
final incidentSummaryProvider = Provider<IncidentSummary>((ref) {
  final incidents = ref.watch(incidentsProvider).value ?? const <Incident>[];
  return IncidentSummary.fromIncidents(incidents);
});

/// One report by id, kept live so the details page updates by itself.
final incidentByIdProvider = Provider.family<AsyncValue<Incident?>, String>((ref, id) {
  return ref.watch(incidentsProvider).whenData((incidents) {
    for (final incident in incidents) {
      if (incident.id == id) return incident;
    }
    return null;
  });
});

/// Runs submit, status update and delete, and tracks loading and errors.
class IncidentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required String title,
    required String description,
    required String location,
    required IncidentCategory category,
    File? photo,
  }) {
    return _run(() async {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null) {
        throw const AppException('Your profile is still loading. Please try again.');
      }
      final storage = ref.read(storageServiceProvider);

      // 1. Upload the photo first (if there is one) to get its link.
      ({String url, String path})? uploaded;
      if (photo != null) {
        try {
          uploaded = await storage.uploadIncidentPhoto(uid: profile.uid, file: photo);
        } catch (_) {
          throw const AppException(
            'The photo could not be uploaded. Remove it or try again.',
          );
        }
      }

      // 2. Save the report in Firestore with the photo link.
      await ref.read(incidentServiceProvider).createIncident(
            title: title,
            description: description,
            location: location,
            category: category,
            reporterId: profile.uid,
            reporterName: profile.name,
            photoUrl: uploaded?.url,
            photoPath: uploaded?.path,
          );
    });
  }

  Future<bool> updateStatus({
    required Incident incident,
    required IncidentStatus status,
    String? note,
  }) {
    return _run(() async {
      final profile = ref.read(currentUserProfileProvider).value;
      if (profile == null || !profile.isStaff) {
        throw const AppException('Only staff can update a report status.');
      }
      final trimmedNote = note?.trim() ?? '';
      await ref.read(incidentServiceProvider).updateStatus(
            incidentId: incident.id,
            status: status,
            changedByName: profile.name,
            note: trimmedNote.isEmpty ? null : trimmedNote,
          );
    });
  }

  /// Deletes the report from Firestore. The photo stays on Cloudinary,
  /// because deleting it needs the API secret, which must not be in the app.
  Future<bool> delete(Incident incident) {
    return _run(() => ref.read(incidentServiceProvider).deleteIncident(incident.id));
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}

final incidentControllerProvider =
    AsyncNotifierProvider<IncidentController, void>(IncidentController.new);
