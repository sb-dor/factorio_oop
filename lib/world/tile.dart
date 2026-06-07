import 'package:factorio_oop/entities/entity.dart';
import 'package:factorio_oop/world/position.dart';

final class Tile {
  final Position position;
  Entity? entity;

  Tile(this.position);

  bool get isEmpty => entity == null;
}
