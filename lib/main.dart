import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/main_menu.dart';
import 'screens/login_screen.dart';
import 'screens/adminscreen.dart';
import 'screens/leaderboard.dart';
import 'screens/shop.dart';
import 'screens/gamescreen.dart';
import 'screens/tapscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PrizeGrabApp());
}

class PrizeGrabApp extends StatelessWidget {
  const PrizeGrabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prize Grab',
      debugShowCheckedModeBanner: false,
      initialRoute: TapScreen.route,
      routes: {
        MainMenuScreen.route: (_) => const MainMenuScreen(),
        GameScreen.route: (_) => const GameScreen(),
        Leaderboard.route: (_) => const Leaderboard(),
        ShopScreen.route: (_) => const ShopScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        AdminScreen.route: (_) => const AdminScreen(),
        TapScreen.route: (_) => const TapScreen(),
      },
    );
  }
}
