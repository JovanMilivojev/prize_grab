import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import '../widgets/winter_background.dart';
import 'gamescreen.dart';
import 'leaderboard.dart';
import 'login_screen.dart';
import 'shop.dart';

// Glavni meni ekran
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  static const route = '/';

  @override
  Widget build(BuildContext context) {
    // POZADINSKA SLIKA
    return Scaffold(
      body: WinterBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/PrizeGrabLogo2.png', width: 320),

                  const SizedBox(height: 40),

                  // GLAVNO DUGME
                  MyButton(
                    decorAsset: 'assets/images/snowEdited.png',
                    text: 'Play Game',
                    isPrimary: true, // crveni stil
                    onPressed: () =>
                        Navigator.pushNamed(context, GameScreen.route),
                  ),

                  const SizedBox(height: 14),

                  MyButton(
                    text: 'Leaderboard',
                    decorAsset: 'assets/images/iceEdited.png',
                    decorWidth: 90,
                    decorLeft: -18,
                    decorTop: -6,
                    icon: Icons.emoji_events_outlined,
                    isIcy: true,
                    onPressed: () =>
                        Navigator.pushNamed(context, Leaderboard.route),
                  ),

                  const SizedBox(height: 14),

                  MyButton(
                    text: 'Shop',
                    decorAsset: 'assets/images/iceEdited.png',
                    decorWidth: 90,
                    decorLeft: -18,
                    decorTop: -6,
                    icon: Icons.storefront_outlined,
                    onPressed: () =>
                        Navigator.pushNamed(context, ShopScreen.route),
                    isIcy: true,
                  ),

                  const SizedBox(height: 14),

                  MyButton(
                    text: 'Login',
                    decorAsset: 'assets/images/iceEdited.png',
                    decorWidth: 90,
                    decorLeft: -18,
                    decorTop: -6,
                    icon: Icons.login,
                    onPressed: () =>
                        Navigator.pushNamed(context, LoginScreen.route),
                    isIcy: true,
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
