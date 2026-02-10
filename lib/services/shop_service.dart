import 'package:cloud_firestore/cloud_firestore.dart';

class InsufficientFundsException implements Exception {
  final String message;
  InsufficientFundsException([this.message = 'Nedovoljno sredstava.']);

  @override
  String toString() => message;
}

class NotOwnedException implements Exception {
  final String message;
  NotOwnedException([this.message = 'Skin nije kupljen.']);

  @override
  String toString() => message;
}

class ShopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> buySkin({
    required String uid,
    required String skinId,
    required int price,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('Korisnicki profil ne postoji.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final coins = (data['coins'] as num?)?.toInt() ?? 0;
      final ownedRaw = (data['ownedSkins'] as List?) ?? [];
      final ownedSkins = ownedRaw.map((e) => e.toString()).toSet();

      if (ownedSkins.contains(skinId)) {
        return;
      }

      if (coins < price) {
        throw InsufficientFundsException();
      }

      ownedSkins.add(skinId);

      transaction.update(userRef, {
        'coins': coins - price,
        'ownedSkins': ownedSkins.toList(),
      });
    });
  }

  Future<void> equipSkin({required String uid, required String skinId}) async {
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('Korisnicki profil ne postoji.');
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final ownedRaw = (data['ownedSkins'] as List?) ?? [];
      final ownedSkins = ownedRaw.map((e) => e.toString()).toSet();

      if (skinId != 'classic' && !ownedSkins.contains(skinId)) {
        throw NotOwnedException();
      }

      transaction.update(userRef, {
        'equippedSkinId': skinId,
        'activeSkin': skinId,
      });
    });
  }
}
