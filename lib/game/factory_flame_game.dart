import 'dart:math';

import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/characters/scientist.dart';
import 'package:factorio_oop/characters/soldier.dart';
import 'package:factorio_oop/characters/worker.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum GameScene { splash, characterSelection, playing }

enum TerrainKind { water, grass, dirt, desert, sand, stoneGround, cliff }

enum NaturalKind { tree, rock, hugeRock, bush }

enum ResourceKind { ironOre, copperOre, coal, stone, uraniumOre, crudeOil }

enum CharacterKind {
  worker('Worker', 'Balanced builder with a practical inventory.'),
  soldier('Soldier', 'More weapon slots for future combat.'),
  scientist('Scientist', 'Larger inventory for research-heavy play.');

  final String label;
  final String description;

  const CharacterKind(this.label, this.description);

  Character createCharacter() {
    return switch (this) {
      CharacterKind.worker => Worker(),
      CharacterKind.soldier => Soldier(),
      CharacterKind.scientist => Scientist(),
    };
  }
}

enum BuildKind {
  burnerMiningDrill('Burner Mining Drill'),
  electricMiningDrill('Electric Mining Drill'),
  stoneFurnace('Stone Furnace'),
  steelFurnace('Steel Furnace'),
  electricFurnace('Electric Furnace'),
  assembler('Assembler');

  final String label;

  const BuildKind(this.label);
}

final class FactoryFlameGame extends FlameGame with MultiTouchTapDetector {
  static const int mapWidth = 96;
  static const int mapHeight = 64;
  static const double tileSize = 40;

  late final FactoryWorldComponent factoryWorld;
  GameScene scene = GameScene.splash;
  BuildKind selectedBuild = BuildKind.burnerMiningDrill;
  CharacterKind? selectedCharacterKind;
  Character? selectedCharacter;
  Component? _screenLayer;
  FactoryHudLayer? _hudLayer;

  Vector2? get activeScreenLayerSize {
    final layer = _screenLayer;
    return layer is PositionComponent ? layer.size : null;
  }

  double get worldPixelWidth => mapWidth * tileSize;

  double get worldPixelHeight => mapHeight * tileSize;

  @override
  Color backgroundColor() => const Color(0xff0b100d);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    camera.viewfinder.anchor = Anchor.center;
    _centerCameraOnStartingArea();

    factoryWorld = FactoryWorldComponent(game: this);
    await world.add(factoryWorld);
    _showSplash();
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    final position = info.eventPosition.widget;

