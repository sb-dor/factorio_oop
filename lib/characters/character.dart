import 'package:factorio_oop/inventory/inventory.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';
import 'package:factorio_oop/inventory/weapon_slot/weapon_slot.dart';

abstract base class Character with Inventory {
  final int slotLength;
  final int weaponSlotLength;

  // whenever a character is created
  // a slot from inventory will be created with a character
  Character({
    required this.slotLength,
    required this.weaponSlotLength,
  }) {
    // init of inventory considering what kind of character the player is
    initInventory(slotLength: slotLength, weaponSlotLength: weaponSlotLength);
    //
    // you can event right the "slotLength" instead of "slots.length"
    for (int i = 0; i < slots.length; i++) {
      slots.add(Slot());
    }

    // you can event right the "weaponSlotLength" instead of "weaponSlot.length"
    for (int i = 0; i < weaponSlot.length; i++) {
      weaponSlot.add(WeaponSlot());
    }
  }
}
