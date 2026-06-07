import 'package:factorio_oop/game/factory_flame_game.dart';
import 'package:factorio_oop/main.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('factory game starts from the splash scene', (tester) async {
    final game = FactoryFlameGame();

    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(FactoryGameShell(game: game));
    await tester.pump();

    expect(game.scene, GameScene.splash);
    expect(game.activeScreenLayerSize?.x, greaterThan(0));
    expect(game.activeScreenLayerSize?.y, greaterThan(0));
  });

  testWidgets('new game creates the selected character', (tester) async {
    final game = FactoryFlameGame();

    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(FactoryGameShell(game: game));
    await tester.pump();

    game.startNewGame(CharacterKind.scientist);

    expect(game.scene, GameScene.playing);
    expect(game.selectedCharacterKind, CharacterKind.scientist);
    expect(game.selectedCharacter, isNotNull);
  });

  testWidgets('splash new game button responds to pointer input', (
    tester,
  ) async {
    final game = FactoryFlameGame();

    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(FactoryGameShell(game: game));
    await tester.pump();

    await tester.tapAt(const Offset(640, 402));
    await tester.pump(const Duration(milliseconds: 60));

    expect(game.scene, GameScene.characterSelection);
  });

  testWidgets('character cards respond to pointer input', (tester) async {
    final game = FactoryFlameGame();

    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(FactoryGameShell(game: game));
    await tester.pump();

    game.openCharacterSelection();
    await tester.pump();

    await tester.tapAt(const Offset(640, 360));
    await tester.pump(const Duration(milliseconds: 60));

    expect(game.scene, GameScene.playing);
    expect(game.selectedCharacterKind, CharacterKind.soldier);
  });

  testWidgets('left drag does not pan the map', (tester) async {
    final game = FactoryFlameGame();

    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(FactoryGameShell(game: game));
    await tester.pump();

    game.startNewGame(CharacterKind.worker);
    final before = game.camera.viewfinder.position.clone();

    final gesture = await tester.startGesture(const Offset(640, 360));
    await gesture.moveBy(const Offset(120, 0));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 60));

    expect(game.camera.viewfinder.position, before);
  });

  testWidgets('right drag pan logic moves the map', (tester) async {
    final game = FactoryFlameGame();

    await tester.binding.setSurfaceSize(const Size(1280, 720));
    await tester.pumpWidget(GameWidget(game: game));
    await tester.pump();

    game.startNewGame(CharacterKind.worker);
    final before = game.camera.viewfinder.position.clone();

    game.panByScreenDelta(Vector2(-120, 0));
    await tester.pump(const Duration(milliseconds: 60));

    expect(game.camera.viewfinder.position.x, greaterThan(before.x));
  });
}