    switch (scene) {
      case GameScene.splash:
        _handleSplashTap(position);
      case GameScene.characterSelection:
        _handleCharacterSelectionTap(position);
      case GameScene.playing:
        _handlePlayingTap(position);
    }
  }

  void panByScreenDelta(Vector2 delta) {
    if (scene != GameScene.playing) {
      return;
    }

    camera.viewfinder.position -= delta / camera.viewfinder.zoom;
    _clampCamera();
  }

  void openCharacterSelection() {
    scene = GameScene.characterSelection;
    _replaceScreenLayer(CharacterSelectionLayer(game: this));
  }

  void startNewGame(CharacterKind characterKind) {
    selectedCharacterKind = characterKind;
    selectedCharacter = characterKind.createCharacter();
    scene = GameScene.playing;
    _screenLayer?.removeFromParent();
    _screenLayer = null;
    _centerCameraOnStartingArea();
    _showHud();
  }

  void requestExit() {
    _replaceScreenLayer(ExitLayer(game: this));
  }

  void setSelectedBuild(BuildKind buildKind) {
    selectedBuild = buildKind;
  }

  void clearBuildings() {
    factoryWorld.clearBuildings();
  }

  void returnToSplash() {
    _hudLayer?.removeFromParent();
    _hudLayer = null;
    scene = GameScene.splash;
    _showSplash();
  }

  void _handleSplashTap(Vector2 position) {
    final newGameRect = _centeredRect(
      width: 260,
      height: 56,
      centerX: size.x * 0.5,
      top: size.y * 0.52,
    );
    final exitRect = _centeredRect(
      width: 260,
      height: 56,
      centerX: size.x * 0.5,
      top: size.y * 0.62,
    );

    if (_contains(newGameRect, position)) {
      openCharacterSelection();
    } else if (_contains(exitRect, position)) {
      requestExit();
    }
  }

  void _handleCharacterSelectionTap(Vector2 position) {
    const cardWidth = 300.0;
    const cardHeight = 120.0;
    final totalWidth = CharacterKind.values.length * cardWidth + 2 * 18;
    var x = size.x * 0.5 - totalWidth * 0.5;
    final y = size.y * 0.42;

    for (final characterKind in CharacterKind.values) {
      if (_contains(Rect.fromLTWH(x, y, cardWidth, cardHeight), position)) {
        startNewGame(characterKind);
        return;
      }
      x += cardWidth + 18;
    }

    final backRect = _centeredRect(
      width: 220,
      height: 52,
      centerX: size.x * 0.5,
      top: size.y * 0.74,
    );
    if (_contains(backRect, position)) {
      returnToSplash();
    }
  }

  void _handlePlayingTap(Vector2 position) {
    if (_contains(Rect.fromLTWH(size.x - 238, 28, 96, 44), position)) {
      clearBuildings();
      return;
    }
    if (_contains(Rect.fromLTWH(size.x - 130, 28, 96, 44), position)) {
      returnToSplash();
      return;
    }

    const buttonHeight = 48.0;
    const gap = 8.0;
    var x = 28.0;
    final y = size.y - 83;

    for (final buildKind in BuildKind.values) {
      if (_contains(Rect.fromLTWH(x, y, 156, buttonHeight), position)) {
        setSelectedBuild(buildKind);
        return;
      }
      x += 156 + gap;
    }

    final worldPosition = camera.globalToLocal(position);
    final tileX = worldPosition.x ~/ tileSize;
    final tileY = worldPosition.y ~/ tileSize;
    factoryWorld.toggleTile(tileX, tileY);
  }

  void _showSplash() {
    _replaceScreenLayer(SplashLayer(game: this));
  }

  void _showHud() {
    _hudLayer?.removeFromParent();
    _hudLayer = FactoryHudLayer(game: this);
    add(_hudLayer!);
  }

  void _replaceScreenLayer(Component layer) {
    _screenLayer?.removeFromParent();
    _screenLayer = layer;
    add(layer);
  }

  void _centerCameraOnStartingArea() {
    camera.viewfinder.position = Vector2(16 * tileSize, 34 * tileSize);
    camera.viewfinder.zoom = 1;
  }

  void _clampCamera() {
    final halfWidth = size.x / (2 * camera.viewfinder.zoom);
    final halfHeight = size.y / (2 * camera.viewfinder.zoom);
    final minX = min(halfWidth, worldPixelWidth * 0.5);
    final maxX = max(worldPixelWidth - halfWidth, worldPixelWidth * 0.5);
    final minY = min(halfHeight, worldPixelHeight * 0.5);
    final maxY = max(worldPixelHeight - halfHeight, worldPixelHeight * 0.5);

    camera.viewfinder.position = Vector2(
      camera.viewfinder.position.x.clamp(minX, maxX).toDouble(),
      camera.viewfinder.position.y.clamp(minY, maxY).toDouble(),
    );
  }

  Rect _centeredRect({
    required double width,
    required double height,
    required double centerX,
    required double top,
  }) {
    return Rect.fromLTWH(centerX - width * 0.5, top, width, height);
  }

  bool _contains(Rect rect, Vector2 position) {
    return rect.contains(Offset(position.x, position.y));
  }
}

final class SplashLayer extends PositionComponent {
  final FactoryFlameGame game;
  late final FlameButton _newGameButton;
  late final FlameButton _exitButton;

