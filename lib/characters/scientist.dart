import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/constants/constants.dart';

final class Scientist extends Character {
  Scientist()
      : super(
          slotLength: Constants.scientistSlotLength,
          weaponSlotLength: Constants.scientistWeaponSlotLength,
        );
}
