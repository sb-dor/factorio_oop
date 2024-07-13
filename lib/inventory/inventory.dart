import 'package:factorio_oop/generics/array_generic.dart';

import 'slots/slot.dart';
import 'weapon_slot/weapon_slot.dart';

mixin class Inventory {
  ArrayGeneric<Slot> slots = ArrayGeneric(50);

  ArrayGeneric<WeaponSlot> weaponSlot = ArrayGeneric(2);
}
