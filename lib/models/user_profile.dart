class UserProfile {
  final int coins;
  final Set<String> ownedSkins;
  final String equippedSkinId;

  const UserProfile({
    required this.coins,
    required this.ownedSkins,
    required this.equippedSkinId,
  });
}
