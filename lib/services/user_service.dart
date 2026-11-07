import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';
import '../utils/validators.dart';

/// Reads and writes user profiles in the "users" collection.
class UserService {
  UserService(this._db);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  /// Live updates of one profile. Emits null if the profile does not exist.
  Stream<AppUser?> watchUser(String uid) {
    return _userDoc(uid).snapshots().map(
          (snapshot) => snapshot.exists ? AppUser.fromFirestore(snapshot) : null,
        );
  }

  /// Creates the profile if it is missing.
  /// @alueducation.com accounts start as staff, everyone else as a student.
  /// An admin can also promote an account to staff in the Firebase Console.
  Future<void> ensureProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    final doc = _userDoc(uid);
    final snapshot = await doc.get();
    if (snapshot.exists) return;

    final profile = AppUser(
      uid: uid,
      name: name,
      email: email,
      role: Validators.isStaffEmail(email) ? UserRole.staff : UserRole.student,
    );
    await doc.set(profile.toCreateMap());
  }
}