  SplashLayer({required this.game}) {
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _newGameButton = FlameButton(
      label: 'New Game',
      onPressed: game.openCharacterSelection,
    );
    _exitButton = FlameButton(label: 'Exit Game', onPressed: game.requestExit);
    await addAll([_newGameButton, _exitButton]);
    size = game.size;
    _layout(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout(size);
  }

  @override
  void render(Canvas canvas) {
    _drawSplashBackground(canvas, size);
    _drawCenteredText(
      canvas,
      'Factorio OOP',
      Offset(size.x * 0.5, size.y * 0.28),
      56,
      const Color(0xffeee4c8),
    );
    _drawCenteredText(
      canvas,
      'Build, automate, research, launch.',
      Offset(size.x * 0.5, size.y * 0.37),
      20,
      const Color(0xffc8c0aa),
    );
  }

  void _layout(Vector2 size) {
    const buttonWidth = 260.0;
    const buttonHeight = 56.0;
    _newGameButton
      ..position = Vector2(size.x * 0.5 - buttonWidth * 0.5, size.y * 0.52)
      ..size = Vector2(buttonWidth, buttonHeight);
    _exitButton
      ..position = Vector2(size.x * 0.5 - buttonWidth * 0.5, size.y * 0.62)
      ..size = Vector2(buttonWidth, buttonHeight);
  }
}

final class CharacterSelectionLayer extends PositionComponent {
  final FactoryFlameGame game;
  final List<FlameButton> _characterButtons = [];
  late final FlameButton _backButton;

  CharacterSelectionLayer({required this.game}) {
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (final characterKind in CharacterKind.values) {
      final button = FlameButton(
        label: characterKind.label,
        subtitle: characterKind.description,
        onPressed: () => game.startNewGame(characterKind),
      );
      _characterButtons.add(button);
      await add(button);
    }

    _backButton = FlameButton(label: 'Back', onPressed: game.returnToSplash);
    await add(_backButton);
    size = game.size;
    _layout(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout(size);
  }

  @override
  void render(Canvas canvas) {
    _drawSplashBackground(canvas, size);
    _drawCenteredText(
      canvas,
      'Select Character',
      Offset(size.x * 0.5, size.y * 0.18),
      44,
      const Color(0xffeee4c8),
    );
    _drawCenteredText(
      canvas,
      'Each character is created from your existing OOP classes.',
      Offset(size.x * 0.5, size.y * 0.26),
      18,
      const Color(0xffc8c0aa),
    );
  }

  void _layout(Vector2 size) {
    const cardWidth = 300.0;
    const cardHeight = 120.0;
    final totalWidth = CharacterKind.values.length * cardWidth + 2 * 18;
    var x = size.x * 0.5 - totalWidth * 0.5;
    final y = size.y * 0.42;

    for (final button in _characterButtons) {
      button
        ..position = Vector2(x, y)
        ..size = Vector2(cardWidth, cardHeight);
      x += cardWidth + 18;
    }

    _backButton
      ..position = Vector2(size.x * 0.5 - 110, size.y * 0.74)
      ..size = Vector2(220, 52);
  }
}

final class ExitLayer extends PositionComponent {
  final FactoryFlameGame game;
  late final FlameButton _backButton;

  ExitLayer({required this.game}) {
    priority = 1000;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _backButton = FlameButton(
      label: 'Back To Menu',
      onPressed: () {
        game.returnToSplash();
      },
    );
    await add(_backButton);
    size = game.size;
    _layout(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout(size);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = const Color(0xff080a08),
    );
    _drawCenteredText(
      canvas,
      'Exit requested',
      Offset(size.x * 0.5, size.y * 0.38),
      42,
      const Color(0xffeee4c8),
    );
    _drawCenteredText(
      canvas,
      'Desktop quit handling will be added with platform packaging.',
      Offset(size.x * 0.5, size.y * 0.47),
      18,
      const Color(0xffc8c0aa),
    );
  }

  void _layout(Vector2 size) {
    _backButton
      ..position = Vector2(size.x * 0.5 - 130, size.y * 0.58)
      ..size = Vector2(260, 56);
  }
}

final class FactoryHudLayer extends PositionComponent {
  final FactoryFlameGame game;
  final List<FlameButton> _buildButtons = [];
  late final FlameButton _clearButton;
  late final FlameButton _menuButton;

