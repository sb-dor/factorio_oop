import 'package:factorio_oop/entities/entity.dart';
import 'package:factorio_oop/world/position.dart';

abstract base class PlaceableEntity implements Entity {
  @override
  final String name;

  @override
  final Position position;

  const PlaceableEntity({required this.name, required this.position});
}
