import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String username;
  final String role;
  final bool banned;
  final int coins;
  final Set<String> ownedSkins;
  final String equippedSkinId;
  final DateTime? createdAt;

  const UserProfile({
    this.uid = '',
    this.email = '',
    this.username = '',
    this.role = 'user',
    this.banned = false,
    this.coins = 0,
    this.ownedSkins = const {'classic'},
    this.equippedSkinId = 'classic',
    this.createdAt,
  });

  factory UserProfile.fromMap(
    Map<String, dynamic> data, {
    String uid = '',
  }) {
    final ownedRaw = (data['ownedSkins'] as List?) ?? const ['classic'];
    final equipped = (data['equippedSkinId'] as String?) ??
        (data['activeSkin'] as String?) ??
        'classic';
    final createdAt = data['createdAt'];
    return UserProfile(
      uid: uid.isNotEmpty ? uid : (data['uid'] as String? ?? ''),
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
      banned: data['banned'] as bool? ?? false,
      coins: (data['coins'] as num?)?.toInt() ?? 0,
      ownedSkins: ownedRaw.map((e) => e.toString()).toSet(),
      equippedSkinId: equipped,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap({bool includeUid = true}) {
    return {
      if (includeUid && uid.isNotEmpty) 'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'banned': banned,
      'coins': coins,
      'ownedSkins': ownedSkins.toList(),
      'equippedSkinId': equippedSkinId,
    };
  }
}