  FactoryHudLayer({required this.game}) {
    priority = 900;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    for (final buildKind in BuildKind.values) {
      final button = FlameButton(
        label: buildKind.label,
        isSelected: () => game.selectedBuild == buildKind,
        onPressed: () => game.setSelectedBuild(buildKind),
      );
      _buildButtons.add(button);
      await add(button);
    }

    _clearButton = FlameButton(label: 'Clear', onPressed: game.clearBuildings);
    _menuButton = FlameButton(label: 'Menu', onPressed: game.returnToSplash);
    await addAll([_clearButton, _menuButton]);
    size = game.size;
    _layout(game.size);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _layout(size);
  }

  @override
  void render(Canvas canvas) {
    final selectedCharacter = game.selectedCharacterKind?.label ?? 'Unknown';
    canvas.drawRect(
      const Rect.fromLTWH(16, 16, 260, 82),
      Paint()..color = const Color(0xff111711).withValues(alpha: 0.9),
    );
    _drawText(
      canvas,
      'Character: $selectedCharacter',
      const Offset(30, 32),
      16,
      const Color(0xffeee4c8),
    );
    _drawText(
      canvas,
      'Drag map to pan. Click tile to build/remove.',
      const Offset(30, 58),
      13,
      const Color(0xffbbb39d),
    );

    canvas.drawRect(
      Rect.fromLTWH(16, size.y - 102, size.x - 32, 86),
      Paint()..color = const Color(0xff111711).withValues(alpha: 0.94),
    );
  }

  void _layout(Vector2 size) {
    const buttonHeight = 48.0;
    const gap = 8.0;
    var x = 28.0;
    final y = size.y - 83;

    for (final button in _buildButtons) {
      button
        ..position = Vector2(x, y)
        ..size = Vector2(156, buttonHeight);
      x += 156 + gap;
    }

    _clearButton
      ..position = Vector2(size.x - 238, 28)
      ..size = Vector2(96, 44);
    _menuButton
      ..position = Vector2(size.x - 130, 28)
      ..size = Vector2(96, 44);
  }
}

final class FlameButton extends PositionComponent {
  final String label;
  final String? subtitle;
  final VoidCallback onPressed;
  final bool Function()? isSelected;

  FlameButton({
    required this.label,
    required this.onPressed,
    this.subtitle,
    this.isSelected,
  });

  @override
  void render(Canvas canvas) {
    final selected = isSelected?.call() ?? false;
    final subtitleText = subtitle;
    final rect = Offset.zero & Size(size.x, size.y);
    final fillColor = selected
        ? const Color(0xff5f743c)
        : const Color(0xff20281f);
    final borderColor = selected
        ? const Color(0xffd6c579)
        : const Color(0xff66705f);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()..color = fillColor.withValues(alpha: 0.96),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 2.5 : 1.4,
    );

    final hasSubtitle = subtitleText != null;
    _drawCenteredText(
      canvas,
      label,
      Offset(size.x * 0.5, hasSubtitle ? size.y * 0.34 : size.y * 0.5),
      hasSubtitle ? 22 : 16,
      const Color(0xfff0ead8),
      maxWidth: size.x - 22,
    );

    if (subtitleText != null) {
      _drawCenteredText(
        canvas,
        subtitleText,
        Offset(size.x * 0.5, size.y * 0.68),
        13,
        const Color(0xffc7c0ac),
        maxWidth: size.x - 26,
      );
    }
  }
}

final class FactoryWorldComponent extends Component {
  final FactoryFlameGame game;
  final List<List<FactoryTileData>> _tiles = [];

  FactoryWorldComponent({required this.game});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _generateTiles();

    for (var y = 0; y < FactoryFlameGame.mapHeight; y++) {
      for (var x = 0; x < FactoryFlameGame.mapWidth; x++) {
        await add(FactoryTileComponent(tile: _tiles[y][x], game: game));
      }
    }
  }

  void clearBuildings() {
    for (final row in _tiles) {
      for (final tile in row) {
        tile.building = null;
      }
    }
  }

