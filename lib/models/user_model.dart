import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing a user profile stored in Firestore.
///
/// Each user document is stored in the `users` collection, keyed by their
/// Firebase Authentication UID.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: data['uid'] ?? doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this model to a map suitable for Firestore writes.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, displayName: $displayName)';
}
