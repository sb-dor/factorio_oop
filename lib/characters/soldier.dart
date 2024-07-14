import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/constants/constants.dart';

final class Soldier extends Character {
  Soldier()
      : super(
          slotLength: Constants.soldierSlotLength,
          weaponSlotLength: Constants.soldierWeaponSlotLength,
        );
}
