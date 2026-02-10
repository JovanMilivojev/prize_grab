const String defaultSkinId = 'classic';

String gameplaySpritePathForSkin(String skinId) {
  switch (skinId) {
    case 'gold':
      return 'assets/images/FullBodySantaGold.png';
    case 'glasses':
      return 'assets/images/FullBodySantaGlasses.png';
    case 'snowmanbeard':
      return 'assets/images/Skin4.png';
    case 'snowman':
      return 'assets/images/Skin5.png';
    case 'pipe':
      return 'assets/images/FullBodySantaPipe.png';
    case 'classic':
    default:
      return 'assets/images/FullBodySanta.png';
  }
}
