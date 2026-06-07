import 'package:factorio_oop/game/factory_flame_game.dart';
import 'package:flame/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(FactoryGameShell(game: FactoryFlameGame()));
}

final class FactoryGameShell extends StatefulWidget {
  final FactoryFlameGame game;

  const FactoryGameShell({required this.game, super.key});

  @override
  State<FactoryGameShell> createState() => _FactoryGameShellState();
}

final class _FactoryGameShellState extends State<FactoryGameShell> {
  bool _isRightMouseDragging = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        _isRightMouseDragging = event.buttons & kSecondaryMouseButton != 0;
      },
      onPointerMove: (event) {
        if (_isRightMouseDragging ||
            event.buttons & kSecondaryMouseButton != 0) {
          widget.game.panByScreenDelta(Vector2(event.delta.dx, event.delta.dy));
        }
      },
      onPointerUp: (_) => _isRightMouseDragging = false,
      onPointerCancel: (_) => _isRightMouseDragging = false,
      child: GameWidget(game: widget.game),
    );
  }
}
