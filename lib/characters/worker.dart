import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';

base class Worker extends Character {
  Worker() : super(slotLength: 50, weaponSlotLength: 2);
}
