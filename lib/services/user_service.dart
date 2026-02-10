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

  Future<int> claimDailyBonus({required String uid, int amount = 100}) async {
    final userRef = _firestore.collection('users').doc(uid);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('Korisnicki profil ne postoji.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final lastBonus = data['lastDailyBonus'] as Timestamp?;
      final now = DateTime.now();

      if (lastBonus != null) {
        final elapsed = now.difference(lastBonus.toDate());
        if (elapsed < const Duration(hours: 24)) {
          return 0;
        }
      }

      final coins = (data['coins'] as num?)?.toInt() ?? 0;
      transaction.update(userRef, {
        'coins': coins + amount,
        'lastDailyBonus': Timestamp.now(),
      });

      return amount;
    });
  }
}
