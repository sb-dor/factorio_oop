import 'dart:async';

import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/characters/worker.dart';
import 'package:factorio_oop/crafting/logistic/chests/chest.dart';
import 'package:factorio_oop/crafting/logistic/chests/iron_chest.dart';
import 'package:factorio_oop/crafting/logistic/chests/wooden_chest.dart';
import 'package:factorio_oop/exntentions/list_extentions.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';
import 'package:factorio_oop/resource.dart';
import 'package:factorio_oop/resources/minerals/iron.dart';
import 'package:factorio_oop/resources/plates/iron_plate.dart';
import 'package:factorio_oop/resources/trees/wood.dart';
import 'package:test/test.dart';

void main() {
  group("chest_tests", () {
    test('wooden_chest_test', () {
      final woodenChest = WoodenChest();

      final typeList = <Wood>[
        Wood(),
        Wood(),
      ];

      print(typeList.runtimeType);

      Chest? chest = woodenChest..ingredients.addAll(typeList);

      expect(woodenChest.ingredients.listLength == 2, chest.ingredients.listLength == 2);
    });

    test('iron_chest_test', () {
      final ironChest = IronChest();

      final typeList = <IronPlate>[
        IronPlate(),
        IronPlate(),
        IronPlate(),
        IronPlate(),
        IronPlate(),
        IronPlate(),
        IronPlate(),
        IronPlate(),
      ];

      print(typeList.runtimeType);

      Chest? chest = ironChest..ingredients.addAll(typeList);

      expect(ironChest.ingredients.listLength == 2, chest.ingredients.listLength == 2);
    });
  });
}
