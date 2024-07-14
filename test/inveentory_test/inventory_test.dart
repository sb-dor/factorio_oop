import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/characters/soldier.dart';
import 'package:factorio_oop/crafting/logistic/chests/iron_chest.dart';
import 'package:factorio_oop/resources/minerals/iron.dart';
import 'package:factorio_oop/resources/trees/wood.dart';
import 'package:test/test.dart';

void main() {
  late Character character;

  setUp(() {
    character = Soldier();
  });

  group("inventory_test", () {
    test('soldier_inventory_test', () {
      expect(character.slotLength, Soldier().slotLength);
    });

    test("soldier_inventory_test_2", () {
      final wood = Wood();
      final iron = Iron();
      final ironChest = IronChest();

      character.addToSlot(ironChest);
      character.addToSlot(wood);
      character.addToSlot(wood);
      character.addToSlot(iron);
      character.addToSlot(wood);
      character.addToSlot(ironChest);

      for (final each in character.slots.currentList) {
        print(
            "each slots: ${each?.resources.firstElementOrNull.runtimeType} | length: ${each?.resources.listLength}");
      }
    });
  });
}
