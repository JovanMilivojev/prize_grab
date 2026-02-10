import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/skin_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserProfile>> streamUsers() {
    return _firestore.collection('users').orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserProfile.fromMap(doc.data(), uid: doc.id),
              )
              .toList(),
        );
  }

  Future<void> setBanned(String uid, bool banned) {
    return _firestore.collection('users').doc(uid).set(
      {'banned': banned},
      SetOptions(merge: true),
    );
  }

  Stream<List<SkinModel>> streamSkins() {
    return _firestore.collection('skins').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => SkinModel.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<void> updateSkin(
    String skinId, {
    int? price,
    bool? active,
    String? name,
    String? assetPath,
    String? gameplayAssetPath,
  }) {
    final updates = <String, dynamic>{};
    if (price != null) updates['price'] = price;
    if (active != null) updates['active'] = active;
    if (name != null) updates['name'] = name;
    if (assetPath != null) updates['assetPath'] = assetPath;
    if (gameplayAssetPath != null) {
      updates['gameplayAssetPath'] = gameplayAssetPath;
    }
    if (updates.isEmpty) return Future.value();
    updates['updatedAt'] = FieldValue.serverTimestamp();
    return _firestore.collection('skins').doc(skinId).set(
          updates,
          SetOptions(merge: true),
        );
  }
}
