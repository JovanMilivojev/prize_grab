import 'package:flutter/material.dart';
import '../widgets/winter_background.dart';
import 'main_menu.dart';

class TapScreen extends StatefulWidget {
  const TapScreen({super.key});

  static const route = '/tap';

  @override
  State<TapScreen> createState() => TapScreenState();
}

class TapScreenState extends State<TapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  late final Animation<double> logoScale;
  late final Animation<double> logoFloat;
  late final Animation<double> textOpacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Logo: pulse
    logoScale = Tween<double>(
      begin: 0.98,
      end: 1.06,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // Logo: lagano "plivanje" gore/dole
    logoFloat = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    // Tekst: treperi
    textOpacity = Tween<double>(
      begin: 0.35,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void goNext(BuildContext context) {
    Navigator.pushReplacementNamed(context, MainMenuScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => goNext(context),
        child: WinterBackground(
          child: Center(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // LOGO
                    Transform.translate(
                      offset: Offset(0, logoFloat.value),
                      child: Transform.scale(
                        scale: logoScale.value,
                        child: Image.asset(
                          'assets/images/PrizeGrabLogo2.png',
                          width: 310, // bilo 260
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // TEKST
                    Opacity(
                      opacity: textOpacity.value,
                      child: const Text(
                        'Tap to continue',
                        style: TextStyle(
                          fontSize: 20, // bilo 16
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
