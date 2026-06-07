import 'package:factorio_oop/characters/character.dart';
import 'package:factorio_oop/constants/constants.dart';

final class Worker extends Character {
  Worker()
    : super(
        slotLength: Constants.workerSlotLength,
        weaponSlotLength: Constants.workerWeaponSlotLength,
      );
}
