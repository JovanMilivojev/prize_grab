import 'package:flutter/material.dart';
import '../widgets/winter_background.dart';
import '../widgets/hud_card.dart';
import '../widgets/joystick_widget.dart';
import '../widgets/round_menu_button.dart';
import 'main_menu.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const route = '/game';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WinterBackground(
        child: Stack(
          children: [
            // GAME AREA PLACEHOLDER
            Center(
              child: Image.asset(
                'assets/images/FullBodySanta.png',
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              left: 90,
              top: 140,
              child: Image.asset('assets/images/NormalGift.png', width: 56),
            ),
            Positioned(
              right: 120,
              top: 180,
              child: Image.asset('assets/images/SpecialGift.png', width: 54),
            ),
            Positioned(
              right: 200,
              bottom: 180,
              child: Image.asset('assets/images/ICECUBE.png', width: 48),
            ),

            // SCORE HUD
            const Positioned(
              left: 14,
              top: 14,
              child: HudCard(title: 'Your score', value: '0'),
            ),

            // BACK TO HOME
            Positioned(
              left: 16,
              top: 94,
              child: RoundMenuButton(
                icon: Icons.arrow_back,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    MainMenuScreen.route,
                    (route) => false,
                  );
                },
              ),
            ),

            // TIME HUD
            const Positioned(
              right: 14,
              top: 14,
              child: HudCard(title: 'Time', value: '0s'),
            ),

            // MENU BUTTON
            Positioned(
              right: 16,
              top: 160,
              child: RoundMenuButton(
                icon: Icons.pause,
                onTap: () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Menu (demo)')));
                },
              ),
            ),

            // JOYSTICK UI
            const Positioned(left: 16, bottom: 18, child: JoystickWidget()),
          ],
        ),
      ),
    );
  }
}
