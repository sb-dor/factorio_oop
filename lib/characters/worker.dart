import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/constants/constants.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/inventory/slots/slot.dart';

final class Worker extends Character {
  Worker()
      : super(
          slotLength: Constants.workerSlotLength,
          weaponSlotLength: Constants.workerWeaponSlotLength,
        );
}
