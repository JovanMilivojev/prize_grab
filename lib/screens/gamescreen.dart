import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const route = '/game';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Game Screen')));
  }
}
