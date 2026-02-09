import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';

class PrizeGrabGame extends FlameGame with HasCollisionDetection {
  // GAME STATE (score, hits, time)
  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> time = ValueNotifier(0);
  final ValueNotifier<int> hits = ValueNotifier(0);
  final ValueNotifier<bool> isGameOver = ValueNotifier(false);
  bool isReady = false;

  // PLAYER (Santa)
  late PlayerSanta player;

  // JOYSTICK / INPUT
  late JoystickComponent joystick;

  // SPAWN LOGIC (gifts, ice)
  final Random random = Random();
  double normalSpawnTimer = 0;
  double specialSpawnTimer = 0;
  double iceSpawnTimer = 0;
  double timeAccumulator = 0;

  late Sprite normalGiftSprite;
  late Sprite specialGiftSprite;
  late Sprite iceSprite;
  late Sprite santaSprite;

  PrizeGrabGame({this.santaSpritePath = 'assets/images/FullBodySanta.png'});

  final String santaSpritePath;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    santaSprite = await loadSprite(resolveImagePath(santaSpritePath));
    normalGiftSprite = await loadSprite(
      resolveImagePath('assets/images/NormalGift.png'),
    );
    specialGiftSprite = await loadSprite(
      resolveImagePath('assets/images/SpecialGift.png'),
    );
    iceSprite = await loadSprite(resolveImagePath('assets/images/ICECUBE.png'));

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 22,
        paint: Paint()..color = const Color(0xFFFFFFFF),
      ),
      background: CircleComponent(
        radius: 46,
        paint: Paint()..color = const Color(0xFFB3E5FC).withOpacity(0.55),
      ),
      margin: const EdgeInsets.only(left: 22, bottom: 22),
    );
    add(joystick);

    player = PlayerSanta(sprite: santaSprite);
    player.position = Vector2(size.x / 2, size.y - 120);
    add(player);

    resetSpawnTimers();
    isReady = true;
  }

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isReady) {
      player.updateSizeForScreen(size);
      player.position = Vector2(size.x / 2, size.y - 120);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isReady) return;
    if (isGameOver.value) return;
    if (size.x <= 0 || size.y <= 0) return;

    // TIME COUNT
    timeAccumulator += dt;
    if (timeAccumulator >= 1) {
      time.value += 1;
      timeAccumulator -= 1;
    }

    // JOYSTICK MOVE
    if (joystick.direction != JoystickDirection.idle) {
      player.moveWithJoystick(joystick.relativeDelta, dt, size);
    }

    // SPAWN LOGIC
    normalSpawnTimer -= dt;
    if (normalSpawnTimer <= 0) {
      spawnNormalGift();
      normalSpawnTimer = randomRange(1.2, 1.8);
    }

    specialSpawnTimer -= dt;
    if (specialSpawnTimer <= 0) {
      spawnSpecialGift();
      specialSpawnTimer = randomRange(4.0, 6.0);
    }

    iceSpawnTimer -= dt;
    if (iceSpawnTimer <= 0) {
      spawnIceCube();
      iceSpawnTimer = randomRange(1.0, 1.6);
    }
  }

  void resetSpawnTimers() {
    normalSpawnTimer = randomRange(1.2, 1.8);
    specialSpawnTimer = randomRange(4.0, 6.0);
    iceSpawnTimer = randomRange(1.0, 1.6);
  }

  double randomRange(double min, double max) {
    return min + random.nextDouble() * (max - min);
  }

  String resolveImagePath(String path) {
    const prefix = 'assets/images/';
    if (path.startsWith(prefix)) {
      return path.substring(prefix.length);
    }
    return path;
  }

  void spawnNormalGift() {
    final item = NormalGift(
      sprite: normalGiftSprite,
      speed: randomRange(90, 150),
    );
    item.position = Vector2(randomX(item.size.x), -20);
    add(item);
  }

  void spawnSpecialGift() {
    final item = SpecialGift(
      sprite: specialGiftSprite,
      speed: randomRange(100, 170),
    );
    item.position = Vector2(randomX(item.size.x), -20);
    add(item);
  }

  void spawnIceCube() {
    final item = IceCube(sprite: iceSprite, speed: randomRange(110, 180));
    item.position = Vector2(randomX(item.size.x), -20);
    add(item);
  }

  double randomX(double itemWidth) {
    final minX = itemWidth / 2;
    final maxX = size.x - itemWidth / 2;
    return minX + random.nextDouble() * (maxX - minX);
  }

  // COLLISION HANDLING
  void onGiftCollected(int points) {
    score.value += points;
  }

  void onIceHit() {
    hits.value += 1;
    if (hits.value >= 2 && !isGameOver.value) {
      isGameOver.value = true;
      pauseEngine();
    }
  }

  // GAME OVER + RESET
  void resetGame() {
    score.value = 0;
    time.value = 0;
    hits.value = 0;
    isGameOver.value = false;
    timeAccumulator = 0;

    for (final item in children.whereType<FallingItem>().toList()) {
      item.removeFromParent();
    }

    player.position = Vector2(size.x / 2, size.y - 120);
    resetSpawnTimers();
    resumeEngine();
  }
}

class PlayerSanta extends SpriteComponent
    with CollisionCallbacks, HasGameRef<PrizeGrabGame> {
  PlayerSanta({required Sprite sprite})
    : super(sprite: sprite, anchor: Anchor.center);

  final double speed = 220;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    paint = Paint()..filterQuality = FilterQuality.high;
    updateSizeForScreen(gameRef.size);
    add(CircleHitbox());
  }

  void updateSizeForScreen(Vector2 gameSize) {
    final targetHeight = (gameSize.y * 0.18).clamp(110.0, 170.0).toDouble();
    final ratio = sprite!.srcSize.x / sprite!.srcSize.y;
    size = Vector2(targetHeight * ratio, targetHeight);
  }

  void moveWithJoystick(Vector2 delta, double dt, Vector2 gameSize) {
    if (delta.length2 == 0) return;
    final move = delta.normalized() * speed * dt;
    position.add(move);
    final clampedX = position.x.clamp(size.x / 2, gameSize.x - size.x / 2);
    final clampedY = position.y.clamp(size.y / 2, gameSize.y - size.y / 2);
    position = Vector2(clampedX.toDouble(), clampedY.toDouble());
  }
}

class FallingItem extends SpriteComponent
    with CollisionCallbacks, HasGameRef<PrizeGrabGame> {
  FallingItem({required Sprite sprite, required this.speed})
    : super(sprite: sprite, size: Vector2(44, 44), anchor: Anchor.center);

  final double speed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    if (position.y > gameRef.size.y + size.y) {
      removeFromParent();
    }
  }
}

class NormalGift extends FallingItem {
  NormalGift({required Sprite sprite, required double speed})
    : super(sprite: sprite, speed: speed);

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is PlayerSanta) {
      gameRef.onGiftCollected(50);
      removeFromParent();
    }
  }
}

class SpecialGift extends FallingItem {
  SpecialGift({required Sprite sprite, required double speed})
    : super(sprite: sprite, speed: speed);

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is PlayerSanta) {
      gameRef.onGiftCollected(100);
      removeFromParent();
    }
  }
}

class IceCube extends FallingItem {
  IceCube({required Sprite sprite, required double speed})
    : super(sprite: sprite, speed: speed);

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is PlayerSanta) {
      gameRef.onIceHit();
      removeFromParent();
    }
  }
}
