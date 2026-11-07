import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student('Student'),
  staff('Staff');

  const UserRole(this.label);

  final String label;

  static UserRole fromName(String? name) =>
      name == UserRole.staff.name ? UserRole.staff : UserRole.student;
}

/// A user's profile, stored in Firestore at users/{uid}.
/// The role decides what the user can see and do.
class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;

  bool get isStaff => role == UserRole.staff;

  String get firstName {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'there' : trimmed.split(' ').first;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: UserRole.fromName(data['role'] as String?),
    );
  }

  /// The data written when the profile is first created.
  Map<String, dynamic> toCreateMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
