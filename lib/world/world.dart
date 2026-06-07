import 'package:factorio_oop/entities/entity.dart';
import 'package:factorio_oop/world/position.dart';
import 'package:factorio_oop/world/tile.dart';

final class World {
  final int width;
  final int height;
  late final List<List<Tile>> _tiles;

  World({required this.width, required this.height}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('World width and height must be positive');
    }

    _tiles = List.generate(
      height,
      (y) => List.generate(width, (x) => Tile(Position(x, y))),
    );
  }

  bool isInBounds(Position position) {
    return position.x >= 0 &&
        position.y >= 0 &&
        position.x < width &&
        position.y < height;
  }

  Tile tileAt(Position position) {
    if (!isInBounds(position)) {
      throw RangeError('Position is outside the world: $position');
    }

    return _tiles[position.y][position.x];
  }

  bool canPlace(Entity entity) {
    return isInBounds(entity.position) && tileAt(entity.position).isEmpty;
  }

  bool place(Entity entity) {
    if (!canPlace(entity)) {
      return false;
    }

    tileAt(entity.position).entity = entity;
    return true;
  }

  Entity? removeAt(Position position) {
    final tile = tileAt(position);
    final entity = tile.entity;
    tile.entity = null;
    return entity;
  }
}
