import 'package:factorio_oop/constants/constants.dart';
import 'package:factorio_oop/generics/array_generic.dart';
import 'package:factorio_oop/resource.dart';

import 'slots/slot.dart';
import 'weapon_slot/weapon_slot.dart';

mixin class Inventory {
  // is required, to use remember to use that
  void initInventory({int? slotLength, int? weaponSlotLength}) {
    //
    slots = ArrayGeneric<Slot>(slotLength ?? Constants.slotLength);

    weaponSlot = ArrayGeneric<WeaponSlot>(weaponSlotLength ?? Constants.weaponSlotLength);
  }

  late ArrayGeneric<Slot> slots;

  late ArrayGeneric<WeaponSlot> weaponSlot;

  void addToSlot(Resource? resource, {int slotNumber = 0}) {
    final addedToSlot = _addToSlot(resource, slotNumber: slotNumber);
    if (!addedToSlot) {
      // show a message here
      // that the resource was not added to slot
    }
  }

  /// This function attempts to add a given resource to a specified slot, or to any available slot if no slot number is specified.
  ///
  /// Parameters:
  /// - `resource`: The resource to be added to a slot. It can be `null`.
  /// - `slotNumber`: An optional parameter indicating the specific slot where the resource should be added. If not specified, the function will try to add the resource to any available slot.
  ///
  /// Returns:
  /// - `true` if the resource was successfully added to a slot.
  /// - `false` if the resource could not be added to any slot.
  ///
  /// The function works as follows:
  /// 1. It initializes a boolean variable `resourceAdded` to `false`.
  /// 2. It checks if a `slotNumber` is provided:
  ///    - If a `slotNumber` is provided, it tries to add the resource to the specified slot using `_addToSlotHelper`.
  ///    - If the resource is successfully added, `resourceAdded` is set to `true`.
  /// 3. If the resource could not be added to the specified slot or if no `slotNumber` is provided:
  ///    - It iterates over all slots, trying to add the resource to each slot using `_addToSlotHelper`.
  ///    - If the resource is successfully added to any slot, it breaks the loop and sets `resourceAdded` to `true`.
  /// 4. The function returns the value of `resourceAdded`, indicating whether the resource was successfully added to any slot.
  bool _addToSlot(Resource? resource, {int? slotNumber}) {
    bool resourceAdded = false;
    if (slotNumber != null) {
      resourceAdded = _addToSlotHelper(resource, slotNumber);
    }
    if (!resourceAdded) {
      for (int i = 0; i < slots.listLength; i++) {
        resourceAdded = _addToSlotHelper(resource, i);
        if (resourceAdded) break;
      }
    }
    return resourceAdded;
  }

  /// This function attempts to add a given resource to a specific slot.
  ///
  /// Parameters:
  /// - `resource`: The resource to be added to the slot. It can be `null`.
  /// - `slotNumber`: The index of the slot where the resource should be added.
  ///
  /// Returns:
  /// - `true` if the resource was successfully added to the slot.
  /// - `false` if the resource could not be added to the slot.
  ///
  /// The function works as follows:
  /// 1. It initializes a boolean variable `resourceAdded` to `false`.
  /// 2. It checks if the current list of resources in the specified slot is empty:
  ///    - If the list is empty, it adds the resource to the list and sets `resourceAdded` to `true`.
  /// 3. If the list is not empty, it checks two conditions:
  ///    - The first resource in the slot should be of the same type as the resource being added.
  ///    - The length of the current list of resources in the slot should be less than the maximum allowed length (`Constants.resourcesLength`).
  ///    - If both conditions are satisfied, it adds the resource to the list and sets `resourceAdded` to `true`.
  /// 4. The function returns the value of `resourceAdded`, indicating whether the resource was successfully added to the slot.
  bool _addToSlotHelper(Resource? resource, int slotNumber) {
    bool resourceAdded = false;
    if ((slots.currentList[slotNumber]?.resources.currentList ?? []).isEmpty) {
      slots.currentList[slotNumber]?.resources.add(resource);
      resourceAdded = true;
    } else if (slots.currentList[slotNumber]?.resources.firstElementOrNull.runtimeType ==
            resource.runtimeType &&
        (slots.currentList[slotNumber]?.resources.listLength ?? 0) < Constants.resourcesLength) {
      slots.currentList[slotNumber]?.resources.add(resource);
      resourceAdded = true;
    }
    return resourceAdded;
  }
}
