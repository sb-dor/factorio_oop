import 'package:factorio_oop/entities/simple_entity.dart';
import 'package:factorio_oop/world/position.dart';
import 'package:factorio_oop/world/world.dart';
import 'package:test/test.dart';

void main() {
  group('World', () {
    test('creates addressable tiles', () {
      final world = World(width: 3, height: 2);

      expect(world.tileAt(const Position(0, 0)).position, const Position(0, 0));
      expect(world.tileAt(const Position(2, 1)).position, const Position(2, 1));
    });

    test('places an entity on an empty tile', () {
      final world = World(width: 3, height: 3);
      const drill = SimpleEntity(
        name: 'Burner mining drill',
        position: Position(1, 1),
      );

      expect(world.place(drill), isTrue);
      expect(world.tileAt(const Position(1, 1)).entity, drill);
    });

    test('does not place two entities on the same tile', () {
      final world = World(width: 3, height: 3);
      const first = SimpleEntity(name: 'Chest', position: Position(1, 1));
      const second = SimpleEntity(name: 'Furnace', position: Position(1, 1));

      expect(world.place(first), isTrue);
      expect(world.place(second), isFalse);
      expect(world.tileAt(const Position(1, 1)).entity, first);
    });

    test('does not place entities outside the world', () {
      final world = World(width: 3, height: 3);
      const entity = SimpleEntity(name: 'Assembler', position: Position(4, 1));

      expect(world.place(entity), isFalse);
    });

    test('removes an entity from a tile', () {
      final world = World(width: 3, height: 3);
      const chest = SimpleEntity(name: 'Chest', position: Position(1, 1));

      world.place(chest);

      expect(world.removeAt(const Position(1, 1)), chest);
      expect(world.tileAt(const Position(1, 1)).isEmpty, isTrue);
    });
  });
}
