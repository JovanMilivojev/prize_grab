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
      'email': email,
      'username': username,
      'coins': 450,
      'ownedSkins': ['classic'],
      'equippedSkinId': 'classic',
      'activeSkin': 'classic',
      'role': 'user',
      'banned': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastDailyBonus': null,
    }, SetOptions(merge: true));
  }

  Stream<UserProfile> streamUserProfile(String uid) {
    final userRef = _firestore.collection('users').doc(uid);
    return userRef.snapshots().asyncMap((snapshot) async {
      final data = snapshot.data() ?? {};
      final updates = _buildDefaultUpdates(data);

      if (!snapshot.exists || updates.isNotEmpty) {
        await userRef.set(updates, SetOptions(merge: true));
      }

      final merged = {...data, ...updates};
      return _profileFromData(merged);
    });
  }

  Future<void> ensureUserDefaults(
    String uid, {
    String? email,
    String? username,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};
    final updates = _buildDefaultUpdates(data);

    if (!snapshot.exists) {
      if (email != null) updates['email'] = email;
      if (username != null) updates['username'] = username;
    }

    if (updates.isNotEmpty) {
      await userRef.set(updates, SetOptions(merge: true));
    }
  }

  Map<String, dynamic> _buildDefaultUpdates(Map<String, dynamic> data) {
    final Map<String, dynamic> updates = {};

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
      updates['activeSkin'] = updates['equippedSkinId'] ?? active ?? 'classic';
    }

    return updates;
  }

  UserProfile _profileFromData(Map<String, dynamic> data) {
    final coins = (data['coins'] as num?)?.toInt() ?? 450;
    final ownedRaw = (data['ownedSkins'] as List?) ?? ['classic'];
    final ownedSkins = ownedRaw.map((e) => e.toString()).toSet();
    final equipped =
        (data['equippedSkinId'] as String?) ??
        (data['activeSkin'] as String?) ??
        'classic';

    return UserProfile(
      coins: coins,
      ownedSkins: ownedSkins,
      equippedSkinId: equipped,
    );
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
