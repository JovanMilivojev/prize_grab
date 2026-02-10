import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'email': email,
      'username': username,
      'coins': 450,
      'ownedSkins': ['classic'],
      'activeSkin': 'classic',
      'role': 'user',
      'banned': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastDailyBonus': null,
    }, SetOptions(merge: true));
  }
}
