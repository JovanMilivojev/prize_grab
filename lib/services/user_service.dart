import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String username,
  }) {
    return _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'username': username,
      'role': 'user',
      'banned': false,
      'coins': 450,
      'ownedSkins': ['classic'],
      'equippedSkinId': 'classic',
      'activeSkin': 'classic',
      'createdAt': FieldValue.serverTimestamp(),
      'lastDailyBonus': null,
    }, SetOptions(merge: true));
  }

  Stream<UserProfile> streamUserProfile(String uid) {
    final userRef = _firestore.collection('users').doc(uid);
    return userRef.snapshots().asyncMap((snapshot) async {
      final data = snapshot.data() ?? {};
      final updates = _buildDefaultUpdates(data, uid: uid);

      if (!snapshot.exists || updates.isNotEmpty) {
        await userRef.set(updates, SetOptions(merge: true));
      }

      final merged = {...data, ...updates};
      return UserProfile.fromMap(merged, uid: uid);
    });
  }

  Future<UserProfile> getUserProfile(
    String uid, {
    String? email,
    String? username,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};

    final updates = _buildDefaultUpdates(data, uid: uid);
    if (!snapshot.exists) {
      if (email != null && email.isNotEmpty) updates['email'] = email;
      if (username != null && username.isNotEmpty) {
        updates['username'] = username;
      }
    }

    if (updates.isNotEmpty) {
      await userRef.set(updates, SetOptions(merge: true));
    }

    final merged = {...data, ...updates};
    return UserProfile.fromMap(merged, uid: uid);
  }

  Future<bool> isAdmin(String uid) async {
    final profile = await getUserProfile(uid);
    return profile.role == 'admin';
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) {
    return _firestore.collection('users').doc(uid).set(
          fields,
          SetOptions(merge: true),
        );
  }

  Stream<List<UserProfile>> streamUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserProfile.fromMap(doc.data(), uid: doc.id))
              .toList(),
        );
  }

  Future<void> setBanned(String uid, bool banned) {
    return updateUserFields(uid, {'banned': banned});
  }

  Future<void> adjustCoins(String uid, int delta) {
    return updateUserFields(uid, {'coins': FieldValue.increment(delta)});
  }

  Future<void> resetSkins(String uid) {
    return updateUserFields(uid, {
      'ownedSkins': ['classic'],
      'equippedSkinId': 'classic',
      'activeSkin': 'classic',
    });
  }

  Future<void> promoteToAdmin(String uid) {
    return updateUserFields(uid, {'role': 'admin'});
  }

  Future<void> ensureUserDefaults(
    String uid, {
    String? email,
    String? username,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};
    final updates = _buildDefaultUpdates(data, uid: uid);

    if (!snapshot.exists) {
      if (email != null) updates['email'] = email;
      if (username != null) updates['username'] = username;
    }

    if (updates.isNotEmpty) {
      await userRef.set(updates, SetOptions(merge: true));
    }
  }

  Map<String, dynamic> _buildDefaultUpdates(
    Map<String, dynamic> data, {
    String? uid,
  }) {
    final Map<String, dynamic> updates = {};

    if (uid != null && uid.isNotEmpty && data['uid'] != uid) {
      updates['uid'] = uid;
    }
    if (!data.containsKey('role')) {
      updates['role'] = 'user';
    }
    if (!data.containsKey('banned')) {
      updates['banned'] = false;
    }
    if (!data.containsKey('coins')) {
      updates['coins'] = 450;
    }
    if (!data.containsKey('ownedSkins')) {
      updates['ownedSkins'] = ['classic'];
    }

    final equipped = data['equippedSkinId'] as String?;
    final active = data['activeSkin'] as String?;
    if (equipped == null || equipped.trim().isEmpty) {
      updates['equippedSkinId'] = (active == null || active.trim().isEmpty)
          ? 'classic'
          : active;
    }
    if (!data.containsKey('activeSkin')) {
      updates['activeSkin'] =
          updates['equippedSkinId'] ?? active ?? 'classic';
    }

    return updates;
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