  void toggleTile(int x, int y) {
    if (x < 0 ||
        y < 0 ||
        x >= FactoryFlameGame.mapWidth ||
        y >= FactoryFlameGame.mapHeight) {
      return;
    }

    final tile = _tiles[y][x];
    if (!tile.canBuildOn) {
      return;
    }

    if (tile.building != null) {
      tile.building = null;
    } else {
      tile.building = game.selectedBuild;
    }
  }

  void _generateTiles() {
    final random = Random(12);

    for (var y = 0; y < FactoryFlameGame.mapHeight; y++) {
      final row = <FactoryTileData>[];
      for (var x = 0; x < FactoryFlameGame.mapWidth; x++) {
        final terrain = _terrainAt(x, y);
        final resource = _resourceAt(x, y);
        final natural = _naturalAt(x, y, terrain, resource, random);

        row.add(
          FactoryTileData(
            x: x,
            y: y,
            terrain: terrain,
            natural: natural,
            resource: resource,
            isStartingArea: _isInsideCircle(x, y, 16, 34, 7),
          ),
        );
      }
      _tiles.add(row);
    }
  }

  TerrainKind _terrainAt(int x, int y) {
    final lake = _isInsideEllipse(x, y, 18, 13, 13, 8);
    final southLake = _isInsideEllipse(x, y, 68, 54, 18, 7);
    final river = (x - 45 + sin(y * 0.28) * 6).abs() < 2.4 && y > 10 && y < 54;

    if (lake || southLake || river) {
      return TerrainKind.water;
    }

    final nearWater =
        _isInsideEllipse(x, y, 18, 13, 16, 11) ||
        _isInsideEllipse(x, y, 68, 54, 21, 10) ||
        ((x - 45 + sin(y * 0.28) * 6).abs() < 4.2 && y > 9 && y < 55);
    if (nearWater) {
      return TerrainKind.sand;
    }

    if ((x - 12).abs() + (y - 48).abs() < 13 || (x > 62 && y < 24)) {
      return TerrainKind.desert;
    }

    if ((x > 73 && y > 30 && y < 46) || _isInsideEllipse(x, y, 54, 34, 8, 5)) {
      return TerrainKind.stoneGround;
    }

    if ((x - y * 0.9 - 28).abs() < 1.4 && y > 18 && y < 48) {
      return TerrainKind.cliff;
    }

    if ((x + y) % 9 < 3) {
      return TerrainKind.dirt;
    }

    return TerrainKind.grass;
  }

  ResourceKind? _resourceAt(int x, int y) {
    if (_isInsideCircle(x, y, 27, 31, 5)) {
      return ResourceKind.ironOre;
    }
    if (_isInsideCircle(x, y, 54, 21, 5)) {
      return ResourceKind.copperOre;
    }
    if (_isInsideCircle(x, y, 35, 48, 5)) {
      return ResourceKind.coal;
    }
    if (_isInsideCircle(x, y, 73, 42, 6)) {
      return ResourceKind.stone;
    }
    if (_isInsideCircle(x, y, 84, 17, 4)) {
      return ResourceKind.uraniumOre;
    }
    if (_isInsideCircle(x, y, 79, 55, 3) || _isInsideCircle(x, y, 86, 51, 2)) {
      return ResourceKind.crudeOil;
    }
    return null;
  }

  NaturalKind? _naturalAt(
    int x,
    int y,
    TerrainKind terrain,
    ResourceKind? resource,
    Random random,
  ) {
    if (terrain == TerrainKind.water ||
        terrain == TerrainKind.cliff ||
        resource != null) {
      return null;
    }

    if (_isInsideEllipse(x, y, 23, 43, 12, 8) && random.nextDouble() > 0.22) {
      return NaturalKind.tree;
    }
    if (_isInsideEllipse(x, y, 10, 22, 8, 10) && random.nextDouble() > 0.32) {
      return NaturalKind.tree;
    }
    if (terrain == TerrainKind.stoneGround && random.nextDouble() > 0.84) {
      return random.nextBool() ? NaturalKind.rock : NaturalKind.hugeRock;
    }
    if (terrain == TerrainKind.grass && random.nextDouble() > 0.94) {
      return NaturalKind.bush;
    }
    if (terrain == TerrainKind.desert && random.nextDouble() > 0.96) {
      return NaturalKind.rock;
    }

    return null;
  }

