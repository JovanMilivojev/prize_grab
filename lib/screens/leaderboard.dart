import 'package:flutter/material.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({super.key});
  static const route = '/leaderboard';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Leaderboard Screen')));
  }
}
