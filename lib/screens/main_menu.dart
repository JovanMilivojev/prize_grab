import 'package:flutter/material.dart';
import '../widgets/my_button.dart';
import 'gamescreen.dart';
import 'leaderboard.dart';
import 'login_screen.dart';
import 'shop.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});
  static const route = '/';

  @override
  Widget build(BuildContext context) {
    // POZADINSKA SLIKA
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/PrizeGrabBG.png',
              fit: BoxFit.cover,
            ),
          ),
          // OVERLAY
          Positioned.fill(
            child: Container(
              color: const Color(
                0xFFB3E5FC,
              ).withOpacity(0.25), // ledeno-plavi overlay
            ),
          ),
          // SADRŽAJ EKRANA (naslov + dugmad)
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Prize Grab',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,

                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black38,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),
                      const Text(
                        'Main Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      // GLAVNO DUGME
                      MyButton(
                        text: 'Play Game',
                        isPrimary: true, // crveni stil
                        onPressed: () =>
                            Navigator.pushNamed(context, GameScreen.route),
                      ),

                      const SizedBox(height: 14),

                      MyButton(
                        text: 'Leaderboard',
                        icon: Icons.emoji_events_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, Leaderboard.route),
                      ),

                      const SizedBox(height: 14),

                      MyButton(
                        text: 'Shop',
                        icon: Icons.storefront_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, ShopScreen.route),
                      ),

                      const SizedBox(height: 14),

                      MyButton(
                        text: 'Login',
                        icon: Icons.login,
                        onPressed: () =>
                            Navigator.pushNamed(context, LoginScreen.route),
                      ),

                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