  bool _isInsideCircle(int x, int y, int centerX, int centerY, int radius) {
    final dx = x - centerX;
    final dy = y - centerY;
    return dx * dx + dy * dy <= radius * radius;
  }

  bool _isInsideEllipse(
    int x,
    int y,
    int centerX,
    int centerY,
    int radiusX,
    int radiusY,
  ) {
    final dx = (x - centerX) / radiusX;
    final dy = (y - centerY) / radiusY;
    return dx * dx + dy * dy <= 1;
  }
}

final class FactoryTileData {
  final int x;
  final int y;
  final TerrainKind terrain;
  final NaturalKind? natural;
  final ResourceKind? resource;
  final bool isStartingArea;
  BuildKind? building;

  FactoryTileData({
    required this.x,
    required this.y,
    required this.terrain,
    required this.natural,
    required this.resource,
    required this.isStartingArea,
  });

  bool get canBuildOn {
    return terrain != TerrainKind.water &&
        terrain != TerrainKind.cliff &&
        natural == null;
  }
}

final class FactoryTileComponent extends PositionComponent with TapCallbacks {
  final FactoryTileData tile;
  final FactoryFlameGame game;

  FactoryTileComponent({required this.tile, required this.game})
    : super(
        position: Vector2(
          tile.x * FactoryFlameGame.tileSize,
          tile.y * FactoryFlameGame.tileSize,
        ),
        size: Vector2.all(FactoryFlameGame.tileSize),
      );

