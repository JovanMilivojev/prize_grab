import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/game.dart';
import '../widgets/winter_background.dart';
import '../widgets/hud_card.dart';
import '../widgets/round_menu_button.dart';
import 'main_menu.dart';
import '../igrica/prize_grab_game.dart';
import '../services/score_service.dart';
import '../services/user_service.dart';
import '../services/skin_assets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const route = '/game';

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  PrizeGrabGame? _game;
  bool _scoreSubmitted = false;
  bool _listenerAttached = false;
  late final VoidCallback _gameOverListener;
  late final Future<String> _spritePathFuture;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _gameOverListener = _handleGameOverChange;
    _spritePathFuture = _loadSpritePath();
  }

  @override
  void dispose() {
    if (_listenerAttached && _game != null) {
      _game!.isGameOver.removeListener(_gameOverListener);
    }
    super.dispose();
  }

  Future<String> _loadSpritePath() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return gameplaySpritePathForSkin(defaultSkinId);
    }

    try {
      await _userService.ensureUserDefaults(user.uid, email: user.email);
      final profile = await _userService.streamUserProfile(user.uid).first;
      return gameplaySpritePathForSkin(profile.equippedSkinId);
    } catch (_) {
      return gameplaySpritePathForSkin(defaultSkinId);
    }
  }

  void _initGame(String spritePath) {
    if (_game != null) return;
    _game = PrizeGrabGame(santaSpritePath: spritePath);
    _game!.isGameOver.addListener(_gameOverListener);
    _listenerAttached = true;
  }

  void _handleGameOverChange() {
    if (_game == null) return;
    if (_game!.isGameOver.value) {
      _submitScoreOnce();
    } else {
      _scoreSubmitted = false;
    }
  }

  Future<void> _submitScoreOnce() async {
    if (_scoreSubmitted) return;
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    _scoreSubmitted = true;
    try {
      await ScoreService().submitScore(score: _game!.score.value);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _spritePathFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: WinterBackground(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
              ),
            ),
          );
        }

        final spritePath =
            snapshot.data ?? gameplaySpritePathForSkin(defaultSkinId);
        _initGame(spritePath);
        final game = _game!;

        return Scaffold(
          body: WinterBackground(
            child: Stack(
              fit: StackFit.expand,
              children: [
                GameWidget(
                  game: game,
                  loadingBuilder: (context) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                    );
                  },
                  errorBuilder: (context, error) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Game error: $error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // SCORE HUD
                Positioned(
                  left: 14,
                  top: 14,
                  child: ValueListenableBuilder<int>(
                    valueListenable: game.score,
                    builder: (context, value, _) {
                      return HudCard(title: 'Your score', value: '$value');
                    },
                  ),
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
                Positioned(
                  right: 14,
                  top: 14,
                  child: ValueListenableBuilder<int>(
                    valueListenable: game.time,
                    builder: (context, value, _) {
                      return HudCard(title: 'Time', value: '${value}s');
                    },
                  ),
                ),

                // MENU BUTTON
                Positioned(
                  right: 16,
                  top: 160,
                  child: RoundMenuButton(
                    icon: Icons.pause,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menu (demo)')),
                      );
                    },
                  ),
                ),

                // GAME OVER OVERLAY
                ValueListenableBuilder<bool>(
                  valueListenable: game.isGameOver,
                  builder: (context, isOver, _) {
                    if (!isOver) return const SizedBox.shrink();
                    return Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 20,
                                  offset: Offset(0, 12),
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Game Over',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: game.resetGame,
                                  child: const Text('Play Again'),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      MainMenuScreen.route,
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Home'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
