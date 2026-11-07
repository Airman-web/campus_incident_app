import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../services/incident_service.dart';
import '../services/storage_service.dart';
import '../services/user_service.dart';

// Firebase objects. Keeping them in providers means the rest of the app
// never calls FirebaseAuth.instance (and friends) directly.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// One HTTP client for talking to Cloudinary. It is closed when no longer used.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

// Services, built from the Firebase objects above.
final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(firebaseAuthProvider)),
);
final userServiceProvider = Provider<UserService>(
  (ref) => UserService(ref.watch(firestoreProvider)),
);
final incidentServiceProvider = Provider<IncidentService>(
  (ref) => IncidentService(ref.watch(firestoreProvider)),
);
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(ref.watch(httpClientProvider)),
);