  @override
  void onTapDown(TapDownEvent event) {
    if (game.scene != GameScene.playing || !tile.canBuildOn) {
      return;
    }

    if (tile.building != null) {
      tile.building = null;
      return;
    }

    tile.building = game.selectedBuild;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = _terrainColor,
    );
    _drawTileTexture(canvas);
    _drawResource(canvas);
    _drawNatural(canvas);
    _drawStartingArea(canvas);
    _drawBuilding(canvas);
    _drawGridLine(canvas);
  }

  Color get _terrainColor {
    return switch (tile.terrain) {
      TerrainKind.water => const Color(0xff284e6b),
      TerrainKind.grass => const Color(0xff526b3c),
      TerrainKind.dirt => const Color(0xff735b3b),
      TerrainKind.desert => const Color(0xff9d8b57),
      TerrainKind.sand => const Color(0xffb8aa72),
      TerrainKind.stoneGround => const Color(0xff62625b),
      TerrainKind.cliff => const Color(0xff25251f),
    };
  }

  void _drawTileTexture(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.black.withValues(
        alpha: tile.terrain == TerrainKind.water ? 0.08 : 0.06,
      )
      ..strokeWidth = 1;
    final offset = ((tile.x * 13 + tile.y * 7) % 12).toDouble();
    canvas.drawLine(Offset(offset, 0), Offset(size.x, size.y - offset), paint);
  }

  void _drawResource(Canvas canvas) {
    final resource = tile.resource;
    if (resource == null) {
      return;
    }

    final paint = Paint()..color = _resourceColor(resource);
    for (var i = 0; i < 4; i++) {
      final cx = 10.0 + ((tile.x * 11 + tile.y * 5 + i * 7) % 22);
      final cy = 10.0 + ((tile.x * 3 + tile.y * 17 + i * 9) % 22);
      canvas.drawCircle(
        Offset(cx, cy),
        resource == ResourceKind.crudeOil ? 3.8 : 3.2,
        paint,
      );
    }
  }

  void _drawNatural(Canvas canvas) {
    final natural = tile.natural;
    if (natural == null) {
      return;
    }

    switch (natural) {
      case NaturalKind.tree:
        canvas.drawRect(
          const Rect.fromLTWH(18, 20, 5, 13),
          Paint()..color = const Color(0xff5c3d22),
        );
        canvas.drawCircle(
          const Offset(20, 17),
          11,
          Paint()..color = const Color(0xff1f4f2d),
        );
      case NaturalKind.rock:
        canvas.drawOval(
          const Rect.fromLTWH(11, 15, 18, 14),
          Paint()..color = const Color(0xff8a8780),
        );
      case NaturalKind.hugeRock:
        canvas.drawOval(
          const Rect.fromLTWH(7, 10, 26, 22),
          Paint()..color = const Color(0xff74716c),
        );
      case NaturalKind.bush:
        canvas.drawCircle(
          const Offset(20, 22),
          8,
          Paint()..color = const Color(0xff335f35),
        );
    }
  }

  void _drawStartingArea(Canvas canvas) {
    if (!tile.isStartingArea) {
      return;
    }

    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()
        ..color = const Color(0xffd8c16d).withValues(alpha: 0.09)
        ..style = PaintingStyle.fill,
    );
  }

  void _drawBuilding(Canvas canvas) {
    final building = tile.building;
    if (building == null) {
      return;
    }

    final bodyPaint = Paint()..color = _buildingColor(building);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(7, 7, 26, 26),
        const Radius.circular(3),
      ),
      bodyPaint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(12, 12, 16, 16),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );

    if (building == BuildKind.burnerMiningDrill ||
        building == BuildKind.electricMiningDrill) {
      canvas.drawLine(
        const Offset(10, 29),
        const Offset(30, 11),
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 3,
      );
    } else if (building == BuildKind.assembler) {
      canvas.drawCircle(
        const Offset(20, 20),
        8,
        Paint()..color = Colors.white24,
      );
    } else {
      canvas.drawCircle(
        const Offset(20, 20),
        5,
        Paint()..color = const Color(0xffffd089),
      );
    }
  }

  void _drawGridLine(Canvas canvas) {
    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  Color _resourceColor(ResourceKind resource) {
    return switch (resource) {
      ResourceKind.ironOre => const Color(0xff9a8f7d),
      ResourceKind.copperOre => const Color(0xffb8733b),
      ResourceKind.coal => const Color(0xff252321),
      ResourceKind.stone => const Color(0xffb7b0a3),
      ResourceKind.uraniumOre => const Color(0xff78d64b),
      ResourceKind.crudeOil => const Color(0xff1a1719),
    };
  }

  Color _buildingColor(BuildKind building) {
    return switch (building) {
      BuildKind.burnerMiningDrill => const Color(0xff6e7840),
      BuildKind.electricMiningDrill => const Color(0xff507c86),
      BuildKind.stoneFurnace => const Color(0xff8a4d2a),
      BuildKind.steelFurnace => const Color(0xff7a7874),
      BuildKind.electricFurnace => const Color(0xff6f668e),
      BuildKind.assembler => const Color(0xff2d6f73),
    };
  }
}

void _drawSplashBackground(Canvas canvas, Vector2 size) {
  canvas.drawRect(
    Offset.zero & Size(size.x, size.y),
    Paint()..color = const Color(0xff0c110d),
  );

  final random = Random(4);
  for (var i = 0; i < 140; i++) {
    final x = random.nextDouble() * size.x;
    final y = random.nextDouble() * size.y;
    final color = i.isEven ? const Color(0xff2d3b24) : const Color(0xff52422b);
    canvas.drawCircle(
      Offset(x, y),
      random.nextDouble() * 2.6 + 0.8,
      Paint()..color = color,
    );
  }

  canvas.drawRect(
    Offset.zero & Size(size.x, size.y),
    Paint()..color = Colors.black.withValues(alpha: 0.36),
  );
}

void _drawText(
  Canvas canvas,
  String text,
  Offset position,
  double fontSize,
  Color color, {
  double? maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 2,
    ellipsis: '...',
  )..layout(maxWidth: maxWidth ?? double.infinity);

  painter.paint(canvas, position);
}

void _drawCenteredText(
  Canvas canvas,
  String text,
  Offset center,
  double fontSize,
  Color color, {
  double? maxWidth,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    maxLines: 2,
    ellipsis: '...',
  )..layout(maxWidth: maxWidth ?? double.infinity);

  painter.paint(
    canvas,
    center - Offset(painter.width * 0.5, painter.height * 0.5),
  );
}
