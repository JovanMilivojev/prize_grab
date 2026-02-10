import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitScore({required int score}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Korisnik nije ulogovan.');
    }

    final uid = user.uid;
    String username = 'Unknown';

    try {
      final userSnapshot = await _firestore.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data();
        final storedUsername = data?['username'] as String?;
        if (storedUsername != null && storedUsername.trim().isNotEmpty) {
          username = storedUsername.trim();
        } else {
          final email = data?['email'] as String?;
          username = email ?? user.email ?? 'Unknown';
        }
      } else {
        username = user.email ?? 'Unknown';
      }
    } catch (_) {
      username = user.email ?? 'Unknown';
    }

    try {
      await _firestore.collection('scores').add({
        'uid': uid,
        'username': username,
        'score': score,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Neuspesan upis skora: $e');
    }
  }

  Stream<QuerySnapshot> topScoresStream({int limit = 7}) {
    return _firestore
        .collection('scores')
        .orderBy('score', descending: true)
        .limit(limit)
        .snapshots();
  }
}
